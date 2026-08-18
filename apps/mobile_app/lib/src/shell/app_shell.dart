import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twogo_design_system/design_system.dart';

/// Application Shell composing bottom navigation and nested route stacks.
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
            icon: Icon(TwoGoIcons.homeOutlined),
            selectedIcon: Icon(TwoGoIcons.home),
            label: 'Início',
            semanticLabel: 'Aba Início',
          ),
          TwoGoBottomNavigationItem(
            icon: Icon(TwoGoIcons.travelOutlined),
            selectedIcon: Icon(TwoGoIcons.travel),
            label: 'Viagens',
            semanticLabel: 'Aba Viagens',
          ),
          TwoGoBottomNavigationItem(
            icon: Icon(TwoGoIcons.notificationsOutlined),
            selectedIcon: Icon(TwoGoIcons.notifications),
            label: 'Notificações',
            semanticLabel: 'Aba Notificações',
          ),
          TwoGoBottomNavigationItem(
            icon: Icon(TwoGoIcons.profileOutlined),
            selectedIcon: Icon(TwoGoIcons.profile),
            label: 'Perfil',
            semanticLabel: 'Aba Perfil',
          ),
        ],
      ),
    );
  }
}
