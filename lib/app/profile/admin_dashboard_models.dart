class AdminDashboardStats {
  final int totalUsers;
  final int totalOwners;
  final int totalTenants;
  final int totalComplaints;
  final int pendingComplaints;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalOwners,
    required this.totalTenants,
    required this.totalComplaints,
    required this.pendingComplaints,
  });

  factory AdminDashboardStats.empty() {
    return const AdminDashboardStats(
      totalUsers: 0,
      totalOwners: 0,
      totalTenants: 0,
      totalComplaints: 0,
      pendingComplaints: 0,
    );
  }
}
