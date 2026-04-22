import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/app/booking/booking_models.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/receipt_screen.dart';

enum HomeUMonthlyRentMethod { card, banking, ewallet }

class HomeUMonthlyRentPaymentScreen extends StatefulWidget {
  const HomeUMonthlyRentPaymentScreen({
    super.key,
    required this.booking,
    required this.property,
  });

  final BookingRequest booking;
  final PropertyItem property;

  @override
  State<HomeUMonthlyRentPaymentScreen> createState() => _HomeUMonthlyRentPaymentScreenState();
}

class _HomeUMonthlyRentPaymentScreenState extends State<HomeUMonthlyRentPaymentScreen> {
  final PaymentRemoteDataSource _paymentRemoteDataSource = const PaymentRemoteDataSource();
  HomeUMonthlyRentMethod _selectedMethod = HomeUMonthlyRentMethod.card;
  final TextEditingController _referenceController = TextEditingController();
  bool _isSubmitting = false;
  Payment? _latestPayment;

  double get _monthlyRentAmount => widget.property.pricePerMonthValue;
  double get _depositAmount => widget.booking.totalAmount > 0 ? widget.booking.totalAmount : _monthlyRentAmount;
  bool get _isApproved => widget.booking.status.trim().toLowerCase() == 'approved';

  @override
  void initState() {
    super.initState();
    _loadLatestPayment();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    if (!_isApproved) {
      return Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: const Text('Monthly Rent Payment'),
          backgroundColor: context.colors.surface,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Monthly rent payment is only available after the owner approves your booking request.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF667896), fontSize: 14, height: 1.5),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Monthly Rent Payment'),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('pay_monthly_rent_button'),
            onPressed: _isSubmitting ? null : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(_latestPayment?.status == 'Success' ? 'Rent Paid' : 'Pay Monthly Rent'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly rent is now due because your booking request has been approved.',
                style: TextStyle(
                  color: context.homeuMutedText,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                key: const Key('monthly_rent_summary_section'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.homeuCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.homeuAccent.withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rent Summary',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _summaryRow('Property', widget.property.name),
                    _summaryRow('Booking Status', widget.booking.status),
                    _summaryRow('Deposit Already Paid', 'RM ${_formatCurrency(_depositAmount)}'),
                    _summaryRow('Monthly Rent Amount', 'RM ${_formatCurrency(_monthlyRentAmount)}'),
                    const Divider(height: 18),
                    _summaryRow('Total Due Now', 'RM ${_formatCurrency(_monthlyRentAmount)}', emphasize: true),
                    if (_latestPayment != null)
                      _summaryRow('Payment Status', _latestPayment!.status),
                    const SizedBox(height: 8),
                    Text(
                      'The deposit has already been recorded. This page is for the ongoing monthly rent after approval.',
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    if (_latestPayment != null && _latestPayment!.status == 'Success') ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HomeUReceiptScreen(
                                payment: _latestPayment!,
                                propertyName: widget.property.name,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('View Receipt'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Payment Method',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<HomeUMonthlyRentMethod>(
                initialValue: _selectedMethod,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.homeuCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.homeuSoftBorder),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: HomeUMonthlyRentMethod.card,
                    child: Text('Credit / Debit Card'),
                  ),
                  DropdownMenuItem(
                    value: HomeUMonthlyRentMethod.banking,
                    child: Text('Online Banking'),
                  ),
                  DropdownMenuItem(
                    value: HomeUMonthlyRentMethod.ewallet,
                    child: Text('E-wallet'),
                  ),
                ],
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() => _selectedMethod = value);
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _referenceController,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  labelText: 'Payment Reference',
                  hintText: 'Optional receipt or reference number',
                  filled: true,
                  fillColor: context.homeuCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.homeuSoftBorder),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your monthly rent payment is separated from the initial deposit, so the booking flow stays clear and approval-based.',
                style: TextStyle(
                  color: context.homeuMutedText,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadLatestPayment() async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    final payment = await _paymentRemoteDataSource.getLatestPayment(widget.booking.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _latestPayment = payment;
    });
  }

  Future<void> _submitPayment() async {
    if (!AppSupabase.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase is not initialized. Please try again later.')),
      );
      return;
    }

    final payerId = AppSupabase.auth.currentUser?.id;
    if (payerId == null || payerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue payment.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payment = await _paymentRemoteDataSource.createPaymentSimulated(
        bookingId: widget.booking.id,
        payerId: payerId,
        method: _methodLabel(_selectedMethod),
        amount: _monthlyRentAmount,
        bookingPaymentStatus: BookingPaymentStatus.monthlyRentPaid,
        simulateSuccess: true,
      );

      if (!mounted) {
        return;
      }

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            payment.status == 'Success'
                ? 'Monthly rent payment completed successfully.'
                : 'Payment failed. Please try again.',
          ),
        ),
      );

      await _loadLatestPayment();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to process payment right now.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _methodLabel(HomeUMonthlyRentMethod method) {
    switch (method) {
      case HomeUMonthlyRentMethod.card:
        return 'Card';
      case HomeUMonthlyRentMethod.banking:
        return 'Online Banking';
      case HomeUMonthlyRentMethod.ewallet:
        return 'E-Wallet';
    }
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: context.homeuMutedText, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? context.homeuPrice : context.homeuPrimaryText,
              fontSize: emphasize ? 16 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
}


