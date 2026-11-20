import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

import '../../domain/paid_trip_controls.dart';
import '../widgets/alternatives_filter_sheet.dart';
import '../widgets/trip_control_sheets.dart';

/// Design: "Substituir por" — quota, recommended carousel, search (+ Filtrar).
class SubstituteAttractionPage extends StatefulWidget {
  final TripControls controls;
  final String itemId;
  final String? destinationHint;

  const SubstituteAttractionPage({
    super.key,
    required this.controls,
    required this.itemId,
    this.destinationHint,
  });

  static Future<void> open(
    BuildContext context, {
    required TripControls controls,
    required String itemId,
    String? destinationHint,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => SubstituteAttractionPage(
          controls: controls,
          itemId: itemId,
          destinationHint: destinationHint,
        ),
      ),
    );
  }

  @override
  State<SubstituteAttractionPage> createState() =>
      _SubstituteAttractionPageState();
}

class _SubstituteAttractionPageState extends State<SubstituteAttractionPage> {
  AlternativesResult? _result;
  AlternativesFilter _filter = AlternativesFilter.empty;
  var _loading = true;
  String? _error;
  String? _pendingTitle;
  final _query = TextEditingController();
  Timer? _debounce;
  List<PlaceSearchResult> _searchHits = const [];
  var _searching = false;
  var _showNameOnlyList = false;

