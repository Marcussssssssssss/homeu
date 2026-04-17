import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/booking_history_screen.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUHomePage extends StatefulWidget {
  const HomeUHomePage({
    super.key,
    this.tenantName = 'Aisyah',
    this.showNotificationBadge = true,
    this.showQrScanFab = true,
  });

  final String tenantName;
  final bool showNotificationBadge;
  final bool showQrScanFab;

  @override
  State<HomeUHomePage> createState() => _HomeUHomePageState();
}

class _HomeUHomePageState extends State<HomeUHomePage> {
  int _selectedNavIndex = 0;
  final PropertyRemoteDataSource _propertyRemoteDataSource = const PropertyRemoteDataSource();
  late Future<List<PropertyItem>> _propertiesFuture;

  static const List<String> _categories = [
    'Room',
    'Whole Unit',
    'Condo',
    'Landed',
    'Apartment',
  ];

  static const List<PropertyItem> _properties = [
    PropertyItem(
      id: '2861d5db-0b6f-44a2-85f2-865f99de2428',
      ownerId: '59259006-029c-4a6a-9037-48c4f9972566',
      name: 'Skyline Condo Suite',
      location: 'Mont Kiara, Kuala Lumpur',
      pricePerMonth: 'RM 2,100 / month',
      rating: 4.8,
      accentColor: Color(0xFF1E3A8A),
      description:
          'A bright condo with modern finishing, full kitchen, and great ventilation. Ideal for professionals who need quick city access and a calm neighborhood.',
      ownerName: 'Nurul Huda',
      ownerRole: 'Verified Owner',
      photoColors: [Color(0xFF5D7FBF), Color(0xFF4A68A8), Color(0xFF2F4F8F)],
    ),
    PropertyItem(
      id: 'demo-property-2',
      ownerId: 'demo-owner-2',
      name: 'Cozy Student Room',
      location: 'SS15, Subang Jaya',
      pricePerMonth: 'RM 680 / month',
      rating: 4.5,
      accentColor: Color(0xFF10B981),
      description:
          'Comfortable private room with study desk and wardrobe. Located near campus with food courts and transit options within walking distance.',
      ownerName: 'Amir Rahman',
      ownerRole: 'Host',
      photoColors: [Color(0xFF4FAF95), Color(0xFF3D9B83), Color(0xFF2B7F6B)],
    ),
    PropertyItem(
      id: 'demo-property-3',
      ownerId: 'demo-owner-3',
      name: 'Family Apartment',
      location: 'Setapak, Kuala Lumpur',
      pricePerMonth: 'RM 1,450 / month',
      rating: 4.7,
      accentColor: Color(0xFF334155),
      description:
          'Spacious apartment suitable for families, featuring two bathrooms, secure access, and nearby schools, clinics, and supermarkets.',
      ownerName: 'Sarah Lim',
      ownerRole: 'Premium Owner',
      photoColors: [Color(0xFF586476), Color(0xFF495567), Color(0xFF374151)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _propertiesFuture = AppSupabase.isInitialized
        ? _propertyRemoteDataSource.fetchPublishedProperties()
        : Future<List<PropertyItem>>.value(_properties);
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      floatingActionButton: widget.showQrScanFab
          ? FloatingActionButton.extended(
              onPressed: () {},
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HomeUBookingHistoryScreen()),
            );
            return;
          }

          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HomeUProfileScreen(
                  role: HomeURole.tenant,
                  name: widget.tenantName,
                  email: 'tenant@homeu.app',
                  phone: '+60 12 335 7788',
                ),
              ),
            );
            return;
          }

          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online_outlined),
            selectedIcon: Icon(Icons.book_online_rounded),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.06).clamp(16.0, 24.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                14,
                horizontalPadding,
                22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hello, ${widget.tenantName}',
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          if (widget.showNotificationBadge)
                            const Positioned(
                              right: 8,
                              top: 9,
                              child: _NotificationDot(),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find your next rental with a quick search.',
                    style: TextStyle(
                      color: Color(0xFF50617F),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search location, condo, house',
                      hintStyle: const TextStyle(color: Color(0xFF7384A1)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: const Icon(Icons.tune_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E3A8A),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _CategoryChip(
                                label: item,
                                isSelected: item == 'Room',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recommended Properties',
                    style: TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<PropertyItem>>(
                    future: _propertiesFuture,
                    builder: (context, snapshot) {
                      final items = (snapshot.data == null || snapshot.data!.isEmpty)
                          ? _properties
                          : snapshot.data!;

                      return Column(
                        children: items
                            .map(
                              (property) => _PropertyCard(
                                property: property,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => HomeUPropertyDetailsScreen(property: property),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                ],
              ),
            );
            },
          ),
        ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.4),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x261E3A8A)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property, required this.onTap});

  final PropertyItem property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x141E3A8A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        key: Key('property_card_${property.name}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 148,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        property.photoColors.first.withOpacity(0.9),
                        const Color(0xFFF0F5FF),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.apartment_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: property.accentColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      color: Color(0xFF1F314F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF667896),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                            color: Color(0xFF667896),
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
                      Text(
                        property.pricePerMonth,
                        style: TextStyle(
                          color: property.accentColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        property.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF1F314F),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

