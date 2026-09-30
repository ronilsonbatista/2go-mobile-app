import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';

import '../../domain/entities/itinerary_item_entity.dart';
import '../../domain/entities/trip_accommodation.dart';
import '../../domain/entities/trip_day_entity.dart';
import '../../domain/entities/trip_entity.dart';
import 'trip_control_sheets.dart';

/// Roteiro devolvido por `GET /trips/:id`.
///
/// Dia 2+ sem itens é paywall. Dia 1 vazio não é erro.
class TripItineraryView extends StatelessWidget {
  final TripEntity trip;
  final ValueChanged<Uri>? onOpenUrl;
  final TripControls? controls;

  const TripItineraryView({
    super.key,
    required this.trip,
    this.onOpenUrl,
    this.controls,
  });

  static const paywallMessage =
      'Desbloqueie o acesso completo para visualizar as atividades deste dia.';

  static String formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }

  static String? swapsLabel({int? used, int? allowed}) {
    if (used == null && allowed == null) return null;
    if (used != null && allowed != null) return 'Trocas: $used de $allowed';
    if (used != null) return 'Trocas usadas: $used';
    return 'Trocas permitidas: $allowed';
  }

  static String? ticketStatusLabel(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    switch (value.toUpperCase()) {
      case 'FREE':
        return 'Gratuito';
      case 'TICKET_REQUIRED':
        return 'Ingresso necessário';
      case 'UNKNOWN':
        return 'Ingresso não informado';
      default:
        return value;
    }
  }

  static String? transitLabel({int? meters, int? minutes, String? mode}) {
    if (meters == null && minutes == null) return null;
    final parts = <String>[];
    if (meters != null) parts.add(_distanceLabel(meters));
    if (minutes != null) parts.add('$minutes min');
    final modeLabel = _transitModeLabel(mode);
    if (modeLabel != null) parts.add(modeLabel);
    return parts.join(' · ');
  }

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
    final swaps = swapsLabel(
      used: trip.usedSwapsCount,
      allowed: trip.allowedSwapsCount,
    );

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
          if (trip.arrivalDateTime != null)
            _line('Chegada: ${formatDateTime(trip.arrivalDateTime!)}'),
          if (trip.departureDateTime != null)
            _line('Partida: ${formatDateTime(trip.departureDateTime!)}'),
          if (swaps != null) _line(swaps),
          if (trip.accommodation != null) ...[
            const SizedBox(height: TwoGoSpacing.md),
            _buildAccommodation(trip.accommodation!),
          ],
          if (controls != null) ...[
            const SizedBox(height: TwoGoSpacing.sm),
            if (trip.accommodation == null)
              TextButton(
                onPressed: () => showAccommodationSheet(
                  context,
                  controls: controls!,
                  tripId: trip.id,
                ),
                child: const Text('Cadastrar hospedagem'),
              )
            else
              Wrap(
                spacing: TwoGoSpacing.xs,
                children: [
                  TextButton(
                    onPressed: () => showAccommodationSheet(
                      context,
                      controls: controls!,
                      tripId: trip.id,
                    ),
                    child: const Text('Editar hospedagem'),
                  ),
                  TextButton(
                    onPressed: () => confirmDeleteAccommodation(
                      context,
                      controls: controls!,
                      tripId: trip.id,
                    ),
                    child: const Text('Remover hospedagem'),
                  ),
                ],
              ),
          ],
          const SizedBox(height: TwoGoSpacing.lg),
          ...days.map((day) => _buildDay(context, day)),
        ],
      ),
    );
  }

  Widget _buildDay(BuildContext context, TripDayEntity day) {
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
          if (controls != null && !locked && items.isNotEmpty)
            TextButton(
              onPressed: () => showMealRecommendationsSheet(
                context,
                controls: controls!,
                dayId: day.id,
                items: items,
              ),
              child: const Text('Sugestões de refeição'),
            ),
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
            ...items.map((item) => _buildItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildAccommodation(TripAccommodation stay) {
    final checkIn = _stayMoment(
      stay.checkInDateTime,
      stay.checkInDate,
      stay.checkInTime,
    );
    final checkOut = _stayMoment(
      stay.checkOutDateTime,
      stay.checkOutDate,
      stay.checkOutTime,
    );
    final place = [
      stay.address,
      stay.neighborhood,
      stay.zipCode,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
    final mapLink = stay.latitude != null && stay.longitude != null
        ? 'https://www.google.com/maps/search/?api=1&query=${stay.latitude},${stay.longitude}'
        : null;

    return TwoGoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hospedagem',
            style: TwoGoTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_filled(stay.name)) _line(stay.name!),
          if (place.isNotEmpty) _line(place),
          if (checkIn != null) _line('Check-in: $checkIn'),
          if (checkOut != null) _line('Check-out: $checkOut'),
          if (mapLink != null) ...[
            const SizedBox(height: TwoGoSpacing.xs),
            _mapLink(mapLink),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, ItineraryItemEntity item) {
    final mapLink = mapUrl(item);
    final transit = transitLabel(
      meters: item.transitDistanceMeters,
      minutes: item.transitDurationMinutes,
      mode: item.transitMode,
    );
    final ticket = ticketStatusLabel(item.ticketStatus);
    return Padding(
      padding: const EdgeInsets.only(bottom: TwoGoSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (transit != null) ...[
            Text(
              transit,
              style: TwoGoTypography.labelSmall.copyWith(
                color: TwoGoColors.contentSecondary,
              ),
            ),
            const SizedBox(height: TwoGoSpacing.xs),
          ],
          TwoGoCard(
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
                if (ticket != null) _line(ticket),
                if (mapLink != null) ...[
                  const SizedBox(height: TwoGoSpacing.xs),
                  _mapLink(mapLink),
                ],
                if (controls != null)
                  Wrap(
                    spacing: TwoGoSpacing.xs,
                    children: [
                      TextButton(
                        onPressed: () => showAlternativesSheet(
                          context,
                          controls: controls!,
                          itemId: item.id,
                        ),
                        child: const Text('Substituir'),
                      ),
                      TextButton(
                        onPressed: () => showDurationEditor(
                          context,
                          controls: controls!,
                          itemId: item.id,
                          currentDuration: item.duration,
                        ),
                        child: const Text('Duração'),
                      ),
                      TextButton(
                        onPressed: () => showVerifiedDetails(
                          context,
                          controls: controls!,
                          itemId: item.id,
                        ),
                        child: const Text('Detalhes'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
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

  String? _stayMoment(DateTime? dateTime, DateTime? date, String? time) {
    if (dateTime != null) return formatDateTime(dateTime);
    final clock = time?.trim();
    if (date == null && (clock == null || clock.isEmpty)) return null;
    final day = date == null ? null : formatDateTime(date).split(' ').first;
    if (day != null && clock != null && clock.isNotEmpty) return '$day $clock';
    return day ?? clock;
  }

  static String _distanceLabel(int meters) {
    if (meters < 1000) return '$meters m';
    final km = meters / 1000;
    final digits = km >= 10 ? 0 : 1;
    return '${km.toStringAsFixed(digits)} km';
  }

  static String? _transitModeLabel(String? mode) {
    final value = mode?.trim();
    if (value == null || value.isEmpty) return null;
    switch (value.toUpperCase()) {
      case 'WALKING':
        return 'a pé';
      case 'DRIVING':
        return 'de carro';
      case 'TRANSIT':
        return 'transporte';
      case 'BICYCLING':
        return 'de bicicleta';
      default:
        return value;
    }
  }

  String? _dateLabel(DateTime? date) {
    if (date == null) return null;
    final iso = date.toIso8601String();
    return iso.split('T').first;
  }
}