  @override
  void initState() {
    super.initState();
    _load();
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.removeListener(_onQueryChanged);
    _query.dispose();
    super.dispose();
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final result = await widget.controls.repository.getItemAlternatives(
        widget.itemId,
        filter: _filter,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = apiErrorMessage(error);
      });
    }
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final q = _query.text.trim();
    if (q.isEmpty) {
      setState(() {
        _searchHits = const [];
        _searching = false;
        _showNameOnlyList = false;
      });
      return;
    }
    _showNameOnlyList = q.length < 2;
    _debounce = Timer(const Duration(milliseconds: 280), () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    final search = widget.controls.searchPlaces;
    if (search == null) {
      setState(() {
        _searchHits = _localFilter(q);
        _searching = false;
        _showNameOnlyList = true;
      });
      return;
    }
    setState(() => _searching = true);
    final hint = widget.destinationHint?.trim();
    final query = (hint == null || hint.isEmpty) ? q : '$q $hint';
    final result = await search(query);
    if (!mounted || _query.text.trim() != q) return;
    if (result.isFailure) {
      setState(() {
        _searchHits = _localFilter(q);
        _searching = false;
        _showNameOnlyList = q.length == 1;
      });
      return;
    }
    final hits = result.getOrNull() ?? const <PlaceSearchResult>[];
    setState(() {
      _searchHits = hits;
      _searching = false;
      _showNameOnlyList = q.length == 1 && hits.isEmpty;
      if (_showNameOnlyList) _searchHits = _localFilter(q);
    });
  }

  List<PlaceSearchResult> _localFilter(String q) {
    final items = _result?.items ?? const <ItemAlternative>[];
    final needle = q.toLowerCase();
    return items
        .where((a) => (a.title ?? '').toLowerCase().contains(needle))
        .map(
          (a) => PlaceSearchResult(
            providerPlaceId: a.providerPlaceId ?? '',
            name: a.title ?? '',
            formattedAddress: a.location,
            latitude: a.latitude,
            longitude: a.longitude,
            rating: a.rating,
            priceLevelDisplay: a.priceLevelDisplay,
          ),
        )
        .toList();
  }

  Future<void> _substituteAlternative(ItemAlternative alternative) async {
    final body = alternative.toSubstituteBody();
    if (body == null || _result?.quota.canSubstitute != true) return;
    setState(() => _pendingTitle = alternative.title);
    try {
      await widget.controls.repository.substituteItem(widget.itemId, body);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingTitle = null;
        _error = apiErrorMessage(error);
      });
    }
  }

  Future<void> _substitutePlace(PlaceSearchResult place) async {
    if (_result?.quota.canSubstitute != true) return;
    final title = place.name.trim();
    if (title.isEmpty) return;
    setState(() => _pendingTitle = title);
    final body = <String, dynamic>{'title': title};
    final placeId = place.providerPlaceId.trim();
    if (placeId.isNotEmpty) body['providerPlaceId'] = placeId;
    final loc = place.formattedAddress?.trim();
    if (loc != null && loc.isNotEmpty) body['location'] = loc;
    if (place.latitude != null) body['latitude'] = place.latitude;
    if (place.longitude != null) body['longitude'] = place.longitude;
    try {
      await widget.controls.repository.substituteItem(widget.itemId, body);
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pendingTitle = null;
        _error = apiErrorMessage(error);
      });
    }
  }

  Future<void> _openFilters() async {
    final facets = _result?.facets ?? const AlternativesFacets();
    final applied = await showAlternativesFilterSheet(
      context,
      initial: _filter,
      facets: facets,
    );
    if (applied == null || !mounted) return;
    setState(() {
      _filter = applied.copyWith(q: _query.text.trim());
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final quota = _result?.quota;
    final query = _query.text.trim();
    final showSearchResults = query.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: TwoGoColors.contentPrimary,
            ),
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
        ),
        title: Text(
          'Substituir por',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (quota != null) _QuotaCard(quota: quota),
                if (quota != null && !quota.canSubstitute)
                  Padding(
                    padding: const EdgeInsets.only(top: TwoGoSpacing.sm),
                    child: Text(
                      quota.exhausted
                          ? 'Cota de trocas esgotada'
                          : 'Cota de trocas indisponível',
                      style: TwoGoTypography.bodySmall.copyWith(
                        color: TwoGoColors.contentSecondary,
                      ),
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: TwoGoSpacing.sm),
                  Text(
                    _error!,
                    style: TwoGoTypography.bodySmall.copyWith(
                      color: TwoGoColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: TwoGoSpacing.lg),
                Text(
                  'Atrações recomendadas',
                  style: TwoGoTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TwoGoSpacing.sm),
                SizedBox(
                  height: 88,
                  child: (_result?.items.isEmpty ?? true)
                      ? Center(
                          child: Text(
                            'Nenhuma recomendação nesta resposta.',
                            style: TwoGoTypography.bodySmall.copyWith(
                              color: TwoGoColors.contentSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _result!.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final alt = _result!.items[index];
                            return _AttractionPickCard(
                              title: alt.title ?? 'Atividade',
                              rating: alt.rating,
                              price: alt.priceLevelDisplay,
                              imageUrl: alt.imageUrl,
                              enabled: quota?.canSubstitute == true &&
                                  _pendingTitle == null,
                              pending: _pendingTitle == alt.title,
                              onTap: () => _substituteAlternative(alt),
                            );
                          },
                        ),
                ),
                const SizedBox(height: TwoGoSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ou busque por atividade',
                        style: TwoGoTypography.bodyMedium.copyWith(
                          color: TwoGoColors.contentSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openFilters,
                      child: Text(
                        _filter.hasSheetFilters ? 'Filtrar ·' : 'Filtrar',
                        style: TwoGoTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: TwoGoColors.contentPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: _query,
                  decoration: InputDecoration(
                    hintText: '',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF3EFD9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8A8F3C)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8A8F3C)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF8A8F3C),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (showSearchResults && !_searching) ...[
                  const SizedBox(height: 12),
                  if (_showNameOnlyList)
                    _NameOnlyResults(
                      names: _searchHits.map((h) => h.name).toList(),
                      onPick: (name) {
                        final hit = _searchHits.firstWhere(
                          (h) => h.name == name,
                          orElse: () => PlaceSearchResult(
                            providerPlaceId: '',
                            name: name,
                          ),
                        );
                        _substitutePlace(hit);
                      },
                    )
                  else
                    ..._searchHits.map(
                      (hit) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _AttractionPickCard(
                          title: hit.name,
                          rating: hit.rating,
                          price: hit.priceLevelDisplay,
                          imageUrl: hit.iconUrl,
                          wide: true,
                          enabled: quota?.canSubstitute == true &&
                              _pendingTitle == null,
                          pending: _pendingTitle == hit.name,
                          onTap: () => _substitutePlace(hit),
                        ),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  final SwapQuota quota;

  const _QuotaCard({required this.quota});

  @override
  Widget build(BuildContext context) {
    final counter = quota.availableChangesCounter;
    final allowed = quota.allowedSwapsCount ?? 4;
    final filled = quota.progressFilledSegments;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDECEA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Alterações disponíveis',
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (counter != null)
                Text(
                  counter,
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(allowed, (index) {
              final on = index < filled;
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: index == allowed - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: on
                        ? const Color(0xFFB7E04A)
                        : const Color(0xFFD8D6D2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NameOnlyResults extends StatelessWidget {
  final List<String> names;
  final ValueChanged<String> onPick;

  const _NameOnlyResults({required this.names, required this.onPick});

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) {
      return Text(
        'Nenhum resultado',
        style: TwoGoTypography.bodySmall.copyWith(
          color: TwoGoColors.contentSecondary,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TwoGoColors.neutral200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < names.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            ListTile(
              title: Text(
                names[i],
                style: TwoGoTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => onPick(names[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttractionPickCard extends StatelessWidget {
  final String title;
  final double? rating;
  final String? price;
  final String? imageUrl;
  final bool enabled;
  final bool pending;
  final bool wide;
  final VoidCallback onTap;

  const _AttractionPickCard({
    required this.title,
    required this.onTap,
    this.rating,
    this.price,
    this.imageUrl,
    this.enabled = true,
    this.pending = false,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: wide ? null : 260,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fallback(),
                            )
                          : _fallback(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pending ? 'Substituindo…' : title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TwoGoTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (rating != null) ...[
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: Color(0xFFF5B942),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating!.toStringAsFixed(1),
                                style: TwoGoTypography.labelLarge,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (price != null)
                              Text(
                                price!,
                                style: TwoGoTypography.labelLarge.copyWith(
                                  color: const Color(0xFF2F6BFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.north_east_rounded,
                    size: 18,
                    color: TwoGoColors.neutral500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: TwoGoColors.neutral100,
      alignment: Alignment.center,
      child: const Icon(Icons.place_outlined, color: TwoGoColors.neutral500),
    );
  }
}
