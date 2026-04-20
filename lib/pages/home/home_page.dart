import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/booking_history_screen.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUHomePage extends StatefulWidget {
  const HomeUHomePage({
    super.key,
    this.showNotificationBadge = true,
    this.showQrScanFab = true,
  });

  final bool showNotificationBadge;
  final bool showQrScanFab;

  @override
  State<HomeUHomePage> createState() => _HomeUHomePageState();
}

class _HomeUHomePageState extends State<HomeUHomePage> {
  int _selectedNavIndex = 0;
  late final HomeUProfileController _profileController;

  static const List<String> _categories = [
    'Room',
    'Whole Unit',
    'Condo',
    'Landed',
    'Apartment',
  ];

  final List<PropertyItem> _properties = const [
    PropertyItem(
      name: 'Skyline Condo Suite',
      location: 'Mont Kiara, Kuala Lumpur',
      pricePerMonth: 'RM 2,100 / month',
      rating: 4.8,
      accentColor: Color(0xFF1E3A8A),
      description:
          'A bright condo with modern finishing, full kitchen, and great ventilation. Ideal for professionals who need quick city access and a calm neighborhood.',
      ownerName: 'Nurul Huda',
      ownerRole: 'Verified Owner',
      photoColors: [Color(0xFF5D7FBF), Color(0xFF4A68A8), Color(0xFF2F4F8F)],
    ),
    PropertyItem(
      name: 'Cozy Student Room',
      location: 'SS15, Subang Jaya',
      pricePerMonth: 'RM 680 / month',
      rating: 4.5,
      accentColor: Color(0xFF10B981),
      description:
          'Comfortable private room with study desk and wardrobe. Located near campus with food courts and transit options within walking distance.',
      ownerName: 'Amir Rahman',
      ownerRole: 'Host',
      photoColors: [Color(0xFF4FAF95), Color(0xFF3D9B83), Color(0xFF2B7F6B)],
    ),
    PropertyItem(
      name: 'Family Apartment',
      location: 'Setapak, Kuala Lumpur',
      pricePerMonth: 'RM 1,450 / month',
      rating: 4.7,
      accentColor: Color(0xFF334155),
      description:
          'Spacious apartment suitable for families, featuring two bathrooms, secure access, and nearby schools, clinics, and supermarkets.',
      ownerName: 'Sarah Lim',
      ownerRole: 'Premium Owner',
      photoColors: [Color(0xFF586476), Color(0xFF495567), Color(0xFF374151)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    final authService = HomeUAuthService.instance;
    _profileController = HomeUProfileController(
      initialProfile: HomeUProfileData(
        userId: authService.currentUserId ?? '',
        fullName: '',
        email: authService.currentSession?.user.email ?? '',
        phoneNumber: '',
        role: HomeURole.tenant,
      ),
    );
    _profileController.loadProfile();
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  String _resolvedGreetingName(HomeUProfileData profile) {
    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = profile.email.trim();
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return AnimatedBuilder(
      animation: _profileController,
      builder: (context, _) {
        final greetingName = _resolvedGreetingName(_profileController.profile);
        final t = context.l10n;
        final greetingText = greetingName.isEmpty
            ? t.homeGreetingAnonymous
            : t.homeGreetingWithName(greetingName);

        return Scaffold(
          backgroundColor: context.colors.surface,
          floatingActionButton: widget.showQrScanFab
              ? FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: context.homeuAccent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(t.homeScanQr),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeUBookingHistoryScreen(),
                  ),
                );
                return;
              }

              if (index == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const HomeUProfileScreen(role: HomeURole.tenant),
                  ),
                );
                return;
              }

              setState(() {
                _selectedNavIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: t.navHome,
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: t.navFavorites,
              ),
              NavigationDestination(
                icon: Icon(Icons.book_online_outlined),
                selectedIcon: Icon(Icons.book_online_rounded),
                label: t.navBookings,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: t.navProfile,
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final horizontalPadding = (width * 0.06).clamp(16.0, 24.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    14,
                    horizontalPadding,
                    22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              greetingText,
                              style: TextStyle(
                                color: context.homeuPrimaryText,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  color: context.homeuAccent,
                                ),
                              ),
                              if (widget.showNotificationBadge)
                                const Positioned(
                                  right: 8,
                                  top: 9,
                                  child: _NotificationDot(),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.homeQuickSearchSubtitle,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: t.homeSearchHint,
                          hintStyle: TextStyle(color: context.homeuHelperText),
                          filled: true,
                          fillColor: context.homeuCard,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: const Icon(Icons.tune_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuSoftBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuSoftBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuAccent,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        t.homeCategories,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _CategoryChip(
                                    label: item,
                                    isSelected: item == 'Room',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.homeRecommendedProperties,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._properties.map(
                        (property) => _PropertyCard(
                          property: property,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HomeUPropertyDetailsScreen(
                                  property: property,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: context.homeuSuccess,
        shape: BoxShape.circle,
        border: Border.all(color: context.homeuCard, width: 1.4),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final accent = context.homeuAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? accent : context.homeuCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : accent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.onTap});

  final PropertyItem property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        key: Key('property_card_${property.name}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 148,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        property.photoColors.first.withValues(alpha: 0.9),
                        context.isDarkMode
                            ? const Color(0xFF243047)
                            : const Color(0xFFF0F5FF),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.homeuCard,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: property.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: context.homeuMutedText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            color: context.homeuSecondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        property.pricePerMonth,
                        style: TextStyle(
                          color: context.homeuPrice,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
