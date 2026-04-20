import 'package:flutter/material.dart';

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

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: isCompact ? 72 : 76,
        indicatorColor: const Color(0x1F1E3A8A),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final bool isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: isCompact ? 21 : 22,
            color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF5D6F8D),
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final bool isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: isCompact ? 10 : 11,
            height: 1.15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF5D6F8D),
          );
        }),
      ),
      child: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_work_outlined),
            selectedIcon: const Icon(Icons.home_work_rounded),
            label: isCompact ? 'My Properties' : 'Properties',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Requests',
          ),
          const NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Analytics',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

