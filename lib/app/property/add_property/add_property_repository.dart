import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/property/add_property/add_property_models.dart';
import 'package:homeu/app/property/add_property/add_property_remote_datasource.dart';
import 'package:homeu/app/property/add_property/property_image_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';

class AddPropertyRepository {
  AddPropertyRepository({
    AddPropertyRemoteDataSource? remoteDataSource,
    PropertyImageRemoteDataSource? imageRemoteDataSource,
    HomeUAuthService? authService,
  }) : _remoteDataSource =
           remoteDataSource ?? const AddPropertyRemoteDataSource(),
       _imageRemoteDataSource =
           imageRemoteDataSource ??
           const PropertyImageRemoteDataSource(), // NEW
       _authService = authService ?? HomeUAuthService.instance;

  final AddPropertyRemoteDataSource _remoteDataSource;
  final PropertyImageRemoteDataSource _imageRemoteDataSource;
  final HomeUAuthService _authService;

  Future<Map<String, dynamic>?> getPropertyDetails(String propertyId) async {
    return await _remoteDataSource.fetchPropertyDetails(propertyId);
  }

  Future<AddPropertySubmissionResult> submit(
    AddPropertyPayload payload, {
    String? existingPropertyId,
  }) async {
    if (!AppSupabase.isInitialized) {
      return const AddPropertySubmissionResult(
        status: AddPropertySubmissionStatus.failure,
        message:
            'Backend is not initialized. Please check your Supabase configuration.',
      );
    }

    final userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) {
      return const AddPropertySubmissionResult(
        status: AddPropertySubmissionStatus.failure,
        message: 'Please log in again to submit a property.',
      );
    }

    try {
      String finalPropertyId;

      if (existingPropertyId != null) {
        await _remoteDataSource.updateProperty(
          propertyId: existingPropertyId,
          title: payload.title,
          description: payload.description,
          locationArea: payload.locationArea,
          latitude: payload.latitude,
          longitude: payload.longitude,
          monthlyPrice: payload.monthlyPrice,
          rentalType: payload.rentalType,
          propertyType: payload.propertyType,
          furnishing: payload.furnishing,
          facilities: payload.facilities,
          status: payload.status,
          publishAt: payload.publishAt,
        );
        finalPropertyId = existingPropertyId;
      } else {
        final id = await _remoteDataSource.createProperty(
          title: payload.title,
          description: payload.description,
          locationArea: payload.locationArea,
          latitude: payload.latitude,
          longitude: payload.longitude,
          monthlyPrice: payload.monthlyPrice,
          rentalType: payload.rentalType,
          propertyType: payload.propertyType,
          furnishing: payload.furnishing,
          facilities: payload.facilities,
          status: payload.status,
          publishAt: payload.publishAt,
        );

        if (id == null) {
          return const AddPropertySubmissionResult(
            status: AddPropertySubmissionStatus.failure,
            message: 'Unable to create property right now. Please try again.',
          );
        }
        finalPropertyId = id;
      }

      if (payload.images.isNotEmpty) {
        for (var i = 0; i < payload.images.length; i++) {
          final file = payload.images[i];
          final publicUrl = await _imageRemoteDataSource.uploadAndGetPublicUrl(
            propertyId: finalPropertyId,
            file: file,
            sortOrder: i,
          );
          await _imageRemoteDataSource.createPropertyImageRow(
            propertyId: finalPropertyId,
            publicUrl: publicUrl,
            sortOrder: i,
          );
        }
      }

      if (payload.deletedImageIds.isNotEmpty) {
        await _imageRemoteDataSource.deleteImages(payload.deletedImageIds);
      }

      String successMessage;
      if (payload.status == 'Draft') {
        successMessage = 'Draft saved successfully.';
      } else {
        final isScheduled =
            payload.publishAt != null &&
            payload.publishAt!.isAfter(
              DateTime.now().add(const Duration(minutes: 5)),
            );
        if (isScheduled) {
          successMessage = 'Property successfully scheduled for publication.';
        } else {
          successMessage = 'Property published and is now live.';
        }
      }

      return AddPropertySubmissionResult(
        status: AddPropertySubmissionStatus.success,
        message: successMessage,
        createdPropertyId: finalPropertyId,
      );
    } catch (e) {
      return AddPropertySubmissionResult(
        status: AddPropertySubmissionStatus.failure,
        message: e.toString(),
      );
    }
  }
}
