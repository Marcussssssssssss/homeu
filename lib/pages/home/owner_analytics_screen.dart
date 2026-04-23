import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_my_properties_screen.dart';
import '../../app/property/owner_analytics/owner_analytics_models.dart';
import '../../app/property/owner_analytics/owner_analytics_controller.dart';
import 'owner_dashboard_screen.dart';

class HomeUOwnerAnalyticsScreen extends StatefulWidget {
  const HomeUOwnerAnalyticsScreen({
    super.key,
    this.showBottomNavigationBar = true,
  });

  final bool showBottomNavigationBar;

  @override
  State<HomeUOwnerAnalyticsScreen> createState() =>
      _HomeUOwnerAnalyticsScreenState();
}

class _HomeUOwnerAnalyticsScreenState extends State<HomeUOwnerAnalyticsScreen> {
  int _selectedNavIndex = 3;
  late final OwnerAnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OwnerAnalyticsController();
    _controller.loadAnalytics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _monthLabel(BuildContext context, int month) {
    final t = context.l10n;
    switch (month) {
      case 1: return t.monthShortJan;
      case 2: return t.monthShortFeb;
      case 3: return t.monthShortMar;
      case 4: return t.monthShortApr;
      case 5: return t.monthShortMay;
      case 6: return t.monthShortJun;
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return month.toString();
    }
  }

  String _rentalTypeLabel(BuildContext context, OwnerRentalType type) {
    final t = context.l10n;
    switch (type) {
      case OwnerRentalType.condo: return t.rentalTypeCondo;
      case OwnerRentalType.apartment: return t.rentalTypeApartment;
      case OwnerRentalType.room: return t.rentalTypeRoom;
      case OwnerRentalType.landed: return t.rentalTypeLanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.ownerAnalyticsTitle),
        backgroundColor: context.colors.surface,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: widget.showBottomNavigationBar
          ? HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == _selectedNavIndex) return;

          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeUOwnerDashboardScreen()),
                  (route) => false,
            );
            return;
          }
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerMyPropertiesScreen()),
            );
            return;
          }
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerBookingRequestsScreen()),
            );
            return;
          }
          if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomeUConversationListScreen()),
            );
            return;
          }
          if (index == 5) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomeUProfileScreen(role: HomeURole.owner)),
            );
            return;
          }
        },
      )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.loadAnalytics,
          color: context.homeuAccent,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading) {
                return Center(child: CircularProgressIndicator(color: context.homeuAccent));
              }

              if (_controller.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 40),
                      const SizedBox(height: 16),
                      Text(_controller.errorMessage!),
                      TextButton(
                        onPressed: _controller.loadAnalytics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final data = _controller.data!;

              // Calculate max value for the bar chart scaling
              double maxMonthlyValue = 1.0;
              if (data.monthlyEarnings.isNotEmpty) {
                maxMonthlyValue = data.monthlyEarnings.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                if (maxMonthlyValue == 0) maxMonthlyValue = 1.0; // Prevent divide by zero
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ownerAnalyticsSubtitle,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _OwnerAnalyticsStatCard(
                            label: context.l10n.ownerStatNetEarnings,
                            value: 'RM ${data.netEarnings.toStringAsFixed(0)}',
                            keyValue: const Key('owner_stat_net_earnings'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OwnerAnalyticsStatCard(
                            label: context.l10n.ownerOccupancy,
                            value: data.occupancyRate,
                            keyValue: const Key('owner_stat_occupancy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _OwnerAnalyticsStatCard(
                            label: context.l10n.ownerNavRequests,
                            value: '${data.totalRequests}',
                            keyValue: const Key('owner_stat_requests'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      key: const Key('monthly_earnings_bar_chart'),
                      padding: const EdgeInsets.all(14),
                      decoration: _cardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.ownerMonthlyEarnings,
                            style: TextStyle(
                              color: context.homeuPrimaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: data.monthlyEarnings
                                  .map(
                                    (entry) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: 130 * (entry.value / maxMonthlyValue),
                                              decoration: BoxDecoration(
                                                color: context.homeuAccent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _monthLabel(context, entry.month),
                                          style: TextStyle(
                                            color: context.homeuMutedText,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      key: const Key('rental_type_pie_chart'),
                      padding: const EdgeInsets.all(14),
                      decoration: _cardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.ownerRentalTypeDistribution,
                            style: TextStyle(
                              color: context.homeuPrimaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 130,
                                height: 130,
                                child: CustomPaint(
                                  painter: _PieChartPainter(data.rentalDistribution),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  children: data.rentalDistribution
                                      .map(
                                        (slice) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: slice.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${_rentalTypeLabel(context, slice.type)} (${slice.percent}%)',
                                              style: TextStyle(
                                                color: context.homeuPrimaryText,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.homeuCard,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: context.homeuAccent.withValues(alpha: 0.14),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _OwnerAnalyticsStatCard extends StatelessWidget {
  const _OwnerAnalyticsStatCard({
    required this.label,
    required this.value,
    required this.keyValue,
  });

  final String label;
  final String value;
  final Key keyValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyValue,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              fontSize: 15,
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

class _PieChartPainter extends CustomPainter {
  _PieChartPainter(this.slices);

  final List<RentalTypeData> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, item) => sum + item.percent);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.percent / total) * (2 * math.pi);
      paint.color = slice.color;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    canvas.drawCircle(
      center,
      radius * 0.42,
      Paint()..color = const Color(0xFFF6F8FC),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}