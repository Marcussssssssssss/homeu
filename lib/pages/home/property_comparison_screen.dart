import 'package:flutter/material.dart';
import 'package:homeu/app/property/property_comparison_controller.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/property_image_gallery.dart';

class PropertyComparisonScreen extends StatefulWidget {
  const PropertyComparisonScreen({super.key});

  @override
  State<PropertyComparisonScreen> createState() =>
      _PropertyComparisonScreenState();
}

class _PropertyComparisonScreenState extends State<PropertyComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Compare Properties'),
        backgroundColor: context.colors.surface,
        elevation: 1,
        actions: [
          ListenableBuilder(
            listenable: PropertyComparisonController.instance,
            builder: (context, _) {
              final count =
                  PropertyComparisonController.instance.selectionCount;
              if (count > 0) {
                return TextButton(
                  onPressed: () {
                    PropertyComparisonController.instance.clearSelection();
                  },
                  child: Text(
                    'Clear',
                    style: TextStyle(color: context.homeuAccent),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: PropertyComparisonController.instance,
        builder: (context, _) {
          final selected =
              PropertyComparisonController.instance.selectedProperties;

          if (selected.isEmpty) {
            return _EmptyComparisonState(context: context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Comparison content
                _ComparisonCardView(properties: selected),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyComparisonState extends StatelessWidget {
  const _EmptyComparisonState({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.homeuAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.compare_arrows_rounded,
              size: 40,
              color: context.homeuAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Properties Selected',
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back and select 2 properties\nto start comparing',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.homeuSecondaryText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Listings'),
          ),
        ],
      ),
    );
  }
}

class _ComparisonCardView extends StatelessWidget {
  const _ComparisonCardView({required this.properties});

  final List<PropertyItem> properties;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Price comparison highlight
          _PriceComparisonWidget(properties: properties),
          const SizedBox(height: 20),
          // Property cards
          Row(
            children: properties
                .asMap()
                .entries
                .map(
                  (entry) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: entry.key == 0 ? 8 : 0,
                        left: entry.key == 1 ? 8 : 0,
                      ),
                      child: _PropertyComparisonCard(
                        property: entry.value,
                        index: entry.key,
                        totalCount: properties.length,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          // Detailed comparison rows
          _DetailedComparisonRows(properties: properties),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PriceComparisonWidget extends StatelessWidget {
  const _PriceComparisonWidget({required this.properties});

  final List<PropertyItem> properties;

  @override
  Widget build(BuildContext context) {
    if (properties.length < 2) return const SizedBox.shrink();

    final prices = properties.map((p) => p.pricePerMonthValue).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.homeuAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_down_rounded,
            color: context.homeuAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Range',
                  style: TextStyle(
                    color: context.homeuMutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'RM ${minPrice.toStringAsFixed(0)} - RM ${maxPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: context.homeuPrice,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Save RM ${(maxPrice - minPrice).toStringAsFixed(0)}',
            style: TextStyle(
              color: context.homeuSuccess,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyComparisonCard extends StatelessWidget {
  const _PropertyComparisonCard({
    required this.property,
    required this.index,
    required this.totalCount,
  });

  final PropertyItem property;
  final int index;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              PropertyImageGallery(
                colors: property.photoColors,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: () {
                    PropertyComparisonController.instance
                        .removeProperty(property.id);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.pricePerMonth,
                  style: TextStyle(
                    color: context.homeuPrice,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      property.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailedComparisonRows extends StatelessWidget {
  const _DetailedComparisonRows({required this.properties});

  final List<PropertyItem> properties;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Location', properties.map((p) => p.location).toList()),
      ('Type', properties.map((p) => p.propertyType).toList()),
      ('Rooms', properties.map((p) => p.roomType).toList()),
      ('Furnishing', properties.map((p) => p.furnishing).toList()),
      ('Owner', properties.map((p) => p.ownerName).toList()),
      ('Nearby', properties.map((p) => p.nearbyLandmarks).toList()),
    ];

    return Column(
      children: rows
          .asMap()
          .entries
          .map(
            (entry) => _ComparisonRow(
              label: entry.value.$1,
              values: entry.value.$2,
            ),
          )
          .toList(),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.values,
  });

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.homeuSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.homeuMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: values
                .map(
                  (value) => Expanded(
                    child: Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
