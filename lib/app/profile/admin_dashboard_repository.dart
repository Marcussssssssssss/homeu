import 'package:homeu/app/profile/admin_dashboard_models.dart';
import 'package:homeu/app/profile/admin_dashboard_remote_datasource.dart';

class AdminDashboardRepository {
  AdminDashboardRepository({
    AdminDashboardRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? const AdminDashboardRemoteDataSource();

  final AdminDashboardRemoteDataSource _remoteDataSource;

  Future<AdminDashboardStats> fetchStats() async {
    final totalUsers = await _remoteDataSource.fetchTotalUsers();
    final totalOwners = await _remoteDataSource.fetchTotalByRole('owner');
    final totalTenants = await _remoteDataSource.fetchTotalByRole('tenant');
    final totalComplaints = await _remoteDataSource.fetchTotalComplaints();

    return AdminDashboardStats(
      totalUsers: totalUsers,
      totalOwners: totalOwners,
      totalTenants: totalTenants,
      totalComplaints: totalComplaints,
    );
  }
}
