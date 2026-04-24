import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/app/viewing/viewing_local_datasource.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/widgets/status_filter_chips.dart';

enum HomeUViewingFilterStatus {
  all,
  pending,
  approved,
  rejected,
  completed,
  cancelled,
  rescheduleRequested,
  slotTaken,
  propertyRented,
}

class HomeUViewingHistoryScreen extends StatefulWidget {
  const HomeUViewingHistoryScreen({super.key, this.initialViewings});

  final List<ViewingRequest>? initialViewings;

  @override
  State<HomeUViewingHistoryScreen> createState() =>
      HomeUViewingHistoryScreenState();
}

class HomeUViewingHistoryScreenState extends State<HomeUViewingHistoryScreen> {
  final ViewingRemoteDataSource _viewingRemoteDataSource =
      const ViewingRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  
  HomeUViewingFilterStatus _selectedStatus = HomeUViewingFilterStatus.all;
  Map<String, PropertyItem> _propertyById = const <String, PropertyItem>{};
  String? _tenantId;
  Stream<List<ViewingRequest>>? _viewingStream;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _tenantId = AppSupabase.auth.currentUser?.id;
    if (_tenantId != null) {
      _viewingStream = _viewingRemoteDataSource.viewingRequestsStream(_tenantId!);
    }
  }

  /// Forces a refresh of the stream. Useful for Tab Bar double-taps.
  void refresh() {
    if (mounted) {
      setState(() {
        _initStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    if (_tenantId == null) {
      _initStream();
    }

    if (_tenantId == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Viewing History',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HomeUStatusFilterChips<HomeUViewingFilterStatus>(
                statuses: const [
                  HomeUViewingFilterStatus.all,
                  HomeUViewingFilterStatus.pending,
                  HomeUViewingFilterStatus.approved,
                  HomeUViewingFilterStatus.rejected,
                  HomeUViewingFilterStatus.cancelled,
                  HomeUViewingFilterStatus.completed,
                ],
                selected: _selectedStatus,
                labelBuilder: _statusLabel,
                keyBuilder: (status) =>
                    Key('viewing_status_filter_${status.name}'),
                onSelected: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ViewingRequest>>(
                stream: _viewingStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final viewings = snapshot.data ?? [];

                  if (viewings.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredViewings = _filterViewings(viewings);

                  if (filteredViewings.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildViewingList(filteredViewings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ViewingRequest> _filterViewings(List<ViewingRequest> viewings) {
    if (_selectedStatus == HomeUViewingFilterStatus.all) {
      return viewings;
    }
    return viewings.where((v) => _mapStatus(v.status) == _selectedStatus).toList();
  }

  Widget _buildViewingList(List<ViewingRequest> viewings) {
    _ensurePropertiesLoaded(viewings);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: viewings.length,
      itemBuilder: (context, index) {
        final viewing = viewings[index];
        final property = _propertyById[viewing.propertyId] ?? _buildFallbackPropertyItem(viewing);

        return _ViewingHistoryCard(
          viewing: viewing,
          property: property,
          status: _statusLabel(_mapStatus(viewing.status)),
          statusEnum: _mapStatus(viewing.status),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HomeUPropertyDetailsScreen(
                  property: property,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Center(
            child: Text(
              _selectedStatus == HomeUViewingFilterStatus.all
                  ? 'No viewing requests yet.'
                  : 'No viewing requests found for this status.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF667896),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _ensurePropertiesLoaded(List<ViewingRequest> viewings) {
    final missingIds = viewings
        .map((v) => v.propertyId)
        .where((id) => !_propertyById.containsKey(id))
        .toSet();

    if (missingIds.isNotEmpty) {
      _propertyRemoteDataSource.fetchPropertiesByIds(missingIds).then((newProperties) {
        if (mounted && newProperties.isNotEmpty) {
          setState(() {
            _propertyById = {..._propertyById, ...newProperties};
          });
        }
      });
    }
  }

  PropertyItem _buildFallbackPropertyItem(ViewingRequest viewing) {
    return PropertyItem(
      id: viewing.propertyId,
      ownerId: viewing.ownerId,
      name: viewing.propertyId,
      location: 'Location unavailable',
      pricePerMonth: 'Price unavailable',
      rating: 4.5,
      accentColor: const Color(0xFF1E3A8A),
      description: 'Property details are currently unavailable.',
      ownerName: viewing.ownerId,
      ownerRole: 'Host',
      photoColors: const [
        Color(0xFF5D7FBF),
        Color(0xFF4A68A8),
        Color(0xFF2F4F8F),
      ],
    );
  }

  HomeUViewingFilterStatus _mapStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'approved':
        return HomeUViewingFilterStatus.approved;
      case 'rejected':
        return HomeUViewingFilterStatus.rejected;
      case 'completed':
        return HomeUViewingFilterStatus.completed;
      case 'cancelled':
      case 'canceled':
        return HomeUViewingFilterStatus.cancelled;
      case 'reschedulerequested':
      case 'reschedule requested':
        return HomeUViewingFilterStatus.rescheduleRequested;
      case 'slot taken':
      case 'slottaken':
        return HomeUViewingFilterStatus.slotTaken;
      case 'property rented':
      case 'propertyrented':
        return HomeUViewingFilterStatus.propertyRented;
      default:
        return HomeUViewingFilterStatus.pending;
    }
  }

  String _statusLabel(HomeUViewingFilterStatus status) {
    switch (status) {
      case HomeUViewingFilterStatus.all:
        return 'All';
      case HomeUViewingFilterStatus.pending:
        return 'Pending';
      case HomeUViewingFilterStatus.approved:
        return 'Approved';
      case HomeUViewingFilterStatus.rejected:
        return 'Rejected';
      case HomeUViewingFilterStatus.completed:
        return 'Completed';
      case HomeUViewingFilterStatus.cancelled:
        return 'Cancelled';
      case HomeUViewingFilterStatus.rescheduleRequested:
        return 'Rescheduled';
      case HomeUViewingFilterStatus.slotTaken:
        return 'Slot Taken';
      case HomeUViewingFilterStatus.propertyRented:
        return 'Property Rented';
    }
  }
}

class _ViewingHistoryCard extends StatelessWidget {
  const _ViewingHistoryCard({
    required this.viewing,
    required this.property,
    required this.status,
    required this.statusEnum,
    this.onTap,
  });

  final ViewingRequest viewing;
  final PropertyItem property;
  final String status;
  final HomeUViewingFilterStatus statusEnum;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const purpleAccent = Color(0xFF6366F1);
    const grayBorder = Color(0xFFF1F5F9);
    final isPast = viewing.status.toLowerCase() == 'completed' || 
                   viewing.status.toLowerCase() == 'cancelled' ||
                   viewing.status.toLowerCase() == 'rejected' ||
                   viewing.status.toLowerCase() == 'slot taken' ||
                   viewing.status.toLowerCase() == 'property rented';

    final isRented = property.status.toLowerCase() == 'rented';
    final showRentedKillSwitch = isRented && (viewing.status.toLowerCase() == 'pending' || viewing.status.toLowerCase() == 'approved');

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section: 110x130
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImage(
            property.imageUrls.isNotEmpty ? property.imageUrls[0] : null,
            110,
            130,
          ),
        ),
        const SizedBox(width: 16),
        // Info Section
        Expanded(
          child: _buildInfoSection(context, purpleAccent),
        ),
      ],
    );

    if (isPast) {
      cardContent = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: cardContent,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: grayBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            cardContent,
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: showRentedKillSwitch ? const Color(0xFFEF4444) : _getStatusColor(statusEnum),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (showRentedKillSwitch ? 'Property Rented' : status).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url, double width, double height) {
    if (url == null || url.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 24),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.broken_image_outlined, color: Color(0xFF94A3B8), size: 24),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Color purpleAccent) {
    final dateFormat = DateFormat('MMM d');
    final dayFormat = DateFormat('EEEE');
    final timeFormat = DateFormat('hh:mm a');
    final scheduledAt = viewing.scheduledAt.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star rating
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 14,
              color: index < property.rating.floor() ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Title
        Padding(
          padding: const EdgeInsets.only(right: 60), 
          child: Text(
            property.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        // Location
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: purpleAccent),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.location,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Details Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDetailColumn(
              'Viewing Date',
              dateFormat.format(scheduledAt),
              dayFormat.format(scheduledAt),
              purpleAccent,
            ),
            const SizedBox(width: 14),
            _buildDetailColumn(
              'Viewing Time',
              timeFormat.format(scheduledAt),
              'Scheduled',
              purpleAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value, String subValue, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: accentColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          subValue,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Color _getStatusColor(HomeUViewingFilterStatus status) {
    switch (status) {
      case HomeUViewingFilterStatus.approved:
        return const Color(0xFF10B981); // Green
      case HomeUViewingFilterStatus.pending:
        return const Color(0xFF3B82F6); // Blue
      case HomeUViewingFilterStatus.cancelled:
        return const Color(0xFF94A3B8); // Muted Gray
      case HomeUViewingFilterStatus.rejected:
        return const Color(0xFFEF4444); // Red
      case HomeUViewingFilterStatus.completed:
        return const Color(0xFF6366F1); // Indigo
      case HomeUViewingFilterStatus.rescheduleRequested:
        return const Color(0xFFF59E0B); // Amber
      case HomeUViewingFilterStatus.slotTaken:
      case HomeUViewingFilterStatus.propertyRented:
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF1E3A8A);
    }
  }
}
