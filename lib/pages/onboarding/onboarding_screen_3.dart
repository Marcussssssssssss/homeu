import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/auth/login_screen.dart';

class HomeUOnboardingScreen3 extends StatelessWidget {
  const HomeUOnboardingScreen3({super.key, this.onNext, this.onSkip});

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
                    const _SecurePaymentIllustration(),
                    const SizedBox(height: 28),
                    Text(
                      t.onboardingStep3Title,
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
                      t.onboardingStep3Subtitle,
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
                      currentStep: 3,
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
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const HomeULoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.homeuAccent,
                              foregroundColor: context.colors.onPrimary,
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
                            child: Text(t.onboardingGetStarted),
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

class _SecurePaymentIllustration extends StatelessWidget {
  const _SecurePaymentIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final card = context.homeuCard;
    final accent = context.homeuAccent;
    final success = context.homeuSuccess;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.surfaceContainerHighest],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 232,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: accent.withValues(alpha: 0.2),
                      child: Icon(Icons.calendar_month_rounded, color: accent),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.onboardingViewingConfirmed,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.homeuPrimaryText,
                        ),
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: success, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.16),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: success.withValues(alpha: 0.2),
                      child: Icon(Icons.lock_rounded, color: success),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.l10n.onboardingSecurePayment,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.homeuPrimaryText,
                        ),
                      ),
                    ),
                    Text(
                      context.l10n.onboardingProtected,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: success,
                      ),
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
