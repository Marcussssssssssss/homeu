import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingHistoryCard extends StatelessWidget {
  const BookingHistoryCard({
    super.key,
    required this.hotelName,
    required this.locationAddress,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.rating,
    required this.imageUrls,
    required this.status,
    this.isPast = false,
    this.onTap,
  });

  final String hotelName;
  final String locationAddress;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final double rating;
  final List<String> imageUrls;
  final String status;
  final bool isPast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const purpleAccent = Color(0xFF6366F1); // Muted purple-blue
    const grayBorder = Color(0xFFF1F5F9); // Light gray-100/200

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Section: Single large image focus
        _buildImageSection(),
        const SizedBox(width: 16),
        // Right Section: Info
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
                  status.toUpperCase(),
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

  Widget _buildImageSection() {
    const double mainWidth = 110;
    const double mainHeight = 130;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _buildImage(
        imageUrls.isNotEmpty ? imageUrls[0] : null,
        mainWidth,
        mainHeight,
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
    final dateFormat = DateFormat('MMM d');
    final dayFormat = DateFormat('EEEE');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star rating above title
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 14,
              color: index < rating.floor() ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Title (Property Name)
        Text(
          hotelName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        // Location with purple pin
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: purpleAccent),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                locationAddress,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Booking Stats Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDateColumn('Move-in', checkInDate, dateFormat, dayFormat, purpleAccent),
            const SizedBox(width: 14),
            _buildDateColumn('Move-out', checkOutDate, dateFormat, dayFormat, purpleAccent),
            const Spacer(),
            // Pricing (Booking Fee)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Booking Fee',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                Text(
                  'RM ${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24, // Larger price
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateColumn(
      String label, DateTime date, DateFormat df, DateFormat ddf, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: accentColor, // Purple label
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          df.format(date),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        Text(
          ddf.format(date),
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
