import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/booking_screen.dart';
import 'package:homeu/pages/home/chat_screen.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUPropertyDetailsScreen extends StatefulWidget {
  const HomeUPropertyDetailsScreen({super.key, required this.property});

  final PropertyItem property;

  @override
  State<HomeUPropertyDetailsScreen> createState() => _HomeUPropertyDetailsScreenState();
}

class _HomeUPropertyDetailsScreenState extends State<HomeUPropertyDetailsScreen> {
  final PageController _pageController = PageController();
  final HomeUFavoritesController _favoritesController = HomeUFavoritesController.instance;
  int _activeImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getFacilityIcon(String facility) {
    final f = facility.toLowerCase();
    if (f.contains('wifi')) return Icons.wifi_rounded;
    if (f.contains('parking')) return Icons.local_parking_rounded;
    if (f.contains('aircond')) return Icons.ac_unit_rounded;
    if (f.contains('lift')) return Icons.elevator_rounded;
    if (f.contains('gym')) return Icons.fitness_center_rounded;
    if (f.contains('swimming pool') || f.contains('pool')) return Icons.pool_rounded;
    if (f.contains('security')) return Icons.security_rounded;
    if (f.contains('balcony')) return Icons.balcony_rounded;
    if (f.contains('playground')) return Icons.child_care_rounded;
    if (f.contains('washing machine')) return Icons.local_laundry_service_rounded;
    if (f.contains('bbq') || f.contains('pit')) return Icons.outdoor_grill_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    final property = widget.property;

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
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                key: const Key('chat_with_owner_button'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HomeUChatScreen.start(property: property),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E3A8A)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Chat with Owner',
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
                      builder: (_) => HomeUBookingScreen(property: property),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: PageView.builder(
                    key: const Key('property_image_carousel'),
                    controller: _pageController,
                    itemCount: property.photoColors.length,
                    onPageChanged: (index) {
                      setState(() {
                        _activeImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              property.photoColors[index].withValues(alpha: 0.95),
                              const Color(0xFFF2F6FF),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 82,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(property.photoColors.length, (index) {
                  final bool isActive = index == _activeImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.homeuAccent
                          : context.homeuAccent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
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
                      offset: Offset(0, 4),
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
              Text(
                'Owner Information',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.homeuCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.homeuAccent.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0x1F1E3A8A),
                      child: Icon(Icons.person_rounded, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.ownerName,
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
                    IconButton(
                      key: const Key('owner_contact_shortcut'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => HomeUChatScreen.start(property: property),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      color: context.homeuAccent,
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
