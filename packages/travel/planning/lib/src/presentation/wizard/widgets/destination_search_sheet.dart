import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

import '../form_course_tokens.dart';
import 'place_thumb.dart';

/// Full-screen Places locality search (type "Roma" → autocomplete rows).
///
/// Presented as a [fullscreenDialog] route so the title stays in the safe
/// area when the keyboard opens (not a half [TwoGoBottomSheet]).
class DestinationSearchSheet extends StatefulWidget {
  final SearchPlacesUseCase searchPlacesUseCase;

  const DestinationSearchSheet({super.key, required this.searchPlacesUseCase});

  static Future<PlaceSearchResult?> show(
    BuildContext context, {
    required SearchPlacesUseCase searchPlacesUseCase,
  }) {
    return Navigator.of(context).push<PlaceSearchResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DestinationSearchSheet(
          searchPlacesUseCase: searchPlacesUseCase,
        ),
      ),
    );
  }

  @override
  State<DestinationSearchSheet> createState() => _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<DestinationSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounceTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<PlaceSearchResult> _results = [];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = null;
        _results = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await widget.searchPlacesUseCase(query);
      if (!mounted) return;
      result.fold(
        (places) {
          setState(() {
            _isLoading = false;
            _results = places;
          });
        },
        (failure) {
          setState(() {
            _isLoading = false;
            if (failure is NetworkFailure) {
              _errorMessage = null;
              TwoGoErrorFeedback.present(context, failure);
            } else {
              _errorMessage = failure.message;
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Header stays under SafeArea; only the results list shrinks for the keyboard.
    return Scaffold(
      backgroundColor: FormCourseTokens.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FormCourseTokens.pageGutter,
                FormCourseTokens.sheetTopPadding,
                FormCourseTokens.sheetCloseInset,
                TwoGoSpacing.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Para onde você vai?',
                      style: TwoGoTypography.titleLarge.copyWith(
                        color: FormCourseTokens.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TwoGoIconButton(
                    icon: TwoGoIcons.close,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                FormCourseTokens.pageGutter,
                TwoGoSpacing.md,
                FormCourseTokens.pageGutter,
                TwoGoSpacing.sm,
              ),
              child: TwoGoTextField(
                controller: _controller,
                focusNode: _focus,
                hintText: 'Digite uma cidade…',
                prefixIcon: TwoGoIcons.search,
                onChanged: _onQueryChanged,
                autofocus: true,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: FormCourseTokens.pageGutter,
                ),
                child: _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: TwoGoLoadingIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: TwoGoStatusMessage(
          title: 'Erro na busca',
          description: _errorMessage!,
          actionText: 'Tentar novamente',
          onActionPressed: () => _onQueryChanged(_controller.text),
        ),
      );
    }

    if (_controller.text.trim().isEmpty) {
      return Center(
        child: Text(
          'Comece a digitar para ver sugestões.',
          style: TwoGoTypography.bodyMedium.copyWith(
            color: FormCourseTokens.label,
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'Nenhum destino encontrado.',
          style: TwoGoTypography.bodyMedium.copyWith(
            color: FormCourseTokens.label,
          ),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: FormCourseTokens.summaryCard),
      itemBuilder: (context, index) {
        final place = _results[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: PlaceThumb(
            iconUrl: place.iconUrl,
            placeName: place.name,
          ),
          title: Text(
            place.name,
            style: TwoGoTypography.titleMedium.copyWith(
              color: FormCourseTokens.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            place.formattedAddress ?? place.country,
            style: TwoGoTypography.bodySmall.copyWith(
              color: FormCourseTokens.label,
            ),
          ),
          onTap: () => Navigator.of(context).pop(place),
        );
      },
    );
  }
}
