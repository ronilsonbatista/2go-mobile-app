import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  group('PlanningMapper destination order wire format', () {
    test('domain 0-based becomes Core 1-based on DTO', () {
      const domain = PlanningDestination(
        name: 'Roma',
        arrivalDate: '2026-11-27',
        arrivalTime: '09:00',
        departureDate: '2026-12-08',
        departureTime: '18:00',
        order: 0,
      );

      final dto = PlanningMapper.destinationToDto(domain);
      expect(dto.order, 1);
    });

    test('reindexes multiple destinations without colliding at 1', () {
      final dtos = [0, 1, 2]
          .map(
            (order) => PlanningMapper.destinationToDto(
              PlanningDestination(
                name: 'City $order',
                arrivalDate: '2026-11-27',
                arrivalTime: '09:00',
                departureDate: '2026-12-08',
                departureTime: '18:00',
                order: order,
              ),
            ),
          )
          .toList();

      expect(dtos.map((d) => d.order).toList(), [1, 2, 3]);
    });

    test('DTO 1-based becomes domain 0-based', () {
      final domain = PlanningMapper.destinationToDomain(
        const PlanningDestinationDto(
          name: 'Roma',
          arrivalDate: '2026-11-27',
          arrivalTime: '09:00',
          departureDate: '2026-12-08',
          departureTime: '18:00',
          order: 1,
        ),
      );
      expect(domain.order, 0);
    });
  });
}
