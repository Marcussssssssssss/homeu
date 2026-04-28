import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homeu/app/booking/payment_models.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';

class BookingReceiptDialog extends StatelessWidget {
  const BookingReceiptDialog({
    super.key,
    required this.payment,
    required this.property,
    this.isRefund = false,
  });

  final Payment payment;
  final PropertyItem property;
  final bool isRefund;

  static Future<void> show({
    required BuildContext context,
    required Payment payment,
    required PropertyItem property,
    bool isRefund = false,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => BookingReceiptDialog(
        payment: payment,
        property: property,
        isRefund: isRefund,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, BuildContext context) async {
    final pdf = pw.Document();
    final l10n = context.l10n;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    // Malaysia Timezone Offset: UTC +8
    final DateTime displayTime = (payment.paidAt ?? payment.createdAt).toUtc().add(const Duration(hours: 8));

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(isRefund ? 'Refund Receipt' : l10n.receiptTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text((isRefund ? 'REFUNDED' : l10n.statusApproved).toUpperCase(), style: pw.TextStyle(fontSize: 18, color: isRefund ? PdfColors.orange : PdfColors.green, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('${isRefund ? 'Refund ID' : l10n.receiptTransactionId}: ${payment.transactionReference}'),
              pw.Text('${isRefund ? 'Refund Date' : l10n.receiptPaymentDate}: ${dateFormat.format(displayTime)}'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _pdfRow(l10n.receiptProperty, property.name),
              _pdfRow(l10n.receiptLocation, property.location),
              _pdfRow(l10n.receiptPaymentMethod, payment.method),
              if (payment.monthNumber != null)
                _pdfRow(l10n.receiptInstallment, l10n.receiptMonth(payment.monthNumber!)),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(isRefund ? 'Refunded Amount' : l10n.receiptTotalAmount, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(currencyFormat.format(payment.amount), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (isRefund) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  'Your booking fee of ${currencyFormat.format(payment.amount)} has been refunded to your original payment method. Please allow 3-5 business days for it to appear in your account.',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ],
              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(l10n.receiptFooter, style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(color: PdfColors.grey700)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    
    // Malaysia Timezone Offset: UTC +8
    final DateTime displayTime = (payment.paidAt ?? payment.createdAt).toUtc().add(const Duration(hours: 8));

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Green/Orange Header
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isRefund 
                        ? (context.isDarkMode ? const Color(0xFF7C2D12).withOpacity(0.3) : const Color(0xFFFFF7ED))
                        : (context.isDarkMode ? const Color(0xFF064E3B).withOpacity(0.3) : const Color(0xFFF0FDF4)),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRefund ? Colors.orange : const Color(0xFF22C55E), // Success green or refund orange
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isRefund ? Icons.assignment_return_outlined : Icons.check,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isRefund ? 'Refund Processed' : l10n.receiptSuccess,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isRefund 
                              ? (context.isDarkMode ? const Color(0xFFFB923C) : const Color(0xFF9A3412))
                              : (context.isDarkMode ? const Color(0xFF4ADE80) : const Color(0xFF166534)),
                          ),
                        ),
                        Text(
                          '${isRefund ? 'Refund ID' : l10n.receiptTransactionId}: ${payment.transactionReference}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isRefund 
                              ? (context.isDarkMode ? const Color(0xFFFB923C).withOpacity(0.7) : const Color(0xFF9A3412).withOpacity(0.7))
                              : (context.isDarkMode ? const Color(0xFF4ADE80).withOpacity(0.7) : const Color(0xFF166534).withOpacity(0.7)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Receipt Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(l10n.receiptProperty, property.name, context),
                        _buildInfoRow(l10n.receiptLocation, property.location, context),
                        _buildInfoRow(isRefund ? 'Refund Date' : l10n.receiptPaymentDate, dateFormat.format(displayTime), context),
                        _buildInfoRow(l10n.receiptPaymentMethod, payment.method, context),
                        if (payment.monthNumber != null)
                          _buildInfoRow(l10n.receiptInstallment, l10n.receiptMonth(payment.monthNumber!), context),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: CustomPaint(
                            size: const Size(double.infinity, 1),
                            painter: _DashedLinePainter(color: context.homeuSectionDivider),
                          ),
                        ),

                        Text(
                          isRefund ? 'Refunded Amount' : l10n.receiptTotalAmount,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.homeuMutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(payment.amount),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isRefund ? Colors.orange : context.homeuPrimaryText,
                          ),
                        ),
                        if (isRefund) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Your booking fee of ${currencyFormat.format(payment.amount)} has been refunded to your original payment method. Please allow 3-5 business days for it to appear in your account.',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.homeuMutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final pdfBytes = await _generatePdf(PdfPageFormat.a4, context);
                              await Printing.layoutPdf(onLayout: (format) => pdfBytes);
                            },
                            icon: const Icon(Icons.file_download_outlined, size: 20),
                            label: Text(l10n.receiptDownload),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.homeuAccent,
                              side: BorderSide(color: context.homeuAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final pdfBytes = await _generatePdf(PdfPageFormat.a4, context);
                              await Share.shareXFiles(
                                [
                                  XFile.fromData(
                                    pdfBytes,
                                    name: 'Receipt_${payment.transactionReference}.pdf',
                                    mimeType: 'application/pdf',
                                  ),
                                ],
                                subject: '${l10n.receiptTitle} - ${property.name}',
                              );
                            },
                            icon: const Icon(Icons.share_outlined, size: 20),
                            label: Text(l10n.receiptShare),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.homeuAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.homeuMutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: context.homeuPrimaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
