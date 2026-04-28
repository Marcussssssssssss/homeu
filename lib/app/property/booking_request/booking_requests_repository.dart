import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'booking_request_models.dart';
import 'booking_requests_remote_datasource.dart';

class BookingRequestsRepository {
  BookingRequestsRepository({
    HomeUAuthService? authService,
    BookingRequestsRemoteDataSource? remoteDataSource,
  }) : _authService = authService ?? HomeUAuthService.instance,
       _remoteDataSource =
           remoteDataSource ?? const BookingRequestsRemoteDataSource();

  final HomeUAuthService _authService;
  final BookingRequestsRemoteDataSource _remoteDataSource;

  Future<List<BookingRequestModel>> getOwnerRequests() async {
    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User is not authenticated.');
    }
    return await _remoteDataSource.fetchOwnerRequests(userId);
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _remoteDataSource.updateBookingStatus(bookingId, newStatus);
  }
}
