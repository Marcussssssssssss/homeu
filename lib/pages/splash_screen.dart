import 'package:flutter/material.dart';
import 'package:homeu/pages/onboarding/onboarding_screen_1.dart';

class HomeUSplashScreen extends StatefulWidget {
  const HomeUSplashScreen({super.key, this.redirectDelay = const Duration(seconds: 2)});

  final Duration redirectDelay;

  @override
  State<HomeUSplashScreen> createState() => _HomeUSplashScreenState();
}

class _HomeUSplashScreenState extends State<HomeUSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.redirectDelay, _goToOnboarding);
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A1E3A8A),
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
                      const Text(
                        'HomeU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: size.height * 0.012),
                      const Text(
                        'Find Your Perfect Home',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF50617F),
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x141E3A8A),
                ),
              ),
            ),
            Positioned(
              bottom: -height * 0.1,
              left: -width * 0.22,
              child: Container(
                width: width * 0.58,
                height: width * 0.58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1410B981),
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
    return Container(
      width: 240,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F8FF), Color(0xFFE8F7F1)],
        ),
        border: Border.all(color: const Color(0x331E3A8A), width: 1),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A1E3A8A),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          const Icon(
            Icons.house_rounded,
            size: 88,
            color: Color(0xFF1E3A8A),
          ),
          const Positioned(
            right: 28,
            top: 28,
            child: Icon(
              Icons.eco_rounded,
              size: 22,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

