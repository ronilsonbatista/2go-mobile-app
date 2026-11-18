import '../models/home_destination.dart';
import '../models/home_profile.dart';

/// Facade for Home content (local stub, remote Core, or fallback composite).
abstract class HomeContentRepository {
  Future<List<HomeDestination>> fetchDestinations();

  /// Resolves avatar data for the Home chip.
  ///
  /// [isAuthenticated] / [userId] come from [SessionCubit].
  /// When Core exposes photo URL, implementations should return it here.
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  });
}
