import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_planning/twogo_planning.dart';

/// Minimal 1×1 PNG (opaque teal) so hero Image.network resolves offline.
const _kPngBytes = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC,
  0x59, 0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

/// Writes PNGs when PREVIEW_SCREENSHOT_DIR is set. Skips otherwise.
void main() {
  testWidgets('export preview + upsell screenshots', (tester) async {
    final outDir = Platform.environment['PREVIEW_SCREENSHOT_DIR'];
    if (outDir == null || outDir.isEmpty) {
      return;
    }
    Directory(outDir).createSync(recursive: true);

    final previous = HttpOverrides.current;
    HttpOverrides.global = _PngHttpOverrides();
    addTearDown(() => HttpOverrides.global = previous);

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
    // Allow mocked network image decode.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
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

class _PngHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _PngHttpClient();
}

class _PngHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _PngHttpRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _PngHttpRequest(url);

  @override
  void close({bool force = false}) {}

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PngHttpRequest implements HttpClientRequest {
  _PngHttpRequest(this._uri);

  final Uri _uri;

  @override
  Uri get uri => _uri;

  @override
  Future<HttpClientResponse> close() async => _PngHttpResponse();

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PngHttpResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _kPngBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kPngBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
            {
              'name': 'Roma',
              'coverImage':
                  'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
            },
          ],
          startDate: '2026-07-25',
          endDate: '2026-07-28',
          totalDays: 4,
          coverImageUrl:
              'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
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
