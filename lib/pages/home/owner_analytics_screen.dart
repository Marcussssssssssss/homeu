import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerAnalyticsScreen extends StatefulWidget {
  const HomeUOwnerAnalyticsScreen({super.key});

  @override
  State<HomeUOwnerAnalyticsScreen> createState() => _HomeUOwnerAnalyticsScreenState();
}

class _HomeUOwnerAnalyticsScreenState extends State<HomeUOwnerAnalyticsScreen> {
  int _selectedNavIndex = 3;

  static const List<_MonthlyEarning> _monthlyEarnings = [
    _MonthlyEarning('Jan', 7400),
    _MonthlyEarning('Feb', 8100),
    _MonthlyEarning('Mar', 9600),
    _MonthlyEarning('Apr', 11200),
    _MonthlyEarning('May', 12480),
    _MonthlyEarning('Jun', 10750),
  ];

  static const List<_RentalTypeSlice> _rentalTypeDistribution = [
    _RentalTypeSlice('Condo', 45, Color(0xFF1E3A8A)),
    _RentalTypeSlice('Apartment', 30, Color(0xFF10B981)),
    _RentalTypeSlice('Room', 15, Color(0xFFF59E0B)),
    _RentalTypeSlice('Landed', 10, Color(0xFF7C3AED)),
  ];

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
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Owner Analytics'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
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
                builder: (_) => const HomeUProfileScreen(
                  role: HomeURole.owner,
                  name: 'Nurul Huda',
                  email: 'owner@homeu.app',
                  phone: '+60 13 882 5560',
                ),
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
              const Text(
                'Performance overview for your rental business this month.',
                style: TextStyle(
                  color: Color(0xFF50617F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _OwnerAnalyticsStatCard(
                      label: 'Net Earnings',
                      value: 'RM 12,480',
                      keyValue: Key('owner_stat_net_earnings'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _OwnerAnalyticsStatCard(
                      label: 'Occupancy',
                      value: '91%',
                      keyValue: Key('owner_stat_occupancy'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _OwnerAnalyticsStatCard(
                      label: 'Requests',
                      value: '17',
                      keyValue: Key('owner_stat_requests'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                key: const Key('monthly_earnings_bar_chart'),
                padding: const EdgeInsets.all(14),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Earnings',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
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
                                              color: const Color(0xFF1E3A8A),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        entry.month,
                                        style: const TextStyle(
                                          color: Color(0xFF667896),
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
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rental Type Distribution',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
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
                                            '${slice.label} (${slice.percent}%)',
                                            style: const TextStyle(
                                              color: Color(0xFF1F314F),
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
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Occupancy Rate',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        minHeight: 10,
                        value: 0.91,
                        backgroundColor: Color(0xFFEAF0FA),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '91% of your listed units are currently occupied.',
                      style: TextStyle(
                        color: Color(0xFF667896),
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x141E3A8A),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1F1E3A8A)),
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

    canvas.drawCircle(center, radius * 0.42, Paint()..color = const Color(0xFFF6F8FC));
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _MonthlyEarning {
  const _MonthlyEarning(this.month, this.value);

  final String month;
  final int value;
}

class _RentalTypeSlice {
  const _RentalTypeSlice(this.label, this.percent, this.color);

  final String label;
  final int percent;
  final Color color;
}

