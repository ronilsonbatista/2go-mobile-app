import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_networking/networking.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_test_support/test_support.dart';

void main() {
  test('paid trip routes receive the bearer token', () async {
    final dio = Dio();
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: InMemoryTokenStorage(
          const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
        ),
      ),
    );
    final headers = <String, String?>{};
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          headers['${options.method} ${options.path}'] =
              options.headers['Authorization'] as String?;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              data: const <String, dynamic>{},
            ),
          );
        },
      ),
    );

    const routes = <(String, String)>[
      ('GET', '/trips/trip-1/accommodation'),
      ('POST', '/trips/trip-1/accommodation'),
      ('DELETE', '/trips/trip-1/accommodation'),
      ('GET', '/itinerary-items/item-1/alternatives'),
      ('POST', '/itinerary-items/item-1/substitute'),
      ('GET', '/trip-days/day-1/meal-recommendations'),
      ('PATCH', '/itinerary-items/item-1/pin-meal'),
      ('PATCH', '/itinerary-items/item-1'),
      ('GET', '/itinerary-items/item-1'),
      ('GET', '/trips/trip-1'),
    ];
    for (final route in routes) {
      await dio.request<dynamic>(route.$2, options: Options(method: route.$1));
    }
    await dio.get<dynamic>('/planning-sessions/journey-1');

    for (final route in routes) {
      expect(headers['${route.$1} ${route.$2}'], 'Bearer access-1');
    }
    expect(headers['GET /planning-sessions/journey-1'], isNull);
  });
}
