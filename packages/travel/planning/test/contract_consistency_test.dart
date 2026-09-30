import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  test('PATCH sends activityWindow and does not invent travelStyle', () {
    final json = const UpdatePlanningSessionDto(
      activityWindow: PlanningActivityWindowDto(
        startTime: '09:00',
        endTime: '18:00',
      ),
      budgetLevel: 'HIGH',
    ).toJson();

    expect(json['activityWindow'], {'startTime': '09:00', 'endTime': '18:00'});
    expect(json.containsKey('activityHours'), isFalse);
    expect(json.containsKey('travelStyle'), isFalse);
  });

  test('GET reads activityHours and still accepts activityWindow', () {
    final fromHours = PlanningSessionResponseDto.fromJson({
      'id': 'journey-1',
      'status': 'COLLECTING',
      'expiresAt': '2026-10-01T00:00:00.000Z',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-01T00:00:00.000Z',
      'activityHours': {'startTime': '10:00', 'endTime': '19:00'},
    });
    expect(fromHours.activityHours?.startTime, '10:00');

    final fromAlias = PlanningSessionResponseDto.fromJson({
      'id': 'journey-1',
      'status': 'COLLECTING',
      'expiresAt': '2026-10-01T00:00:00.000Z',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-01T00:00:00.000Z',
      'activityWindow': {'startTime': '08:00', 'endTime': '17:00'},
    });
    expect(fromAlias.activityHours?.startTime, '08:00');

    final hoursWins = PlanningSessionResponseDto.fromJson({
      'id': 'journey-1',
      'status': 'COLLECTING',
      'expiresAt': '2026-10-01T00:00:00.000Z',
      'createdAt': '2026-09-01T00:00:00.000Z',
      'updatedAt': '2026-09-01T00:00:00.000Z',
      'activityHours': {'startTime': '11:00', 'endTime': '20:00'},
      'activityWindow': {'startTime': '08:00', 'endTime': '17:00'},
    });
    expect(hoursWins.activityHours?.startTime, '11:00');
  });

  test('local draft writes activityHours and still reads activityWindow', () {
    const draft = PlanningDraft(
      activityWindow: {'startTime': '09:00', 'endTime': '18:00'},
      travelStyle: 'COMFORT',
    );
    final json = draft.toJson();
    expect(json.containsKey('activityHours'), isTrue);
    expect(json.containsKey('activityWindow'), isFalse);
    expect(json['travelStyle'], 'COMFORT');
    expect(PlanningDraft.fromJson(json).activityWindow?['startTime'], '09:00');
    expect(
      PlanningDraft.fromJson({
        'activityWindow': {'startTime': '08:00', 'endTime': '17:00'},
        'travelStyle': 'COMFORT',
      }).activityWindow?['endTime'],
      '17:00',
    );
  });

  test('known claim nextAction is checkout and unknown stays on checkout', () {
    expect(
      claimNavigationPath(tripId: 'trip 1', nextAction: 'CHECKOUT'),
      '/checkout?tripId=trip+1',
    );
    expect(
      claimNavigationPath(tripId: 'trip 1', nextAction: ' checkout '),
      '/checkout?tripId=trip+1',
    );
    expect(
      claimNavigationPath(tripId: 'trip 1', nextAction: null),
      '/checkout?tripId=trip+1',
    );
    expect(
      claimNavigationPath(tripId: 'trip 1', nextAction: 'HOME'),
      '/checkout?tripId=trip+1',
    );
  });

  test('map link uses latitude and longitude without a maps sdk', () {
    expect(
      PlanningTimelineItem.mapUrl(latitude: 41.89, longitude: 12.49),
      'https://www.google.com/maps/search/?api=1&query=41.89,12.49',
    );
    expect(PlanningTimelineItem.mapUrl(latitude: 1), isNull);
  });
}
