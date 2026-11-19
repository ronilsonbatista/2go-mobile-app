import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

void main() {
  testWidgets('preview shows hero, countdown, day chips, meals and map fab', (
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
          now: () => DateTime(2026, 7, 1, 12, 0),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Roma'), findsOneWidget);
    expect(find.text('Faltam apenas'), findsOneWidget);
    expect(find.textContaining('R\$ 19,99'), findsWidgets);
    expect(find.text('Sáb 25/07'), findsOneWidget);
    expect(find.text('Adicionar hospedagem'), findsOneWidget);
    expect(find.text('Café da manhã'), findsOneWidget);
    expect(find.text('Ver recomendações'), findsWidgets);
    expect(find.text('Piazza Venezia'), findsOneWidget);
    expect(find.text('08:30 - 10:00'), findsOneWidget);
    expect(find.text('Grátis'), findsOneWidget);
    expect(find.text('Mapa'), findsWidgets);
    expect(find.byIcon(Icons.local_cafe_outlined), findsWidgets);
    expect(find.byIcon(Icons.lock_rounded), findsWidgets);

    // Infinite countdown timer — tear down without pumpAndSettle.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('upsell banner opens Aproveitar modal', (tester) async {
    final bloc = PlanningPreviewBloc(
      getPreviewUseCase: GetPlanningPreviewUseCase(_PreviewRepository()),
    );
    addTearDown(bloc.close);

    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: PlanningPreviewPage(
          journeyId: 'journey-1',
          bloc: bloc,
          now: () => DateTime(2026, 7, 1, 12, 0),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.textContaining('todos os dias de roteiro').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Aproveitar'), findsOneWidget);
    expect(find.text('Dicas exclusivas'), findsOneWidget);
    expect(find.text('Roteiro personalizado'), findsOneWidget);
    expect(find.text('Acesso offline ao seu roteiro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('activity image uses the parsed imageUrl', (tester) async {
    const pngBytes = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 390,
            child: PlanningTimelineItem(
              activity: const PlanningVisibleActivity(
                title: 'Foto',
                category: 'TOURIST_ATTRACTION',
                cost: 0,
                order: 1,
                imageUrl: 'https://cdn.example/cafe.jpg',
                sourceType: 'MANUAL',
              ),
              imageProviderBuilder: (_) =>
                  MemoryImage(Uint8List.fromList(pngBytes)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Foto'), findsOneWidget);
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
          startDate: '2026-07-25',
          endDate: '2026-07-28',
          totalDays: 4,
        ),
        policy: PlanningPreviewPolicy(
          visibleDayCount: 1,
          autoPaywallDelaySeconds: 0,
        ),
        visibleDays: [
          PlanningVisibleDay(
            dayNumber: 1,
            date: '2026-07-25',
            destination: 'Roma',
            title: 'Dia 1',
            activities: [
              PlanningVisibleActivity(
                title: 'Café da manhã',
                category: 'CAFE',
                cost: 0,
                order: 1,
                sourceType: 'MANUAL',
              ),
              PlanningVisibleActivity(
                title: 'Piazza Venezia',
                category: 'TOURIST_ATTRACTION',
                timeLabel: '08:30 - 10:00',
                cost: 0,
                order: 2,
                latitude: 41.9,
                longitude: 12.5,
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Bar da noite',
                category: 'BAR',
                cost: 0,
                order: 3,
                sourceType: 'MANUAL',
              ),
            ],
          ),
        ],
        lockedDays: [
          PlanningLockedDay(
            dayNumber: 2,
            date: '2026-07-26',
            destination: 'Roma',
            title: 'Dia 2',
          ),
        ],
        unlockOffer: PlanningUnlockOffer(
          productId: 'prod',
          code: 'ITINERARY_FULL_ACCESS',
          name: 'Acesso',
          price: 19.99,
          currency: 'BRL',
          available: true,
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
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<GuestJourney>> finalizeJourney(String journeyId) =>
      throw UnimplementedError();

  @override
  Future<Result<PlanningGenerationStatus>> getGenerationStatus(
    String journeyId,
  ) =>
      throw UnimplementedError();

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
  }) =>
      throw UnimplementedError();
}
