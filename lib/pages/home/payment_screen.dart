import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/config/app_env.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/app/booking/payment_remote_datasource.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/home_tenant_shell_screen.dart';

enum HomeUPaymentMethod { card, banking, ewallet }

class HomeUPaymentScreen extends StatefulWidget {
  const HomeUPaymentScreen({
    super.key,
    required this.bookingId,
    required this.property,
    required this.durationMonths,
    required this.startDate,
    required this.totalPrice,
    this.scheduleId,
    this.isInstallment = false,
    this.monthNumber,
  });

  final String bookingId;
  final PropertyItem property;
  final int durationMonths;
  final DateTime startDate;
  final double totalPrice;
  final String? scheduleId;
  final bool isInstallment;
  final int? monthNumber;

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
  String? _selectedBank;
  String? _selectedEWallet;

  final List<Map<String, String>> _eWallets = [
    {
      'name': 'TNG eWallet',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/tng-logo.jpg'
    },
  ];

  final List<Map<String, String>> _banks = [
    {
      'name': 'CIMB Bank',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/cimb-bank-logo-vector.png'
    },
    {
      'name': 'Maybank',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/Maybank-logo.png'
    },
    {
      'name': 'Public Bank',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/public-bank-logo.png'
    },
    {
      'name': 'RHB Bank',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/rhb-bank-logo.png'
    },
    {
      'name': 'Hong Leong Bank',
      'logo': '${AppEnv.supabaseUrl}/storage/v1/object/public/bankassets/HLB-logo.webp'
    },
  ];

  bool get _isFormValid {
    if (_selectedMethod == HomeUPaymentMethod.banking) {
      return _selectedBank != null;
    }
    if (_selectedMethod == HomeUPaymentMethod.ewallet) {
      return _selectedEWallet != null;
    }
    if (_selectedMethod != HomeUPaymentMethod.card) return true;

    final cardNum = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text;
    final cvv = _cvvController.text;

    return cardNum.length == 16 && _getExpiryError(expiry) == null && cvv.length == 3;
  }

