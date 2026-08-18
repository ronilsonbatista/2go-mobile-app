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
        !_shouldSkipJwtRefresh(requestOptions) &&
        _refreshCoordinator != null) {
      try {
        final newTokens = await _refreshCoordinator.handleRefresh();

        requestOptions.headers['Authorization'] =
            'Bearer ${newTokens.accessToken}';

        final client = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
        final clonedResponse = await client.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );

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
    return _guestPaths.any((p) => options.path.contains(p));
  }

  bool _shouldSkipJwtRefresh(RequestOptions options) {
    if (options.extra['skipAuthRefresh'] == true) return true;
    return _isUnprotectedPath(options.path) || _isGuestPath(options);
  }
}
