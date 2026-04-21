import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';

class HomeUAppBottomNav extends StatelessWidget {
  const HomeUAppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: t.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.favorite_border_rounded),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: t.navFavorites,
        ),
        NavigationDestination(
          icon: const Icon(Icons.book_online_outlined),
          selectedIcon: const Icon(Icons.book_online_rounded),
          label: t.navBookings,
        ),
        const NavigationDestination(
          icon: Icon(Icons.visibility_outlined),
          selectedIcon: Icon(Icons.visibility_rounded),
          label: 'Viewings',
        ),
        const NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          selectedIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: t.navProfile,
        ),
      ],
    );
  }
}
