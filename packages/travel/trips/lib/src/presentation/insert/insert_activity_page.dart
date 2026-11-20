import 'dart:async';

import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../widgets/trip_control_sheets.dart';

/// "Inserir nova atividade" — search Places then POST day item.
class InsertActivityPage extends StatefulWidget {
  final TripControls controls;
  final String dayId;
  final int nextOrder;
  final String? destinationHint;

  const InsertActivityPage({
    super.key,
    required this.controls,
    required this.dayId,
    required this.nextOrder,
    this.destinationHint,
  });

  static Future<void> open(
    BuildContext context, {
    required TripControls controls,
    required String dayId,
    required int nextOrder,
    String? destinationHint,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => InsertActivityPage(
          controls: controls,
          dayId: dayId,
          nextOrder: nextOrder,
          destinationHint: destinationHint,
        ),
      ),
    );
  }

  @override
  State<InsertActivityPage> createState() => _InsertActivityPageState();
}

class _InsertActivityPageState extends State<InsertActivityPage> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<PlaceSearchResult> _hits = const [];
  var _searching = false;
  String? _error;
  String? _pending;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.removeListener(_onChanged);
    _query.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final q = _query.text.trim();
    if (q.isEmpty) {
      setState(() {
        _hits = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), () => _search(q));
  }

  Future<void> _search(String q) async {
    final search = widget.controls.searchPlaces;
    if (search == null) {
      setState(() {
        _error = 'Busca de lugares indisponível.';
        _searching = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
    });
    final hint = widget.destinationHint?.trim();
    final query = (hint == null || hint.isEmpty) ? q : '$q $hint';
    final result = await search(query);
    if (!mounted || _query.text.trim() != q) return;
    if (result.isFailure) {
      setState(() {
        _searching = false;
        _error = 'Não foi possível buscar atividades.';
        _hits = const [];
      });
      return;
    }
    setState(() {
      _searching = false;
      _hits = result.getOrNull() ?? const [];
    });
  }

  Future<void> _add(PlaceSearchResult place) async {
    final title = place.name.trim();
    if (title.isEmpty) return;
    setState(() => _pending = title);
    try {
      await widget.controls.repository.addItineraryItem(
        widget.dayId,
        ItineraryItemEntity(
          id: '',
          tripDayId: widget.dayId,
          title: title,
          category: ItineraryCategory.touristAttraction,
          location: place.formattedAddress,
          latitude: place.latitude,
          longitude: place.longitude,
          order: widget.nextOrder,
          providerPlaceId: place.providerPlaceId.trim().isEmpty
              ? null
              : place.providerPlaceId,
          isUserModified: true,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await widget.controls.reloadTrip();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pending = null;
        _error = apiErrorMessage(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Inserir nova atividade',
          style: TwoGoTypography.titleMedium.copyWith(
            color: TwoGoColors.contentSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          TextField(
            controller: _query,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Busque por atividade',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF3EFD9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8A8F3C)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8A8F3C)),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TwoGoTypography.bodySmall.copyWith(
                color: TwoGoColors.error,
              ),
            ),
          ],
          if (_searching)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!_searching)
            ..._hits.map(
              (hit) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _pending == hit.name ? 'Adicionando…' : hit.name,
                  style: TwoGoTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: hit.formattedAddress == null
                    ? null
                    : Text(hit.formattedAddress!),
                trailing: hit.rating == null
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF5B942),
                          ),
                          Text(hit.rating!.toStringAsFixed(1)),
                        ],
                      ),
                onTap: _pending != null ? null : () => _add(hit),
              ),
            ),
        ],
      ),
    );
  }
}
