import 'package:flutter/material.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/auth/login_screen.dart';
import 'package:homeu/pages/onboarding/onboarding_screen_2.dart';

class HomeUOnboardingScreen1 extends StatelessWidget {
  const HomeUOnboardingScreen1({super.key, this.onNext, this.onSkip});

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
                    const _BrowseListingIllustration(),
                    const SizedBox(height: 28),
                    Text(
                      t.onboardingStep1Title,
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
                      t.onboardingStep1Subtitle,
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
                      currentStep: 1,
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
                                          const HomeUOnboardingScreen2(),
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

class _BrowseListingIllustration extends StatelessWidget {
  const _BrowseListingIllustration();

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
            top: 14,
            right: 14,
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
                  Icon(Icons.tune_rounded, size: 14, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.onboardingFilters,
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
                  width: 230,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ListingCard(
                        title: context.l10n.onboardingExampleListing1Title,
                        subtitle: context.l10n.onboardingExampleListing1Subtitle,
                        price: context.l10n.onboardingExampleListing1Price,
                        accent: const Color(0xFF1E3A8A),
                      ),
                      const SizedBox(height: 12),
                      _ListingCard(
                        title: context.l10n.onboardingExampleListing2Title,
                        subtitle: context.l10n.onboardingExampleListing2Subtitle,
                        price: context.l10n.onboardingExampleListing2Price,
                        accent: const Color(0xFF10B981),
                      ),
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

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String price;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final card = context.homeuCard;
    final titleColor = context.homeuPrimaryText;
    final subtitleColor = context.homeuMutedText;
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.home_work_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.homeuPrice,
            ),
          ),
        ],
      ),
    );
  }
}
