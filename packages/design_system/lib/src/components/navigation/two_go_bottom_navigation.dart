import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/spacing.dart';
import '../../tokens/typography.dart';
import '../../accessibility/twogo_touch_target.dart';

/// Item descriptor for [TwoGoBottomNavigation].
class TwoGoBottomNavigationItem {
  const TwoGoBottomNavigationItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.semanticLabel,
    this.badge,
  });

  final Widget icon;
  final Widget? selectedIcon;
  final String label;
  final String? semanticLabel;
  final Widget? badge;
}

/// A clean, generic bottom navigation bar primitive for app shell layout.
class TwoGoBottomNavigation extends StatelessWidget {
  const TwoGoBottomNavigation({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  final List<TwoGoBottomNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedItemColor ?? TwoGoColors.contentPrimary;
    final inactiveColor = unselectedItemColor ?? TwoGoColors.contentSecondary;

    return Container(
      decoration: const BoxDecoration(
        color: TwoGoColors.surfacePrimary,
        border: Border(
          top: BorderSide(color: TwoGoColors.borderDefault, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == selectedIndex;

              final currentIcon = isSelected && item.selectedIcon != null
                  ? item.selectedIcon!
                  : item.icon;

              final iconColor = isSelected ? activeColor : inactiveColor;

              return Expanded(
                child: TwoGoTouchTarget(
                  minWidth: 48,
                  minHeight: 48,
                  child: InkWell(
                    onTap: () => onSelected(index),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Semantics(
                      selected: isSelected,
                      button: true,
                      label: item.semanticLabel ?? item.label,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconTheme(
                                data: IconThemeData(color: iconColor, size: 24),
                                child: currentIcon,
                              ),
                              if (item.badge != null)
                                Positioned(
                                  top: -4,
                                  right: -8,
                                  child: item.badge!,
                                ),
                            ],
                          ),
                          const SizedBox(height: TwoGoSpacing.xxs),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TwoGoTypography.labelSmall.copyWith(
                              color: isSelected ? activeColor : inactiveColor,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
