import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_local_datasource.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/profile/profile_remote_datasource.dart';

class HomeUProfileRepository {
  HomeUProfileRepository({
    HomeUAuthService? authService,
    HomeUProfileRemoteDataSource? remoteDataSource,
    HomeUProfileLocalDataSource? localDataSource,
  }) : _authService = authService ?? HomeUAuthService.instance,
       _remoteDataSource = remoteDataSource ?? const HomeUProfileRemoteDataSource(),
       _localDataSource = localDataSource ?? HomeUProfileLocalDataSource();

  final HomeUAuthService _authService;
  final HomeUProfileRemoteDataSource _remoteDataSource;
  final HomeUProfileLocalDataSource _localDataSource;

  String? get currentUserId => _authService.currentUserId;

  String get currentUserEmail => _authService.currentSession?.user.email ?? '';

  Future<HomeUProfileData?> getCachedProfile() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return _localDataSource.getCachedProfile(userId);
  }

  Future<Map<String, dynamic>?> getCachedPreferences() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return _localDataSource.getCachedPreferences(userId);
  }

  Future<HomeUProfileData?> fetchLatestProfile() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final profile = await _remoteDataSource.fetchProfile(
      userId: userId,
      fallbackEmail: currentUserEmail,
    );

    if (profile != null) {
      await _localDataSource.saveProfile(profile);
    }

    return profile;
  }

  Future<Map<String, dynamic>?> fetchLatestPreferences() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final preferences = await _remoteDataSource.fetchUserPreferences(userId);
    if (preferences != null) {
      await _localDataSource.savePreferences(userId: userId, preferences: preferences);
    }

    return preferences;
  }

  Future<HomeUProfileData> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? profileImageUrl,
    required HomeURole fallbackRole,
  }) async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) {
      throw StateError('No authenticated user found.');
    }

    final updated = await _remoteDataSource.updateProfile(
      userId: userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl,
      fallbackEmail: currentUserEmail,
      fallbackRole: fallbackRole,
    );

    await _localDataSource.saveProfile(updated);
    return updated;
  }
}

