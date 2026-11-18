import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_home/twogo_home.dart';

class _FakeHomeRepository implements HomeContentRepository {
  _FakeHomeRepository({
    required this.destinations,
    required this.profile,
  });

  final List<HomeDestination> destinations;
  final HomeProfile profile;

  @override
  Future<List<HomeDestination>> fetchDestinations() async => destinations;

  @override
  Future<HomeProfile> resolveProfile({
    required bool isAuthenticated,
    String? userId,
  }) async {
    if (!isAuthenticated) return HomeProfile.guest();
    return profile;
  }
}

HomeDestination _dest(String id, {int order = 0}) {
  return HomeDestination(
    id: id,
    name: id,
    country: 'Brasil',
    heroAssetPath: 'assets/destinations/rio-de-janeiro.jpg',
    cardAssetPath: 'assets/destinations/rio-de-janeiro-card.jpg',
    sortOrder: order,
  );
}

void main() {
  group('HomeCubit', () {
    test('guest load has silhouette profile and destinations', () async {
      final cubit = HomeCubit(
        repository: _FakeHomeRepository(
          destinations: [_dest('a'), _dest('b', order: 1)],
          profile: HomeProfile.guest(),
        ),
        autoAdvance: false,
      );

      await cubit.load(isAuthenticated: false);

      expect(cubit.state.status, HomeStatus.ready);
      expect(cubit.state.destinations, hasLength(2));
      expect(cubit.state.profile.isAuthenticated, isFalse);
      expect(cubit.state.profile.hasPhoto, isFalse);
      expect(cubit.state.heroIndex, 0);
      await cubit.close();
    });

    test('logged-in with photo exposes hasPhoto', () async {
      final cubit = HomeCubit(
        repository: _FakeHomeRepository(
          destinations: [_dest('rio')],
          profile: HomeProfile.authenticated(
            displayName: 'Gustavo',
            photoAssetPath: 'assets/destinations/demo-avatar.jpg',
          ),
        ),
        autoAdvance: false,
      );

      await cubit.load(isAuthenticated: true, userId: 'gustavo@2go.com');

      expect(cubit.state.profile.isAuthenticated, isTrue);
      expect(cubit.state.profile.hasPhoto, isTrue);
      expect(cubit.state.profile.displayName, 'Gustavo');
      await cubit.close();
    });

    test('logged-in without photo uses initials', () async {
      final cubit = HomeCubit(
        repository: _FakeHomeRepository(
          destinations: [_dest('rio')],
          profile: HomeProfile.authenticated(displayName: 'Gustavo Vieira'),
        ),
        autoAdvance: false,
      );

      await cubit.load(isAuthenticated: true, userId: 'gv@2go.com');

      expect(cubit.state.profile.hasPhoto, isFalse);
      expect(cubit.state.profile.initials, 'GV');
      await cubit.close();
    });

    test('carousel next/previous wraps and selectDestination jumps', () async {
      final destinations = [
        _dest('capadocia', order: 0),
        _dest('rio', order: 1),
        _dest('ny', order: 2),
      ];
      final cubit = HomeCubit(
        repository: _FakeHomeRepository(
          destinations: destinations,
          profile: HomeProfile.guest(),
        ),
        autoAdvance: false,
      );

      await cubit.load(isAuthenticated: false);
      expect(cubit.state.heroIndex, 0);

      cubit.nextHero();
      expect(cubit.state.heroIndex, 1);
      expect(cubit.state.currentDestination?.id, 'rio');

      cubit.nextHero();
      cubit.nextHero();
      expect(cubit.state.heroIndex, 0);

      cubit.previousHero();
      expect(cubit.state.heroIndex, 2);

      cubit.selectDestination('rio');
      expect(cubit.state.heroIndex, 1);
      await cubit.close();
    });

    test('LocalHomeContentRepository catalog has ~10 destinations', () async {
      final repo = LocalHomeContentRepository(forceInitialsOnly: true);
      final items = await repo.fetchDestinations();
      expect(items.length, greaterThanOrEqualTo(10));

      final guest = await repo.resolveProfile(isAuthenticated: false);
      expect(guest.isAuthenticated, isFalse);

      final auth = await repo.resolveProfile(
        isAuthenticated: true,
        userId: 'gustavo.vieira@2go.app',
      );
      expect(auth.isAuthenticated, isTrue);
      expect(auth.hasPhoto, isFalse);
      expect(auth.initials, 'GV');
    });

    test('LocalHomeContentRepository can return demo photo', () async {
      final repo = LocalHomeContentRepository(
        demoPhotoAssetPath: 'assets/destinations/demo-avatar.jpg',
      );
      final auth = await repo.resolveProfile(
        isAuthenticated: true,
        userId: 'ana@2go.app',
      );
      expect(auth.hasPhoto, isTrue);
      expect(auth.photoAssetPath, 'assets/destinations/demo-avatar.jpg');
    });
  });
}
