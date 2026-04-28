import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/chat/chat_remote_datasource.dart';
import '../../app/property/booking_request/booking_request_models.dart';
import '../../app/property/booking_request/booking_requests_controller.dart';
import '../../core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/chat_screen.dart';

class HomeUOwnerBookingRequestDetailsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestDetailsScreen({
    super.key,
    required this.request,
    required this.controller,
  });

  final BookingRequestModel request;
  final BookingRequestsController controller;

  @override
  State<HomeUOwnerBookingRequestDetailsScreen> createState() =>
      _HomeUOwnerBookingRequestDetailsScreenState();
}

class _HomeUOwnerBookingRequestDetailsScreenState
    extends State<HomeUOwnerBookingRequestDetailsScreen> {
  bool _isProcessing = false;
  bool _isOpeningChat = false;

  Future<void> _handleDecision(String newStatus) async {
    setState(() => _isProcessing = true);

    final success = await widget.controller.updateStatus(
      widget.request.id,
      newStatus,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request $newStatus')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status.')));
    }
  }

  Future<void> _openChat() async {
    final propertyId = widget.request.propertyId.trim();
    final tenantId = widget.request.tenantId.trim();
    final ownerId = widget.request.ownerId.trim().isNotEmpty
        ? widget.request.ownerId.trim()
        : (AppSupabase.auth.currentUser?.id ?? '');

    if (propertyId.isEmpty || tenantId.isEmpty || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start chat: missing booking identifiers.'),
        ),
      );
      return;
    }

    setState(() => _isOpeningChat = true);
    try {
      final chatDS = const ChatRemoteDataSource();
      final conv = await chatDS.getOrCreateConversation(
        propertyId: propertyId,
        tenantId: tenantId,
        ownerId: ownerId,
      );

      if (!mounted) {
        return;
      }

      if (conv == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not start chat.')));
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HomeUChatScreen.fromConversation(conversation: conv),
        ),
      );
    } on PostgrestException catch (e) {
      if (!mounted) {
        return;
      }
      final code = e.code?.trim() ?? '';
      final message = e.message.trim().isEmpty
          ? 'Could not start chat.'
          : e.message.trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(code.isEmpty ? message : '$message ($code)')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not start chat: $e')));
    } finally {
      if (mounted) {
        setState(() => _isOpeningChat = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPending =
        widget.request.status == 'Pending' ||
        widget.request.status == 'Pending Decision';
    final bool isApproved = widget.request.status == 'Approved';

    String checkInStr = 'Flexible';
    String checkOutStr = 'TBD';
    if (widget.request.startDate != null) {
      final start = widget.request.startDate!;
      checkInStr = '${start.day}/${start.month}/${start.year}';

      final end = DateTime(
        start.year,
        start.month + widget.request.durationMonths,
        start.day,
      );
      checkOutStr = '${end.day}/${end.month}/${end.year}';
    }

    final totalMoney =
        widget.request.monthlyPrice * widget.request.durationMonths;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E3A8A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFFEAF2FF),
                          backgroundImage:
                              (widget.request.tenantProfileUrl != null &&
                                  widget.request.tenantProfileUrl!.isNotEmpty)
                              ? NetworkImage(widget.request.tenantProfileUrl!)
                              : null,
                          child:
                              (widget.request.tenantProfileUrl == null ||
                                  widget.request.tenantProfileUrl!.isEmpty)
                              ? const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF1E3A8A),
                                  size: 36,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.request.tenantName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F314F),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPending
                                      ? Colors.orange.shade50
                                      : isApproved
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  widget.request.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPending
                                        ? Colors.orange.shade800
                                        : isApproved
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _isOpeningChat ? null : _openChat,
                      icon: _isOpeningChat
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                            ),
                      label: Text(
                        _isOpeningChat ? 'Opening...' : 'Message Tenant',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF6F8FC),
                        foregroundColor: const Color(0xFF1E3A8A),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _SectionCard(
                title: 'Rental Agreement',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.apartment_rounded,
                      label: 'Property',
                      value: widget.request.propertyTitle,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFEAF2FF)),
                    ),
                    _DetailRow(
                      icon: Icons.login_rounded,
                      label: 'Check-in Date',
                      value: checkInStr,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFEAF2FF)),
                    ),
                    _DetailRow(
                      icon: Icons.logout_rounded,
                      label: 'Check-out Date',
                      value: checkOutStr,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFEAF2FF)),
                    ),
                    _DetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Monthly Rent',
                      value: 'RM ${widget.request.monthlyPrice}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x141E3A8A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Contract Value',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'For ${widget.request.durationMonths} months',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'RM ${totalMoney.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (isPending)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isProcessing)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E3A8A),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _handleDecision('Rejected'),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                foregroundColor: const Color(0xFFC53030),
                                side: const BorderSide(
                                  color: Color(0xFFC53030),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _handleDecision('Approved'),
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: const Color(0xFF0F8A5F),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
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
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF667896),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F314F),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
