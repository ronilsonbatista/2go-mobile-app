import '../domain/models/home_crm_snapshot.dart';
import '../domain/models/home_destination.dart';
import '../domain/models/home_profile.dart';
import '../domain/repositories/home_content_repository.dart';

/// Local stub: ~10 destination assets until Core home carousel exists.
class LocalHomeContentRepository implements HomeContentRepository {
  LocalHomeContentRepository({
    this.demoPhotoAssetPath,
    this.forceInitialsOnly = false,
  });

  /// Optional asset for logged-in-with-photo layout QA (Home-10).
  final String? demoPhotoAssetPath;

  /// When true, authenticated profile never returns a photo (Home-11 initials).
  final bool forceInitialsOnly;

  static const String assetPackage = 'twogo_home';

  /// When `true` (default, production app), [AssetImage] uses [assetPackage].
  /// Package-under-test AssetManifest uses bare paths — set `false` in tests.
  static bool usePackageAssetPrefix = true;

  static const List<HomeDestination> catalog = [
    HomeDestination(
      id: 'capadocia',
      name: 'Capadócia',
      country: 'Turquia',
      heroAssetPath: 'assets/destinations/capadocia-wide.jpg',
      cardAssetPath: 'assets/destinations/capadocia.jpg',
      sortOrder: 0,
    ),
    HomeDestination(
      id: 'rio-de-janeiro',
      name: 'Rio de Janeiro',
      country: 'Brasil',
      heroAssetPath: 'assets/destinations/rio-de-janeiro.jpg',
      cardAssetPath: 'assets/destinations/rio-de-janeiro-card.jpg',
      sortOrder: 1,
    ),
    HomeDestination(
      id: 'nova-york',
      name: 'Nova York',
      country: 'EUA',
      heroAssetPath: 'assets/destinations/nova-york.jpg',
      cardAssetPath: 'assets/destinations/nova-york.jpg',
      sortOrder: 2,
    ),
    HomeDestination(
      id: 'lisboa',
      name: 'Lisboa',
      country: 'Portugal',
      heroAssetPath: 'assets/destinations/lisboa.jpg',
      cardAssetPath: 'assets/destinations/lisboa.jpg',
      sortOrder: 3,
    ),
    HomeDestination(
      id: 'paris',
      name: 'Paris',
      country: 'França',
      heroAssetPath: 'assets/destinations/paris.jpg',
      cardAssetPath: 'assets/destinations/paris.jpg',
      sortOrder: 4,
    ),
    HomeDestination(
      id: 'roma',
      name: 'Roma',
      country: 'Itália',
      heroAssetPath: 'assets/destinations/roma.jpg',
      cardAssetPath: 'assets/destinations/roma.jpg',
      sortOrder: 5,
    ),
    HomeDestination(
      id: 'londres',
      name: 'Londres',
      country: 'Reino Unido',
      heroAssetPath: 'assets/destinations/londres.jpg',
      cardAssetPath: 'assets/destinations/londres.jpg',
      sortOrder: 6,
    ),
    HomeDestination(
      id: 'barcelona',
      name: 'Barcelona',
      country: 'Espanha',
      heroAssetPath: 'assets/destinations/barcelona.jpg',
      cardAssetPath: 'assets/destinations/barcelona.jpg',
      sortOrder: 7,
    ),
    HomeDestination(
      id: 'amsterdam',
      name: 'Amsterdã',
      country: 'Holanda',
      heroAssetPath: 'assets/destinations/amsterdam.jpg',
      cardAssetPath: 'assets/destinations/amsterdam.jpg',
      sortOrder: 8,
    ),
    HomeDestination(
      id: 'toquio',
      name: 'Tóquio',
      country: 'Japão',
      heroAssetPath: 'assets/destinations/toquio.jpg',
      cardAssetPath: 'assets/destinations/toquio.jpg',
      sortOrder: 9,
    ),
  ];

  @override
  Future<List<HomeDestination>> fetchDestinations() async {
    final items = List<HomeDestination>.from(catalog)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) {
      return HomeProfile.guest();
    }

    final displayName = _displayNameFrom(userId);
    if (forceInitialsOnly ||
        demoPhotoAssetPath == null ||
        demoPhotoAssetPath!.isEmpty) {
      return HomeProfile.authenticated(displayName: displayName);
    }

    return HomeProfile.authenticated(
      displayName: displayName,
      photoAssetPath: demoPhotoAssetPath,
    );
  }

  @override
  Future<HomeCrmSnapshot> fetchCrmSnapshot({
    required bool isAuthenticated,
    String? userId,
  }) async {
    // Local stub has no paid trip — discovery Home only.
    return HomeCrmSnapshot.empty;
  }

  String _displayNameFrom(String? userId) {
    if (userId == null || userId.isEmpty) return 'Viajante';
    if (userId.contains('@')) {
      return userId.split('@').first;
    }
    return userId;
  }
}
