import 'dart:io';

class AddPropertyPayload {
  const AddPropertyPayload({
    required this.title,
    required this.description,
    required this.locationArea,
    required this.monthlyPrice,
    required this.rentalType,
    required this.propertyType,
    required this.furnishing,
    required this.facilities,
    required this.images,
    required this.status,
    required this.publishAt,
    required this.deletedImageIds,
  });

  final String title;
  final String description;
  final String locationArea;
  final num monthlyPrice;
  final String rentalType;
  final String propertyType;
  final String furnishing;
  final List<String> facilities;
  final List<File> images;
  final String status;
  final DateTime? publishAt;
  final List<String> deletedImageIds;
}

enum AddPropertySubmissionStatus { success, failure }

class AddPropertySubmissionResult {
  const AddPropertySubmissionResult({
    required this.status,
    required this.message,
    this.createdPropertyId,
  });

  final AddPropertySubmissionStatus status;
  final String message;
  final String? createdPropertyId;

  bool get isSuccess => status == AddPropertySubmissionStatus.success;
}