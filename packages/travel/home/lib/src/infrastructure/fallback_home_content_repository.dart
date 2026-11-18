import '../domain/models/home_destination.dart';
import '../domain/models/home_profile.dart';
import '../domain/repositories/home_content_repository.dart';

/// Prefers [remote] when Core is reachable; otherwise uses [fallback] stub.
///
/// Staging may still need migrate+seed — the app stays usable with local
/// destinations and email-derived initials until then.
class FallbackHomeContentRepository implements HomeContentRepository {
  FallbackHomeContentRepository({
    required HomeContentRepository remote,
    required HomeContentRepository fallback,
  }) : _remote = remote,
       _fallback = fallback;

  final HomeContentRepository _remote;
  final HomeContentRepository _fallback;

  @override
  Future<List<HomeDestination>> fetchDestinations() async {
    try {
      final items = await _remote.fetchDestinations();
      if (items.isEmpty) {
        return _fallback.fetchDestinations();
      }
      return items;
    } catch (_) {
      return _fallback.fetchDestinations();
    }
  }

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) {
      return HomeProfile.guest();
    }

    try {
      return await _remote.resolveProfile(
        isAuthenticated: isAuthenticated,
        userId: userId,
      );
    } catch (_) {
      return _fallback.resolveProfile(
        isAuthenticated: isAuthenticated,
        userId: userId,
      );
    }
  }
}
