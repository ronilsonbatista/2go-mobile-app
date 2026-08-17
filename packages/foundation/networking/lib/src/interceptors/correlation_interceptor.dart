import 'package:dio/dio.dart';

class CorrelationInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final correlationId = 'req_${DateTime.now().millisecondsSinceEpoch}';
    options.headers['X-Correlation-ID'] = correlationId;
    options.headers['X-App-Platform'] = 'flutter-mobile';
    options.headers['X-App-Version'] = '1.0.0';
    handler.next(options);
  }
}
