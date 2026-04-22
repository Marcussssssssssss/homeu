import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/booking_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/payment_screen.dart';
import 'package:homeu/pages/home/property_item.dart';

class HomeUBookingScreen extends StatefulWidget {
  const HomeUBookingScreen({super.key, required this.property});

  final PropertyItem property;

  @override
  State<HomeUBookingScreen> createState() => _HomeUBookingScreenState();
}

class _HomeUBookingScreenState extends State<HomeUBookingScreen> {
  static const List<int> _durationOptions = [1, 3, 6, 12];
  final BookingRemoteDataSource _bookingRemoteDataSource =
      const BookingRemoteDataSource();
  int _selectedDurationMonths = 6;
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  bool _isSubmitting = false;

  double get _monthlyPrice => _extractPrice(widget.property.pricePerMonth);
  double get _totalPrice => _monthlyPrice * _selectedDurationMonths;

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Booking'),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('confirm_booking_button'),
            onPressed: _isSubmitting ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirm Booking'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Property',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _buildStepIndicator(0),
              const SizedBox(height: 24),
              Text(
                'Property Details',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                key: const Key('selected_property_summary_card'),
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
                      width: 72,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.property.photoColors.first,
                            const Color(0xFFEAF2FF),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.name,
                            style: TextStyle(
                              color: context.homeuPrimaryText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property.location,
                            style: TextStyle(
                              color: context.homeuMutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.property.pricePerMonth,
                            style: TextStyle(
                              color: context.homeuPrice,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
                'Rental Duration',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                key: const Key('rental_duration_selector'),
                spacing: 8,
                runSpacing: 8,
                children: _durationOptions.map((months) {
                  final bool isSelected = _selectedDurationMonths == months;
                  return ChoiceChip(
                    label: Text('$months month${months > 1 ? 's' : ''}'),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedDurationMonths = months;
                      });
                    },
                    selectedColor: context.homeuAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : context.homeuAccent,
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(color: context.homeuSoftBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                'Start Date',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                key: const Key('start_date_picker_field'),
                borderRadius: BorderRadius.circular(16),
                onTap: _pickStartDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.homeuCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.homeuSoftBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: context.homeuAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_startDate),
                        style: TextStyle(
                          color: context.homeuPrimaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Price Calculation',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Monthly Price',
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'RM ${_formatCurrency(_monthlyPrice)}',
                          style: TextStyle(
                            color: context.homeuPrice,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Duration ($_selectedDurationMonths months)',
                          style: TextStyle(
                            color: context.homeuMutedText,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'x $_selectedDurationMonths',
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Text(
                          'Estimated Total',
                          style: TextStyle(
                            color: context.homeuPrimaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'RM ${_formatCurrency(_totalPrice)}',
                          key: const Key('total_price_text'),
                          style: TextStyle(
                            color: context.homeuPrice,
                            fontSize: 16,
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
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final DateTime initialDate = _startDate;
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = DateTime.now().add(const Duration(days: 365 * 2));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _startDate = pickedDate;
    });
  }

  double _extractPrice(String value) {
    return widget.property.pricePerMonthValue;
  }

  Future<void> _confirmBooking() async {
    if (!AppSupabase.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Supabase is not initialized. Please try again later.'),
        ),
      );
      return;
    }

    final tenantId = AppSupabase.auth.currentUser?.id;
    if (tenantId == null || tenantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue booking.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Check for existing active booking
      final hasActive = await _bookingRemoteDataSource.hasActiveBookingForProperty(
        tenantId: tenantId,
        propertyId: widget.property.id,
      );

      if (hasActive) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You already have an active booking request for this property.'),
          ),
        );
        return;
      }

      final now = DateTime.now().toUtc();
      final booking = BookingRequest(
        id: '',
        propertyId: widget.property.id,
        ownerId: widget.property.ownerId,
        tenantId: tenantId,
        status: 'Pending',
        createdAt: now,
        updatedAt: now,
        totalAmount: _totalPrice,
        paymentStatus: 'Pending',
      );

      debugPrint(
        'Booking submit: propertyId=${widget.property.id}, ownerId=${widget.property.ownerId}, tenantId=$tenantId',
      );

      final created = await _bookingRemoteDataSource.createBooking(booking);
      if (!mounted) return;

      if (created == null || created.id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to create booking. Please try again.'),
          ),
        );
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HomeUPaymentScreen(
            bookingId: created.id,
            property: widget.property,
            durationMonths: _selectedDurationMonths,
            startDate: _startDate,
            totalPrice: _totalPrice,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Create booking failed: $e');
      debugPrint('$st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create booking failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatCurrency(double amount) {
    final rounded = amount.round();
    final source = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < source.length; i++) {
      final reverseIndex = source.length - i;
      buffer.write(source[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: [
        _buildStep(0, 'Details', currentStep >= 0, currentStep),
        _buildConnector(currentStep >= 1),
        _buildStep(1, 'Payment', currentStep >= 1, currentStep),
        _buildConnector(currentStep >= 2),
        _buildStep(2, 'Success', currentStep >= 2, currentStep),
      ],
    );
  }

  Widget _buildStep(int index, String label, bool isActive, int currentStep) {
    final color = isActive ? context.homeuAccent : context.homeuMutedText;
    final isCompleted = isActive && index < currentStep;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? context.homeuAccent : context.homeuSoftBorder,
    );
  }
}
