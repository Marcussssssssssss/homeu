import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:intl/intl.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';
import '../../app/property/viewing_request/viewing_requests_controller.dart';
import 'owner_analytics_screen.dart';
import 'owner_booking_request_details_screen.dart';
import 'owner_my_properties_screen.dart';

class HomeUOwnerBookingRequestsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestsScreen({
    super.key,
    this.showBottomNavigationBar = true,
    this.initialTabIndex = 0,
  });

  final bool showBottomNavigationBar;
  final int initialTabIndex;

  @override
  State<HomeUOwnerBookingRequestsScreen> createState() =>
      _HomeUOwnerBookingRequestsScreenState();
}

class _HomeUOwnerBookingRequestsScreenState extends State<HomeUOwnerBookingRequestsScreen> {
  late final BookingRequestsController _bookingController;
  late final ViewingRequestsController _viewingController;

  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _bookingController = BookingRequestsController();
    _bookingController.loadRequests();

    _viewingController = ViewingRequestsController();
    _viewingController.loadRequests();
  }

  @override
  void dispose() {
    _bookingController.dispose();
    _viewingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(context.l10n.ownerRequestsTitle),
          backgroundColor: context.colors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: context.homeuAccent,
            unselectedLabelColor: context.homeuMutedText,
            indicatorColor: context.homeuAccent,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: context.l10n.ownerRequestsBookingsTab),
              Tab(text: context.l10n.ownerRequestsViewingsTab),
            ],
          ),
        ),

        bottomNavigationBar: widget.showBottomNavigationBar
            ? HomeUOwnerBottomNavigationBar(
          selectedIndex: _selectedNavIndex,
          onDestinationSelected: (index) {
            if (index == _selectedNavIndex) return;

            void switchTabInstantly(Widget screen) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => screen,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }

            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              return;
            }
            if (index == 1) {
              switchTabInstantly(const HomeUOwnerMyPropertiesScreen());
              return;
            }
            if (index == 2) return;
            if (index == 3) {
              switchTabInstantly(const HomeUOwnerAnalyticsScreen());
              return;
            }
            if (index == 4) {
              switchTabInstantly(const HomeUConversationListScreen());
              return;
            }
            if (index == 5) {
              switchTabInstantly(const HomeUProfileScreen(role: HomeURole.owner));
              return;
            }
          },
        )
            : null,

        body: TabBarView(
          children: [_buildBookingRequestsTab(), _buildViewingRequestsTab()],
        ),
      ),
    );
  }

  Widget _buildBookingRequestsTab() {
    return ListenableBuilder(
      listenable: _bookingController,
      builder: (context, child) {
        if (_bookingController.isLoading &&
            _bookingController.requests.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: context.homeuAccent),
          );
        }
        if (_bookingController.errorMessage != null &&
            _bookingController.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: context.colors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _bookingController.errorMessage!,
                  style: TextStyle(
                    color: context.colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _bookingController.loadRequests,
                  child: Text(context.l10n.ownerRequestsRetry),
                ),
              ],
            ),
          );
        }

        final displayedRequests = _bookingController.filteredRequests;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _bookingController.availableFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _bookingController.availableFilters[index];
                  final isSelected =
                      _bookingController.selectedFilter == filter;

                  final filterLabel = _filterLabel(context, filter);
                  return InkWell(
                    onTap: () => _bookingController.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.homeuAccent
                            : context.homeuCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : context.homeuSoftBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            filterLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? context.colors.onPrimary
                                  : context.homeuAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _bookingController.loadRequests,
                color: context.homeuAccent,
                child: displayedRequests.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: context.homeuMutedText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.ownerRequestsEmpty(
                                    _filterLabel(
                                      context,
                                      _bookingController.selectedFilter,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: context.homeuMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: displayedRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final request = displayedRequests[index];

                          final isPending =
                              request.status == 'Pending' ||
                              request.status == 'Pending Decision';
                          final isApproved = request.status == 'Approved';

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HomeUOwnerBookingRequestDetailsScreen(
                                        request: request,
                                        controller: _bookingController,
                                      ),
                                ),
                              );
                              _bookingController.loadRequests();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.homeuCard,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.homeuCardShadow,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: context
                                            .colors.surfaceContainerHighest,
                                        backgroundImage: (request.tenantProfileUrl != null && request.tenantProfileUrl!.isNotEmpty)
                                            ? NetworkImage(request.tenantProfileUrl!)
                                            : null,
                                        child: (request.tenantProfileUrl == null || request.tenantProfileUrl!.isEmpty)
                                            ? Icon(
                                          Icons.person_rounded,
                                          color: context.homeuAccent,
                                          size: 20,
                                        )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          request.tenantName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: context.homeuPrimaryText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPending
                                              ? context.colors.tertiary
                                                  .withValues(alpha: 0.12)
                                              : isApproved
                                              ? context.homeuSuccess
                                                  .withValues(alpha: 0.12)
                                              : context.colors.error
                                                  .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          _statusLabel(context, request.status),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isPending
                                                ? context.colors.tertiary
                                                : isApproved
                                                ? context.homeuSuccess
                                                : context.colors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.apartment_rounded,
                                        size: 16,
                                        color: context.homeuMutedText,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          request.propertyTitle,
                                          style: TextStyle(
                                            color: context.homeuSecondaryText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 16,
                                        color: context.homeuMutedText,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        request.startDate != null
                                            ? context.l10n.ownerRequestsMoveIn(
                                                DateFormat.yMd(
                                                  Localizations.localeOf(context)
                                                      .toString(),
                                                ).format(request.startDate!),
                                                request.durationMonths,
                                              )
                                            : context.l10n
                                                .ownerRequestsFlexibleDuration(
                                                request.durationMonths,
                                              ),
                                        style: TextStyle(
                                          color: context.homeuSecondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: context.homeuSoftBorder,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.ownerRequestsMonthlyPrice(
                                          request.monthlyPrice,
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: context.homeuAccent,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            context.l10n.ownerRequestsReview,
                                            style: TextStyle(
                                              color: context.homeuAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: context.homeuAccent,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewingRequestsTab() {
    return ListenableBuilder(
      listenable: _viewingController,
      builder: (context, child) {
        if (_viewingController.isLoading &&
            _viewingController.requests.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: context.homeuAccent),
          );
        }

        final displayedRequests = List.of(_viewingController.filteredRequests)
          ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _viewingController.availableFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _viewingController.availableFilters[index];
                  final isSelected =
                      _viewingController.selectedFilter == filter;

                  final filterLabel = _filterLabel(context, filter);
                  return InkWell(
                    onTap: () => _viewingController.setFilter(filter),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.homeuAccent
                            : context.homeuCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : context.homeuSoftBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            filterLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? context.colors.onPrimary
                                  : context.homeuAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _viewingController.loadRequests,
                color: context.homeuAccent,
                child: displayedRequests.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.25,
                          ),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 48,
                                  color: context.homeuMutedText,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  context.l10n.ownerRequestsViewingsEmpty(
                                    _filterLabel(
                                      context,
                                      _viewingController.selectedFilter,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: context.homeuMutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: displayedRequests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final request = displayedRequests[index];
                          final isPending = request.status == 'Pending';
                          final isApproved = request.status == 'Approved';

                          final exactWallTime = DateTime(
                            request.scheduledAt.year,
                            request.scheduledAt.month,
                            request.scheduledAt.day,
                            request.scheduledAt.hour,
                            request.scheduledAt.minute,
                          );
                          final isPastViewingTime = DateTime.now().isAfter(exactWallTime);

                          final locale =
                              Localizations.localeOf(context).toString();
                          final timeStr =
                              DateFormat.jm(locale).format(exactWallTime);

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.homeuCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: context.homeuCardShadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor:
                                          context.colors.surfaceContainerHighest,
                                      backgroundImage: (request.tenantProfileUrl != null && request.tenantProfileUrl!.isNotEmpty)
                                          ? NetworkImage(request.tenantProfileUrl!)
                                          : null,
                                      child: (request.tenantProfileUrl == null || request.tenantProfileUrl!.isEmpty)
                                          ? Icon(
                                        Icons.person_rounded,
                                        color: context.homeuAccent,
                                        size: 20,
                                      )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        request.tenantName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.homeuPrimaryText,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isPending
                                            ? context.colors.tertiary
                                                .withValues(alpha: 0.12)
                                            : isApproved
                                            ? context.homeuSuccess
                                                .withValues(alpha: 0.12)
                                            : context.colors.error
                                                .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        _statusLabel(context, request.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPending
                                              ? context.colors.tertiary
                                              : isApproved
                                              ? context.homeuSuccess
                                              : context.colors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.apartment_rounded,
                                      size: 16,
                                      color: context.homeuMutedText,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        request.propertyTitle,
                                        style: TextStyle(
                                          color: context.homeuSecondaryText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: context.homeuMutedText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      context.l10n.ownerRequestsViewingTime(
                                        DateFormat.yMd(locale)
                                            .format(request.scheduledAt),
                                        timeStr,
                                      ),
                                      style: TextStyle(
                                        color: context.homeuAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                if (isPending) ...[
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: context.homeuSoftBorder,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _viewingController.updateStatus(
                                                request.id,
                                                'Rejected',
                                              ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                context.colors.error,
                                            side: BorderSide(
                                              color: context.colors.error,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            context.l10n.ownerRequestsDecline,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () =>
                                              _viewingController.updateStatus(
                                                request.id,
                                                'Approved',
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                context.homeuSuccess,
                                            foregroundColor:
                                                context.colors.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            context.l10n.ownerRequestsApprove,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (isApproved && isPastViewingTime) ...[
                                  const SizedBox(height: 16),
                                  Divider(
                                    color: context.homeuSoftBorder,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _viewingController.updateStatus(
                                            request.id,
                                            'Completed',
                                          ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.homeuAccent,
                                        foregroundColor:
                                            context.colors.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        context.l10n.ownerRequestsMarkCompleted,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _filterLabel(BuildContext context, String raw) {
    final t = context.l10n;
    switch (raw.toLowerCase()) {
      case 'all':
        return t.statusAll;
      case 'pending':
        return t.statusPending;
      case 'approved':
        return t.statusApproved;
      case 'rejected':
        return t.statusRejected;
      case 'completed':
        return t.statusCompleted;
      case 'awaiting response':
        return t.ownerRequestStatusAwaitingResponse;
      case 'new request':
        return t.ownerRequestStatusNewRequest;
      default:
        return raw;
    }
  }

  String _statusLabel(BuildContext context, String raw) {
    final t = context.l10n;
    switch (raw.toLowerCase()) {
      case 'pending':
      case 'pending decision':
        return t.statusPending;
      case 'approved':
        return t.statusApproved;
      case 'rejected':
        return t.statusRejected;
      case 'completed':
        return t.statusCompleted;
      case 'awaiting response':
        return t.ownerRequestStatusAwaitingResponse;
      case 'new request':
        return t.ownerRequestStatusNewRequest;
      default:
        return raw;
    }
  }
}
