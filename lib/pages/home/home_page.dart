import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_auth_service.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/app/property/property_comparison_controller.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/property/property_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_details_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/property_comparison_screen.dart';
import 'package:homeu/pages/home/property_image_gallery.dart';

enum _SortOption { priceLowToHigh, priceHighToLow, newest }

class HomeUHomePage extends StatefulWidget {
  const HomeUHomePage({
    super.key,
    this.showNotificationBadge = true,
    this.showQrScanFab = true,
    this.seedProperties = const <PropertyItem>[],
  });

  final bool showNotificationBadge;
  final bool showQrScanFab;
  final List<PropertyItem> seedProperties;

  @override
  State<HomeUHomePage> createState() => _HomeUHomePageState();
}

class _HomeUHomePageState extends State<HomeUHomePage> {
  static const double _filterMinPrice = 300;
  static const double _filterMaxPrice = 5000;

  late final HomeUProfileController _profileController;
  final HomeUFavoritesController _favoritesController =
      HomeUFavoritesController.instance;
  final PropertyRemoteDataSource _propertyRemoteDataSource =
      const PropertyRemoteDataSource();
  late Future<List<PropertyItem>> _propertiesFuture;
  List<String> _categoryOptions = const <String>['Any'];
  List<String> _roomTypeOptions = const <String>['Any'];
  List<String> _furnishingOptions = const <String>['Any'];
  String _searchQuery = '';
  String _selectedPropertyType = 'Any';
  String _selectedRoomType = 'Any';
  String _selectedFurnishing = 'Any';
  double _minimumRating = 0;
  double? _minimumPrice;
  double? _maximumPrice;
  _SortOption _selectedSortOption = _SortOption.newest;

  @override
  void initState() {
    super.initState();
    final authService = HomeUAuthService.instance;
    _profileController = HomeUProfileController(
      initialProfile: HomeUProfileData(
        userId: authService.currentUserId ?? '',
        fullName: '',
        email: authService.currentSession?.user.email ?? '',
        phoneNumber: '',
        role: HomeURole.tenant,
      ),
    );
    _profileController.loadProfile();
    _hydrateFilterOptions(widget.seedProperties);
    _propertiesFuture =
        (!AppSupabase.isInitialized && widget.seedProperties.isNotEmpty)
        ? Future<List<PropertyItem>>.value(widget.seedProperties)
        : _propertyRemoteDataSource.fetchPublishedProperties();
    _propertiesFuture.then((items) {
      if (!mounted) {
        return;
      }
      final resolved = items.isEmpty ? widget.seedProperties : items;
      setState(() {
        _hydrateFilterOptions(resolved);
      });
    }).catchError((_) {
      // Keep fallback options when remote loading fails.
    });
  }

  void _hydrateFilterOptions(List<PropertyItem> items) {
    _categoryOptions = _buildOptions(items.map((item) => item.propertyType));
    _roomTypeOptions = _buildOptions(items.map((item) => item.roomType));
    _furnishingOptions = _buildOptions(items.map((item) => item.furnishing));

    if (!_categoryOptions.contains(_selectedPropertyType)) {
      _selectedPropertyType = 'Any';
    }
    if (!_roomTypeOptions.contains(_selectedRoomType)) {
      _selectedRoomType = 'Any';
    }
    if (!_furnishingOptions.contains(_selectedFurnishing)) {
      _selectedFurnishing = 'Any';
    }
  }

  List<String> _buildOptions(Iterable<String> values) {
    final options = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && value.toLowerCase() != 'any')
        .toSet()
        .toList(growable: false)
      ..sort();

    return <String>['Any', ...options];
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  String _resolvedGreetingName(HomeUProfileData profile) {
    final fullName = profile.fullName.trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = profile.email.trim();
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return '';
  }

