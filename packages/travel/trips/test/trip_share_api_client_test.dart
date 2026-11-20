import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_trips/trips.dart';

void main() {
  group('TripShareApiClient', () {
    test('POST /trips/:id/participants invites by email', () async {
      String? path;
      dynamic body;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            body = options.data;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Convite enviado com sucesso',
                  'participantId': 'p-1',
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final result = await client.inviteParticipant(
        'trip-1',
        email: 'Guest@2GO.com',
      );

      expect(path, '/trips/trip-1/participants');
      expect(body, {'email': 'guest@2go.com'});
      expect(result.participantId, 'p-1');
      expect(result.message, contains('Convite'));
    });

    test('GET participants reads list (unwrapped)', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'p-1',
                    'tripId': 'trip-1',
                    'email': 'a@b.com',
                    'role': 'VIEWER',
                    'accepted': false,
                  },
                ],
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final list = await client.listParticipants('trip-1');
      expect(list, hasLength(1));
      expect(list.single.email, 'a@b.com');
      expect(list.single.accepted, isFalse);
      expect(list.single.isGuest, isTrue);
    });

    test('GET participants reads raw envelope', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': [
                    {
                      'id': 'p-2',
                      'tripId': 'trip-1',
                      'email': 'c@d.com',
                      'role': 'VIEWER',
                      'accepted': true,
                    },
                  ],
                  'timestamp': '2026-11-20T00:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final list = await client.listParticipants('trip-1');
      expect(list.single.id, 'p-2');
      expect(list.single.accepted, isTrue);
    });

    test('DELETE participant', () async {
      String? path;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'p-1',
                  'tripId': 'trip-1',
                  'email': 'a@b.com',
                  'role': 'VIEWER',
                  'accepted': false,
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final removed = await client.removeParticipant('trip-1', 'p-1');
      expect(path, '/trips/trip-1/participants/p-1');
      expect(removed.id, 'p-1');
    });

    test('POST /trip-invites/accept', () async {
      dynamic body;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            body = options.data;
            expect(options.path, '/trip-invites/accept');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'message': 'Convite aceito com sucesso',
                  'tripId': 'trip-9',
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final result = await client.acceptInvite(inviteToken: 'tok-1');
      expect(body, {'inviteToken': 'tok-1'});
      expect(result.tripId, 'trip-9');
    });

    test('GET pending welcomes reads data.items', () async {
      String? path;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [
                    {
                      'tripId': 'trip-1',
                      'participantId': 'p-1',
                      'role': 'VIEWER',
                      'isGuest': true,
                      'welcomeSeenAt': null,
                      'trip': {
                        'id': 'trip-1',
                        'title': 'Roma',
                        'destination': 'Roma',
                        'coverImage': 'https://cdn.example/roma.jpg',
                      },
                    },
                  ],
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final items = await client.listPendingWelcomes();
      expect(path, '/users/me/trip-welcomes/pending');
      expect(items, hasLength(1));
      expect(items.single.trip.destination, 'Roma');
      expect(items.single.isGuest, isTrue);
    });

    test('GET pending welcomes returns [] on 404 (defensive)', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'message': 'Not Found'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final items = await client.listPendingWelcomes();
      expect(items, isEmpty);
    });

    test('POST mark welcome seen', () async {
      String? path;
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            path = options.path;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'tripId': 'trip-1',
                  'participantId': 'p-1',
                  'isGuest': true,
                  'welcomeSeenAt': '2026-11-20T16:00:00.000Z',
                },
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      final result = await client.markWelcomeSeen('trip-1');
      expect(path, '/users/me/trip-welcomes/trip-1/seen');
      expect(result.isGuest, isTrue);
      expect(result.welcomeSeenAt, isNotNull);
    });

    test('maps Dio errors via ErrorMapper', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: 'socket',
              ),
            );
          },
        ),
      );

      final client = TripShareApiClient(dio);
      expect(
        () => client.listParticipants('trip-1'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
