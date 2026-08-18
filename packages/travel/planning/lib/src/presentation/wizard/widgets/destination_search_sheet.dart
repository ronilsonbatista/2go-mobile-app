import 'dart:async';
import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

class DestinationSearchSheet extends StatefulWidget {
  final SearchPlacesUseCase searchPlacesUseCase;

  const DestinationSearchSheet({super.key, required this.searchPlacesUseCase});

  static Future<PlaceSearchResult?> show(
    BuildContext context, {
    required SearchPlacesUseCase searchPlacesUseCase,
  }) {
    return TwoGoBottomSheet.show<PlaceSearchResult>(
      context,
      title: 'Para onde você vai?',
      child: DestinationSearchSheet(searchPlacesUseCase: searchPlacesUseCase),
    );
  }

  @override
  State<DestinationSearchSheet> createState() => _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<DestinationSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  bool _isLoading = false;
  String? _errorMessage;
  List<PlaceSearchResult> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
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
      result.fold(
        (places) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _results = places;
            });
          }
        },
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      child: Column(
        children: [
          TwoGoTextField(
            controller: _controller,
            hintText: 'Digite uma cidade, praia ou região...',
            prefixIcon: TwoGoIcons.search,
            onChanged: _onQueryChanged,
          ),
          const SizedBox(height: TwoGoSpacing.md),
          Expanded(child: _buildSearchResults()),
        ],
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

    if (_controller.text.trim().isNotEmpty && _results.isEmpty) {
      return Center(
        child: Text(
          'Nenhum destino encontrado.',
          style: TwoGoTypography.bodyMedium.copyWith(
            color: TwoGoColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const TwoGoDivider(),
      itemBuilder: (context, index) {
        final place = _results[index];
        return TwoGoListTile(
          title: place.name,
          subtitle: place.formattedAddress ?? '',
          leadingIcon: TwoGoIcons.travel,
          onTap: () => Navigator.of(context).pop(place),
        );
      },
    );
  }
}
