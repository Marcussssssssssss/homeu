import 'package:flutter/material.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/auth/role_access_widget.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_bottom_navigation_bar.dart';
import 'package:homeu/pages/home/profile_screen.dart';

class HomeUOwnerBookingRequestsScreen extends StatefulWidget {
  const HomeUOwnerBookingRequestsScreen({super.key});

  @override
  State<HomeUOwnerBookingRequestsScreen> createState() =>
      _HomeUOwnerBookingRequestsScreenState();
}

class _HomeUOwnerBookingRequestsScreenState
    extends State<HomeUOwnerBookingRequestsScreen> {
  int _selectedNavIndex = 2;
  _OwnerRequestDecision _decision = _OwnerRequestDecision.pending;

  String _decisionLabel(BuildContext context) {
    final t = context.l10n;
    switch (_decision) {
      case _OwnerRequestDecision.approved:
        return t.ownerRequestDecisionApproved;
      case _OwnerRequestDecision.rejected:
        return t.ownerRequestDecisionRejected;
      case _OwnerRequestDecision.pending:
        return t.ownerRequestDecisionPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HomeUSession.canAccess(HomeURole.owner)) {
      return const HomeURoleBlockedScreen(requiredRole: HomeURole.owner);
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        title: Text(context.l10n.ownerBookingRequestTitle),
        backgroundColor: context.colors.surface,
      ),
      bottomNavigationBar: HomeUOwnerBottomNavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 0) {
            Navigator.of(context).pop();
          }
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUOwnerAnalyticsScreen(),
              ),
            );
          }
          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUConversationListScreen(),
              ),
            );
          }
          if (index == 5) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeUProfileScreen(role: HomeURole.owner),
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.ownerBookingRequestSubtitle,
                style: TextStyle(
                  color: context.homeuMutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: context.l10n.ownerTenantInformation,
                sectionKey: const Key('tenant_information_card'),
                child: Column(
                  children: [
                    _InfoLine(
                      label: context.l10n.profileFieldName,
                      value: 'Aisyah Rahman',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: context.l10n.profileFieldPhone,
                      value: '+60 12 998 1123',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: context.l10n.profileFieldEmail,
                      value: 'aisyah.r@email.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: context.l10n.ownerBookingDetails,
                sectionKey: const Key('booking_details_card'),
                child: Column(
                  children: [
                    _InfoLine(
                      label: context.l10n.ownerPropertyLabel,
                      value: 'Skyline Condo Suite',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: context.l10n.ownerCheckInLabel,
                      value: '1 May 2026',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: context.l10n.ownerDurationLabel,
                      value: '6 months',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      label: context.l10n.ownerMonthlyRentLabel,
                      value: 'RM 2,100 / month',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: context.l10n.ownerRequestSummary,
                sectionKey: const Key('request_summary_card'),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: context.homeuAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _decisionLabel(context),
                        key: const Key('request_decision_text'),
                        style: TextStyle(
                          color: _decision == _OwnerRequestDecision.approved
                              ? const Color(0xFF0F8A5F)
                              : _decision == _OwnerRequestDecision.rejected
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
              Container(
                key: const Key('decision_action_area'),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.l10n.ownerDecision,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('reject_request_button'),
                            onPressed: () {
                              setState(() {
                                _decision = _OwnerRequestDecision.rejected;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFC53030),
                              side: const BorderSide(color: Color(0xFFC53030)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(context.l10n.ownerReject),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            key: const Key('approve_request_button'),
                            onPressed: () {
                              setState(() {
                                _decision = _OwnerRequestDecision.approved;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.homeuAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(context.l10n.ownerApprove),
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

enum _OwnerRequestDecision { pending, approved, rejected }

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.sectionKey,
    required this.child,
  });

  final String title;
  final Key sectionKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
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
            title,
            style: TextStyle(
              color: context.homeuPrimaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
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
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667896),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F314F),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
