import 'package:homeu/app/profile/admin_dashboard_models.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class AdminDashboardRemoteDataSource {
  const AdminDashboardRemoteDataSource();

  Future<int> fetchTotalUsers() async {
    if (!AppSupabase.isInitialized) {
      return 0;
    }

    final dynamic response = await AppSupabase.client
        .from('profiles')
        .select('id');

    if (response is List) {
      return response.length;
    }

    return 0;
  }

  Future<int> fetchTotalByRole(String role) async {
    if (!AppSupabase.isInitialized) {
      return 0;
    }

    final dynamic response = await AppSupabase.client
        .from('profiles')
        .select('id')
        .eq('role', role);

    if (response is List) {
      return response.length;
    }

    return 0;
  }

  Future<int> fetchTotalComplaints() async {
    if (!AppSupabase.isInitialized) {
      return 0;
    }

    try {
      final dynamic response = await AppSupabase.client
          .from('property_reports')
          .select('report_id');

      if (response is List) {
        return response.length;
      }

      return 0;
    } catch (_) {
      // property_reports table may not exist yet.
      return 0;
    }
  }

  Future<int> fetchPendingComplaints() async {
    if (!AppSupabase.isInitialized) {
      return 0;
    }

    try {
      final dynamic response = await AppSupabase.client
          .from('property_reports')
          .select('report_id')
          .eq('status', 'pending');

      if (response is List) {
        return response.length;
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }
}
