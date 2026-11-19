import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';

/// Application Shell composing bottom navigation and nested route stacks.
///
/// Bottom nav icons match design asset d3ddcc41:
/// selected Início = filled house; idle Viagens/Notificações/Perfil =
/// outlined suitcase / bell / person on a white bar with a thin top hairline.
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: TwoGoBottomNavigation(
        selectedIndex: navigationShell.currentIndex,
        onSelected: _onTabSelected,
        items: const [
          TwoGoBottomNavigationItem(
            // Filled house when selected (design d3ddcc41).
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
            semanticLabel: 'Aba Início',
          ),
          TwoGoBottomNavigationItem(
            // Outlined suitcase (Material card_travel).
            icon: Icon(Icons.card_travel_outlined),
            selectedIcon: Icon(Icons.card_travel),
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
  }
}
