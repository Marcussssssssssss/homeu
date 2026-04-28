class DashboardData {
  DashboardData({
    required this.totalEarnings,
    required this.activeListings,
    required this.pendingRequests,
    required this.occupancyRate,
    required this.recentProperties,
    required this.recentRequests,

    required this.recentViewingRequests,
  });

  final double totalEarnings;
  final int activeListings;
  final int pendingRequests;
  final String occupancyRate;
  final List<Map<String, dynamic>> recentProperties;
  final List<Map<String, dynamic>> recentRequests;

  final List<Map<String, dynamic>> recentViewingRequests;
}
