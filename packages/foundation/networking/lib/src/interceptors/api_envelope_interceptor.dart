import 'package:dio/dio.dart';

/// Unwraps Core's `{ success, data, timestamp }` envelope so generated API
/// clients receive the inner `data` payload (or the original body when absent).
class ApiEnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final success = data['success'];
      if (success == null || success == true) {
        response.data = data['data'];
      }
    }
    handler.next(response);
  }
}
