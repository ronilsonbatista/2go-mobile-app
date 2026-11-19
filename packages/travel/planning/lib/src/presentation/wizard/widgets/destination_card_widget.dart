import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import '../../../domain/models/planning_destination.dart';
import '../form_course_tokens.dart';
import 'destination_datetime_sheet.dart';
import 'destination_search_sheet.dart';
import 'place_thumb.dart';
import 'planning_course_sheet.dart';

class DestinationCardWidget extends StatelessWidget {
  final int index;
  final PlanningDestination destination;
  final bool canRemove;
  final SearchPlacesUseCase? searchPlacesUseCase;
  final ValueChanged<PlanningDestination> onChanged;
  final VoidCallback? onRemove;

  const DestinationCardWidget({
    super.key,
    required this.index,
    required this.destination,
    this.canRemove = false,
    this.searchPlacesUseCase,
    required this.onChanged,
    this.onRemove,
  });

  /// Opens Places search only when the user edits this row.
  /// Home-seeded destinations already carry Core `providerPlaceId` — prefer that.
  Future<void> _selectDestination(BuildContext context) async {
    if (searchPlacesUseCase == null) return;
    final selectedPlace = await DestinationSearchSheet.show(
      context,
      searchPlacesUseCase: searchPlacesUseCase!,
    );
    if (selectedPlace != null) {
      onChanged(
        destination.copyWith(
          providerPlaceId: selectedPlace.providerPlaceId,
          name: selectedPlace.name,
          city: selectedPlace.city,
          country: selectedPlace.country,
          coverImage: selectedPlace.iconUrl ?? destination.coverImage,
        ),
      );
    }
  }

  Future<void> _selectArrivalDateTime(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final initial =
        DateTime.tryParse(destination.arrivalDate) ??
        now.add(const Duration(days: 7));
    final picked = await DestinationDateTimeSheet.show(
      context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 730)),
      initialTime: destination.arrivalTime.isEmpty
          ? '09:00'
          : destination.arrivalTime,
      primaryLabel: 'Próximo',
      secondaryLabel: 'Fechar',
    );
    if (picked == null) return;
    onChanged(
      destination.copyWith(
        arrivalDate: picked.date.toIso8601String().split('T').first,
        arrivalTime: picked.time,
      ),
    );
  }

  Future<void> _selectDepartureDateTime(BuildContext context) async {
    final arrival =
        DateTime.tryParse(destination.arrivalDate) ?? DateTime.now();
    final arrivalDay = DateTime(arrival.year, arrival.month, arrival.day);
    final initial =
        DateTime.tryParse(destination.departureDate) ??
        arrival.add(const Duration(days: 4));
    final picked = await DestinationDateTimeSheet.show(
      context,
      initialDate: initial.isBefore(arrivalDay) ? arrivalDay : initial,
      firstDate: arrivalDay,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialTime: destination.departureTime.isEmpty
          ? '23:00'
          : destination.departureTime,
      primaryLabel: 'Salvar',
      secondaryLabel: 'Voltar',
    );
    if (picked == null) return;
    onChanged(
      destination.copyWith(
        departureDate: picked.date.toIso8601String().split('T').first,
        departureTime: picked.time,
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    if (onRemove == null) return;
    final confirmed = await PlanningCourseSheet.show(
      context,
      title: 'Deseja realmente excluir?',
      body: 'Este destino será removido do roteiro.',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
    );
    if (confirmed == true) {
      onRemove!();
    }
  }

  /// Short course date: `26/11` (+ optional compact time).
  String _formatShortDateTime(String isoDate, String time) {
    if (isoDate.isEmpty) return 'Selecionar';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return 'Selecionar';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final datePart = '$day/$month';
    if (time.trim().isEmpty) return datePart;
    return '$datePart - ${_formatTimeDisplay(time)}';
  }

  String _formatTimeDisplay(String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    if (minute == '00') return '$hour:00';
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final hasName = destination.name.trim().isNotEmpty;
    final arrivalLabel = _formatShortDateTime(
      destination.arrivalDate,
      destination.arrivalTime,
    );
    final departureLabel = _formatShortDateTime(
      destination.departureDate,
      destination.departureTime,
    );

    return Container(
      decoration: BoxDecoration(
        color: FormCourseTokens.surface,
        borderRadius: BorderRadius.circular(FormCourseTokens.cardRadius),
      ),
      child: Column(
        children: [
          _DestinationRow(
            label: 'Onde',
            trailing: Row(
              children: [
                Expanded(
                  child: Text(
                    hasName ? destination.name : 'Selecionar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TwoGoTypography.titleMedium.copyWith(
                      color: FormCourseTokens.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasName) ...[
                  const SizedBox(width: TwoGoSpacing.sm),
                  PlaceThumb(
                    iconUrl: destination.coverImage,
                    placeName: destination.name,
                    size: 36,
                  ),
                ],
                // Trash only when ≥2 destinations (never on the sole first row).
                if (canRemove) ...[
                  const SizedBox(width: TwoGoSpacing.xs),
                  TwoGoIconButton(
                    icon: TwoGoIcons.trash,
                    onPressed: () => _confirmRemove(context),
                    variant: TwoGoIconButtonVariant.ghost,
                  ),
                ],
              ],
            ),
            onTap: () => _selectDestination(context),
          ),
          const Divider(height: 1, color: FormCourseTokens.summaryCard),
          _DestinationRow(
            label: 'Chegada',
            trailing: Text(
              arrivalLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: FormCourseTokens.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _selectArrivalDateTime(context),
            leadingIcon: const Text('🗓️', style: TextStyle(fontSize: 18)),
          ),
          const Divider(height: 1, color: FormCourseTokens.summaryCard),
          _DestinationRow(
            label: 'Partida',
            trailing: Text(
              departureLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: FormCourseTokens.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _selectDepartureDateTime(context),
            leadingIcon: const Text('⏰', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.label,
    required this.trailing,
    required this.onTap,
    this.leadingIcon,
  });

  final String label;
  final Widget trailing;
  final VoidCallback onTap;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TwoGoSpacing.md,
          vertical: TwoGoSpacing.md,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              leadingIcon!,
              const SizedBox(width: TwoGoSpacing.xs),
            ],
            Text(
              label,
              style: TwoGoTypography.bodyMedium.copyWith(
                color: FormCourseTokens.label,
              ),
            ),
            const SizedBox(width: TwoGoSpacing.sm),
            // Thumb / dates occupy the remaining width and sit flush right.
            Expanded(child: trailing),
          ],
        ),
      ),
    );
  }
}
