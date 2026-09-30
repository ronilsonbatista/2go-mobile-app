import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  testWidgets('preview shows parsed fields, date, order and cafe/bar icons', (
    tester,
  ) async {
    final opened = <Uri>[];
    final repository = _PreviewRepository();
    final bloc = PlanningPreviewBloc(
      getPreviewUseCase: GetPlanningPreviewUseCase(repository),
    );
    addTearDown(bloc.close);

    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: PlanningPreviewPage(
          journeyId: 'journey-1',
          bloc: bloc,
          onOpenUrl: opened.add,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('2026-08-01'), findsOneWidget);
    expect(find.byIcon(Icons.local_cafe_rounded), findsOneWidget);
    expect(find.byIcon(Icons.local_bar_rounded), findsOneWidget);
    expect(
      find.text('https://www.google.com/maps/search/?api=1&query=41.9,12.5'),
      findsOneWidget,
    );
    expect(find.text('https://tickets.example/bar'), findsOneWidget);
    expect(find.text('https://reserve.example/bar'), findsOneWidget);

    final first = tester.getTopLeft(find.text('Café da manhã'));
    final second = tester.getTopLeft(find.text('Bar da noite'));
    expect(first.dy, lessThan(second.dy));

    await tester.tap(find.text('Ingresso'));
    await tester.pump();
    expect(opened.single.toString(), 'https://tickets.example/bar');
  });

  testWidgets('activity image uses the parsed imageUrl', (tester) async {
    const pngBytes = <int>[
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: PlanningTimelineItem(
          activity: const PlanningVisibleActivity(
            title: 'Foto',
            category: 'CAFE',
            cost: 0,
            order: 1,
            imageUrl: 'https://cdn.example/cafe.jpg',
            sourceType: 'MANUAL',
          ),
          imageProviderBuilder: (_) =>
              MemoryImage(Uint8List.fromList(pngBytes)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.local_cafe_rounded), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is MemoryImage,
      ),
      findsOneWidget,
    );
  });
}

class _PreviewRepository implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'journey-1',
        status: GuestJourneyStatus.previewReady,
        summary: PlanningPreviewSummary(
          destinations: [
            {'name': 'Roma'},
          ],
          totalDays: 1,
        ),
        policy: PlanningPreviewPolicy(
          visibleDayCount: 1,
          autoPaywallDelaySeconds: 0,
        ),
        visibleDays: [
          PlanningVisibleDay(
            dayNumber: 1,
            date: '2026-08-01',
            destination: 'Roma',
            title: 'Dia 1',
            activities: [
              PlanningVisibleActivity(
                title: 'Bar da noite',
                category: 'BAR',
                cost: 0,
                order: 2,
                latitude: 41.9,
                longitude: 12.5,
                ticketUrl: 'https://tickets.example/bar',
                reservationUrl: 'https://reserve.example/bar',
                sourceType: 'MANUAL',
              ),
              PlanningVisibleActivity(
                title: 'Café da manhã',
                category: 'CAFE',
                cost: 0,
                order: 1,
                sourceType: 'MANUAL',
              ),
            ],
          ),
        ],
        lockedDays: [],
        unlockOffer: PlanningUnlockOffer(
          productId: 'prod',
          code: 'ITINERARY_FULL_ACCESS',
          name: 'Acesso',
          price: 19.99,
          currency: 'BRL',
          available: false,
        ),
      ),
    );
  }

  @override
  Future<Result<ClaimJourneyResult>> claimJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<CreatedGuestJourneyResult>> createJourney({
    int? answersVersion,
    int? initialStep,
  }) => throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
    String journeyId,
  ) => throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> getJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> startGeneration(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> updateJourney({
    required String journeyId,
    int? currentStep,
    List<PlanningDestination>? destinations,
    PlanningTravelers? travelers,
    List<PlanningInterest>? interests,
    PlanningActivityWindow? activityWindow,
    String? budgetLevel,
    String? travelStyle,
  }) => throw UnimplementedError();
}
