import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

/// Writes full Day-1 preview PNGs when PREVIEW_SCREENSHOT_DIR is set.
///
/// These are **widget `toImage` compositions** (not a device simulator).
/// Filenames are prefixed accordingly. Provide PREVIEW_HERO_IMAGE for a real
/// destination photo; otherwise a solid teal placeholder is used for the hero.
void main() {
  testWidgets('export full Day-1 preview composition', (tester) async {
    final outDir = Platform.environment['PREVIEW_SCREENSHOT_DIR'];
    if (outDir == null || outDir.isEmpty) {
      return;
    }
    Directory(outDir).createSync(recursive: true);

    final heroPath = Platform.environment['PREVIEW_HERO_IMAGE'];
    final ImageProvider heroProvider;
    if (heroPath != null &&
        heroPath.isNotEmpty &&
        File(heroPath).existsSync()) {
      // MemoryImage avoids FileImage async stalls in widget tests.
      heroProvider = MemoryImage(File(heroPath).readAsBytesSync());
    } else {
      heroProvider = MemoryImage(Uint8List.fromList(_kTealPng));
    }

    final bloc = PlanningPreviewBloc(
      getPreviewUseCase: GetPlanningPreviewUseCase(_FullRepo()),
    );
    addTearDown(bloc.close);

    // Tall enough for hero + countdown + upsell + chips + full Day-1 timeline
    // + Mapa FAB, without a huge empty scroll tail.
    const logical = Size(390, 1100);
    tester.view.physicalSize = logical;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(
            size: logical,
            padding: EdgeInsets.only(top: 44),
          ),
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: logical.width,
              height: logical.height,
              child: PlanningPreviewPage(
                journeyId: 'shot',
                bloc: bloc,
                now: () => DateTime(2026, 6, 30, 12, 0),
                // Empty Core cover → Home catalog URL resolved via loadCoverCatalog.
                loadCoverCatalog: () async => const [
                  PreviewCoverCatalogEntry(
                    name: 'Roma',
                    providerPlaceId: 'places/roma',
                    imageUrl: 'https://cdn.example/home-roma.jpg',
                  ),
                ],
                coverImageProviderBuilder: (_) => heroProvider,
                onAddLodging: () {},
                onActivityTap: (_) {},
                onMealRecommendationsTap: (_) {},
                onItemMenuTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(heroProvider, tester.element(find.byType(MaterialApp)));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 32));
    // Allow async hero catalog resolve.
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Roma'), findsOneWidget);
    expect(find.text('Faltam apenas'), findsOneWidget);
    expect(find.textContaining('R\$ 19,99'), findsWidgets);
    expect(find.text('Sáb 25/07'), findsOneWidget);
    expect(find.text('Adicionar hospedagem'), findsOneWidget);
    expect(find.text('Piazza Venezia'), findsOneWidget);
    expect(find.text('Mapa'), findsWidgets);
    // Edit / PDF / Share remain visible (disabled).
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    expect(find.byIcon(Icons.ios_share_rounded), findsOneWidget);

    await tester.runAsync(
      () => _writePng(
        key,
        '$outDir/01-after-preview-hero-from-home-catalog-roma.png',
      ),
    );

    // Lisboa: empty Core cover → Home/catalog URL (thumb still attached in resolve).
    final lisboaBloc = PlanningPreviewBloc(
      getPreviewUseCase: GetPlanningPreviewUseCase(_LisboaRepo()),
    );
    addTearDown(lisboaBloc.close);
    final lisboaKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: const MediaQueryData(
            size: logical,
            padding: EdgeInsets.only(top: 44),
          ),
          child: RepaintBoundary(
            key: lisboaKey,
            child: SizedBox(
              width: logical.width,
              height: logical.height,
              child: PlanningPreviewPage(
                journeyId: 'shot-lisboa',
                bloc: lisboaBloc,
                now: () => DateTime(2026, 6, 30, 12, 0),
                loadCoverCatalog: () async => const [
                  PreviewCoverCatalogEntry(
                    name: 'Lisboa',
                    providerPlaceId: 'places/lisboa',
                    imageUrl: 'https://cdn.example/home-lisboa.jpg',
                  ),
                ],
                coverImageProviderBuilder: (_) => heroProvider,
                onAddLodging: () {},
                onActivityTap: (_) {},
                onMealRecommendationsTap: (_) {},
                onItemMenuTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await precacheImage(heroProvider, tester.element(find.byType(MaterialApp)));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Lisboa'), findsOneWidget);
    expect(find.text('Ver recomendações'), findsWidgets);
    expect(find.text('Adicionar hospedagem'), findsOneWidget);
    await tester.runAsync(
      () => _writePng(
        lisboaKey,
        '$outDir/02-after-lisboa-hero-from-home-catalog.png',
      ),
    );

    // Modal evidence (secondary).
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
      () => _writePng(modalKey, '$outDir/04-after-upsell-modal-widget-toimage.png'),
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

/// Opaque teal 1×1 PNG fallback when no hero file is provided.
const _kTealPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC,
  0x59, 0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _LisboaRepo implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'shot-lisboa',
        status: GuestJourneyStatus.previewReady,
        summary: PlanningPreviewSummary(
          destinations: [
            {'name': 'Lisboa', 'providerPlaceId': 'places/lisboa'},
          ],
          startDate: '2026-07-25',
          endDate: '2026-07-28',
          totalDays: 4,
        ),
        policy: PlanningPreviewPolicy(
          visibleDayCount: 1,
          autoPaywallDelaySeconds: 10,
        ),
        visibleDays: [
          PlanningVisibleDay(
            dayNumber: 1,
            date: '2026-07-25',
            destination: 'Lisboa',
            title: 'Dia 1: Lisboa',
            activities: [
              PlanningVisibleActivity(
                title: 'Almoço no Time Out Market',
                category: 'RESTAURANT',
                cost: 0,
                order: 1,
                sourceType: 'AI',
              ),
              PlanningVisibleActivity(
                title: 'Miradouro de Santa Catarina',
                category: 'TOURIST_ATTRACTION',
                timeLabel: '11:30 - 12:30',
                cost: 0,
                order: 2,
                latitude: 38.711,
                longitude: -9.148,
                sourceType: 'BASE_ATTRACTION',
              ),
            ],
          ),
        ],
        lockedDays: [
          PlanningLockedDay(
            dayNumber: 2,
            date: '2026-07-26',
            destination: 'Lisboa',
            title: 'Dia 2',
          ),
        ],
        unlockOffer: PlanningUnlockOffer(
          productId: 'prod',
          code: 'ITINERARY_FULL_ACCESS',
          name: 'Roteiro Completo 2GO',
          price: 29.90,
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

class _FullRepo implements PlanningRepository {
  @override
  Future<Result<PlanningPreview>> getPreview(String journeyId) async {
    return Result.success(
      const PlanningPreview(
        id: 'shot',
        status: GuestJourneyStatus.previewReady,
        summary: PlanningPreviewSummary(
          // Mirrors user feedback: Core summary + dest cover empty → Home catalog.
          destinations: [
            {
              'name': 'Roma',
              'providerPlaceId': 'places/roma',
            },
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
            title: 'Dia 1: Roma',
            activities: [
              PlanningVisibleActivity(
                title: 'Café da manhã',
                category: 'CAFE',
                period: 'Manhã',
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
                title: 'Fontana di Trevi',
                category: 'TOURIST_ATTRACTION',
                timeLabel: '10:30 - 11:30',
                cost: 0,
                order: 3,
                latitude: 41.9009,
                longitude: 12.4833,
                sourceType: 'BASE_ATTRACTION',
              ),
              PlanningVisibleActivity(
                title: 'Almoço',
                category: 'RESTAURANT',
                cost: 25,
                order: 4,
                sourceType: 'AI',
              ),
              PlanningVisibleActivity(
                title: 'Panteão',
                category: 'TOURIST_ATTRACTION',
                timeLabel: '13:30 - 15:00',
                cost: 0,
                order: 5,
                latitude: 41.8986,
                longitude: 12.4769,
                sourceType: 'BASE_ATTRACTION',
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
          PlanningLockedDay(
            dayNumber: 3,
            date: '2026-07-27',
            destination: 'Roma',
            title: 'Dia 3',
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
