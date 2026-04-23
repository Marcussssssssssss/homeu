import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:homeu/app/settings/homeu_language_controller.dart';
import 'package:homeu/app/settings/homeu_theme_controller.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/app/startup/startup_auth_gate.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/core/supabase/app_supabase.dart';
import 'package:homeu/pages/home/update_password_screen.dart';
import 'package:homeu/l10n/app_localizations.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomeUApp extends StatefulWidget {
  const HomeUApp({
    super.key,
    this.startupDestination,
    this.startupResolver,
    this.languageController,
    this.themeController,
  });

  final HomeUStartupDestination? startupDestination;
  final HomeUStartupSessionResolver? startupResolver;
  final HomeULanguageController? languageController;
  final HomeUThemeController? themeController;

  @override
  State<HomeUApp> createState() => _HomeUAppState();
}

class _HomeUAppState extends State<HomeUApp> {
  late final HomeULanguageController _languageController;
  late final HomeUThemeController _themeController;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _languageController =
        widget.languageController ?? HomeULanguageController.instance;
    _themeController = widget.themeController ?? HomeUThemeController.instance;
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initDeepLinks() {
    final appLinks = AppLinks();

    // Handle initial link if app was closed (cold start)
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleAuthLink(uri);
      }
    });

    // Handle incoming links if app is in background/foreground (warm start)
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      _handleAuthLink(uri);
    });
  }

  Future<void> _handleAuthLink(Uri uri) async {
    // Expected reset link: homeu://auth/reset?code=...
    final isResetLink = uri.scheme == 'homeu' &&
        uri.host == 'auth' &&
        uri.path.startsWith('/reset');

    if (isResetLink) {
      debugPrint('HomeUApp: Processing reset password link: $uri');

      // 1. Process the link to establish recovery session
      // For Supabase PKCE flow, we exchange the code for a session.
      final code = uri.queryParameters['code'];
      if (code != null) {
        try {
          // This establishes the session and triggers AuthChangeEvent.passwordRecovery
          await AppSupabase.auth.exchangeCodeForSession(code);
        } catch (e) {
          debugPrint('HomeUApp: Code exchange failed: $e');
        }
      }

      // 2. Direct routing to Update Password page
      // Using pushAndRemoveUntil ensures the reset flow is the only thing in the stack
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const HomeUUpdatePasswordScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination =
        widget.startupDestination ?? HomeUStartupDestination.authFlow;
    final resolver = widget.startupResolver ?? HomeUStartupSessionResolver();

    return AnimatedBuilder(
      animation: Listenable.merge([_languageController, _themeController]),
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          locale: _languageController.locale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return supportedLocales.first;
            }

            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }

            return supportedLocales.first;
          },
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: _themeController.themeMode,
          theme: HomeUAppTheme.light(),
          darkTheme: HomeUAppTheme.dark(),
          navigatorObservers: [routeObserver],
          home: HomeUStartupAuthGate(
            initialDestination: destination,
            resolver: resolver,
          ),
        );
      },
    );
  }
}
