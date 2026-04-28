import 'package:flutter/material.dart';

enum OwnerRentalType { condo, apartment, room, landed }

class OwnerAnalyticsData {
  final double netEarnings;
  final String occupancyRate;
  final int totalRequests;
  final List<MonthlyEarningData> monthlyEarnings;
  final List<RentalTypeData> rentalDistribution;

  final double projectedRevenue;
  final double overduePayments;
  final List<PaymentCollectionData> paymentCollection;

  OwnerAnalyticsData({
    required this.netEarnings,
    required this.occupancyRate,
    required this.totalRequests,
    required this.monthlyEarnings,
    required this.projectedRevenue,
    required this.overduePayments,
    required this.paymentCollection,
    required this.rentalDistribution,
  });
}

class MonthlyEarningData {
  final int month;
  final double value;
  MonthlyEarningData(this.month, this.value);
}

class RentalTypeData {
  final OwnerRentalType type;
  final int percent;
  final Color color;
  RentalTypeData(this.type, this.percent, this.color);
}

class PaymentCollectionData {
  final String status;
  final int percent;
  final Color color;
  PaymentCollectionData(this.status, this.percent, this.color);
}