  List<PropertyItem> _applyListingFilters(List<PropertyItem> source) {
    final filtered = source.where((property) {
      final normalizedType = property.propertyType.trim().toLowerCase();
      final matchesType =
          _selectedPropertyType == 'Any' ||
          normalizedType == _selectedPropertyType.toLowerCase();
      if (!matchesType) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        final haystack =
            '${property.name} ${property.description} ${property.location}'
                .toLowerCase();
        if (!haystack.contains(query)) {
          return false;
        }
      }

      final matchesRoomType =
          _selectedRoomType == 'Any' ||
          property.roomType.trim().toLowerCase() ==
              _selectedRoomType.toLowerCase();
      if (!matchesRoomType) {
        return false;
      }

      final matchesFurnishing =
          _selectedFurnishing == 'Any' ||
          property.furnishing.trim().toLowerCase() ==
              _selectedFurnishing.toLowerCase();
      if (!matchesFurnishing) {
        return false;
      }

      final price = property.pricePerMonthValue;
      if (_minimumPrice != null && price < _minimumPrice!) {
        return false;
      }
      if (_maximumPrice != null && price > _maximumPrice!) {
        return false;
      }

      if (property.rating < _minimumRating) {
        return false;
      }

      return true;
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_selectedSortOption) {
        case _SortOption.priceLowToHigh:
          return a.pricePerMonthValue.compareTo(b.pricePerMonthValue);
        case _SortOption.priceHighToLow:
          return b.pricePerMonthValue.compareTo(a.pricePerMonthValue);
        case _SortOption.newest:
          final aCreated = a.createdAt;
          final bCreated = b.createdAt;
          if (aCreated == null && bCreated == null) {
            return 0;
          }
          if (aCreated == null) {
            return 1;
          }
          if (bCreated == null) {
            return -1;
          }
          return bCreated.compareTo(aCreated);
      }
    });

    return filtered;
  }

  Future<void> _openFilterSheet() async {
    const lowerBound = _filterMinPrice;
    const maxBound = _filterMaxPrice;

    var selectedRoomType = _roomTypeOptions.contains(_selectedRoomType)
        ? _selectedRoomType
        : 'Any';
    var selectedFurnishing = _furnishingOptions.contains(_selectedFurnishing)
        ? _selectedFurnishing
        : 'Any';
    var minimumRating = _minimumRating;
    var range = RangeValues(
      (_minimumPrice ?? lowerBound).clamp(lowerBound, maxBound),
      (_maximumPrice ?? maxBound).clamp(lowerBound, maxBound),
    );

    final result = await showModalBottomSheet<_FilterSheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Properties',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Price Range: RM ${range.start.round()} - RM ${range.end.round()}',
                      ),
                      RangeSlider(
                        values: range,
                        min: lowerBound,
                        max: maxBound,
                        divisions: 20,
                        labels: RangeLabels(
                          'RM ${range.start.round()}',
                          'RM ${range.end.round()}',
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            range = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text('Room Type'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRoomType,
                        items: _roomTypeOptions
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setSheetState(() {
                            selectedRoomType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text('Furnishing'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedFurnishing,
                        items: _furnishingOptions
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setSheetState(() {
                            selectedFurnishing = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Text('Minimum Rating: ${minimumRating.toStringAsFixed(1)}'),
                      Slider(
                        value: minimumRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: minimumRating.toStringAsFixed(1),
                        onChanged: (value) {
                          setSheetState(() {
                            minimumRating = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop(
                                  const _FilterSheetResult.reset(),
                                );
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(sheetContext).pop(
                                  _FilterSheetResult.apply(
                                    minimumPrice: range.start,
                                    maximumPrice: range.end,
                                    roomType: selectedRoomType,
                                    furnishing: selectedFurnishing,
                                    minimumRating: minimumRating,
                                  ),
                                );
                              },
                              child: const Text('Apply'),
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
      },
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.isReset) {
      setState(() {
        _minimumPrice = null;
        _maximumPrice = null;
        _selectedRoomType = 'Any';
        _selectedFurnishing = 'Any';
        _minimumRating = 0;
      });
      return;
    }

    setState(() {
      _minimumPrice = result.minimumPrice;
      _maximumPrice = result.maximumPrice;
      _selectedRoomType = result.roomType;
      _selectedFurnishing = result.furnishing;
      _minimumRating = result.minimumRating;
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_SortOption>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Sort Properties',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              ListTile(
                leading: Icon(
                  _selectedSortOption == _SortOption.priceLowToHigh
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                ),
                title: const Text('Price: Low to High'),
                onTap: () {
                  Navigator.of(sheetContext).pop(_SortOption.priceLowToHigh);
                },
              ),
              ListTile(
                leading: Icon(
                  _selectedSortOption == _SortOption.priceHighToLow
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                ),
                title: const Text('Price: High to Low'),
                onTap: () {
                  Navigator.of(sheetContext).pop(_SortOption.priceHighToLow);
                },
              ),
              ListTile(
                leading: Icon(
                  _selectedSortOption == _SortOption.newest
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                ),
                title: const Text('Newest Listing'),
                onTap: () {
                  Navigator.of(sheetContext).pop(_SortOption.newest);
                },
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedSortOption = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_profileController, _favoritesController]),
      builder: (context, _) {
        final greetingName = _resolvedGreetingName(_profileController.profile);
        final t = context.l10n;
        final greetingText = greetingName.isEmpty
            ? t.homeGreetingAnonymous
            : t.homeGreetingWithName(greetingName);

        return Scaffold(
          backgroundColor: context.colors.surface,
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListenableBuilder(
                listenable: PropertyComparisonController.instance,
                builder: (context, _) {
                  final count =
                      PropertyComparisonController.instance.selectionCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: FloatingActionButton(
                        heroTag: 'compare_fab',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PropertyComparisonScreen(),
                            ),
                          );
                        },
                        backgroundColor: context.homeuAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        child: Badge(
                          label: Text('$count'),
                          backgroundColor: Colors.white,
                          textColor: context.homeuAccent,
                          child: const Icon(Icons.compare_arrows_rounded, size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (widget.showQrScanFab)
                FloatingActionButton.extended(
                  heroTag: 'qr_fab',
                  onPressed: () {},
                  backgroundColor: context.homeuAccent,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(t.homeScanQr),
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
                              greetingText,
                              style: TextStyle(
                                color: context.homeuPrimaryText,
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
                                icon: Icon(
                                  Icons.notifications_none_rounded,
                                  color: context.homeuAccent,
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
                      Text(
                        t.homeQuickSearchSubtitle,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: t.homeSearchHint,
                          hintStyle: TextStyle(color: context.homeuHelperText),
                          filled: true,
                          fillColor: context.homeuCard,
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuSoftBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuSoftBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: context.homeuAccent,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.homeCategories,
                              style: TextStyle(
                                color: context.homeuPrimaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('listing_filter_button'),
                            onPressed: _openFilterSheet,
                            icon: const Icon(Icons.tune_rounded),
                            tooltip: 'Filter properties',
                          ),
                          IconButton(
                            key: const Key('listing_sort_button'),
                            onPressed: _openSortSheet,
                            icon: const Icon(Icons.swap_vert_rounded),
                            tooltip: 'Sort properties',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categoryOptions
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _CategoryChip(
                                    label: item,
                                    isSelected: item == _selectedPropertyType,
                                    onTap: () {
                                      setState(() {
                                        _selectedPropertyType = item;
                                      });
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.homeRecommendedProperties,
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<PropertyItem>>(
                        future: _propertiesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasError && widget.seedProperties.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'Unable to load properties. ${snapshot.error}',
                                style: const TextStyle(
                                  color: Color(0xFFC53030),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          final items =
                              (snapshot.data == null || snapshot.data!.isEmpty)
                              ? widget.seedProperties
                              : snapshot.data!;
                          final filteredItems = _applyListingFilters(items);

                          if (filteredItems.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No properties available right now.',
                                style: TextStyle(
                                  color: Color(0xFF667896),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: filteredItems
                                .map(
                                  (property) => _PropertyCard(
                                    property: property,
                                    isFavorited: _favoritesController.isFavorited(
                                      property.id,
                                    ),
                                    onToggleFavorite: () {
                                      _favoritesController.toggle(property);
                                    },
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              HomeUPropertyDetailsScreen(
                                                property: property,
                                              ),
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
      },
    );
  }
}

class _FilterSheetResult {
  const _FilterSheetResult.apply({
    required this.minimumPrice,
    required this.maximumPrice,
    required this.roomType,
    required this.furnishing,
    required this.minimumRating,
  }) : isReset = false;

  const _FilterSheetResult.reset()
    : minimumPrice = null,
      maximumPrice = null,
      roomType = 'Any',
      furnishing = 'Any',
      minimumRating = 0,
      isReset = true;

  final double? minimumPrice;
  final double? maximumPrice;
  final String roomType;
  final String furnishing;
  final double minimumRating;
  final bool isReset;
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: context.homeuSuccess,
        shape: BoxShape.circle,
        border: Border.all(color: context.homeuCard, width: 1.4),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.homeuAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accent : context.homeuCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.homeuSoftBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.onTap,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  final PropertyItem property;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
                PropertyImageGallery(
                  key: ValueKey('home_gallery_${property.id}'),
                  imageUrls: property.imageUrls,
                  onTap: onTap,
                  limit: 3,
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.homeuCard,
                    child: IconButton(
                      key: Key('favorite_toggle_${property.id}'),
                      padding: EdgeInsets.zero,
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorited
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: property.accentColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: ListenableBuilder(
                    listenable: PropertyComparisonController.instance,
                    builder: (context, _) {
                      final isSelected = PropertyComparisonController.instance
                          .isSelected(property.id);
                      final canAdd =
                          PropertyComparisonController.instance.canAddMore ||
                          isSelected;
                      return GestureDetector(
                        onTap: canAdd
                            ? () {
                              final controller = PropertyComparisonController.instance;
                              controller.toggleProperty(property);
                              final nowSelected = controller.isSelected(property.id);
                              
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(nowSelected 
                                    ? 'Added ${property.name} to comparison' 
                                    : 'Removed ${property.name} from comparison'),
                                  duration: const Duration(seconds: 2),
                                  action: nowSelected ? SnackBarAction(
                                    label: 'COMPARE',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const PropertyComparisonScreen(),
                                        ),
                                      );
                                    },
                                  ) : null,
                                ),
                              );
                            }
                            : null,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: isSelected
                              ? context.homeuAccent
                              : context.homeuCard,
                          child: Icon(
                            isSelected
                                ? Icons.check_rounded
                                : Icons.compare_arrows_rounded,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : context.homeuAccent,
                          ),
                        ),
                      );
                    },
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
                    style: TextStyle(
                      color: context.homeuPrimaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: context.homeuMutedText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
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
                      Text(
                        property.pricePerMonth,
                        style: TextStyle(
                          color: context.homeuPrice,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: context.homeuPrimaryText,
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
