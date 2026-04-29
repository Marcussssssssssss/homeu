import 'package:flutter/material.dart';
import 'package:homeu/app/property/my_properties/my_properties_controller.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import '../../app/auth/homeu_session.dart';
import 'owner_add_property_screen.dart';
import 'owner_analytics_screen.dart';
import 'owner_booking_requests_screen.dart';
import 'owner_bottom_navigation_bar.dart';
import 'owner_property_details_screen.dart';

class HomeUOwnerMyPropertiesScreen extends StatefulWidget {
  const HomeUOwnerMyPropertiesScreen({
    super.key,
    this.showBottomNavigationBar = true,
  });

  final bool showBottomNavigationBar;

  @override
  State<HomeUOwnerMyPropertiesScreen> createState() =>
      _HomeUOwnerMyPropertiesScreenState();
}

class _HomeUOwnerMyPropertiesScreenState
    extends State<HomeUOwnerMyPropertiesScreen> {
  late final MyPropertiesController _controller;
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _controller = MyPropertiesController();
    _controller.loadProperties();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Properties',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: widget.showBottomNavigationBar
          ? HomeUOwnerBottomNavigationBar(
              selectedIndex: _selectedNavIndex,
              onDestinationSelected: (index) {
                if (index == _selectedNavIndex) return;

                if (index == 0) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  return;
                }
                if (index == 1) return;
                if (index == 2) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeUOwnerBookingRequestsScreen(),
                    ),
                  );
                  return;
                }
                if (index == 3) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeUOwnerAnalyticsScreen(),
                    ),
                  );
                  return;
                }
                if (index == 4) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomeUConversationListScreen(),
                    ),
                  );
                  return;
                }
                if (index == 5) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          const HomeUProfileScreen(role: HomeURole.owner),
                    ),
                  );
                  return;
                }
              },
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HomeUOwnerAddPropertyScreen(),
            ),
          );
          if (result == true) _controller.loadProperties();
        },
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading && _controller.properties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null &&
              _controller.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(_controller.errorMessage!),
                  TextButton(
                    onPressed: _controller.loadProperties,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_controller.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t listed any properties yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: _controller.loadProperties,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _controller.properties.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final property = _controller.properties[index];
                final imageUrl = property.coverImageUrl?.trim();
                final hasImage = imageUrl != null && imageUrl.isNotEmpty;
                final isDraft = property.status == 'Draft';

                // THE SMART UI STATUS
                final displayStatus = property.displayStatus;
                Color statusColor;
                Color statusBgColor;

                if (displayStatus == 'Draft') {
                  statusColor = Colors.orange.shade700;
                  statusBgColor = statusColor.withValues(
                    alpha: context.isDarkMode ? 0.22 : 0.12,
                  );
                } else if (displayStatus == 'Booked') {
                  statusColor = Colors.teal.shade700;
                  statusBgColor = statusColor.withValues(
                    alpha: context.isDarkMode ? 0.24 : 0.12,
                  );
                } else if (displayStatus == 'Expiring Soon') {
                  statusColor = Colors.amber.shade700;
                  statusBgColor = statusColor.withValues(
                    alpha: context.isDarkMode ? 0.22 : 0.12,
                  );
                } else if (displayStatus == 'Occupied') {
                  statusColor = const Color(0xFF0F8A5F);
                  statusBgColor = statusColor.withValues(
                    alpha: context.isDarkMode ? 0.24 : 0.12,
                  );
                } else {
                  // Active
                  statusColor = colorScheme.primary;
                  statusBgColor = colorScheme.primary.withValues(
                    alpha: context.isDarkMode ? 0.24 : 0.12,
                  );
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HomeUOwnerPropertyDetailsScreen(
                            property: property,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.homeuCard,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.homeuCardShadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: hasImage
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      loadingBuilder:
                                          (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            property.title.isEmpty
                                                ? 'Untitled Property'
                                                : property.title,
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              displayStatus,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert_rounded,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) async {
                                        if (value == 'publish') {
                                          await _controller.publishDraft(
                                            property.id,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Property published successfully!',
                                                ),
                                              ),
                                            );
                                          }
                                        } else if (value == 'edit') {
                                          final result =
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomeUOwnerAddPropertyScreen(
                                                        propertyId: property.id,
                                                      ),
                                                ),
                                              );
                                          if (result == true)
                                            _controller.loadProperties();
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              title: const Text(
                                                'Delete Property?',
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete this listing? This action cannot be undone.',
                                                style: TextStyle(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red.shade600,
                                                      ),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            final errorMsg = await _controller
                                                .archiveProperty(property.id);
                                            if (context.mounted) {
                                              if (errorMsg == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Property deleted successfully.',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(errorMsg),
                                                    backgroundColor:
                                                        Colors.red.shade600,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_rounded,
                                                size: 20,
                                                color: colorScheme.onSurface,
                                              ),
                                              SizedBox(width: 10),
                                              Text('Edit Property'),
                                            ],
                                          ),
                                        ),
                                        if (isDraft)
                                          const PopupMenuItem(
                                            value: 'publish',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.publish_rounded,
                                                  size: 20,
                                                  color: Color(0xFF0F8A5F),
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Publish Now',
                                                  style: TextStyle(
                                                    color: Color(0xFF0F8A5F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline_rounded,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  property.locationArea,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'RM ${property.monthlyPrice}/mo',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
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
            ),
          );
        },
      ),
    );
  }
}
