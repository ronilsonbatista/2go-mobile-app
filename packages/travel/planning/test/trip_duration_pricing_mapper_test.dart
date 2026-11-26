import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  PlanningPreviewResponseDto previewDto({
    required int totalDays,
    double? amount,
    double? price,
    int days = 0,
    String tier = '',
  }) {
    final list = amount ?? price ?? 0;
    return PlanningPreviewResponseDto(
      id: 'j1',
      status: 'PREVIEW_READY',
      summary: PlanningPreviewSummaryDto(
        destinations: const [],
        startDate: '2026-07-25',
        endDate: '2026-07-28',
        totalDays: totalDays,
      ),
      previewPolicy: PlanningPreviewPolicyDto(
        visibleDayCount: 1,
        autoPaywallDelaySeconds: 0,
      ),
      visibleDays: const [],
      lockedDays: const [],
      unlockOffer: PlanningUnlockOfferDto(
        code: 'ITINERARY_FULL_ACCESS',
        name: 'Acesso Completo',
        price: price ?? list,
        amount: list,
        currency: 'BRL',
        days: days,
        tier: tier,
        available: true,
      ),
    );
  }

  test('consumes Core amount/days/tier when present', () {
    final mapped = PlanningMapper.toPreviewDomain(
      previewDto(
        totalDays: 10,
        amount: 119.9,
        days: 10,
        tier: 'FROM_8_TO_12',
      ),
    );
    expect(mapped.unlockOffer.amount, 119.9);
    expect(mapped.unlockOffer.price, 119.9);
    expect(mapped.unlockOffer.days, 10);
    expect(mapped.unlockOffer.tier, 'FROM_8_TO_12');
  });

  test('falls back to local mirror when Core omits amount', () {
    final short = PlanningMapper.toPreviewDomain(
      previewDto(totalDays: 4),
    );
    expect(short.unlockOffer.price, 99.90);
    expect(short.unlockOffer.days, 4);
    expect(short.unlockOffer.tier, 'UP_TO_7');

    final mid = PlanningMapper.toPreviewDomain(
      previewDto(totalDays: 10),
    );
    expect(mid.unlockOffer.price, 119.90);
    expect(mid.unlockOffer.tier, 'FROM_8_TO_12');

    final long = PlanningMapper.toPreviewDomain(
      previewDto(totalDays: 14),
    );
    expect(long.unlockOffer.price, 139.90);
    expect(long.unlockOffer.tier, 'FROM_13');
  });
}
