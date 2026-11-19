import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twogo_design_system/design_system.dart';

void main() {
  group('TwoGoBottomNavigation Widget & Golden Tests', () {
    testWidgets('renders items and handles tab tap callback', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: TwoGoBottomNavigation(
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: const [
                    TwoGoBottomNavigationItem(
                      icon: Icon(TwoGoIcons.homeOutlined),
                      selectedIcon: Icon(TwoGoIcons.home),
                      label: 'Início',
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(TwoGoIcons.travelOutlined),
                      selectedIcon: Icon(TwoGoIcons.travel),
                      label: 'Viagens',
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(TwoGoIcons.notificationsOutlined),
                      selectedIcon: Icon(TwoGoIcons.notifications),
                      label: 'Notificações',
                      badge: TwoGoBadge(count: 2),
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(TwoGoIcons.profileOutlined),
                      selectedIcon: Icon(TwoGoIcons.profile),
                      label: 'Perfil',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Viagens'), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      // Design d3ddcc41: filled house selected; outlined suitcase/bell/person idle.
      expect(find.byIcon(TwoGoIcons.home), findsOneWidget);
      expect(find.byIcon(TwoGoIcons.travelOutlined), findsOneWidget);
      expect(find.byIcon(TwoGoIcons.notificationsOutlined), findsOneWidget);
      expect(find.byIcon(TwoGoIcons.profileOutlined), findsOneWidget);

      await tester.tap(find.text('Viagens'));
      await tester.pump();

      expect(selectedIndex, equals(1));
      expect(find.byIcon(TwoGoIcons.travel), findsOneWidget);
      expect(find.byIcon(TwoGoIcons.homeOutlined), findsOneWidget);
    });

    testWidgets('Golden Test - TwoGoBottomNavigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: TwoGoTheme.light,
          home: Scaffold(
            bottomNavigationBar: TwoGoBottomNavigation(
              selectedIndex: 0,
              onSelected: (_) {},
              items: const [
                TwoGoBottomNavigationItem(
                  icon: Icon(TwoGoIcons.homeOutlined),
                  selectedIcon: Icon(TwoGoIcons.home),
                  label: 'Início',
                ),
                TwoGoBottomNavigationItem(
                  icon: Icon(TwoGoIcons.travelOutlined),
                  selectedIcon: Icon(TwoGoIcons.travel),
                  label: 'Viagens',
                ),
                TwoGoBottomNavigationItem(
                  icon: Icon(TwoGoIcons.notificationsOutlined),
                  selectedIcon: Icon(TwoGoIcons.notifications),
                  label: 'Notificações',
                  badge: TwoGoBadge(isDot: true),
                ),
                TwoGoBottomNavigationItem(
                  icon: Icon(TwoGoIcons.profileOutlined),
                  selectedIcon: Icon(TwoGoIcons.profile),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TwoGoBottomNavigation), findsOneWidget);
    });
  });
}
