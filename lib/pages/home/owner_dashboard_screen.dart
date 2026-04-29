import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/owner_add_property_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

import '../../app/property/booking_request/booking_request_models.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';
import '../../app/property/my_properties/my_properties_models.dart';
import '../../app/property/owner_dashboard/owner_dashboard_controller.dart';
import 'owner_booking_request_details_screen.dart';
import 'owner_my_properties_screen.dart';
import 'owner_property_details_screen.dart';

class HomeUOwnerDashboardScreen extends StatefulWidget {
  const HomeUOwnerDashboardScreen({
    super.key,
    this.ownerName = 'Owner',
    this.showBottomNavigationBar = true,
    this.onNavigateToTab,
  });

  final String ownerName;
  final bool showBottomNavigationBar;
  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomeUOwnerDashboardScreen> createState() => _HomeUOwnerDashboardScreenState();
}

class _HomeUOwnerDashboardScreenState extends State<HomeUOwnerDashboardScreen> {
  int _selectedNavIndex = 0;
  late final OwnerDashboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OwnerDashboardController();
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      bottomNavigationBar: widget.showBottomNavigationBar
          ? HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerMyPropertiesScreen()));
            return;
          }
          if (index == 2) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerBookingRequestsScreen()));
            return;
          }
          if (index == 3) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAnalyticsScreen()));
            return;
          }
          if (index == 4) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUConversationListScreen()));
            return;
          }
          if (index == 5) {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUProfileScreen(role: HomeURole.owner)));
            return;
          }
          setState(() {
            _selectedNavIndex = index;
          });
        },
      )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadDashboard,
          color: context.homeuAccent,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: context.homeuAccent),
                );
              }

              if (_controller.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 16),
                      Text(_controller.errorMessage!),
                      TextButton(
                        onPressed: _controller.loadDashboard,
                        child: Text(context.l10n.ownerRequestsRetry),
                      ),
                    ],
                  ),
                );
              }

              final data = _controller.dashboardData!;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ownerGreeting(data.ownerName),
                      style: TextStyle(
                        color: context.homeuAccent,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.ownerDashboardSubtitle,
                      style: TextStyle(
                        color: context.homeuSecondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAddPropertyScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.homeuAccent,
                          foregroundColor: context.colors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.add_business_rounded),
                        label: Text(context.l10n.ownerAddProperty),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.homeuCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.homeuCardShadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
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
                                  context.l10n.ownerMonthlyEarnings,
                                  style: TextStyle(
                                    color: context.homeuMutedText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  context.l10n.paymentAmountRm(
                                    data.totalEarnings.toStringAsFixed(0),
                                  ),
                                  style: TextStyle(
                                    color: context.homeuAccent,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.trending_up_rounded,
                            color: context.homeuSuccess,
                            size: 34,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.ownerQuickStats,
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
                            label: context.l10n.ownerActiveListings,
                            value: '${data.activeListings}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OwnerStatCard(
                            label: context.l10n.ownerPendingRequests,
                            value: '${data.pendingRequests}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OwnerStatCard(
                            label: context.l10n.ownerOccupancy,
                            value: data.occupancyRate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.ownerRecentProperties,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (data.recentProperties.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.homeuSoftBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 48,
                              color: context.homeuMutedText,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.ownerNoProperties,
                              style: TextStyle(
                                color: context.homeuMutedText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HomeUOwnerAddPropertyScreen()));
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(context.l10n.ownerAddFirstProperty),
                              style: TextButton.styleFrom(
                                foregroundColor: context.homeuAccent,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.recentProperties.map((prop) {
                        final propertyModel = OwnerPropertyModel.fromJson(prop);

                        return _OwnerPropertyCard(
                          propertyName: propertyModel.title.isEmpty
                              ? context.l10n.ownerUntitledProperty
                              : propertyModel.title,
                          location: propertyModel.locationArea,
                          status: propertyModel.displayStatus,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => HomeUOwnerPropertyDetailsScreen(
                                  property: propertyModel,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                    const SizedBox(height: 12),

                    Text(
                      context.l10n.ownerRecentBookingRequests,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (data.recentRequests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.homeuSoftBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: context.homeuMutedText,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.ownerNoBookingRequests,
                              style: TextStyle(
                                color: context.homeuMutedText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.recentRequests.map((req) => _RequestCard(
                        requestKey: Key('req_${req['id']}'),
                        tenantName: req['tenantName'],
                        tenantProfileUrl: req['profile_image_url'],
                        propertyName: req['propertyName'],
                        status: req['status'],
                        onTap: () {
                          final requestModel = BookingRequestModel(
                            id: req['id']?.toString() ?? '',
                            propertyId: req['propertyId']?.toString() ?? '',
                            ownerId: req['ownerId']?.toString() ?? '',
                            tenantId: req['tenantId']?.toString() ?? '',
                            propertyTitle:
                                req['propertyName']?.toString() ??
                                context.l10n.ownerUnknownProperty,
                            monthlyPrice: req['monthlyPrice'] as num? ?? 0,
                            tenantName: req['tenantName']?.toString() ??
                                context.l10n.ownerUnknownTenant,
                            tenantProfileUrl: req['profile_image_url'] as String?,
                            tenantPhone: req['tenantPhone']?.toString() ?? '',
                            tenantEmail: req['tenantEmail']?.toString() ?? '',
                            startDate: req['startDate'] as DateTime?,
                            durationMonths: req['durationMonths'] as int? ?? 1,
                            status:
                                req['status']?.toString() ?? 'Pending',
                          );

                          final bookingController = BookingRequestsController();

                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => HomeUOwnerBookingRequestDetailsScreen(
                                request: requestModel,
                                controller: bookingController,
                              ),
                            ),
                          ).then((_) => _controller.loadDashboard());
                        },
                      )),

                    const SizedBox(height: 16),

                    Text(
                      context.l10n.ownerRecentViewingRequests,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (data.recentViewingRequests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.homeuSoftBorder),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 48,
                              color: context.homeuMutedText,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.ownerNoViewingRequests,
                              style: TextStyle(
                                color: context.homeuMutedText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...data.recentViewingRequests.map((req) => _ViewingRequestCard(
                        requestKey: Key('view_${req['id']}'),
                        tenantName: req['tenantName'],
                        tenantProfileUrl: req['profile_image_url'],
                        propertyName: req['propertyName'],
                        status: req['status'],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeUOwnerBookingRequestsScreen(
                                initialTabIndex: 1,
                              ),
                            ),
                          ).then((_) => _controller.loadDashboard());
                        },
                      )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
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
            style: TextStyle(
              color: context.homeuAccent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.homeuMutedText,
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
    required this.status,
    this.onTap,
  });

  final String propertyName;
  final String location;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBgColor;

    if (status == 'Draft') {
      statusColor = context.colors.tertiary;
      statusBgColor = context.colors.tertiary.withValues(alpha: 0.12);
    } else if (status == 'Booked') {
      statusColor = context.homeuSuccess;
      statusBgColor = context.homeuSuccess.withValues(alpha: 0.12);
    } else if (status == 'Expiring Soon') {
      statusColor = context.colors.tertiary;
      statusBgColor = context.colors.tertiary.withValues(alpha: 0.12);
    } else if (status == 'Occupied') {
      statusColor = context.homeuSuccess;
      statusBgColor = context.homeuSuccess.withValues(alpha: 0.12);
    } else {
      statusColor = context.homeuAccent;
      statusBgColor = context.homeuAccent.withValues(alpha: 0.12);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.homeuCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: context.homeuCardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.homeuAccent.withValues(alpha: 0.12),
              child: Icon(
                Icons.apartment_rounded,
                color: context.homeuAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyName,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    location,
                    style: TextStyle(
                      color: context.homeuMutedText,
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
                color: statusBgColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.requestKey,
    required this.tenantName,
    this.tenantProfileUrl,
    required this.propertyName,
    required this.status,
    required this.onTap,
  });

  final Key requestKey;
  final String tenantName;
  final String? tenantProfileUrl;
  final String propertyName;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending' || status == 'Pending Decision' || status == 'Awaiting Response';
    final isApproved = status == 'Approved';

    Color badgeColor;
    Color textColor;

    if (isPending) {
      badgeColor = context.colors.tertiary.withValues(alpha: 0.12);
      textColor = context.colors.tertiary;
    } else if (isApproved) {
      badgeColor = context.homeuSuccess.withValues(alpha: 0.12);
      textColor = context.homeuSuccess;
    } else {
      badgeColor = context.colors.error.withValues(alpha: 0.12);
      textColor = context.colors.error;
    }

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
              color: context.homeuCardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  backgroundImage: (tenantProfileUrl != null && tenantProfileUrl!.isNotEmpty)
                      ? NetworkImage(tenantProfileUrl!)
                      : null,
                  child: (tenantProfileUrl == null || tenantProfileUrl!.isEmpty)
                      ? Icon(
                          Icons.person_rounded,
                          color: context.homeuAccent,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenantName,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.ownerPropertyLabel,
              style: TextStyle(
                color: context.homeuMutedText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              propertyName,
              style: TextStyle(
                color: context.homeuPrimaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.homeuAccent,
                  size: 20,
                ),
                const SizedBox(width: 2),
                Text(
                  context.l10n.ownerTapToReviewRequest,
                  style: TextStyle(
                    color: context.homeuAccent,
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

class _ViewingRequestCard extends StatelessWidget {
  const _ViewingRequestCard({
    required this.requestKey,
    required this.tenantName,
    this.tenantProfileUrl,
    required this.propertyName,
    required this.status,
    required this.onTap,
  });

  final Key requestKey;
  final String tenantName;
  final String? tenantProfileUrl;
  final String propertyName;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending' || status == 'Pending Decision';
    final isApproved = status == 'Approved';

    Color badgeColor;
    Color textColor;

    if (isPending) {
      badgeColor = context.colors.tertiary.withValues(alpha: 0.12);
      textColor = context.colors.tertiary;
    } else if (isApproved) {
      badgeColor = context.homeuSuccess.withValues(alpha: 0.12);
      textColor = context.homeuSuccess;
    } else {
      badgeColor = context.colors.surfaceContainerHighest;
      textColor = context.homeuMutedText;
    }

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
              color: context.homeuCardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.surfaceContainerHighest,
                  backgroundImage: (tenantProfileUrl != null && tenantProfileUrl!.isNotEmpty)
                      ? NetworkImage(tenantProfileUrl!)
                      : null,
                  child: (tenantProfileUrl == null || tenantProfileUrl!.isEmpty)
                      ? Icon(
                          Icons.person_rounded,
                          color: context.homeuAccent,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tenantName,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.ownerPropertyLabel,
              style: TextStyle(
                color: context.homeuMutedText,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              propertyName,
              style: TextStyle(
                color: context.homeuPrimaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: context.homeuAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.ownerTapToReviewViewing,
                  style: TextStyle(
                    color: context.homeuAccent,
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