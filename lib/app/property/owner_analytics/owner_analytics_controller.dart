import 'package:flutter/material.dart';
import 'owner_analytics_models.dart';
import 'owner_analytics_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class OwnerAnalyticsController extends ChangeNotifier {
  final OwnerAnalyticsRemoteDataSource _dataSource =
      OwnerAnalyticsRemoteDataSource();

  bool isLoading = true;
  String? errorMessage;
  OwnerAnalyticsData? data;

  Future<void> loadAnalytics() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ownerId = AppSupabase.client.auth.currentUser?.id;
      if (ownerId == null) throw Exception("User not logged in");

      data = await _dataSource.fetchAnalytics(ownerId);
    } catch (e) {
      errorMessage = 'Failed to load analytics: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
