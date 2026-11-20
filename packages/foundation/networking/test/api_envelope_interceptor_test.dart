import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/twogo_networking.dart';

class _CapturingHandler extends ResponseInterceptorHandler {
  Response? nextResponse;

  @override
  void next(Response response) {
    nextResponse = response;
  }
}

void main() {
  group('ApiEnvelopeInterceptor', () {
    late ApiEnvelopeInterceptor interceptor;

    setUp(() {
      interceptor = ApiEnvelopeInterceptor();
    });

    Response<dynamic> _response(dynamic data) {
      return Response<dynamic>(
        requestOptions: RequestOptions(path: '/probe'),
        statusCode: 200,
        data: data,
      );
    }

    test('unwraps {success:true,data,timestamp} to inner data', () {
      final handler = _CapturingHandler();
      interceptor.onResponse(
        _response({
          'success': true,
          'data': {
            'items': [
              {'id': '1'},
            ],
          },
          'timestamp': '2026-11-20T00:00:00.000Z',
        }),
        handler,
      );

      expect(handler.nextResponse?.data, isA<Map>());
      expect((handler.nextResponse!.data as Map)['items'], isNotEmpty);
      expect(
        (handler.nextResponse!.data as Map).containsKey('success'),
        isFalse,
      );
    });

    test('unwraps when success key is null/absent but data present', () {
      final handler = _CapturingHandler();
      interceptor.onResponse(
        _response({
          'data': {'accessToken': 'tok'},
          'timestamp': '2026-11-20T00:00:00.000Z',
        }),
        handler,
      );

      expect(handler.nextResponse?.data, {'accessToken': 'tok'});
    });

    test('does not unwrap when success is false', () {
      final envelope = {
        'success': false,
        'code': 'AUTH_OTP_INVALID',
        'message': 'Código incorreto',
        'data': null,
        'timestamp': '2026-11-20T00:00:00.000Z',
      };
      final handler = _CapturingHandler();
      interceptor.onResponse(_response(envelope), handler);

      expect(handler.nextResponse?.data, envelope);
    });

    test('leaves non-map bodies unchanged', () {
      final handler = _CapturingHandler();
      interceptor.onResponse(_response(['a', 'b']), handler);
      expect(handler.nextResponse?.data, ['a', 'b']);
    });

    test('leaves map without data key unchanged', () {
      final handler = _CapturingHandler();
      interceptor.onResponse(_response({'items': []}), handler);
      expect(handler.nextResponse?.data, {'items': []});
    });

    test('unwraps through Dio with HttpClientAdapter mock', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://core.test'));
      dio.interceptors.add(ApiEnvelopeInterceptor());
      dio.httpClientAdapter = _JsonAdapter();

      final response = await dio.get<dynamic>('/probe');
      expect(response.data, {'ok': true});
    });
  });
}

/// Minimal adapter that returns a JSON map without using request interceptors.
class _JsonAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      // Encode as JSON string so Dio's transformer builds a real decoded map.
      '{"success":true,"data":{"ok":true},"timestamp":"2026-11-20T00:00:00.000Z"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
