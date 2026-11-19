import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

import '../trip_control_sheets.dart';
import 'accommodation_candidate.dart';
import 'confirm_accommodation_page.dart';
import 'manual_address_sheet.dart';

/// Entry + Busca — Adicionar hospedagem (typeahead + manual).
class AddAccommodationSearchPage extends StatefulWidget {
  final TripControls controls;
  final String tripId;
  final SearchHotelsUseCase searchHotels;
  final GetPlaceDetailsUseCase getPlaceDetails;
  final double? biasLatitude;
  final double? biasLongitude;

  /// When true, skip Core save (debug preview only).
  final bool previewOnly;

  const AddAccommodationSearchPage({
    super.key,
    required this.controls,
    required this.tripId,
    required this.searchHotels,
    required this.getPlaceDetails,
    this.biasLatitude,
    this.biasLongitude,
    this.previewOnly = false,
  });

  @override
  State<AddAccommodationSearchPage> createState() =>
      _AddAccommodationSearchPageState();
}

class _AddAccommodationSearchPageState
    extends State<AddAccommodationSearchPage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;

  var _loading = false;
  String? _error;
  List<PlaceSearchResult> _results = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _loading = false;
        _error = null;
        _results = const [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await widget.searchHotels(
      query,
      latitude: widget.biasLatitude,
      longitude: widget.biasLongitude,
    );
    if (!mounted) return;
    result.fold(
      (places) {
        setState(() {
          _loading = false;
          _results = places.isNotEmpty
              ? places
              : (widget.previewOnly ? _demoHotels(query) : places);
        });
      },
      (failure) {
        setState(() {
          _loading = false;
          if (widget.previewOnly) {
            _error = null;
            _results = _demoHotels(query);
          } else {
            _error = failure.message;
            _results = const [];
          }
        });
      },
    );
  }

  List<PlaceSearchResult> _demoHotels(String query) {
    const demos = <PlaceSearchResult>[
      PlaceSearchResult(
        providerPlaceId: 'demo-diana',
        name: 'Hotel Diana Roof Garden',
        formattedAddress: 'Roma, Itália',
        latitude: 41.9028,
        longitude: 12.4964,
      ),
      PlaceSearchResult(
        providerPlaceId: 'demo-dorica',
        name: 'Hotel Dorica',
        formattedAddress: 'Roma, Itália',
        latitude: 41.901,
        longitude: 12.50,
      ),
      PlaceSearchResult(
        providerPlaceId: 'demo-gioberti',
        name: 'Gioberti Hotel',
        formattedAddress: 'Roma, Itália',
        latitude: 41.900,
        longitude: 12.501,
      ),
      PlaceSearchResult(
        providerPlaceId: 'demo-tiberio',
        name: 'Grand Hotel Tiberio',
        formattedAddress: 'Roma, Itália',
        latitude: 41.91,
        longitude: 12.45,
      ),
      PlaceSearchResult(
        providerPlaceId: 'demo-hoxton',
        name: 'The Hoxton Rome',
        formattedAddress: 'Roma, Itália',
        latitude: 41.895,
        longitude: 12.49,
      ),
    ];
    final q = query.toLowerCase();
    return demos
        .where((h) => h.name.toLowerCase().contains(q) || q.length < 3)
        .toList();
  }

  Future<void> _onSelectPlace(PlaceSearchResult place) async {
    setState(() => _loading = true);
    PlaceSearchResult resolved = place;
    if (!widget.previewOnly) {
      final details = await widget.getPlaceDetails(place.providerPlaceId);
      if (!mounted) return;
      details.fold(
        (value) {
          if (value != null) resolved = value;
        },
        (_) {},
      );
    }
    if (!mounted) return;
    setState(() => _loading = false);

    final candidate = AccommodationCandidate(
      name: resolved.name,
      address: resolved.formattedAddress ?? place.formattedAddress,
      latitude: resolved.latitude ?? place.latitude,
      longitude: resolved.longitude ?? place.longitude,
      providerPlaceId: widget.previewOnly
          ? null
          : (resolved.providerPlaceId.isNotEmpty
                ? resolved.providerPlaceId
                : place.providerPlaceId),
    );
    await _openConfirm(candidate);
  }

  Future<void> _onManual() async {
    final candidate = await showManualAddressSheet(context);
    if (candidate == null || !mounted) return;
    await _openConfirm(candidate);
  }

  Future<void> _openConfirm(AccommodationCandidate candidate) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConfirmAccommodationPage(
          controls: widget.controls,
          tripId: widget.tripId,
          candidate: candidate,
          onChange: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (saved == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().length >= 2;
    final showDropdown =
        hasQuery && (_loading || _error != null || _results.isNotEmpty);

    return Scaffold(
      backgroundColor: TwoGoColors.surfacePrimary,
      appBar: AppBar(
        backgroundColor: TwoGoColors.surfacePrimary,
        elevation: 0,
        centerTitle: true,
        leading: _CircleBack(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Adicionar hospedagem',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: TwoGoSpacing.md),
              Text(
                'Buscar por nome da hospedagem',
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),
              const SizedBox(height: TwoGoSpacing.sm),
              TwoGoTextField(
                key: const Key('hotel-search-field'),
                controller: _controller,
                focusNode: _focus,
                hintText: '',
                prefixIcon: TwoGoIcons.search,
                onChanged: _onQueryChanged,
                autofocus: true,
              ),
              if (showDropdown) ...[
                const SizedBox(height: TwoGoSpacing.sm),
                Material(
                  color: TwoGoColors.surfacePrimary,
                  elevation: 2,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: _buildResults(),
                  ),
                ),
              ] else ...[
                const SizedBox(height: TwoGoSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    key: const Key('hotel-manual-entry'),
                    onPressed: _onManual,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TwoGoColors.contentPrimary,
                      side: const BorderSide(color: TwoGoColors.neutral900),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: TwoGoSpacing.lg,
                        vertical: TwoGoSpacing.sm,
                      ),
                    ),
                    child: Text(
                      'Adicionar endereço manualmente',
                      style: TwoGoTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(TwoGoSpacing.lg),
        child: Center(child: TwoGoLoadingIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(TwoGoSpacing.md),
        child: Text(
          _error!,
          style: TwoGoTypography.bodySmall.copyWith(color: TwoGoColors.error),
        ),
      );
    }
    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(TwoGoSpacing.md),
        child: Text(
          'Nenhuma hospedagem encontrada.',
          style: TwoGoTypography.bodyMedium.copyWith(
            color: TwoGoColors.contentSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.sm),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = _results[index];
        return ListTile(
          title: Text(
            place.name,
            style: TwoGoTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: place.formattedAddress == null
              ? null
              : Text(
                  place.formattedAddress!,
                  style: TwoGoTypography.bodySmall.copyWith(
                    color: TwoGoColors.contentSecondary,
                  ),
                ),
          onTap: () => _onSelectPlace(place),
        );
      },
    );
  }
}

class _CircleBack extends StatelessWidget {
  final VoidCallback onPressed;

  const _CircleBack({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: TwoGoSpacing.sm),
      child: Center(
        child: Material(
          color: TwoGoColors.surfacePrimary,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.chevron_left, color: TwoGoColors.contentPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
