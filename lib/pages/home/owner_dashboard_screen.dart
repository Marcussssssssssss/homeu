import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/owner_add_property_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerDashboardScreen extends StatefulWidget {
  const HomeUOwnerDashboardScreen({super.key});

  @override
  State<HomeUOwnerDashboardScreen> createState() =>
      _HomeUOwnerDashboardScreenState();
}

class _HomeUOwnerDashboardScreenState extends State<HomeUOwnerDashboardScreen> {
  int _selectedNavIndex = 0;
  late final HomeUProfileController _profileController;

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
        role: HomeURole.owner,
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
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
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
          bottomNavigationBar: HomeUOwnerBottomNavigationBar(
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeUOwnerBookingRequestsScreen(),
                  ),
                );
                return;
              }

              if (index == 3) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeUOwnerAnalyticsScreen(),
                  ),
                );
                return;
              }

              if (index == 4) {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        const HomeUProfileScreen(role: HomeURole.owner),
                  ),
                );
                return;
              }

              setState(() {
                _selectedNavIndex = index;
              });
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingText,
                    key: const Key('owner_greeting_text'),
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.ownerDashboardSubtitle,
                    style: TextStyle(
                      color: context.homeuMutedText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('add_property_button'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HomeUOwnerAddPropertyScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.homeuAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      icon: const Icon(Icons.add_business_rounded),
                      label: Text(t.ownerAddProperty),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    key: const Key('earnings_summary_card'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.homeuCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.homeuAccent.withValues(alpha: 0.14),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.ownerMonthlyEarnings,
                                style: TextStyle(
                                  color: Color(0xFF667896),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'RM 12,480',
                                style: TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.trending_up_rounded,
                          color: Color(0xFF10B981),
                          size: 34,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    t.ownerQuickStats,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _OwnerStatCard(
                          label: t.ownerActiveListings,
                          value: '8',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _OwnerStatCard(
                          label: t.ownerPendingRequests,
                          value: '5',
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _OwnerStatCard(
                          label: t.ownerOccupancy,
                          value: '91%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.ownerMyProperties,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _OwnerPropertyCard(
                    propertyName: 'Skyline Condo Suite',
                    location: 'Mont Kiara, Kuala Lumpur',
                    isOccupied: true,
                  ),
                  const _OwnerPropertyCard(
                    propertyName: 'Greenview Apartment',
                    location: 'Setapak, Kuala Lumpur',
                    isOccupied: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.ownerBookingRequests,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _RequestCard(
                    requestKey: const Key('owner_request_card_aisyah'),
                    tenantName: 'Aisyah Rahman',
                    propertyName: 'Skyline Condo Suite',
                    isAwaitingResponse: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const HomeUOwnerBookingRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _RequestCard(
                    requestKey: const Key('owner_request_card_daniel'),
                    tenantName: 'Daniel Lee',
                    propertyName: 'Greenview Apartment',
                    isAwaitingResponse: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const HomeUOwnerBookingRequestsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OwnerStatCard extends StatelessWidget {
  const _OwnerStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('owner_stat_$label'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667896),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerPropertyCard extends StatelessWidget {
  const _OwnerPropertyCard({
    required this.propertyName,
    required this.location,
    required this.isOccupied,
  });

  final String propertyName;
  final String location;
  final bool isOccupied;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0x1F1E3A8A),
            child: Icon(Icons.apartment_rounded, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyName,
                  style: const TextStyle(
                    color: Color(0xFF1F314F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF667896),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isOccupied
                  ? const Color(0xFFE6F7EF)
                  : const Color(0xFFFFF4DB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isOccupied
                  ? context.l10n.ownerOccupancyOccupied
                  : context.l10n.ownerOccupancyVacant,
              style: TextStyle(
                color: isOccupied
                    ? const Color(0xFF0F8A5F)
                    : const Color(0xFFB7791F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.requestKey,
    required this.tenantName,
    required this.propertyName,
    required this.isAwaitingResponse,
    required this.onTap,
  });

  final Key requestKey;
  final String tenantName;
  final String propertyName;
  final bool isAwaitingResponse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor = isAwaitingResponse
        ? const Color(0xFFE8F5EF)
        : const Color(0xFFEAF0FA);
    final Color textColor = isAwaitingResponse
        ? context.homeuSuccess
        : context.homeuAccent;

    return InkWell(
      key: requestKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: context.homeuCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.homeuAccent.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0x1F1E3A8A),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF1E3A8A),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenantName,
                    style: const TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAwaitingResponse
                        ? context.l10n.ownerRequestStatusAwaitingResponse
                        : context.l10n.ownerRequestStatusNewRequest,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.ownerPropertyLabel,
              style: TextStyle(
                color: Color(0xFF667896),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              propertyName,
              style: const TextStyle(
                color: Color(0xFF1F314F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF1E3A8A),
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  context.l10n.ownerTapToReviewRequest,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
