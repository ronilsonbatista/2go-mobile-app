import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Application Shell — nested route stacks only.
///
/// Product rule: the app has **no** bottom tab bar (Início / Viagens /
/// Notificações / Perfil). Navigation uses in-page CTAs and routes
/// (`/app/home`, `/app/trips`, `/app/profile`, `/planning/wizard`, …).
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: null,
    );
  }
}
