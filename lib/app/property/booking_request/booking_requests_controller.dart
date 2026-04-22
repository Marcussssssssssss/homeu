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

  String selectedFilter = 'All';

  final List<String> availableFilters = [
    'All',
    'Pending',
    'Approved',
    'Rejected',
    'Completed',
    'Cancelled'
  ];

  List<BookingRequestModel> get filteredRequests {
    if (selectedFilter == 'All') return requests;

    if (selectedFilter == 'Pending') {
      return requests.where((r) => r.status == 'Pending' || r.status == 'Pending Decision').toList();
    }

    return requests.where((r) => r.status == selectedFilter).toList();
  }

  void setFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

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

      await loadRequests();
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }
}