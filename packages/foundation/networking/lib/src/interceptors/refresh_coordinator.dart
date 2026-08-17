import 'dart:async';
import 'package:twogo_security/twogo_security.dart';

typedef RefreshFunction = Future<AuthTokens> Function(String refreshToken);

class RefreshCoordinator {
  final TokenStorage _tokenStorage;
  final RefreshFunction _refreshFunction;

  Future<AuthTokens>? _refreshFuture;
  int _refreshCallCount = 0;

  RefreshCoordinator({
    required TokenStorage tokenStorage,
    required RefreshFunction refreshFunction,
  }) : _tokenStorage = tokenStorage,
       _refreshFunction = refreshFunction;

  int get refreshCallCount => _refreshCallCount;

  Future<AuthTokens> handleRefresh() {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }

    final completer = Completer<AuthTokens>();
    _refreshFuture = completer.future;

    _executeRefresh()
        .then((newTokens) {
          if (!completer.isCompleted) {
            completer.complete(newTokens);
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        })
        .whenComplete(() {
          _refreshFuture = null;
        });

    return completer.future;
  }

  Future<AuthTokens> _executeRefresh() async {
    _refreshCallCount++;

    final currentTokens = await _tokenStorage.readTokens();
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await _tokenStorage.clearTokens();
      throw Exception('No refresh token available');
    }

    try {
      final newTokens = await _refreshFunction(currentTokens.refreshToken);
      await _tokenStorage.saveTokens(newTokens);
      return newTokens;
    } catch (e) {
      await _tokenStorage.clearTokens();
      rethrow;
    }
  }
}
