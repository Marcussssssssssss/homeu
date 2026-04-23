import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
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
}

class HomeUViewingHistoryScreen extends StatefulWidget {
  const HomeUViewingHistoryScreen({super.key, this.initialViewings});

  final List<ViewingRequest>? initialViewings;

  @override
  State<HomeUViewingHistoryScreen> createState() =>
      _HomeUViewingHistoryScreenState();
}

class _HomeUViewingHistoryScreenState extends State<HomeUViewingHistoryScreen> {
  final ViewingRemoteDataSource _viewingRemoteDataSource =
      const ViewingRemoteDataSource();
  final PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  HomeUViewingFilterStatus _selectedStatus = HomeUViewingFilterStatus.all;
  List<ViewingRequest> _viewings = const <ViewingRequest>[];
  Map<String, PropertyItem> _propertyById = const <String, PropertyItem>{};
  bool _isLoading = true;
  String? _tenantId;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    if (widget.initialViewings != null) {
      _tenantId = 'preview-tenant';
      _viewings = widget.initialViewings!;
      _propertyById = {
        for (final viewing in _viewings)
          viewing.propertyId: _buildFallbackPropertyItem(viewing),
      };
      _isLoading = false;
      return;
    }
    _loadViewings();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final visibleViewings = _viewings
        .where((viewing) {
          if (_selectedStatus == HomeUViewingFilterStatus.all) {
            return true;
          }
          return _mapStatus(viewing.status) == _selectedStatus;
        })
        .toList(growable: false);

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Viewing History'),
        backgroundColor: context.colors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HomeUStatusFilterChips<HomeUViewingFilterStatus>(
                statuses: HomeUViewingFilterStatus.values
                    .where((s) => s != HomeUViewingFilterStatus.pending)
                    .toList(),
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadViewings,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: visibleViewings.length + (_loadError != null || visibleViewings.isEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_loadError != null && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFC53030),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          if (visibleViewings.isEmpty && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 120),
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
                            );
                          }

                          final viewing = visibleViewings[index];
                          final property =
                              _propertyById[viewing.propertyId] ??
                              _buildFallbackPropertyItem(viewing);
                          
                          return _ViewingHistoryCard(
                            viewing: viewing,
                            property: property,
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
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadViewings() async {
    if (!AppSupabase.isInitialized) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = null;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Supabase is not initialized.';
        _isLoading = false;
      });
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;

    if (tenantId == null || tenantId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = null;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Please log in to view your viewing history.';
        _isLoading = false;
      });
      return;
    }

    try {
      final rows = await _viewingRemoteDataSource.getTenantViewingRequests(
        tenantId,
      );
      final propertyById = await _propertyRemoteDataSource.fetchPropertiesByIds(
        rows.map((viewing) => viewing.propertyId),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = rows;
        _propertyById = propertyById;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _tenantId = tenantId;
        _viewings = const <ViewingRequest>[];
        _propertyById = const <String, PropertyItem>{};
        _loadError = 'Unable to load viewing history.';
        _isLoading = false;
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
    }
  }
}

class _ViewingHistoryCard extends StatelessWidget {
  const _ViewingHistoryCard({
    required this.viewing,
    required this.property,
    this.onTap,
  });

  final ViewingRequest viewing;
  final PropertyItem property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const purpleAccent = Color(0xFF6366F1);
    const grayBorder = Color(0xFFF1F5F9);
    final isPast = viewing.status.toLowerCase() == 'completed' || 
                   viewing.status.toLowerCase() == 'cancelled' ||
                   viewing.status.toLowerCase() == 'rejected';

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImage(
            property.imageUrls.isNotEmpty ? property.imageUrls[0] : null,
            110,
            130,
          ),
        ),
        const SizedBox(width: 16),
        // Info
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
                  color: const Color(0xFF10B981), // Premium Green badge
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  viewing.status.toUpperCase(),
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
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final scheduledAt = viewing.scheduledAt.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star rating above title
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
        // Title (Property Name)
        Padding(
          padding: const EdgeInsets.only(right: 60), // Avoid overlap with status badge
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
        // Location with purple pin
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
        // Viewing Details Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDetailColumn(
              'Viewing Date',
              dateFormat.format(scheduledAt),
              purpleAccent,
            ),
            const SizedBox(width: 14),
            _buildDetailColumn(
              'Viewing Time',
              timeFormat.format(scheduledAt),
              purpleAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn(String label, String value, Color accentColor) {
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
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return const Color(0xFF0F172A);
    }
  }
}
