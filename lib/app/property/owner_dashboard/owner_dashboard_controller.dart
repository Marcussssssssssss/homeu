import 'package:flutter/foundation.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'owner_dashboard_models.dart';
import 'owner_dashboard_remote_datasource.dart';

class OwnerDashboardController extends ChangeNotifier {
  OwnerDashboardController() : _dataSource = OwnerDashboardRemoteDataSource();

  final OwnerDashboardRemoteDataSource _dataSource;

  bool isLoading = true;
  String? errorMessage;
  DashboardData? dashboardData;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = HomeUAuthService.instance.currentUserId;
      if (userId == null) throw Exception('User not logged in');

      dashboardData = await _dataSource.fetchDashboardData(userId);
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      errorMessage = 'Failed to load dashboard data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
