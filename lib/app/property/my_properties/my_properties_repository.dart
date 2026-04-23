import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'my_properties_models.dart';
import 'my_properties_remote_datasource.dart';

class MyPropertiesRepository {
  MyPropertiesRepository({
    HomeUAuthService? authService,
    MyPropertiesRemoteDataSource? remoteDataSource,
  })  : _authService = authService ?? HomeUAuthService.instance,
        _remoteDataSource = remoteDataSource ?? const MyPropertiesRemoteDataSource();

  final HomeUAuthService _authService;
  final MyPropertiesRemoteDataSource _remoteDataSource;

  Future<List<OwnerPropertyModel>> getMyProperties() async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User is not authenticated.');
    }

    return await _remoteDataSource.fetchOwnerProperties(userId);
  }

  Future<void> updatePropertyStatus(String propertyId, String newStatus) async {
    await _remoteDataSource.updatePropertyStatus(propertyId, newStatus);
  }

  Future<void> archiveProperty(String propertyId) async {
    try {
      await _remoteDataSource.archiveProperty(propertyId);
    } catch (_) {
      rethrow;
    }
  }
}