import 'package:flutter/material.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/app/booking/payment_models.dart';

class HomeUReceiptScreen extends StatelessWidget {
  const HomeUReceiptScreen({
    super.key,
    required this.payment,
    required this.propertyName,
  });

  final Payment payment;
  final String propertyName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shadowColor: context.homeuAccent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ClipPath(
                clipper: _TicketClipper(),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Successful',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F314F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RM ${payment.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: context.homeuPrice,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _DashedLine(),
                      const SizedBox(height: 24),
                      _ReceiptRow(label: 'Property', value: propertyName),
                      _ReceiptRow(label: 'Transaction ID', value: payment.transactionReference),
                      _ReceiptRow(label: 'Date', value: _formatDate(payment.paidAt ?? payment.createdAt)),
                      _ReceiptRow(label: 'Payment Method', value: payment.method),
                      const SizedBox(height: 32),
                      Transform.rotate(
                        angle: -0.1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF10B981), width: 3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'SUCCESS',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF667896), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF1F314F), fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFCBD5E0))),
            );
          }),
        );
      },
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    
    // Create the "ticket punch" effect in the middle
    const punchRadius = 12.0;
    const punchY = 240.0; // Estimate based on the dash line position
    
    path.addOval(Rect.fromCircle(center: Offset(0, punchY), radius: punchRadius));
    path.addOval(Rect.fromCircle(center: Offset(size.width, punchY), radius: punchRadius));
    
    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
