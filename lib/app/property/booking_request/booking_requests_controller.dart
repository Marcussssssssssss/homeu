import 'package:flutter/foundation.dart';
import 'booking_request_models.dart';
import 'booking_requests_repository.dart';

class BookingRequestsController extends ChangeNotifier {
  BookingRequestsController({BookingRequestsRepository? repository})
      : _repository = repository ?? BookingRequestsRepository();

  final BookingRequestsRepository _repository;

  List<BookingRequestModel> requests = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadRequests() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      requests = await _repository.getOwnerRequests();
    } catch (e) {
      errorMessage = 'Failed to load booking requests.';
      debugPrint('Error loading requests: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String bookingId, String newStatus) async {
    try {
      await _repository.updateBookingStatus(bookingId, newStatus);
      // Update local list to avoid re-fetching everything immediately
      final index = requests.indexWhere((r) => r.id == bookingId);
      if (index != -1) {
        final old = requests[index];
        requests[index] = BookingRequestModel(
          id: old.id,
          propertyTitle: old.propertyTitle,
          monthlyPrice: old.monthlyPrice,
          tenantName: old.tenantName,
          tenantPhone: old.tenantPhone,
          tenantEmail: old.tenantEmail,
          startDate: old.startDate,
          durationMonths: old.durationMonths,
          status: newStatus,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }
}