import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/pages/home/property_item.dart';

enum HomeUPaymentMethod { card, banking, ewallet }

class HomeUPaymentScreen extends StatefulWidget {
  const HomeUPaymentScreen({
    super.key,
    required this.property,
    required this.durationMonths,
    required this.startDate,
    required this.totalPrice,
  });

  final PropertyItem property;
  final int durationMonths;
  final DateTime startDate;
  final double totalPrice;

  @override
  State<HomeUPaymentScreen> createState() => _HomeUPaymentScreenState();
}

class _HomeUPaymentScreenState extends State<HomeUPaymentScreen> {
  HomeUPaymentMethod _selectedMethod = HomeUPaymentMethod.card;
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();
  bool _showCardBack = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('pay_now_button'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment completed successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            child: const Text('Pay Now'),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: Color(0xFF1F314F),
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
                  focusNode: _cardNumberFocus,
                  onTap: () {
                    if (_showCardBack) {
                      setState(() {
                        _showCardBack = false;
                      });
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('Card Number', '1234 5678 9012 3456'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('expiry_field'),
                        focusNode: _expiryFocus,
                        onTap: () {
                          if (_showCardBack) {
                            setState(() {
                              _showCardBack = false;
                            });
                          }
                        },
                        keyboardType: TextInputType.datetime,
                        decoration: _fieldDecoration('Expiry', 'MM/YY'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        key: const Key('cvv_field'),
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
                        decoration: _fieldDecoration('CVV', '***'),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E3A8A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        color: Color(0xFF1F314F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _summaryRow('Property', widget.property.name),
                    _summaryRow('Start Date', _formatDate(widget.startDate)),
                    _summaryRow('Duration', '${widget.durationMonths} months'),
                    const Divider(height: 18),
                    _summaryRow('Total Amount', 'RM ${_formatCurrency(widget.totalPrice)}', emphasize: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x1F1E3A8A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
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
            style: const TextStyle(color: Color(0xFF667896), fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: emphasize ? const Color(0xFF1E3A8A) : const Color(0xFF1F314F),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? const Color(0xFF1E3A8A) : const Color(0x1F1E3A8A),
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1F314F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: const Color(0xFF1E3A8A),
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




