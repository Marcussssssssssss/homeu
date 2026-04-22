import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';

import 'package:homeu/pages/home/receipt_screen.dart';

enum HomeUPaymentMethod { card, banking, ewallet }

class HomeUPaymentScreen extends StatefulWidget {
  const HomeUPaymentScreen({
    super.key,
    required this.bookingId,
    required this.property,
    required this.durationMonths,
    required this.startDate,
    required this.totalPrice,
  });

  final String bookingId;
  final PropertyItem property;
  final int durationMonths;
  final DateTime startDate;
  final double totalPrice;

  @override
  State<HomeUPaymentScreen> createState() => _HomeUPaymentScreenState();
}

class _HomeUPaymentScreenState extends State<HomeUPaymentScreen> {
  final PaymentRemoteDataSource _paymentRemoteDataSource = const PaymentRemoteDataSource();
  HomeUPaymentMethod _selectedMethod = HomeUPaymentMethod.card;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  bool _showCardBack = false;
  bool _isSubmittingPayment = false;
  Payment? _latestPayment;

  @override
  void initState() {
    super.initState();
    _loadLatestPayment();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.tenant)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.tenant);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('pay_now_button'),
            onPressed: _isSubmittingPayment ? null : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.homeuAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            child: _isSubmittingPayment
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Pay Now'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(1),
              const SizedBox(height: 24),
              Text(
                'Payment Method',
                style: TextStyle(
                  color: context.homeuPrimaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _PaymentMethodTile(
                label: 'Credit / Debit Card',
                icon: Icons.credit_card_rounded,
                selected: _selectedMethod == HomeUPaymentMethod.card,
                onTap: () {
                  setState(() {
                    _selectedMethod = HomeUPaymentMethod.card;
                  });
                },
              ),
              _PaymentMethodTile(
                label: 'Online Banking',
                icon: Icons.account_balance_rounded,
                selected: _selectedMethod == HomeUPaymentMethod.banking,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedMethod = HomeUPaymentMethod.banking;
                    _showCardBack = false;
                  });
                },
              ),
              _PaymentMethodTile(
                label: 'E-wallet',
                icon: Icons.account_balance_wallet_rounded,
                selected: _selectedMethod == HomeUPaymentMethod.ewallet,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedMethod = HomeUPaymentMethod.ewallet;
                    _showCardBack = false;
                  });
                },
              ),
              if (_selectedMethod == HomeUPaymentMethod.card) ...[
                const SizedBox(height: 14),
                _FlippingCardVisual(
                  showBack: _showCardBack,
                  showCvvHighlight: _cvvFocus.hasFocus,
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('card_number_field'),
                  controller: _cardNumberController,
                  focusNode: _cardNumberFocus,
                  onTap: () {
                    if (_showCardBack) {
                      setState(() {
                        _showCardBack = false;
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(context, 'Card Number', '1234 5678 9012 3456'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('expiry_field'),
                        controller: _expiryController,
                        focusNode: _expiryFocus,
                        onTap: () {
                          if (_showCardBack) {
                            setState(() {
                              _showCardBack = false;
                            });
                          }
                        },
                        keyboardType: TextInputType.datetime,
                        decoration: _fieldDecoration(context, 'Expiry', 'MM/YY'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        key: const Key('cvv_field'),
                        controller: _cvvController,
                        focusNode: _cvvFocus,
                        onTap: () {
                          if (!_showCardBack) {
                            setState(() {
                              _showCardBack = true;
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: _fieldDecoration(context, 'CVV', '***'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              Container(
                key: const Key('payment_summary_section'),
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
                      'Payment Summary',
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _summaryRow('Property', widget.property.name),
                    _summaryRow('Start Date', _formatDate(widget.startDate)),
                    _summaryRow('Duration', '${widget.durationMonths} months'),
                    if (_latestPayment != null)
                      _summaryRow('Payment Status', _latestPayment!.status),
                    const Divider(height: 18),
                    _summaryRow('Total Amount', 'RM ${_formatCurrency(widget.totalPrice)}', emphasize: true),
                    if (_latestPayment != null && _latestPayment!.status == 'Success') ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeUReceiptScreen(
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
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(BuildContext context, String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: context.homeuCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.homeuSoftBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.homeuSoftBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: context.homeuAccent, width: 1.2),
      ),
    );
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

  Future<void> _loadLatestPayment() async {
    if (!AppSupabase.isInitialized) {
      return;
    }

    final payment = await _paymentRemoteDataSource.getLatestPayment(widget.bookingId);
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

    if (_selectedMethod == HomeUPaymentMethod.card) {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all card details.')),
        );
        return;
      }
    }

    final payerId = AppSupabase.auth.currentUser?.id;
    if (payerId == null || payerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue payment.')),
      );
      return;
    }

    setState(() {
      _isSubmittingPayment = true;
    });

    try {
      final payment = await _paymentRemoteDataSource.createPaymentSimulated(
        bookingId: widget.bookingId,
        payerId: payerId,
        method: _methodLabel(_selectedMethod),
        amount: widget.totalPrice,
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
                ? 'Payment completed successfully.'
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
          _isSubmittingPayment = false;
        });
      }
    }
  }

  String _methodLabel(HomeUPaymentMethod method) {
    switch (method) {
      case HomeUPaymentMethod.card:
        return 'Card';
      case HomeUPaymentMethod.banking:
        return 'Online Banking';
      case HomeUPaymentMethod.ewallet:
        return 'E-Wallet';
    }
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: context.homeuCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? context.homeuAccent : context.homeuSoftBorder,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: context.homeuAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: context.homeuAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlippingCardVisual extends StatelessWidget {
  const _FlippingCardVisual({required this.showBack, required this.showCvvHighlight});

  final bool showBack;
  final bool showCvvHighlight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('credit_card_visual'),
      height: 190,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          final rotation = Tween<double>(begin: math.pi / 2, end: 0).animate(animation);

          return AnimatedBuilder(
            animation: rotation,
            child: child,
            builder: (context, childWidget) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(rotation.value),
                child: childWidget,
              );
            },
          );
        },
        child: DecoratedBox(
          key: ValueKey<String>(showBack ? 'card-back' : 'card-front'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF2F55B5)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x331E3A8A),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: showBack
              ? _CardBackFace(showCvvHighlight: showCvvHighlight)
              : const _CardFrontFace(),
        ),
      ),
    );
  }
}

class _CardFrontFace extends StatelessWidget {
  const _CardFrontFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('card_front_side'),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card_rounded, color: Colors.white),
              Spacer(),
              Text('HomeU Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          Spacer(),
          Text(
            '****  ****  ****  3456',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                'CARD HOLDER',
                style: TextStyle(color: Color(0xCCE9EEFF), fontSize: 10, fontWeight: FontWeight.w600),
              ),
              Spacer(),
              Text(
                'EXPIRES',
                style: TextStyle(color: Color(0xCCE9EEFF), fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 3),
          Row(
            children: [
              Text('AISYAH R.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Spacer(),
              Text('08/29', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBackFace extends StatelessWidget {
  const _CardBackFace({required this.showCvvHighlight});

  final bool showCvvHighlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('card_back_side'),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(height: 38, color: const Color(0xFF192C66)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              key: const Key('cvv_highlight_area'),
              height: 38,
              decoration: BoxDecoration(
                color: showCvvHighlight ? const Color(0xFFE8F2FF) : const Color(0xFFF4F7FD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: showCvvHighlight ? const Color(0xFF10B981) : const Color(0x331E3A8A),
                  width: showCvvHighlight ? 1.4 : 1,
                ),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: const Text(
                '***',
                style: TextStyle(
                  color: Color(0xFF1F314F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'For your security, never share your CVV with anyone.',
              style: TextStyle(
                color: Color(0xFFDDE6FF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




