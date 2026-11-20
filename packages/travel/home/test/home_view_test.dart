import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';
import 'package:twogo_home/twogo_home.dart';
import 'package:twogo_security/twogo_security.dart';
import 'package:twogo_session/twogo_session.dart';

class _MemoryTokenStorage implements TokenStorage {
  AuthTokens? _tokens;

  @override
  Future<void> clearTokens() async => _tokens = null;

  @override
  Future<AuthTokens?> readTokens() async => _tokens;

  @override
  Future<void> saveTokens(AuthTokens tokens) async => _tokens = tokens;
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required Size size,
  required HomeCubit homeCubit,
  required SessionCubit sessionCubit,
  ValueChanged<HomeDestination>? onDestinationSelected,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        theme: TwoGoTheme.light,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SessionCubit>.value(value: sessionCubit),
            BlocProvider<HomeCubit>.value(value: homeCubit),
          ],
          child: HomeView(
            onCreateItinerary: () {},
            onAccessItineraries: () {},
            onProfileTap: () {},
            onDestinationSelected: onDestinationSelected,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionCubit sessionCubit;

  setUp(() {
    LocalHomeContentRepository.usePackageAssetPrefix = false;
    sessionCubit = SessionCubit(tokenStorage: _MemoryTokenStorage());
  });

  tearDown(() async {
    LocalHomeContentRepository.usePackageAssetPrefix = true;
    await sessionCubit.close();
  });

  testWidgets('guest home shows silhouette CTAs and destinations section', (
    tester,
  ) async {
    final homeCubit = HomeCubit(
      repository: LocalHomeContentRepository(forceInitialsOnly: true),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    await homeCubit.load(isAuthenticated: false);

    await _pumpHome(
      tester,
      size: const Size(390, 844),
      homeCubit: homeCubit,
      sessionCubit: sessionCubit,
    );

    expect(find.text('Criar novo roteiro'), findsOneWidget);
    expect(find.text('Acessar roteiros'), findsOneWidget);
    expect(find.textContaining('Destinos em alta'), findsOneWidget);
    expect(find.text('Capadócia'), findsWidgets);
    expect(homeCubit.state.profile.isAuthenticated, isFalse);
  });

  testWidgets('logged-in initials profile chip', (tester) async {
    sessionCubit.onAuthenticated(
      const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      'gustavo.vieira@2go.com',
    );

    final homeCubit = HomeCubit(
      repository: LocalHomeContentRepository(forceInitialsOnly: true),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    await homeCubit.load(
      isAuthenticated: true,
      userId: 'gustavo.vieira@2go.com',
    );

    await _pumpHome(
      tester,
      size: const Size(390, 844),
      homeCubit: homeCubit,
      sessionCubit: sessionCubit,
    );

    expect(homeCubit.state.profile.isAuthenticated, isTrue);
    expect(homeCubit.state.profile.hasPhoto, isFalse);
    expect(find.text('GV'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
  });

  testWidgets('logged-in photo profile uses chevron without initials text', (
    tester,
  ) async {
    sessionCubit.onAuthenticated(
      const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      'ana@2go.com',
    );

    final homeCubit = HomeCubit(
      repository: LocalHomeContentRepository(
        demoPhotoAssetPath: 'assets/destinations/demo-avatar.jpg',
      ),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    await homeCubit.load(isAuthenticated: true, userId: 'ana@2go.com');

    await _pumpHome(
      tester,
      size: const Size(360, 780),
      homeCubit: homeCubit,
      sessionCubit: sessionCubit,
    );

    expect(homeCubit.state.profile.hasPhoto, isTrue);
    expect(find.text('AN'), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
  });

  testWidgets('strip destination tap notifies selection for Onde prefill', (
    tester,
  ) async {
    HomeDestination? selected;
    final homeCubit = HomeCubit(
      repository: LocalHomeContentRepository(forceInitialsOnly: true),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    await homeCubit.load(isAuthenticated: false);

    await _pumpHome(
      tester,
      size: const Size(390, 844),
      homeCubit: homeCubit,
      sessionCubit: sessionCubit,
      onDestinationSelected: (destination) => selected = destination,
    );

    await tester.ensureVisible(find.text('Capadócia').last);
    await tester.tap(find.text('Capadócia').last);
    await tester.pump();

    expect(selected, isNotNull);
    expect(selected!.id, 'capadocia');
    expect(selected!.name, 'Capadócia');
    expect(homeCubit.state.heroIndex, 0);
  });

  testWidgets('hero destination tap notifies selection for Onde prefill', (
    tester,
  ) async {
    HomeDestination? selected;
    final homeCubit = HomeCubit(
      repository: LocalHomeContentRepository(forceInitialsOnly: true),
      autoAdvance: false,
    );
    addTearDown(homeCubit.close);
    await homeCubit.load(isAuthenticated: false);
    homeCubit.selectDestination('rio-de-janeiro');

    await _pumpHome(
      tester,
      size: const Size(390, 844),
      homeCubit: homeCubit,
      sessionCubit: sessionCubit,
      onDestinationSelected: (destination) => selected = destination,
    );

    // Tap upper half of the hero PageView (above CTA sheet overlap).
    final hero = find.byType(PageView);
    expect(hero, findsOneWidget);
    await tester.tapAt(tester.getCenter(hero) - const Offset(0, 80));
    await tester.pump();

    expect(selected, isNotNull);
    expect(selected!.id, 'rio-de-janeiro');
    expect(selected!.name, 'Rio de Janeiro');
    expect(selected!.country, 'Brasil');
  });
}
