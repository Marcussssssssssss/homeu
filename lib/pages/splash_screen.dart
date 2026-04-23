import 'package:flutter/material.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/pages/onboarding/onboarding_screen_1.dart';

class HomeUSplashScreen extends StatefulWidget {
  const HomeUSplashScreen({
    super.key,
    this.redirectDelay = const Duration(seconds: 2),
    this.canRedirect = true,
  });

  final Duration redirectDelay;
  final bool canRedirect;

  @override
  State<HomeUSplashScreen> createState() => _HomeUSplashScreenState();
}

class _HomeUSplashScreenState extends State<HomeUSplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.canRedirect) {
      Future<void>.delayed(widget.redirectDelay, _goToOnboarding);
    }
  }

  void _goToOnboarding() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeUOnboardingScreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final logoSize = (size.width * 0.42).clamp(120.0, 190.0);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Stack(
        children: [
          const _SplashBackgroundAccents(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.04,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: context.homeuCard,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withValues(alpha: 0.18),
                              blurRadius: 22,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'HomeU.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        'HomeU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.homeuAccent,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: size.height * 0.012),
                      Text(
                        'Find Your Perfect Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.homeuMutedText,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: size.height * 0.055),
                      const _HouseIllustration(),
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

class _SplashBackgroundAccents extends StatelessWidget {
  const _SplashBackgroundAccents();

  @override
  Widget build(BuildContext context) {
    final accent = context.homeuAccent;
    final secondary = context.homeuSuccess;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            Positioned(
              top: -height * 0.12,
              right: -width * 0.2,
              child: Container(
                width: width * 0.55,
                height: width * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -height * 0.1,
              left: -width * 0.22,
              child: Container(
                width: width * 0.58,
                height: width * 0.58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: secondary.withValues(alpha: 0.12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HouseIllustration extends StatelessWidget {
  const _HouseIllustration();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Container(
      width: 240,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1A263D), const Color(0xFF162B27)]
              : [const Color(0xFFF4F8FF), const Color(0xFFE8F7F1)],
        ),
        border: Border.all(color: context.homeuSoftBorder, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 26,
            child: Container(
              width: 150,
              height: 64,
              decoration: BoxDecoration(
                color: context.homeuCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.house_rounded,
            size: 88,
            color: context.homeuAccent,
          ),
          Positioned(
            right: 28,
            top: 28,
            child: Icon(
              Icons.eco_rounded,
              size: 22,
              color: context.homeuSuccess,
            ),
          ),
        ],
      ),
    );
  }
}
