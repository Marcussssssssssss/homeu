import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/auth/login_screen.dart';
import 'package:homeu/pages/onboarding/onboarding_screen_3.dart';

class HomeUOnboardingScreen2 extends StatelessWidget {
  const HomeUOnboardingScreen2({super.key, this.onNext, this.onSkip});

  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = (width * 0.08).clamp(20.0, 28.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 44,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const _OwnerListingIllustration(),
                    const SizedBox(height: 28),
                    Text(
                      t.onboardingStep2Title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.homeuPrimaryText,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      t.onboardingStep2Subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.homeuMutedText,
                        fontSize: 16,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _OnboardingProgressIndicator(
                      currentStep: 2,
                      totalSteps: 3,
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                onSkip ??
                                () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const HomeULoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                            style: TextButton.styleFrom(
                              foregroundColor: context.homeuMutedText,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(t.onboardingSkip),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                onNext ??
                                () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const HomeUOnboardingScreen3(),
                                    ),
                                  );
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.homeuAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(t.onboardingNext),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingProgressIndicator extends StatelessWidget {
  const _OnboardingProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final muted = context.homeuMutedText;
    final accent = context.homeuAccent;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isActive = index + 1 == currentStep;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 26 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? accent : accent.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.onboardingStepProgress(currentStep, totalSteps),
          style: TextStyle(
            color: muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _OwnerListingIllustration extends StatelessWidget {
  const _OwnerListingIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final card = context.homeuCard;
    final accent = context.homeuAccent;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A263D), const Color(0xFF162B27)]
              : [const Color(0xFFF4F8FF), const Color(0xFFEAF8F2)],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_home_work_rounded, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.ownerNewListing,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: 232,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _ListingFormCard(),
                      SizedBox(height: 12),
                      _RequestCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingFormCard extends StatelessWidget {
  const _ListingFormCard();

  @override
  Widget build(BuildContext context) {
    final card = context.homeuCard;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _formRow(
            context,
            icon: Icons.home_work_rounded,
            label: context.l10n.ownerPropertyType,
          ),
          const SizedBox(height: 8),
          _formRow(
            context,
            icon: Icons.image_rounded,
            label: context.l10n.ownerUploadPhotos,
          ),
          const SizedBox(height: 8),
          _formRow(
            context,
            icon: Icons.location_on_rounded,
            label: context.l10n.ownerLocationAndPrice,
          ),
        ],
      ),
    );
  }

  Widget _formRow(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF111A2A)
            : const Color(0xFFF7F9FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.homeuAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.homeuMutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.homeuCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.homeuAccent.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: context.homeuSuccess.withValues(alpha: 0.2),
            child: Icon(
              Icons.person_rounded,
              size: 16,
              color: context.homeuSuccess,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.ownerNewRentalRequests,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.homeuPrimaryText,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.homeuAccent),
        ],
      ),
    );
  }
}
