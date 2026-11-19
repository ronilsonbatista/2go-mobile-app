import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';

import '../router/app_router.dart';

/// Application Shell composing bottom navigation and nested route stacks.
///
/// Bottom nav icons match design asset d3ddcc41:
/// selected Início = filled house; idle Viagens/Notificações/Perfil =
/// outlined suitcase / bell / person on a white bar with a thin top hairline.
///
/// Product rule: Q&A Form Course (`/planning/*`) must never show this bar.
/// Full-screen routes use [AppRouter.rootNavigatorKey]; this shell also
/// nulls [bottomNavigationBar] whenever the top route is full-screen so the
/// bar cannot peek through an indexed shell still mounted underneath.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);

    return ListenableBuilder(
      listenable: router.routerDelegate,
      builder: (context, _) {
        final path =
            router.routerDelegate.currentConfiguration.uri.path;
        final hideTabBar = AppRouter.isFullScreenPath(path);

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: hideTabBar
              ? null
              : TwoGoBottomNavigation(
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _onTabSelected,
                  items: const [
                    TwoGoBottomNavigationItem(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: 'Início',
                      semanticLabel: 'Aba Início',
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(Icons.luggage_outlined),
                      selectedIcon: Icon(Icons.luggage),
                      label: 'Viagens',
                      semanticLabel: 'Aba Viagens',
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: 'Notificações',
                      semanticLabel: 'Aba Notificações',
                    ),
                    TwoGoBottomNavigationItem(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: 'Perfil',
                      semanticLabel: 'Aba Perfil',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
