import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

class HomeUOwnerBottomNavigationBar extends StatelessWidget {
  const HomeUOwnerBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.sizeOf(context).width <= 400;
    final t = context.l10n;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: isCompact ? 72 : 76,
        backgroundColor: context.homeuCard,
        indicatorColor: context.homeuAccent.withValues(
          alpha: context.isDarkMode ? 0.34 : 0.18,
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final bool isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: isCompact ? 21 : 22,
            color: isSelected ? context.homeuAccent : context.homeuMutedText,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final bool isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: isCompact ? 10 : 11,
            height: 1.15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? context.homeuAccent : context.homeuMutedText,
          );
        }),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: t.ownerNavDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_work_outlined),
            selectedIcon: const Icon(Icons.home_work_rounded),
            label: isCompact ? 'My Properties' : 'Properties',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: t.ownerNavRequests,
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: t.ownerNavAnalytics,
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: t.navProfile,
          ),
        ],
      ),
    );
  }
}
