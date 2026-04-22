import 'package:flutter/material.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUPropertyCard extends StatelessWidget {
  const HomeUPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  final PropertyItem property;
  final VoidCallback onTap;

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
                SizedBox(
                  height: 148,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        property.imageUrl != null &&
                            property.imageUrl!.isNotEmpty
                        ? Image.network(
                            property.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _FallbackPropertyHeader(property: property),
                          )
                        : _FallbackPropertyHeader(property: property),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: context.homeuCard,
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 18,
                      color: property.accentColor,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.homeuCard.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.homeuSoftBorder),
                    ),
                    child: Text(
                      property.status,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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

class _FallbackPropertyHeader extends StatelessWidget {
  const _FallbackPropertyHeader({required this.property});

  final PropertyItem property;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            property.photoColors.first.withValues(alpha: 0.9),
            context.isDarkMode
                ? const Color(0xFF243047)
                : const Color(0xFFF0F5FF),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.apartment_rounded, size: 56, color: Colors.white),
      ),
    );
  }
}
