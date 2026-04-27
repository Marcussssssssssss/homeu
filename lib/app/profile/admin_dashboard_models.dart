class AdminDashboardStats {
  final int totalUsers;
  final int totalOwners;
  final int totalTenants;
  final int totalComplaints;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalOwners,
    required this.totalTenants,
    required this.totalComplaints,
  });

  factory AdminDashboardStats.empty() {
    return const AdminDashboardStats(
      totalUsers: 0,
      totalOwners: 0,
      totalTenants: 0,
      totalComplaints: 0,
    );
  }
}
