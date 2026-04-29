import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

class HomeUAdminBottomNavigationBar extends StatelessWidget {
  const HomeUAdminBottomNavigationBar({
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
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded),
            label: context.l10n.adminNavDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.report_gmailerrorred_outlined),
            selectedIcon: const Icon(Icons.report_gmailerrorred_rounded),
            label: context.l10n.adminNavReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: context.l10n.adminNavChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_rounded),
            selectedIcon: const Icon(Icons.history_toggle_off_rounded),
            label: context.l10n.adminNavLogs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.l10n.adminNavProfile,
          ),
        ],
      ),
    );
  }
}
