import 'package:flutter/material.dart';
import 'package:twogo_design_system/design_system.dart';
import 'src/components_view.dart';
import 'src/foundations_view.dart';

void main() {
  runApp(const TwoGoDesignCatalogApp());
}

class TwoGoDesignCatalogApp extends StatelessWidget {
  const TwoGoDesignCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2GO Design System Catalog',
      theme: TwoGoTheme.light,
      darkTheme: TwoGoTheme.dark,
      themeMode: ThemeMode.light,
      home: const DesignCatalogHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DesignCatalogHome extends StatefulWidget {
  const DesignCatalogHome({super.key});

  @override
  State<DesignCatalogHome> createState() => _DesignCatalogHomeState();
}

class _DesignCatalogHomeState extends State<DesignCatalogHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TwoGoAppBar(
        title: _currentIndex == 0 ? 'Foundations' : 'Components',
        showBackButton: false,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [FoundationsCatalogView(), ComponentsCatalogView()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: TwoGoColors.neutral900,
        unselectedItemColor: TwoGoColors.contentSecondary,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.style_rounded),
            label: 'Foundations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_rounded),
            label: 'Components',
          ),
        ],
      ),
    );
  }
}
