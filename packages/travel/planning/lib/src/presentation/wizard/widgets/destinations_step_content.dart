import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_places/places.dart';
import '../../../domain/models/planning_destination.dart';
import '../form_course_tokens.dart';
import 'destination_card_widget.dart';
import 'form_asset_placeholder.dart';

class DestinationsStepContent extends StatelessWidget {
  final List<PlanningDestination> destinations;
  final SearchPlacesUseCase? searchPlacesUseCase;
  final ValueChanged<PlanningDestination> onDestinationChanged;
  final VoidCallback onAddDestination;
  final ValueChanged<int> onRemoveDestination;

  const DestinationsStepContent({
    super.key,
    required this.destinations,
    this.searchPlacesUseCase,
    required this.onDestinationChanged,
    required this.onAddDestination,
    required this.onRemoveDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TwoGoSpacing.md),
      child: Column(
        children: [
          ...destinations.asMap().entries.map((entry) {
            final index = entry.key;
            final dest = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: TwoGoSpacing.md),
              child: DestinationCardWidget(
                index: index,
                destination: dest,
                canRemove: destinations.length > 1,
                searchPlacesUseCase: searchPlacesUseCase,
                onChanged: (updated) => onDestinationChanged(updated),
                onRemove: () => onRemoveDestination(index),
              ),
            );
          }),
          const SizedBox(height: TwoGoSpacing.xs),
          InkWell(
            onTap: onAddDestination,
            borderRadius: BorderRadius.circular(TwoGoRadius.medium),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TwoGoSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FormAssetPlaceholder(
                    assetName: 'globe-add-destination',
                    size: 20,
                    fallbackIcon: Icons.public,
                  ),
                  const SizedBox(width: TwoGoSpacing.sm),
                  Text(
                    'Deseja adicionar mais um destino?',
                    style: TwoGoTypography.bodyMedium.copyWith(
                      color: FormCourseTokens.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: TwoGoSpacing.lg),
        ],
      ),
    );
  }
}
