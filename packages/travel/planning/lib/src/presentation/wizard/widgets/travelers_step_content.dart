import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import '../../../domain/models/planning_travelers.dart';

class TravelersStepContent extends StatelessWidget {
  final PlanningTravelers travelers;
  final ValueChanged<PlanningTravelers> onChanged;

  const TravelersStepContent({
    super.key,
    required this.travelers,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TwoGoSpacing.md),
      child: TwoGoCard(
        child: Column(
          children: [
            TwoGoCounter(
              label: 'Adultos',
              subtitle: '18 anos ou mais',
              value: travelers.adults,
              min: 1,
              onChanged: (val) => onChanged(travelers.copyWith(adults: val)),
            ),
            const TwoGoDivider(space: TwoGoSpacing.lg),
            TwoGoCounter(
              label: 'Crianças',
              subtitle: 'Até 17 anos',
              value: travelers.children,
              min: 0,
              onChanged: (val) => onChanged(travelers.copyWith(children: val)),
            ),
            const TwoGoDivider(space: TwoGoSpacing.lg),
            TwoGoCounter(
              label: 'Idosos',
              subtitle: '60 anos ou mais',
              value: travelers.elders,
              min: 0,
              onChanged: (val) => onChanged(travelers.copyWith(elders: val)),
            ),
          ],
        ),
      ),
    );
  }
}
