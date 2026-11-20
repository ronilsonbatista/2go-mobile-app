import 'package:dio/dio.dart';

/// Unwraps Core's `{ success, data, timestamp }` envelope so generated API
/// clients receive the inner `data` payload (or the original body when absent).
class ApiEnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    // Dio JSON maps are often Map<String, Object> / Map<dynamic, dynamic>,
    // not Map<String, dynamic> — use Map and normalize before reading keys.
    if (data is Map && data.containsKey('data')) {
      final map = Map<String, dynamic>.from(data);
      final success = map['success'];
      if (success == null || success == true) {
        response.data = map['data'];
      }
    }
    handler.next(response);
  }
}