  String? _getExpiryError(String value) {
    if (value.isEmpty) return null;
    if (value.length < 5) return 'Incomplete';

    try {
      final month = int.parse(value.substring(0, 2));
      final year = int.parse(value.substring(3, 5));

      if (month < 1 || month > 12) {
        return 'Invalid Month';
      }

      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;

      if (year < currentYear) {
        return 'Card has expired';
      }

      if (year == currentYear && month < currentMonth) {
        return 'Card has expired';
      }
    } catch (e) {
      return 'Invalid Format';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isInstallment) {
      _loadLatestPayment();
    }
    
    _cardNumberController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
    _cvvController.addListener(() => setState(() {}));
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

    final bool isSuccess = _latestPayment?.status == 'Success';

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
            onPressed: (_isSubmittingPayment || isSuccess || !_isFormValid) ? null : _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: (isSuccess || !_isFormValid) ? Colors.grey : context.homeuAccent,
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
                : Text(isSuccess ? 'Payment Completed' : 'Pay Now'),
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
              if (_selectedMethod == HomeUPaymentMethod.banking) ...[
                const SizedBox(height: 14),
                Text(
                  'Select Bank',
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _banks.length,
                  itemBuilder: (context, index) {
                    final bank = _banks[index];
                    final isSelected = _selectedBank == bank['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank['name'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF1E3A8A).withOpacity(0.05) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[200]!,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                              blurRadius: isSelected ? 8 : 4,
                              offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Image.network(
                                      bank['logo']!,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.account_balance_rounded, color: Colors.grey, size: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  bank['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFF1E3A8A) : context.homeuPrimaryText,
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              const Positioned(
                                top: -4,
                                right: -4,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1E3A8A),
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              _PaymentMethodTile(
                label: 'E-wallet',
                icon: Icons.account_balance_wallet_rounded,
                selected: _selectedMethod == HomeUPaymentMethod.ewallet,
                onTap: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _selectedMethod = HomeUPaymentMethod.ewallet;
                    _showCardBack = false;
                    _selectedEWallet = 'TNG eWallet';
                  });
                },
              ),
              if (_selectedMethod == HomeUPaymentMethod.ewallet) ...[
                const SizedBox(height: 14),
                Text(
                  'Select E-Wallet',
                  style: TextStyle(
                    color: context.homeuPrimaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _eWallets.length,
                  itemBuilder: (context, index) {
                    final wallet = _eWallets[index];
                    final isSelected = _selectedEWallet == wallet['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedEWallet = wallet['name'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF1E3A8A).withOpacity(0.05) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[200]!,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                              blurRadius: isSelected ? 8 : 4,
                              offset: isSelected ? const Offset(0, 4) : const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Image.network(
                                      wallet['logo']!,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey, size: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  wallet['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? const Color(0xFF1E3A8A) : context.homeuPrimaryText,
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              const Positioned(
                                top: -4,
                                right: -4,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF1E3A8A),
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
              if (_selectedMethod == HomeUPaymentMethod.card) ...[
                const SizedBox(height: 14),
                _FlippingCardVisual(
                  showBack: _showCardBack,
                  showCvvHighlight: _cvvFocus.hasFocus,
                  cardNumber: _cardNumberController.text,
                  expiry: _expiryController.text,
                  cvv: _cvvController.text,
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    const _CardNumberFormatter(),
                  ],
                  decoration: _fieldDecoration(
                    context, 
                    'Card Number', 
                    '1234 5678 9012 3456',
                    errorText: _cardNumberController.text.isNotEmpty && _cardNumberController.text.replaceAll(' ', '').length < 16
                        ? 'Enter a valid 16-digit card number'
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                          LengthLimitingTextInputFormatter(5),
                          const _ExpiryFormatter(),
                        ],
                        decoration: _fieldDecoration(
                          context, 
                          'Expiry', 
                          'MM/YY',
                          errorText: _getExpiryError(_expiryController.text),
                        ),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: _fieldDecoration(
                          context, 
                          'CVV', 
                          '***',
                          errorText: _cvvController.text.isNotEmpty && _cvvController.text.length < 3
                              ? 'Invalid'
                              : null,
                        ),
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
                    _summaryRow('Duration', widget.isInstallment ? 'Monthly Rent' : '${widget.durationMonths} months'),
                    _summaryRow(
                      'Payment Method', 
                      _selectedMethod == HomeUPaymentMethod.banking && _selectedBank != null
                          ? 'Online Banking ($_selectedBank)'
                          : _selectedMethod == HomeUPaymentMethod.ewallet && _selectedEWallet != null
                              ? 'E-Wallet ($_selectedEWallet)'
                              : _methodLabel(_selectedMethod)
                    ),
                    if (_latestPayment != null)
                      _summaryRow('Payment Status', _latestPayment!.status),
                    const Divider(height: 18),
                    _summaryRow(
                      widget.isInstallment 
                          ? 'Rent Payment (Month ${widget.monthNumber})' 
                          : 'Booking Fee (1 Month)', 
                      'RM ${_formatCurrency(widget.totalPrice)}', 
                      emphasize: true
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

  InputDecoration _fieldDecoration(BuildContext context, String label, String hint, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: context.homeuMutedText, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: emphasize ? context.homeuPrice : context.homeuPrimaryText,
                fontSize: emphasize ? 16 : 13,
                fontWeight: FontWeight.w700,
              ),
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

    final payerId = AppSupabase.auth.currentUser?.id;
    if (payerId == null || payerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue payment.')),
      );
      return;
    }

    try {
      if (_selectedMethod == HomeUPaymentMethod.banking && _selectedBank == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a bank to continue.')),
        );
        return;
      }

      if (_selectedMethod == HomeUPaymentMethod.ewallet && _selectedEWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an e-wallet to continue.')),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.homeuCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Confirm Payment',
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to proceed with this payment?',
                style: TextStyle(color: context.homeuSecondaryText),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.homeuSoftBorder),
                ),
                child: Column(
                  children: [
                    _summaryRow('Amount', 'RM ${_formatCurrency(widget.totalPrice)}', emphasize: true),
                    const Divider(height: 16),
                    _summaryRow(
                      'Method',
                      _selectedMethod == HomeUPaymentMethod.banking
                          ? 'Online Banking ($_selectedBank)'
                          : _selectedMethod == HomeUPaymentMethod.ewallet
                              ? 'E-Wallet ($_selectedEWallet)'
                              : 'Credit / Debit Card',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.homeuMutedText),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.homeuAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Confirm & Pay'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() {
        _isSubmittingPayment = true;
      });

      Payment? payment;
      if (widget.isInstallment && widget.scheduleId != null) {
        payment = await _paymentRemoteDataSource.processInstallmentPayment(
          bookingId: widget.bookingId,
          scheduleId: widget.scheduleId!,
          payerId: payerId,
          method: _selectedMethod == HomeUPaymentMethod.banking && _selectedBank != null
              ? 'Online Banking ($_selectedBank)'
              : _selectedMethod == HomeUPaymentMethod.ewallet && _selectedEWallet != null
                  ? 'E-Wallet ($_selectedEWallet)'
                  : _methodLabel(_selectedMethod),
          amount: widget.totalPrice,
          monthNumber: widget.monthNumber,
        );
      } else {
        payment = await _paymentRemoteDataSource.createPaymentSimulated(
          bookingId: widget.bookingId,
          payerId: payerId,
          method: _selectedMethod == HomeUPaymentMethod.banking && _selectedBank != null
              ? 'Online Banking ($_selectedBank)'
              : _selectedMethod == HomeUPaymentMethod.ewallet && _selectedEWallet != null
                  ? 'E-Wallet ($_selectedEWallet)'
                  : _methodLabel(_selectedMethod),
          amount: widget.totalPrice,
          simulateSuccess: true,
        );
      }

      if (!mounted) {
        return;
      }

      if (payment == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
        setState(() {
          _isSubmittingPayment = false;
        });
        return;
      }

      final isSuccessful = payment.status == 'Success';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSuccessful
                ? 'Payment completed successfully.'
                : 'Payment failed. Please try again.',
          ),
        ),
      );

      await _loadLatestPayment();

      if (isSuccessful) {
        if (widget.isInstallment) {
          // If it's an installment, wait a moment to show success message then pop
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) return;
          // Navigate to Home Dashboard (Tenant Shell) and clear stack for initial booking fee
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(
              builder: (_) => HomeUTenantShellScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      debugPrint('Payment processing error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(label: 'Details', onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error Details'),
                content: SingleChildScrollView(child: Text(e.toString())),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
              ),
            );
          }),
        ),
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
  const _FlippingCardVisual({
    required this.showBack,
    required this.showCvvHighlight,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
  });

  final bool showBack;
  final bool showCvvHighlight;
  final String cardNumber;
  final String expiry;
  final String cvv;

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
              ? _CardBackFace(showCvvHighlight: showCvvHighlight, cvv: cvv)
              : _CardFrontFace(cardNumber: cardNumber, expiry: expiry),
        ),
      ),
    );
  }
}

class _CardFrontFace extends StatelessWidget {
  const _CardFrontFace({required this.cardNumber, required this.expiry});

  final String cardNumber;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    String displayCardNumber = cardNumber;
    if (displayCardNumber.isEmpty) {
      displayCardNumber = '**** **** **** ****';
    }

    String displayExpiry = expiry;
    if (displayExpiry.isEmpty) {
      displayExpiry = 'MM/YY';
    }

    return Container(
      key: const Key('card_front_side'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.credit_card_rounded, color: Colors.white),
              Spacer(),
              Text('HomeU Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          const Spacer(),
          Text(
            displayCardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.2,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
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
          const SizedBox(height: 3),
          Row(
            children: [
              const Text('TENANT NAME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(displayExpiry, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBackFace extends StatelessWidget {
  const _CardBackFace({required this.showCvvHighlight, required this.cvv});

  final bool showCvvHighlight;
  final String cvv;

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
              child: Text(
                cvv.isEmpty ? '***' : cvv.replaceAll(RegExp(r'.'), '*'),
                style: const TextStyle(
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

class _CardNumberFormatter extends TextInputFormatter {
  const _CardNumberFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) {
        buffer.write(' ');
      }
    }
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  const _ExpiryFormatter();
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }
    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}




