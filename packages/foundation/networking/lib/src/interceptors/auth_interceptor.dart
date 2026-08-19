import 'package:dio/dio.dart';
import 'package:twogo_security/twogo_security.dart';
import 'refresh_coordinator.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final RefreshCoordinator? _refreshCoordinator;

  static const List<String> _unprotectedPaths = [
    '/auth/login',
    '/auth/signup',
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/refresh',
    '/auth/password/forgot',
    '/auth/password/reset',
  ];

  static const List<String> _guestPaths = ['/planning-sessions'];

  AuthInterceptor({
    required TokenStorage tokenStorage,
    RefreshCoordinator? refreshCoordinator,
  }) : _tokenStorage = tokenStorage,
       _refreshCoordinator = refreshCoordinator;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;

    if (_isUnprotectedPath(path) || _isGuestPath(options)) {
      return handler.next(options);
    }

    final tokens = await _tokenStorage.readTokens();
    if (tokens != null && tokens.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestOptions = err.requestOptions;

    if (response?.statusCode == 401 &&
        !_shouldSkipJwtRefresh(err) &&
        _refreshCoordinator != null) {
      try {
        final newTokens = await _refreshCoordinator.handleRefresh();

        requestOptions.headers['Authorization'] =
            'Bearer ${newTokens.accessToken}';

        final fetcher = requestOptions.extra['dioFetch'] as Future<Response<dynamic>> Function(RequestOptions)? ??
            (opts) => Dio(BaseOptions(baseUrl: opts.baseUrl)).fetch<dynamic>(opts);

        final retryOptions = RequestOptions(
          path: requestOptions.path,
          method: requestOptions.method,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          headers: Map<String, dynamic>.from(requestOptions.headers),
          extra: Map<String, dynamic>.from(requestOptions.extra),
        );

        final clonedResponse = await fetcher(retryOptions);
        return handler.resolve(clonedResponse);
      } catch (refreshError) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _isUnprotectedPath(String path) {
    return _unprotectedPaths.any((p) => path.contains(p));
  }

  bool _isGuestPath(RequestOptions options) {
    if (options.extra['isGuestRequest'] == true) return true;
    if (options.extra['isDualAuthRequest'] == true ||
        options.path.contains('/claim')) {
      return false;
    }
    return _guestPaths.any((p) => options.path.contains(p));
  }

  bool _shouldSkipJwtRefresh(DioException err) {
    final options = err.requestOptions;
    if (options.extra['skipAuthRefresh'] == true) return true;
    if (_isUnprotectedPath(options.path)) return true;

    final data = err.response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'] as String?;
      if (code == 'PLANNING_JOURNEY_INVALID_TOKEN' ||
          code == 'PLANNING_JOURNEY_EXPIRED') {
        return true;
      }
    }

    if (options.path.contains('/claim') ||
        options.extra['isDualAuthRequest'] == true) {
      return false;
    }

    return _isGuestPath(options);
  }
}
