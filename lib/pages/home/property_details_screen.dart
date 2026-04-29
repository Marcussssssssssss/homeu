import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/booking_screen.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/property_image_gallery.dart';
import 'package:homeu/pages/home/viewing_screen.dart';
import 'dart:async';

import 'package:homeu/core/supabase/app_supabase.dart';

class HomeUPropertyDetailsScreen extends StatefulWidget {
  const HomeUPropertyDetailsScreen({super.key, required this.property});

  final PropertyItem property;

  @override
  State<HomeUPropertyDetailsScreen> createState() =>
      _HomeUPropertyDetailsScreenState();
}

class _HomeUPropertyDetailsScreenState
    extends State<HomeUPropertyDetailsScreen> {
  final HomeUFavoritesController _favoritesController =
      HomeUFavoritesController.instance;
  late Future<Map<String, dynamic>?> _ownerProfileFuture;

  @override
  void initState() {
    super.initState();
    unawaited(_favoritesController.loadForCurrentTenant());
    _ownerProfileFuture = AppSupabase.client
        .from('profiles')
        .select(
          'full_name, profile_image_url, risk_status, account_status, risk_reason',
        )
        .eq('id', widget.property.ownerId)
        .maybeSingle();
  }

  @override
  void dispose() {
    super.dispose();
  }

  IconData _getFacilityIcon(String facility) {
    final f = facility.toLowerCase();
    if (f.contains('wifi')) return Icons.wifi_rounded;
    if (f.contains('parking')) return Icons.local_parking_rounded;
    if (f.contains('aircond')) return Icons.ac_unit_rounded;
    if (f.contains('lift')) return Icons.elevator_rounded;
    if (f.contains('gym')) return Icons.fitness_center_rounded;
    if (f.contains('swimming pool') || f.contains('pool')) {
      return Icons.pool_rounded;
    }
    if (f.contains('security')) return Icons.security_rounded;
    if (f.contains('balcony')) return Icons.balcony_rounded;
    if (f.contains('playground')) return Icons.child_care_rounded;
    if (f.contains('washing machine')) {
      return Icons.local_laundry_service_rounded;
    }
    if (f.contains('bbq') || f.contains('pit')) {
      return Icons.outdoor_grill_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  String _normalizedAvailabilityStatus(PropertyItem property) {
    final status = property.status.trim().toLowerCase();
    if (status == 'occupied') {
      return context.l10n.propertyStatusOccupied;
    } else if (status == 'inactive') {
      return context.l10n.propertyStatusInactive;
    }
    return context.l10n.propertyStatusActive;
  }

  bool _isBookNowAvailable(PropertyItem property) {
    final normalized = property.status.trim().toLowerCase();
    return normalized.isEmpty || normalized == 'active';
  }

  bool _isViewingAvailable(PropertyItem property) {
    final normalized = property.status.trim().toLowerCase();
    return normalized != 'occupied';
  }

  HomeURiskStatus _resolvedOwnerRiskStatus(Map<String, dynamic>? data) {
    if (data != null && data['risk_status'] != null) {
      return HomeUProfileData.mapRiskStatus(data['risk_status']?.toString());
    }
    return widget.property.ownerRiskStatus;
  }

  HomeUAccountStatus _resolvedOwnerAccountStatus(Map<String, dynamic>? data) {
    if (data != null && data['account_status'] != null) {
      return HomeUProfileData.mapAccountStatus(
        data['account_status']?.toString(),
      );
    }
    return widget.property.ownerAccountStatus;
  }

  Widget _buildLocationMapPreview(PropertyItem property) {
    if (!property.hasCoordinates) {
      return const SizedBox.shrink();
    }

    final latitude = property.latitude!;
    final longitude = property.longitude!;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(latitude, longitude),
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.homeu',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(latitude, longitude),
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFFC53030),
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  bool _isValidUuid(String value) => _uuidPattern.hasMatch(value.trim());

  void _showReportMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.colors.error : context.homeuSuccess,
      ),
    );
  }

  String _resolveReportSubmitErrorMessage(PostgrestException error) {
    switch (error.code) {
      case '42501':
        return context.l10n.propertyReportErrorPermission;
      case '23503':
        return context.l10n.propertyReportErrorInvalidListing;
      case '22P02':
        return context.l10n.propertyReportErrorInvalidData;
      default:
        return context.l10n.propertyReportSubmitFailed;
    }
  }

  Future<void> _showReportBottomSheet() async {
    final currentUserId = HomeUAuthService.instance.currentUserId;
    if (currentUserId == null) {
      _showReportMessage(context.l10n.propertyReportLoginRequired, isError: true);
      return;
    }
    if (HomeUSession.loggedInRole != HomeURole.tenant) {
      _showReportMessage(
        context.l10n.propertyReportTenantOnly,
        isError: true,
      );
      return;
    }
    if (currentUserId == widget.property.ownerId) {
      _showReportMessage(
        context.l10n.propertyReportOwnProperty,
        isError: true,
      );
      return;
    }
    if (!_isValidUuid(widget.property.id) ||
        !_isValidUuid(widget.property.ownerId)) {
      _showReportMessage(
        context.l10n.propertyReportInvalidMetadata,
        isError: true,
      );
      return;
    }

    String? selectedReason;
    final reasons = [
      context.l10n.propertyReportReasonFake,
      context.l10n.propertyReportReasonSuspicious,
      context.l10n.propertyReportReasonWrongDetails,
      context.l10n.propertyReportReasonInappropriate,
      context.l10n.propertyReportReasonOther,
    ];
    final descriptionController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.homeuSoftBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.l10n.propertyReportTitle,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.propertyReportSubtitle,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...reasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return ListTile(
                        onTap: () =>
                            setSheetState(() => selectedReason = reason),
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? context.homeuAccent
                              : context.homeuMutedText,
                        ),
                        title: Text(
                          reason,
                          style: TextStyle(
                            color: isSelected
                                ? context.homeuPrimaryText
                                : context.homeuSecondaryText,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: context.l10n.propertyReportDescriptionHint,
                        filled: true,
                        fillColor: context.homeuRaisedCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.homeuSoftBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: context.homeuSoftBorder,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(context.l10n.propertyReportCancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedReason == null
                                ? null
                                : () async {
                                    final reason = selectedReason!;
                                    final desc = descriptionController.text
                                        .trim();
                                    Navigator.pop(context);
                                    await _submitReport(reason, desc);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.error,
                              foregroundColor: context.colors.onError,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              context.l10n.propertyReportSubmit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String reason, String description) async {
    try {
      if (!AppSupabase.isInitialized) {
        _showReportMessage(
          context.l10n.propertyReportServiceUnavailable,
          isError: true,
        );
        return;
      }

      final currentUser = HomeUAuthService.instance.currentUser;
      final currentUserId = currentUser?.id;
      final currentUserEmail = currentUser?.email;
      if (currentUserId == null) {
        _showReportMessage(
          context.l10n.propertyReportLoginRequired,
          isError: true,
        );
        return;
      }

      if (HomeUSession.loggedInRole != HomeURole.tenant) {
        _showReportMessage(
          context.l10n.propertyReportTenantOnly,
          isError: true,
        );
        return;
      }

      if (currentUserId == widget.property.ownerId) {
        _showReportMessage(
          context.l10n.propertyReportOwnProperty,
          isError: true,
        );
        return;
      }

      if (!_isValidUuid(widget.property.id) ||
          !_isValidUuid(widget.property.ownerId)) {
        _showReportMessage(
          context.l10n.propertyReportInvalidMetadata,
          isError: true,
        );
        return;
      }

      debugPrint(
        'Property report submit: tenant_id=$currentUserId, email=$currentUserEmail, '
        'property_id=${widget.property.id}, owner_id=${widget.property.ownerId}',
      );

      await AppSupabase.client.from('property_reports').insert({
        'property_id': widget.property.id,
        'owner_id': widget.property.ownerId,
        'tenant_id': currentUserId,
        'reason': reason,
        'description': description,
        'status': 'pending',
      });

      _showReportMessage(context.l10n.propertyReportSubmitted);
    } on PostgrestException catch (e) {
      debugPrint(
        'Property report insert failed. '
        'code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}',
      );
      _showReportMessage(_resolveReportSubmitErrorMessage(e), isError: true);
    } catch (e, stackTrace) {
      debugPrint('Property report insert unexpected error: $e');
      debugPrint('$stackTrace');
      _showReportMessage(
        context.l10n.propertyReportSubmitFailed,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final property = widget.property;
    final currentUserId = AppSupabase.auth.currentUser?.id;
    final isOwner = currentUserId == property.ownerId;
    final availabilityStatus = _normalizedAvailabilityStatus(property);
    final ownerRestricted = property.isOwnerRestricted;
    final canBookNow = _isBookNowAvailable(property) && !ownerRestricted;
    final canScheduleViewing =
        _isViewingAvailable(property) && !ownerRestricted;

    debugPrint('[DEBUG] Details Page Build for ID: ${property.id}');
    debugPrint('[DEBUG] Total Images Received: ${property.imageUrls.length}');
    if (property.imageUrls.isNotEmpty) {
      debugPrint('[DEBUG] First Image URL: ${property.imageUrls.first}');
    }

    return AnimatedBuilder(
      animation: _favoritesController,
      builder: (context, _) {
        final isFavorited = _favoritesController.isFavorited(property.id);

        return Scaffold(
          backgroundColor: context.colors.surface,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: Text(
              context.l10n.propertyDetailsTitle,
              style: TextStyle(
                color: context.homeuPrimaryText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: context.colors.surface,
            actions: [
              if (!isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'report') {
                      _showReportBottomSheet();
                    }
                  },
                  itemBuilder: (context) => [
                      PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_gmailerrorred_rounded,
                            size: 20,
                              color: context.colors.error,
                          ),
                          const SizedBox(width: 8),
                            Text(context.l10n.propertyReportTitle),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 4),
            ],
          ),
          bottomNavigationBar: isOwner
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton(
                          key: const Key('schedule_viewing_button'),
                          onPressed: canScheduleViewing
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => HomeUViewingScreen(
                                        property: property,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.homeuAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            context.l10n.viewingScheduleTitle,
                            style: TextStyle(
                              color: context.homeuAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('book_now_button'),
                          onPressed: canBookNow
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => HomeUBookingScreen(
                                        property: property,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.homeuAccent,
                            foregroundColor: context.colors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Text(context.l10n.bookingBookNow),
                        ),
                      ),
                      if (!canBookNow) ...[
                        const SizedBox(height: 8),
                        Text(
                          ownerRestricted
                              ? context.l10n.propertyUnavailableAdmin
                              : context.l10n.propertyUnavailableBooking,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: PropertyImageGallery(
                      key: ValueKey('details_gallery_${property.id}'),
                      imageUrls: property.imageUrls,
                      height: 250,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                        HomeUSession.loggedInRole != null &&
                                HomeUSession.loggedInRole != HomeURole.tenant
                            ? const SizedBox.shrink()
                            : IconButton(
                                key: const Key('details_favorite_toggle'),
                                onPressed: _favoritesController.isBusy(
                                        property.id)
                                    ? null
                                    : () async {
                                        final result = await _favoritesController
                                            .toggle(property);
                                        if (!context.mounted) return;
                                        switch (result) {
                                          case HomeUFavouriteActionResult
                                              .added:
                                          case HomeUFavouriteActionResult
                                              .removed:
                                          case HomeUFavouriteActionResult.busy:
                                            break;
                                          case HomeUFavouriteActionResult
                                              .requiresLogin:
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context.l10n
                                                      .propertyFavoriteLoginRequired,
                                                ),
                                              ),
                                            );
                                            break;
                                          case HomeUFavouriteActionResult
                                              .requiresTenant:
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context.l10n
                                                      .propertyFavoriteTenantOnly,
                                                ),
                                              ),
                                            );
                                            break;
                                          case HomeUFavouriteActionResult
                                              .policyBlocked:
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context.l10n
                                                      .propertyFavoritePolicyBlocked,
                                                ),
                                              ),
                                            );
                                            break;
                                          case HomeUFavouriteActionResult
                                              .failed:
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  context.l10n
                                                      .propertyFavoriteUpdateFailed,
                                                ),
                                              ),
                                            );
                                            break;
                                        }
                                      },
                                icon: Icon(
                                  isFavorited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFavorited
                                      ? context.colors.error
                                      : context.homeuMutedText,
                                ),
                              ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        property.pricePerMonth,
                        style: TextStyle(
                          color: context.homeuPrice,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (property.hasHighRiskReport)
                        _ModerationTag(
                          label: context.l10n.propertyHighRiskTag,
                          color: context.colors.error,
                          icon: Icons.warning_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.propertyLocationTitle,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    key: const Key('location_info_section'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.homeuCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.homeuAccent.withValues(alpha: 0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 78,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    context.colors.surfaceContainerHighest,
                                    context.colors.surfaceContainerHigh,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.location_city_rounded,
                                color: context.homeuAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.displayAddress,
                                    style: TextStyle(
                                      color: context.homeuPrimaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                    Text(
                                      context.l10n.propertyNearbyLabel(
                                        property.nearbyLandmarks,
                                      ),
                                      style: TextStyle(
                                        color: context.homeuMutedText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _buildLocationMapPreview(property),
                      ],
                    ),
                  ),
                   const SizedBox(height: 18),
                   Text(
                     context.l10n.propertyDescriptionTitle,
                     style: TextStyle(
                       color: context.homeuPrimaryText,
                       fontSize: 16,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                   const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: TextStyle(
                      color: context.homeuMutedText,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.propertyFacilitiesTitle,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (property.facilities.isEmpty)
                    Text(
                      context.l10n.propertyNoFacilities,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 13,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: property.facilities.map((f) {
                        return _FacilityBadge(
                          icon: _getFacilityIcon(f),
                          label: f,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 18),
                  if (!isOwner) ...[
                    Text(
                      context.l10n.propertyOwnerInfoTitle,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _ownerProfileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 70,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          debugPrint(
                            'Error fetching owner profile: ${snapshot.error}',
                          );
                        }

                        final data = snapshot.data;
                        final ownerRiskStatus =
                            _resolvedOwnerRiskStatus(data);
                        final ownerAccountStatus =
                            _resolvedOwnerAccountStatus(data);
                        final String ownerName =
                            (data?['full_name'] as String?)?.isNotEmpty == true
                            ? data!['full_name'] as String
                            : property.ownerName;

                        final String? avatarUrl =
                            (data?['profile_image_url'] as String?)
                                    ?.isNotEmpty ==
                                true
                            ? data!['profile_image_url'] as String
                            : property.ownerPhotoUrl;

                        final bool hasAvatar =
                            avatarUrl != null && avatarUrl.isNotEmpty;

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    HomeUChatScreen.start(property: property),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.homeuCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: context.homeuAccent.withValues(
                                    alpha: 0.14,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: context.homeuAccent
                                      .withValues(alpha: 0.12),
                                  backgroundImage: hasAvatar
                                      ? NetworkImage(avatarUrl)
                                      : null,
                                  child: !hasAvatar
                                      ? Text(
                                          ownerName.isNotEmpty
                                              ? ownerName
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                              : 'P',
                                          style: TextStyle(
                                            color: context.homeuAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ownerName,
                                        style: TextStyle(
                                          color: context.homeuPrimaryText,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        property.ownerRole,
                                        style: TextStyle(
                                          color: context.homeuMutedText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (ownerRiskStatus !=
                                              HomeURiskStatus.normal ||
                                          ownerAccountStatus !=
                                              HomeUAccountStatus.active) ...[
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            if (ownerRiskStatus ==
                                                    HomeURiskStatus.suspicious ||
                                                ownerRiskStatus ==
                                                    HomeURiskStatus.highRisk)
                                              _ModerationTag(
                                                label: ownerRiskStatus ==
                                                        HomeURiskStatus.highRisk
                                                    ? context.l10n.propertyOwnerHighRisk
                                                    : context.l10n.propertyOwnerSuspicious,
                                                color: ownerRiskStatus ==
                                                        HomeURiskStatus.highRisk
                                                    ? const Color(0xFFDC2626)
                                                    : const Color(0xFFF59E0B),
                                              ),
                                            if (ownerAccountStatus !=
                                                HomeUAccountStatus.active)
                                              _ModerationTag(
                                                label: ownerAccountStatus ==
                                                        HomeUAccountStatus.suspended
                                                    ? context.l10n.propertyOwnerSuspended
                                                    : context.l10n.propertyOwnerRemoved,
                                                color: const Color(0xFF6B7280),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: context.homeuAccent,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    context.l10n.propertyAvailabilityTitle,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.homeuCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.homeuAccent.withValues(alpha: 0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          context.l10n.propertyAvailabilityLabel,
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            availabilityStatus,
                            style: TextStyle(
                              color: context.homeuPrimaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModerationTag extends StatelessWidget {
  const _ModerationTag({
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityBadge extends StatelessWidget {
  const _FacilityBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: context.homeuAccent, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
