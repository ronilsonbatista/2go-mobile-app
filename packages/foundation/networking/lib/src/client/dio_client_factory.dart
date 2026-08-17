import 'package:dio/dio.dart';
import 'package:twogo_config/twogo_config.dart';
import 'package:twogo_security/twogo_security.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/correlation_interceptor.dart';
import '../interceptors/refresh_coordinator.dart';

class DioClientFactory {
  static Dio create({
    required ApiConfig config,
    required TokenStorage tokenStorage,
    RefreshCoordinator? refreshCoordinator,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(CorrelationInterceptor());
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: tokenStorage,
        refreshCoordinator: refreshCoordinator,
      ),
    );

    return dio;
  }
}
