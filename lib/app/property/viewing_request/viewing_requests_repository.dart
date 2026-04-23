import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'viewing_request_models.dart';
import 'viewing_requests_remote_datasource.dart';

class ViewingRequestsRepository {
  ViewingRequestsRepository({
    HomeUAuthService? authService,
    ViewingRequestsRemoteDataSource? remoteDataSource,
  })  : _authService = authService ?? HomeUAuthService.instance,
        _remoteDataSource = remoteDataSource ?? const ViewingRequestsRemoteDataSource();

  final HomeUAuthService _authService;
  final ViewingRequestsRemoteDataSource _remoteDataSource;

  Future<List<ViewingRequestModel>> getOwnerViewingRequests() async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User is not authenticated.');
    }
    return await _remoteDataSource.fetchOwnerViewingRequests(userId);
  }

  Future<void> updateViewingStatus(String viewingId, String newStatus) async {
    await _remoteDataSource.updateViewingStatus(viewingId, newStatus);
  }
}