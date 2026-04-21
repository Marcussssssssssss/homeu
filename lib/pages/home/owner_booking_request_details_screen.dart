import 'package:flutter/material.dart';
import '../../app/property/booking_request/booking_request_models.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';

class HomeUOwnerBookingRequestDetailsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestDetailsScreen({
    super.key,
    required this.request,
    required this.controller,
  });

  final BookingRequestModel request;
  final BookingRequestsController controller;

  @override
  State<HomeUOwnerBookingRequestDetailsScreen> createState() => _HomeUOwnerBookingRequestDetailsScreenState();
}

class _HomeUOwnerBookingRequestDetailsScreenState extends State<HomeUOwnerBookingRequestDetailsScreen> {
  bool _isProcessing = false;

  Future<void> _handleDecision(String newStatus) async {
    setState(() => _isProcessing = true);

    final success = await widget.controller.updateStatus(widget.request.id, newStatus);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request $newStatus')));
      Navigator.of(context).pop(); // Go back to the list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if a decision has already been made
    final bool isPending = widget.request.status == 'Pending' || widget.request.status == 'Pending Decision';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFFF6F8FC),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionCard(
                title: 'Tenant Information',
                child: Column(
                  children: [
                    _InfoLine(label: 'Name', value: widget.request.tenantName),
                    const SizedBox(height: 6),
                    _InfoLine(label: 'Phone', value: widget.request.tenantPhone),
                    const SizedBox(height: 6),
                    _InfoLine(label: 'Email', value: widget.request.tenantEmail),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Booking Details',
                child: Column(
                  children: [
                    _InfoLine(label: 'Property', value: widget.request.propertyTitle),
                    const SizedBox(height: 6),
                    _InfoLine(label: 'Check-in', value: widget.request.startDate != null ? '${widget.request.startDate!.day}/${widget.request.startDate!.month}/${widget.request.startDate!.year}' : 'TBD'),
                    const SizedBox(height: 6),
                    _InfoLine(label: 'Duration', value: '${widget.request.durationMonths} months'),
                    const SizedBox(height: 6),
                    _InfoLine(label: 'Monthly Rent', value: 'RM ${widget.request.monthlyPrice} / month'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Request Summary',
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.request.status,
                        style: TextStyle(
                          color: widget.request.status == 'Approved'
                              ? const Color(0xFF0F8A5F)
                              : widget.request.status == 'Rejected'
                              ? const Color(0xFFC53030)
                              : const Color(0xFF1E3A8A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Only show the decision buttons if the request is still Pending
              if (isPending)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x141E3A8A), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Decision', style: TextStyle(color: Color(0xFF1F314F), fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      if (_isProcessing)
                        const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _handleDecision('Rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFC53030),
                                  side: const BorderSide(color: Color(0xFFC53030)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _handleDecision('Approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Approve'),
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
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x141E3A8A), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF1F314F), fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 84, child: Text(label, style: const TextStyle(color: Color(0xFF667896), fontSize: 12, fontWeight: FontWeight.w600))),
        Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF1F314F), fontSize: 13, fontWeight: FontWeight.w700))),
      ],
    );
  }
}