import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_core/twogo_core.dart';
import 'package:twogo_profile/profile.dart';

void main() {
  group('RemoteAccountProfileRepository', () {
    test('fetchMe GETs /users/me and maps Core user payload', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'GET');
            expect(options.path, '/users/me');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                // Shape after ApiEnvelopeInterceptor unwraps { success, data }.
                data: {
                  'message': 'Acesso liberado!',
                  'user': {
                    'userId': 'usr_1',
                    'id': 'usr_1',
                    'email': 'gustavo.gv@gmail.com',
                    'role': 'USER',
                    'displayName': 'Gustavo Vieira',
                    'photoUrl': null,
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      final profile = await repo.fetchMe();

      expect(profile.id, 'usr_1');
      expect(profile.email, 'gustavo.gv@gmail.com');
      expect(profile.displayName, 'Gustavo Vieira');
      expect(profile.hasPhoto, isFalse);
      expect(profile.initials, 'GV');
    });

    test('fetchMe accepts raw { success, data } envelope', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/users/me');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'timestamp': '2026-11-20T12:00:00.000Z',
                  'data': {
                    'message': 'Acesso liberado!',
                    'user': {
                      'id': 'usr_2',
                      'email': 'ana@2go.app',
                      'displayName': 'Ana Costa',
                      'photoUrl': 'https://cdn.example/ana.jpg',
                    },
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      final profile = await repo.fetchMe();

      expect(profile.id, 'usr_2');
      expect(profile.email, 'ana@2go.app');
      expect(profile.photoUrl, 'https://cdn.example/ana.jpg');
      expect(profile.hasPhoto, isTrue);
    });

    test('fetchMe uses fallbackEmail when Core omits email', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'user': {
                    'id': 'usr_3',
                    'displayName': 'Sem Email',
                    'photoUrl': null,
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      final profile = await repo.fetchMe(fallbackEmail: 'session@2go.app');

      expect(profile.email, 'session@2go.app');
      expect(profile.displayName, 'Sem Email');
    });

    test('fetchMe maps Dio 401 to SessionExpiredFailure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 401,
                  data: {
                    'success': false,
                    'code': 'AUTH_SESSION_EXPIRED',
                    'message': 'Sessão expirada.',
                    'statusCode': 401,
                  },
                ),
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      await expectLater(
        repo.fetchMe(),
        throwsA(isA<SessionExpiredFailure>()),
      );
    });

    test(
      'uploadAvatar POSTs multipart file to /media/upload/avatar',
      () async {
        final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
        late FormData captured;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              expect(options.method, 'POST');
              expect(options.path, '/media/upload/avatar');
              expect(options.data, isA<FormData>());
              captured = options.data as FormData;

              final fileFields = captured.files
                  .where((e) => e.key == 'file')
                  .toList();
              expect(fileFields, hasLength(1));
              expect(fileFields.single.value.filename, 'avatar.jpg');

              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  statusCode: 201,
                  // Unwrapped UploadResult (after envelope interceptor).
                  data: {
                    'url': 'https://cdn.2go.com/avatars/test.jpg',
                    'filename': 'test.jpg',
                    'mimeType': 'image/jpeg',
                    'size': 1024,
                  },
                ),
              );
            },
          ),
        );

        final repo = RemoteAccountProfileRepository(dio: dio);
        final url = await repo.uploadAvatar(
          bytes: [1, 2, 3, 4],
          filename: 'avatar.jpg',
          contentType: 'image/jpeg',
        );

        expect(url, 'https://cdn.2go.com/avatars/test.jpg');
        expect(captured.files.single.key, 'file');
      },
    );

    test('uploadAvatar reads nested data.url from raw envelope', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/media/upload/avatar');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'timestamp': '2026-11-20T12:00:00.000Z',
                  'data': {
                    'url': 'https://cdn.2go.com/avatars/nested.jpg',
                    'filename': 'nested.jpg',
                    'mimeType': 'image/png',
                    'size': 2048,
                  },
                },
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      final url = await repo.uploadAvatar(
        bytes: [9, 8, 7],
        filename: 'avatar.png',
        contentType: 'image/png',
      );

      expect(url, 'https://cdn.2go.com/avatars/nested.jpg');
    });

    test('uploadAvatar throws when response has no url', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: {'filename': 'x.jpg', 'size': 1},
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      await expectLater(
        repo.uploadAvatar(bytes: [1], filename: 'x.jpg'),
        throwsA(isA<StateError>()),
      );
    });

    test('uploadAvatar maps validation Dio errors to AppFailure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.badResponse,
                response: Response<dynamic>(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    'success': false,
                    'code': 'BAD_REQUEST',
                    'message': 'Arquivo inválido.',
                    'statusCode': 400,
                  },
                ),
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      await expectLater(
        repo.uploadAvatar(bytes: [1], filename: 'bad.txt'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('uploadAvatar maps connectivity errors to NetworkFailure', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                error: Exception('offline'),
              ),
            );
          },
        ),
      );

      final repo = RemoteAccountProfileRepository(dio: dio);
      await expectLater(
        repo.uploadAvatar(bytes: [1], filename: 'avatar.jpg'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
