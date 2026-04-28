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
    this.paymentStatus,
    this.isPast = false,
    this.propertyStatus,
    this.onTap,
    this.onPaymentScheduleTap,
    this.onReceiptTap,
  });

  final String hotelName;
  final String locationAddress;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double totalPrice;
  final double rating;
  final List<String> imageUrls;
  final String status;
  final String? paymentStatus;
  final bool isPast;
  final String? propertyStatus;
  final VoidCallback? onTap;
  final VoidCallback? onPaymentScheduleTap;
  final VoidCallback? onReceiptTap;

  @override
  Widget build(BuildContext context) {
    const purpleAccent = Color(0xFF6366F1); // Muted purple-blue
    const grayBorder = Color(0xFFF1F5F9); // Light gray-100/200

    final isPropertyRented = propertyStatus?.toLowerCase() == 'rented';
    final isPendingOrApproved = status.toLowerCase() == 'pending' || status.toLowerCase() == 'approved';
    final showRentedKillSwitch = isPropertyRented && isPendingOrApproved;
    final isRejected = status.toLowerCase() == 'rejected' || status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'canceled';

    Widget cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Section: Single large image focus
        _buildImageSection(isRejected),
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
                constraints: const BoxConstraints(maxWidth: 80),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: showRentedKillSwitch ? const Color(0xFF94A3B8) : _getStatusColor(status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    (showRentedKillSwitch ? 'Cancelled' : status).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981); // Green (Matches Viewing)
      case 'pending':
        return const Color(0xFF3B82F6); // Blue
      case 'rejected':
        return const Color(0xFFEF4444); // Red (Matches Viewing)
      case 'cancelled':
      case 'canceled':
        return const Color(0xFF94A3B8); // Muted Gray
      case 'completed':
        return const Color(0xFF6366F1); // Indigo (Matches Viewing)
      default:
        return const Color(0xFF1E3A8A);
    }
  }

  Widget _buildImageSection(bool isRejected) {
    const double mainWidth = 110;
    const double mainHeight = 130;

    Widget image = _buildImage(
      imageUrls.isNotEmpty ? imageUrls[0] : null,
      mainWidth,
      mainHeight,
    );

    if (isRejected) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: image,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: image,
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
    final dayFormat = DateFormat('E'); // Short day name (e.g., Wed) to save horizontal space

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
        Padding(
          padding: const EdgeInsets.only(right: 70), // Leave room for status badge
          child: Text(
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
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Action Buttons Row (Payment Schedule & Receipt)
        if ((onPaymentScheduleTap != null && !isPast && (status.toLowerCase() == 'approved' || status.toLowerCase() == 'paid' || status.toLowerCase() == 'active')) || onReceiptTap != null)
          Builder(builder: (context) {
            final lowerStatus = status.toLowerCase();
            final isApprovedOrActive = lowerStatus == 'approved' || lowerStatus == 'active' || lowerStatus == 'paid';
            final isPending = lowerStatus == 'pending';
            final isRejectedStatus = lowerStatus == 'rejected' || lowerStatus == 'cancelled' || lowerStatus == 'canceled';
            final isRefund = isRejectedStatus && (paymentStatus == 'Paid' || paymentStatus == 'Fully Paid');

            // Hide Receipt button if it's Approved/Active (since it's in the schedule)
            // Show Receipt button if it's Pending
            // Show Refund Receipt if it's Rejected and paid
            final shouldShowReceipt = (isPending && onReceiptTap != null) || (isRefund && onReceiptTap != null);
            final shouldShowSchedule = onPaymentScheduleTap != null && !isPast && isApprovedOrActive;

            if (!shouldShowReceipt && !shouldShowSchedule) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (shouldShowSchedule)
                    GestureDetector(
                      onTap: onPaymentScheduleTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: purpleAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: purpleAccent.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 14, color: purpleAccent),
                            const SizedBox(width: 6),
                            const Text(
                              'VIEW PAYMENT SCHEDULE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6366F1),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (shouldShowReceipt)
                    Builder(builder: (context) {
                      final receiptColor = isRefund ? Colors.orange : const Color(0xFF10B981);
                      
                      return GestureDetector(
                        onTap: onReceiptTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: receiptColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: receiptColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isRefund ? Icons.assignment_return_outlined : Icons.receipt_outlined,
                                size: 14,
                                color: receiptColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isRefund ? 'REFUND RECEIPT' : 'RECEIPT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: receiptColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        const SizedBox(height: 16),
        // Booking Stats Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildDateColumn('Move-in', checkInDate, dateFormat, dayFormat, purpleAccent)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildDateColumn('Move-out', checkOutDate, dateFormat, dayFormat, purpleAccent)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Pricing (Booking Fee)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Booking Fee',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 90),
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'RM ${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
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
