import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

/// Writes PNGs when PREVIEW_SCREENSHOT_DIR is set. Skips otherwise.
void main() {
  testWidgets('export preview + upsell screenshots', (tester) async {
    final outDir = Platform.environment['PREVIEW_SCREENSHOT_DIR'];
    if (outDir == null || outDir.isEmpty) {
      return;
    }
    Directory(outDir).createSync(recursive: true);

    final bloc = PlanningPreviewBloc(
      getPreviewUseCase: GetPlanningPreviewUseCase(_Repo()),
    );
    addTearDown(bloc.close);

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: key,
          child: SizedBox(
            width: 390,
            height: 844,
            child: PlanningPreviewPage(
              journeyId: 'shot',
              bloc: bloc,
              now: () => DateTime(2026, 6, 30, 12, 0),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('Roma'), findsOneWidget);
    await tester.runAsync(() => _writePng(key, '$outDir/01-sim-preview-roma.png'));

    // Modal lives in the overlay — capture the sheet alone for evidence.
    final modalKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: Colors.black54,
          child: Center(
            child: RepaintBoundary(
              key: modalKey,
              child: SizedBox(
                width: 334,
                child: PlanningUnlockSheet(
                  offer: const PlanningUnlockOffer(
                    productId: 'prod',
                    code: 'ITINERARY_FULL_ACCESS',
                    name: 'Roteiro Completo 2GO',
                    price: 19.99,
                    currency: 'BRL',
                    available: true,
                  ),
                  onUnlockRequested: () {},
                  onDismiss: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Aproveitar'), findsOneWidget);
    await tester.runAsync(
      () => _writePng(modalKey, '$outDir/02-sim-upsell-modal.png'),
    );

    await tester.pumpWidget(const SizedBox());
  });
}

Future<void> _writePng(GlobalKey key, String path) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

class _Repo implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'shot',
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
                sourceType: 'AI',
              ),
              PlanningVisibleActivity(
                title: 'Piazza Venezia',
                category: 'TOURIST_ATTRACTION',
                timeLabel: '08:30 - 10:00',
                cost: 0,
                order: 2,
                latitude: 41.9022,
                longitude: 12.4825,
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Almoço',
                category: 'RESTAURANT',
                cost: 0,
                order: 3,
                sourceType: 'AI',
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
          name: 'Roteiro Completo 2GO',
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
