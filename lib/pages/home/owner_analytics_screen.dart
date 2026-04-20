import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
<<<<<<< UserAuthentication
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
=======
import 'package:homeu/pages/home/conversation_list_screen.dart';
>>>>>>> main
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerAnalyticsScreen extends StatefulWidget {
  const HomeUOwnerAnalyticsScreen({super.key});

  @override
  State<HomeUOwnerAnalyticsScreen> createState() =>
      _HomeUOwnerAnalyticsScreenState();
}

class _HomeUOwnerAnalyticsScreenState extends State<HomeUOwnerAnalyticsScreen> {
  int _selectedNavIndex = 3;

  static const List<_MonthlyEarning> _monthlyEarnings = [
    _MonthlyEarning(1, 7400),
    _MonthlyEarning(2, 8100),
    _MonthlyEarning(3, 9600),
    _MonthlyEarning(4, 11200),
    _MonthlyEarning(5, 12480),
    _MonthlyEarning(6, 10750),
  ];

  static const List<_RentalTypeSlice> _rentalTypeDistribution = [
    _RentalTypeSlice(_OwnerRentalType.condo, 45, Color(0xFF1E3A8A)),
    _RentalTypeSlice(_OwnerRentalType.apartment, 30, Color(0xFF10B981)),
    _RentalTypeSlice(_OwnerRentalType.room, 15, Color(0xFFF59E0B)),
    _RentalTypeSlice(_OwnerRentalType.landed, 10, Color(0xFF7C3AED)),
  ];

  String _monthLabel(BuildContext context, int month) {
    final t = context.l10n;
    switch (month) {
      case 1:
        return t.monthShortJan;
      case 2:
        return t.monthShortFeb;
      case 3:
        return t.monthShortMar;
      case 4:
        return t.monthShortApr;
      case 5:
        return t.monthShortMay;
      case 6:
        return t.monthShortJun;
      default:
        return month.toString();
    }
  }

  String _rentalTypeLabel(BuildContext context, _OwnerRentalType type) {
    final t = context.l10n;
    switch (type) {
      case _OwnerRentalType.condo:
        return t.rentalTypeCondo;
      case _OwnerRentalType.apartment:
        return t.rentalTypeApartment;
      case _OwnerRentalType.room:
        return t.rentalTypeRoom;
      case _OwnerRentalType.landed:
        return t.rentalTypeLanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    final maxMonthlyValue = _monthlyEarnings
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.ownerAnalyticsTitle),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 0) {
            Navigator.of(context).pop();
          }
          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
<<<<<<< UserAuthentication
                builder: (_) => const HomeUProfileScreen(role: HomeURole.owner),
=======
                builder: (_) => const HomeUConversationListScreen(),
              ),
            );
          }
          if (index == 5) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUProfileScreen(
                  role: HomeURole.owner,
                  name: 'Nurul Huda',
                  email: 'owner@homeu.app',
                  phone: '+60 13 882 5560',
                ),
>>>>>>> main
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      value: 'RM 12,480',
                      keyValue: const Key('owner_stat_net_earnings'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OwnerAnalyticsStatCard(
                      label: context.l10n.ownerOccupancy,
                      value: '91%',
                      keyValue: const Key('owner_stat_occupancy'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _OwnerAnalyticsStatCard(
                      label: context.l10n.ownerNavRequests,
                      value: '17',
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
                        children: _monthlyEarnings
                            .map(
                              (entry) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height:
                                                130 *
                                                (entry.value / maxMonthlyValue),
                                            decoration: BoxDecoration(
                                              color: context.homeuAccent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                            )
                            .toList(),
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
                            painter: _PieChartPainter(_rentalTypeDistribution),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: _rentalTypeDistribution
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
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                key: const Key('occupancy_rate_progress'),
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.ownerOccupancyRate,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: 0.91,
                        backgroundColor: context.homeuSoftBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.homeuSuccess,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.ownerOccupancyRateDescription,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
          offset: Offset(0, 4),
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

  final List<_RentalTypeSlice> slices;

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

class _MonthlyEarning {
  const _MonthlyEarning(this.month, this.value);

  final int month;
  final int value;
}

enum _OwnerRentalType { condo, apartment, room, landed }

class _RentalTypeSlice {
  const _RentalTypeSlice(this.type, this.percent, this.color);

  final _OwnerRentalType type;
  final int percent;
  final Color color;
}
