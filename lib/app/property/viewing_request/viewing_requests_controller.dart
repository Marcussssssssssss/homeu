import 'package:flutter/foundation.dart';
import 'viewing_request_models.dart';
import 'viewing_requests_repository.dart';

class ViewingRequestsController extends ChangeNotifier {
  ViewingRequestsController({ViewingRequestsRepository? repository})
      : _repository = repository ?? ViewingRequestsRepository();

  final ViewingRequestsRepository _repository;

  List<ViewingRequestModel> requests = [];
  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = 'All';
  final List<String> availableFilters = ['All', 'Pending', 'Approved', 'Rejected', 'Completed', 'Cancelled'];

  List<ViewingRequestModel> get filteredRequests {
    if (selectedFilter == 'All') return requests;
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
      requests = await _repository.getOwnerViewingRequests();
    } catch (e) {
      errorMessage = 'Failed to load viewing requests.';
      debugPrint('Error loading viewings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String viewingId, String newStatus) async {
    try {
      await _repository.updateViewingStatus(viewingId, newStatus);
      await loadRequests();
      return true;
    } catch (e) {
      debugPrint('Error updating viewing status: $e');
      return false;
    }
  }
}