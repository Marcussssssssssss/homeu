import 'package:flutter/material.dart';
import 'package:homeu/app/property/my_properties/my_properties_controller.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import '../../app/auth/homeu_session.dart';
import 'owner_add_property_screen.dart';
import 'owner_analytics_screen.dart';
import 'owner_booking_requests_screen.dart';
import 'owner_bottom_navigation_bar.dart';


class HomeUOwnerMyPropertiesScreen extends StatefulWidget {
  const HomeUOwnerMyPropertiesScreen({super.key});

  @override
  State<HomeUOwnerMyPropertiesScreen> createState() => _HomeUOwnerMyPropertiesScreenState();
}

class _HomeUOwnerMyPropertiesScreenState extends State<HomeUOwnerMyPropertiesScreen> {
  late final MyPropertiesController _controller;
  int _selectedNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _controller = MyPropertiesController();
    // Load properties immediately when the screen opens
    _controller.loadProperties();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == _selectedNavIndex) return;

          // Index 0: Dashboard (Go back to the main dashboard screen, which is the first route in the stack)
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            return;
          }

          // Index 1: Already here (My Properties)
          if (index == 1) return;

          // Index 2: Booking Requests
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerBookingRequestsScreen()),
            );
            return;
          }

          // Index 3: Analytics
          if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeUOwnerAnalyticsScreen()),
            );
            return;
          }

          // Index 4: Profile
          if (index == 4) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const HomeUProfileScreen(
                  role: HomeURole.owner,
                ),
              ),
            );
            return;
          }
        },
      ),

      // Floating Action Button to Add New Property
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
        onPressed: () async {
          // Navigate to Add Property Screen
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HomeUOwnerAddPropertyScreen(),
            ),
          );

          // If the owner successfully submitted/saved a draft, refresh the list!
          if (result == true) {
            _controller.loadProperties();
          }
        },
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          if (_controller.isLoading && _controller.properties.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (_controller.errorMessage != null && _controller.properties.isEmpty) {
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
                  Icon(Icons.home_work_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'You haven\'t listed any properties yet.',
                    style: TextStyle(color: Color(0xFF50617F), fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF1E3A8A),
            onRefresh: _controller.loadProperties,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80), // 80px bottom padding for the FAB
              itemCount: _controller.properties.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final property = _controller.properties[index];
                final imageUrl = property.coverImageUrl?.trim();
                final hasImage = imageUrl != null && imageUrl.isNotEmpty;

                // Determine styling based on status
                final isDraft = property.status == 'Draft';
                final statusColor = isDraft ? Colors.orange.shade700 : Colors.green.shade700;
                final statusBgColor = isDraft ? Colors.orange.shade50 : Colors.green.shade50;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A1E3A8A), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image Thumbnail
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: hasImage
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.broken_image_outlined, color: Color(0xFF90A4C4)),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          )
                              : const Center(
                            child: Icon(Icons.image_not_supported, color: Color(0xFF90A4C4)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Property Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.title.isEmpty ? 'Untitled Property' : property.title,
                                        style: const TextStyle(
                                          color: Color(0xFF1F314F),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      // Status Chip moved under the title for a cleaner look with the menu
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBgColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          property.status,
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
                                // NEW: Action Menu
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF90A4C4)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) async {
                                    if (value == 'publish') {
                                      await _controller.publishDraft(property.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Property published successfully!')),
                                        );
                                      }
                                    } else if (value == 'edit') {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => HomeUOwnerAddPropertyScreen(
                                            propertyId: property.id,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _controller.loadProperties();
                                      }
                                    } else if (value == 'delete') {
                                      // SHOW CONFIRMATION DIALOG
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: const Text('Delete Property?'),
                                          content: const Text(
                                            'Are you sure you want to delete this listing? This action cannot be undone.',
                                            style: TextStyle(color: Color(0xFF50617F)),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel', style: TextStyle(color: Color(0xFF667896))),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                                              child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      );

                                      // IF USER CLICKED YES, EXECUTE DELETE
                                      if (confirm == true) {
                                        final success = await _controller.deleteProperty(property.id);
                                        if (context.mounted) {
                                          if (success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Property deleted successfully.')),
                                            );
                                          } else {
                                            // NEW: Show a red error if it fails!
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(_controller.errorMessage ?? 'Failed to delete property.'),
                                                backgroundColor: Colors.red.shade600,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_rounded, size: 20, color: Color(0xFF1F314F)),
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
                                            Icon(Icons.publish_rounded, size: 20, color: Color(0xFF0F8A5F)),
                                            SizedBox(width: 10),
                                            Text('Publish Now', style: TextStyle(color: Color(0xFF0F8A5F))),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                                          SizedBox(width: 10),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
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
                              style: const TextStyle(color: Color(0xFF667896), fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'RM ${property.monthlyPrice}/mo',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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