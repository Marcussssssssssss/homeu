import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/booking_screen.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/property_image_gallery.dart';
import 'package:homeu/pages/home/viewing_screen.dart';

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
    _ownerProfileFuture = AppSupabase.client
        .from('profiles')
        .select('full_name, profile_image_url')
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
        backgroundColor: isError ? null : Colors.green,
      ),
    );
  }

  String _resolveReportSubmitErrorMessage(PostgrestException error) {
    switch (error.code) {
      case '42501':
        return 'Unable to submit report due to permission policy. Please contact support.';
      case '23503':
        return 'Unable to submit report because the listing reference is invalid.';
      case '22P02':
        return 'Unable to submit report because the listing data is invalid.';
      default:
        return 'Failed to submit report. Please try again later.';
    }
  }

  Future<void> _showReportBottomSheet() async {
    final currentUserId = HomeUAuthService.instance.currentUserId;
    if (currentUserId == null) {
      _showReportMessage('Please log in to submit a report.', isError: true);
      return;
    }
    if (HomeUSession.loggedInRole != HomeURole.tenant) {
      _showReportMessage(
        'Only tenants can submit property reports.',
        isError: true,
      );
      return;
    }
    if (currentUserId == widget.property.ownerId) {
      _showReportMessage('You cannot report your own property.', isError: true);
      return;
    }
    if (!_isValidUuid(widget.property.id) ||
        !_isValidUuid(widget.property.ownerId)) {
      _showReportMessage(
        'This property is missing required reporting data. Please try another listing.',
        isError: true,
      );
      return;
    }

    String? selectedReason;
    final reasons = [
      'Fake or misleading advertisement',
      'Suspicious owner',
      'Wrong property details',
      'Inappropriate content',
      'Other',
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
                      'Report Listing',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please select a reason for reporting this property.',
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
                        hintText: 'Describe the issue (optional)',
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
                            child: const Text('Cancel'),
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
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Submit Report'),
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
          'Reporting service is not available right now.',
          isError: true,
        );
        return;
      }

      final currentUser = HomeUAuthService.instance.currentUser;
      final currentUserId = currentUser?.id;
      final currentUserEmail = currentUser?.email;
      if (currentUserId == null) {
        _showReportMessage('Please log in to submit a report.', isError: true);
        return;
      }

      if (HomeUSession.loggedInRole != HomeURole.tenant) {
        _showReportMessage(
          'Only tenants can submit property reports.',
          isError: true,
        );
        return;
      }

      if (currentUserId == widget.property.ownerId) {
        _showReportMessage(
          'You cannot report your own property.',
          isError: true,
        );
        return;
      }

      if (!_isValidUuid(widget.property.id) ||
          !_isValidUuid(widget.property.ownerId)) {
        _showReportMessage(
          'Unable to submit report because listing metadata is invalid.',
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

      _showReportMessage('Report submitted. Our admin team will review it.');
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
        'Failed to submit report. Please try again later.',
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
              'Property Details',
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
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_gmailerrorred_rounded,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text('Report Listing'),
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
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    HomeUViewingScreen(property: property),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1E3A8A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Schedule Viewing',
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
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
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    HomeUBookingScreen(property: property),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Book Now'),
                        ),
                      ),
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
                      IconButton(
                        key: const Key('details_favorite_toggle'),
                        onPressed: () {
                          _favoritesController.toggle(property);
                        },
                        icon: Icon(
                          isFavorited
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: context.homeuAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.pricePerMonth,
                    style: TextStyle(
                      color: context.homeuPrice,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Location',
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
                    child: Row(
                      children: [
                        Container(
                          width: 78,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE7F0FF), Color(0xFFDDF4EA)],
                            ),
                          ),
                          child: const Icon(
                            Icons.location_city_rounded,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.location,
                                style: TextStyle(
                                  color: context.homeuPrimaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nearby: ${property.nearbyLandmarks}',
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
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Description',
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
                    'Facilities',
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (property.facilities.isEmpty)
                    Text(
                      'No facilities listed.',
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
                      'Owner Information',
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

                        return Column(
                          children: [
                            InkWell(
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
                            ),
                            if (property.hasHighRiskReport) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'High Risk Report',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'This owner/property has received a high-risk report. Please proceed carefully.',
                                            style: TextStyle(
                                              color: context.homeuPrimaryText.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
