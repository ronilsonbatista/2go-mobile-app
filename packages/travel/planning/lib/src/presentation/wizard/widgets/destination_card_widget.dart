import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import '../../../domain/models/planning_destination.dart';
import 'destination_search_sheet.dart';

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
        ),
      );
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final initial =
        DateTime.tryParse(destination.arrivalDate) ??
        DateTime.now().add(const Duration(days: 7));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      final formattedDate = picked.toIso8601String().split('T').first;
      onChanged(destination.copyWith(arrivalDate: formattedDate));
    }
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final arrival =
        DateTime.tryParse(destination.arrivalDate) ?? DateTime.now();
    final initial =
        DateTime.tryParse(destination.departureDate) ??
        arrival.add(const Duration(days: 4));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(arrival) ? arrival : initial,
      firstDate: arrival,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      final formattedDate = picked.toIso8601String().split('T').first;
      onChanged(destination.copyWith(departureDate: formattedDate));
    }
  }

  Future<void> _selectArrivalTime(BuildContext context) async {
    final parts = destination.arrivalTime.split(':');
    final initialTime = TimeOfDay(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(destination.copyWith(arrivalTime: formattedTime));
    }
  }

  Future<void> _selectDepartureTime(BuildContext context) async {
    final parts = destination.departureTime.split(':');
    final initialTime = TimeOfDay(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 18 : 18,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onChanged(destination.copyWith(departureTime: formattedTime));
    }
  }

  String _formatDisplayDate(String isoDate) {
    if (isoDate.isEmpty) return 'dd/mm/aaaa';
    final parts = isoDate.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return isoDate;
  }

  @override
  Widget build(BuildContext context) {
    return TwoGoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destino ${index + 1}',
                style: TwoGoTypography.titleMedium.copyWith(
                  color: TwoGoColors.textPrimary,
                ),
              ),
              if (canRemove)
                TwoGoIconButton(
                  icon: TwoGoIcons.trash,
                  onPressed: onRemove,
                  variant: TwoGoIconButtonVariant.ghost,
                ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.sm),
          InkWell(
            onTap: () => _selectDestination(context),
            borderRadius: TwoGoRadius.borderMedium,
            child: IgnorePointer(
              child: TwoGoTextField(
                label: 'Cidade ou país',
                hintText: 'Buscar destino...',
                prefixIcon: TwoGoIcons.search,
                controller: TextEditingController(
                  text: destination.name.isNotEmpty
                      ? destination.name
                      : 'Selecionar cidade ou país',
                ),
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.md),

          // Chegada
          Text(
            'Chegada',
            style: TwoGoTypography.labelMedium.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => _selectArrivalDate(context),
                  borderRadius: TwoGoRadius.borderMedium,
                  child: IgnorePointer(
                    child: TwoGoTextField(
                      hintText: 'Data de chegada',
                      prefixIcon: TwoGoIcons.calendar,
                      controller: TextEditingController(
                        text: _formatDisplayDate(destination.arrivalDate),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TwoGoSpacing.xs),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => _selectArrivalTime(context),
                  borderRadius: TwoGoRadius.borderMedium,
                  child: IgnorePointer(
                    child: TwoGoTextField(
                      hintText: 'Horário',
                      prefixIcon: TwoGoIcons.clock,
                      controller: TextEditingController(
                        text: destination.arrivalTime.isNotEmpty
                            ? destination.arrivalTime
                            : '09:00',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwoGoSpacing.sm),

          // Saída
          Text(
            'Saída',
            style: TwoGoTypography.labelMedium.copyWith(
              color: TwoGoColors.textSecondary,
            ),
          ),
          const SizedBox(height: TwoGoSpacing.xs),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => _selectDepartureDate(context),
                  borderRadius: TwoGoRadius.borderMedium,
                  child: IgnorePointer(
                    child: TwoGoTextField(
                      hintText: 'Data de saída',
                      prefixIcon: TwoGoIcons.calendar,
                      controller: TextEditingController(
                        text: _formatDisplayDate(destination.departureDate),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TwoGoSpacing.xs),
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () => _selectDepartureTime(context),
                  borderRadius: TwoGoRadius.borderMedium,
                  child: IgnorePointer(
                    child: TwoGoTextField(
                      hintText: 'Horário',
                      prefixIcon: TwoGoIcons.clock,
                      controller: TextEditingController(
                        text: destination.departureTime.isNotEmpty
                            ? destination.departureTime
                            : '18:00',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
