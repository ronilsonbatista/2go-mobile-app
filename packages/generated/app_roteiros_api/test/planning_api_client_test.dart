import 'package:app_roteiros_api/app_roteiros_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanningApiClient', () {
    test('POST /planning-sessions creates session from unwrapped data',
        () async {
      String? path;
      String? method;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            method = options.method;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _sessionPayload(guestToken: 'guest-abc'),
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      final created = await client.createSession(
        const CreatePlanningSessionDto(answersVersion: 1, initialStep: 1),
      );

      expect(method, 'POST');
      expect(path, '/planning-sessions');
      expect(created.id, 'journey-1');
      expect(created.guestToken, 'guest-abc');
      expect(created.status, 'DRAFT');
    });

    test('GET /planning-sessions/:id sends X-Guest-Token', () async {
      String? path;
      String? guestHeader;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            guestHeader = options.headers['X-Guest-Token'] as String?;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: _sessionPayload(),
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      final session = await client.getSession(
        'journey-1',
        guestToken: 'guest-abc',
      );

      expect(path, '/planning-sessions/journey-1');
      expect(guestHeader, 'guest-abc');
      expect(session.id, 'journey-1');
      expect(session.currentStep, 2);
    });

    test('POST /planning-sessions/:id/generate parses status', () async {
      String? path;
      String? guestHeader;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            guestHeader = options.headers['X-Guest-Token'] as String?;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'journey-1',
                  'status': 'GENERATING',
                  'generationStartedAt': '2026-11-20T12:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      final status = await client.startGeneration(
        'journey-1',
        guestToken: 'guest-abc',
      );

      expect(path, '/planning-sessions/journey-1/generate');
      expect(guestHeader, 'guest-abc');
      expect(status.status, 'GENERATING');
    });

    test('GET generation-status and preview paths', () async {
      final paths = <String>[];
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            paths.add(options.path);
            final isPreview = options.path.endsWith('/preview');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: isPreview
                    ? _previewPayload()
                    : {
                        'id': 'journey-1',
                        'status': 'PREVIEW_READY',
                        'generationCompletedAt': '2026-11-20T12:05:00.000Z',
                      },
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      final status = await client.getGenerationStatus(
        'journey-1',
        guestToken: 'guest-abc',
      );
      final preview = await client.getPreview(
        'journey-1',
        guestToken: 'guest-abc',
      );

      expect(paths, [
        '/planning-sessions/journey-1/generation-status',
        '/planning-sessions/journey-1/preview',
      ]);
      expect(status.status, 'PREVIEW_READY');
      expect(preview.summary.totalDays, 5);
      expect(preview.visibleDays, hasLength(1));
      expect(preview.unlockOffer.currency, 'BRL');
    });

    test('POST claim sends guest token and parses nextAction', () async {
      String? path;
      String? guestHeader;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            guestHeader = options.headers['X-Guest-Token'] as String?;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'journeyId': 'journey-1',
                  'tripId': 'trip-9',
                  'status': 'CLAIMED',
                  'nextAction': 'CHECKOUT',
                },
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      final claim = await client.claimJourney(
        'journey-1',
        guestToken: 'guest-abc',
      );

      expect(path, '/planning-sessions/journey-1/claim');
      expect(guestHeader, 'guest-abc');
      expect(claim.tripId, 'trip-9');
      expect(claim.nextAction, 'CHECKOUT');
    });

    test('propagates DioException on generate failure envelope', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response(
                  requestOptions: options,
                  statusCode: 410,
                  data: {
                    'success': false,
                    'code': 'PLANNING_SESSION_EXPIRED',
                    'message': 'Sessão expirada',
                    'timestamp': '2026-11-20T00:00:00.000Z',
                  },
                ),
              ),
            );
          },
        ),
      );

      final client = PlanningApiClient(dio);
      expect(
        () => client.startGeneration('journey-1', guestToken: 'guest-abc'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.data['code'],
            'code',
            'PLANNING_SESSION_EXPIRED',
          ),
        ),
      );
    });
  });
}

Map<String, dynamic> _sessionPayload({String? guestToken}) => {
      'id': 'journey-1',
      'status': 'DRAFT',
      'answersVersion': 1,
      'currentStep': 2,
      'expiresAt': '2026-11-27T00:00:00.000Z',
      'createdAt': '2026-11-20T00:00:00.000Z',
      'updatedAt': '2026-11-20T00:00:00.000Z',
      if (guestToken != null) 'guestToken': guestToken,
    };

Map<String, dynamic> _previewPayload() => {
      'id': 'journey-1',
      'status': 'PREVIEW_READY',
      'summary': {
        'destinations': ['Lisboa'],
        'startDate': '2026-12-01',
        'endDate': '2026-12-05',
        'totalDays': 5,
        'coverImageUrl': 'https://cdn.example/lisboa.jpg',
      },
      'previewPolicy': {
        'visibleDayCount': 1,
        'autoPaywallDelaySeconds': 10,
      },
      'visibleDays': [
        {
          'dayNumber': 1,
          'date': '2026-12-01',
          'destination': 'Lisboa',
          'title': 'Dia 1',
          'activities': [
            {
              'title': 'Miradouro',
              'category': 'TOURIST_ATTRACTION',
              'cost': 0,
              'order': 1,
              'sourceType': 'AI',
            },
          ],
        },
      ],
      'lockedDays': [
        {
          'dayNumber': 2,
          'destination': 'Lisboa',
          'title': 'Dia 2',
          'locked': true,
        },
      ],
      'unlockOffer': {
        'code': 'ITINERARY_FULL_ACCESS',
        'name': 'Acesso Completo',
        'price': 99.90,
        'amount': 99.90,
        'currency': 'BRL',
        'days': 4,
        'tier': 'UP_TO_7',
        'available': true,
      },
    };
