import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/entities/trip_day_entity.dart';
import '../../domain/entities/trip_entity.dart';

/// Roteiro devolvido por `GET /trips/:id`.
///
/// Dia 2+ sem itens é paywall. Dia 1 vazio não é erro.
class TripItineraryView extends StatelessWidget {
  final TripEntity trip;
  final ValueChanged<Uri>? onOpenUrl;

  const TripItineraryView({super.key, required this.trip, this.onOpenUrl});

  static const paywallMessage =
      'Desbloqueie o acesso completo para visualizar as atividades deste dia.';

  static String? mapUrl(ItineraryItemEntity item) {
    final link = item.googleMapsLink?.trim();
    if (link != null && link.isNotEmpty) return link;
    if (item.latitude == null || item.longitude == null) return null;
    return 'https://www.google.com/maps/search/?api=1&query=${item.latitude},${item.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    final days = [...trip.days]
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TwoGoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trip.title,
            style: TwoGoTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Text(
            trip.destination,
            style: TwoGoTypography.bodyMedium.copyWith(
              color: TwoGoColors.contentSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
          ...days.map(_buildDay),
        ],
      ),
    );
  }

  Widget _buildDay(TripDayEntity day) {
    final locked = day.dayNumber > 1 && day.items.isEmpty;
    final items = [...day.items]..sort((a, b) => a.order.compareTo(b.order));
    final dateLabel = _dateLabel(day.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.title?.trim().isNotEmpty == true
                ? day.title!
                : 'Dia ${day.dayNumber}',
            style: TwoGoTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (dateLabel != null) ...[
            const SizedBox(height: TwoGoSpacing.xs),
            Text(
              dateLabel,
              style: TwoGoTypography.bodySmall.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            ),
          ],
          const SizedBox(height: TwoGoSpacing.sm),
          if (locked)
            TwoGoCard(
              child: Text(
                paywallMessage,
                style: TwoGoTypography.bodyMedium.copyWith(
                  color: TwoGoColors.contentSecondary,
                ),
              ),
            )
          else if (items.isEmpty)
            Text(
              'Nenhuma atividade neste dia.',
              style: TwoGoTypography.bodyMedium.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            )
          else
            ...items.map(_buildItem),
        ],
      ),
    );
  }

  Widget _buildItem(ItineraryItemEntity item) {
    final mapLink = mapUrl(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: TwoGoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: TwoGoTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_filled(item.timeLabel)) _line(item.timeLabel!),
            if (item.duration != null) _line('${item.duration} min'),
            if (item.cost != null && _filled(item.currency))
              _line('${item.currency} ${item.cost}'),
            if (_filled(item.notes)) _line(item.notes!),
            if (mapLink != null) ...[
              const SizedBox(height: TwoGoSpacing.xs),
              _mapLink(mapLink),
            ],
          ],
        ),
      ),
    );
  }

  Widget _line(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: TwoGoSpacing.xs),
      child: Text(text, style: TwoGoTypography.bodySmall),
    );
  }

  Widget _mapLink(String url) {
    final uri = Uri.tryParse(url);
    final canOpen = uri != null && onOpenUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canOpen)
          TextButton(
            onPressed: () => onOpenUrl!(uri),
            child: const Text('Ver no mapa'),
          )
        else
          Text(
            'Ver no mapa',
            style: TwoGoTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        SelectableText(url, style: TwoGoTypography.labelSmall),
      ],
    );
  }

  bool _filled(String? value) => value != null && value.trim().isNotEmpty;

  String? _dateLabel(DateTime? date) {
    if (date == null) return null;
    final iso = date.toIso8601String();
    return iso.split('T').first;
  }
}
