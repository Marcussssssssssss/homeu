import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/app/viewing/viewing_local_datasource.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/app/viewing/viewing_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/core/utils/date_time_utils.dart';
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
  const HomeUViewingHistoryScreen({super.key, this.initialViewings, this.isStandalone = true});

  final List<ViewingRequest>? initialViewings;
  final bool isStandalone;

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
  final Set<String> _failedPropertyIds = <String>{};
  bool _isFetchingProperties = false;
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
        _failedPropertyIds.clear();
        _isFetchingProperties = false;
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
      return Scaffold(
        body: Center(child: Text(context.l10n.viewingHistoryPleaseLogin)),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: widget.isStandalone
          ? AppBar(
              title: Text(
                context.l10n.viewingHistoryTitle,
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: context.colors.surface,
              elevation: 0,
              iconTheme: IconThemeData(color: context.colors.onSurface),
            )
          : null,
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
              child: RefreshIndicator(
                onRefresh: () async {
                  refresh();
                },
                color: context.homeuAccent,
                child: StreamBuilder<List<ViewingRequest>>(
                  stream: _viewingStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return ListView(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                context.l10n.viewingHistoryErrorWithMessage(
                                  '${snapshot.error}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    final viewings = snapshot.data ?? [];

                    if (viewings.isEmpty && (snapshot.connectionState == ConnectionState.waiting || _isFetchingProperties)) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Ensure properties are loaded before showing the list
                    final missingIds = viewings
                        .map((v) => v.propertyId)
                        .where((id) => !_propertyById.containsKey(id) && !_failedPropertyIds.contains(id))
                        .toSet();

                    if (missingIds.isNotEmpty) {
                      // Schedule property loading for the next frame to avoid setState during build
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _ensurePropertiesLoaded(viewings);
                      });
                      
                      // Show loading if we don't have enough data to render cards correctly
                      if (viewings.isNotEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }

                    final filteredViewings = _filterViewings(viewings);

                    if (filteredViewings.isEmpty) {
                      return _buildEmptyState();
                    }

                    return _buildViewingList(filteredViewings);
                  },
                ),
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
          onCancel: () => _confirmCancelViewing(viewing),
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

  Future<void> _confirmCancelViewing(ViewingRequest viewing) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: context.colors.scrim.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              backgroundColor: context.homeuCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: context.colors.error,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.viewingHistoryCancelTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.viewingHistoryCancelMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.homeuMutedText,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.homeuAccent,
                            foregroundColor: context.colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            context.l10n.viewingHistoryKeepAppointment,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: context.colors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            context.l10n.viewingHistoryConfirmCancellation,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await _viewingRemoteDataSource.cancelViewing(
          viewingId: viewing.id,
          tenantId: _tenantId!,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.viewingHistoryCancelledSuccess),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.viewingHistoryCancelFailed('$e'),
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 120),
          child: Center(
            child: Text(
              _selectedStatus == HomeUViewingFilterStatus.all
                  ? context.l10n.viewingHistoryEmptyAll
                  : context.l10n.viewingHistoryEmptyForStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.homeuMutedText,
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
    if (_isFetchingProperties) return;

    final missingIds = viewings
        .map((v) => v.propertyId)
        .where((id) => !_propertyById.containsKey(id) && !_failedPropertyIds.contains(id))
        .toSet();

    if (missingIds.isNotEmpty) {
      setState(() => _isFetchingProperties = true);
      
      _propertyRemoteDataSource.fetchPropertiesByIds(missingIds).then((newProperties) {
        if (mounted) {
          setState(() {
            _propertyById = {..._propertyById, ...newProperties};
            // Identify IDs that were requested but not returned
            for (final id in missingIds) {
              if (!newProperties.containsKey(id)) {
                _failedPropertyIds.add(id);
              }
            }
            _isFetchingProperties = false;
          });
        }
      }).catchError((_) {
        if (mounted) {
          setState(() {
            _failedPropertyIds.addAll(missingIds);
            _isFetchingProperties = false;
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
      location: context.l10n.viewingHistoryFallbackLocation,
      pricePerMonth: context.l10n.viewingHistoryFallbackPrice,
      rating: 4.5,
      accentColor: context.homeuAccent,
      description: context.l10n.viewingHistoryFallbackDescription,
      ownerName: viewing.ownerId,
      ownerRole: context.l10n.viewingHistoryFallbackHostRole,
      photoColors: [
        context.homeuAccent.withValues(alpha: 0.6),
        context.homeuAccent.withValues(alpha: 0.75),
        context.homeuAccent,
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
        return context.l10n.statusAll;
      case HomeUViewingFilterStatus.pending:
        return context.l10n.statusPending;
      case HomeUViewingFilterStatus.approved:
        return context.l10n.statusApproved;
      case HomeUViewingFilterStatus.rejected:
        return context.l10n.statusRejected;
      case HomeUViewingFilterStatus.completed:
        return context.l10n.statusCompleted;
      case HomeUViewingFilterStatus.cancelled:
        return context.l10n.statusCancelled;
      case HomeUViewingFilterStatus.rescheduleRequested:
        return context.l10n.statusRescheduled;
      case HomeUViewingFilterStatus.slotTaken:
        return context.l10n.statusSlotTaken;
      case HomeUViewingFilterStatus.propertyRented:
        return context.l10n.statusPropertyRented;
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
    this.onCancel,
  });

  final ViewingRequest viewing;
  final PropertyItem property;
  final String status;
  final HomeUViewingFilterStatus statusEnum;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final accent = context.homeuAccent;
    final border = context.homeuSoftBorder;
    final isPast = viewing.status.toLowerCase() == 'completed' ||
                   viewing.status.toLowerCase() == 'cancelled' ||
                   viewing.status.toLowerCase() == 'rejected' ||
                   viewing.status.toLowerCase() == 'slot taken' ||
                   viewing.status.toLowerCase() == 'property rented';

    final isRented = property.status.toLowerCase() == 'rented';
    final showRentedKillSwitch = isRented && (viewing.status.toLowerCase() == 'pending' || viewing.status.toLowerCase() == 'approved');

    final bool isFuture = viewing.scheduledAt.isAfter(DateTime.now());
    final bool showCancelButton = (statusEnum == HomeUViewingFilterStatus.pending) || 
                                 (statusEnum == HomeUViewingFilterStatus.approved && isFuture);

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section: 110x130
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildImage(
            context,
            property.imageUrls.isNotEmpty ? property.imageUrls[0] : null,
            110,
            130,
            applyGrayscale: isPast,
          ),
        ),
        const SizedBox(width: 16),
        // Info Section
        Expanded(
          child: Opacity(
            opacity: isPast ? 0.6 : 1.0,
            child: _buildInfoSection(
              context,
              accent,
              showCancelButton: showCancelButton,
            ),
          ),
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
          color: context.homeuCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: context.homeuCardShadow,
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
                constraints: const BoxConstraints(maxWidth: 80),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: showRentedKillSwitch
                      ? context.colors.surfaceContainerHighest
                      : _getStatusColor(context, statusEnum),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    (showRentedKillSwitch
                            ? context.l10n.statusCancelled
                            : status)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.colors.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String? url, double width, double height, {bool applyGrayscale = false}) {
    Widget image;
    if (url == null || url.isEmpty) {
      image = Container(
        width: width,
        height: height,
        color: context.colors.surfaceContainerHighest,
        child: Icon(
          Icons.image_outlined,
          color: context.homeuMutedText,
          size: 24,
        ),
      );
    } else {
      image = Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: context.colors.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            color: context.homeuMutedText,
            size: 24,
          ),
        ),
      );
    }

    if (applyGrayscale) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: image,
      );
    }
    return image;
  }

  Widget _buildInfoSection(
    BuildContext context,
    Color accent, {
    bool showCancelButton = false,
  }) {
    final dateFormat = DateFormat('MMM d');
    final dayFormat = DateFormat('EEEE');
    final timeFormat = DateFormat('h:mm a');
    // Treating scheduledAt as Wall Time (already UTC) to avoid double-offsetting on physical phones.
    final scheduledAt = viewing.scheduledAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(right: 60),
          child: Text(
            property.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.homeuPrimaryText,
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
            Icon(Icons.location_on, size: 16, color: accent),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.location,
                style: TextStyle(
                  fontSize: 13,
                  color: context.homeuMutedText,
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
              context,
              context.l10n.viewingHistoryDateLabel,
              dateFormat.format(scheduledAt),
              dayFormat.format(scheduledAt),
              accent,
            ),
            const SizedBox(width: 14),
            _buildDetailColumn(
              context,
              context.l10n.viewingHistoryTimeLabel,
              timeFormat.format(scheduledAt),
              context.l10n.viewingHistoryScheduledLabel,
              accent,
            ),
            if (showCancelButton) ...[
              const Spacer(),
              OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(color: context.colors.error, width: 1.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: Text(context.l10n.viewingHistoryCancelAction),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn(BuildContext context, String label, String value, String subValue, Color accentColor) {
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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: context.homeuPrimaryText,
          ),
        ),
        Text(
          subValue,
          style: TextStyle(fontSize: 10, color: context.homeuMutedText),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, HomeUViewingFilterStatus status) {
    switch (status) {
      case HomeUViewingFilterStatus.approved:
        return context.homeuSuccess;
      case HomeUViewingFilterStatus.pending:
        return context.colors.primary;
      case HomeUViewingFilterStatus.cancelled:
        return context.colors.surfaceContainerHighest;
      case HomeUViewingFilterStatus.rejected:
        return context.colors.error;
      case HomeUViewingFilterStatus.completed:
        return context.colors.secondary;
      case HomeUViewingFilterStatus.rescheduleRequested:
        return context.colors.tertiary;
      case HomeUViewingFilterStatus.slotTaken:
      case HomeUViewingFilterStatus.propertyRented:
        return context.colors.error;
      default:
        return context.homeuAccent;
    }
  }
}
