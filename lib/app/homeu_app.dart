import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:homeu/app/settings/homeu_language_controller.dart';
import 'package:homeu/app/settings/homeu_theme_controller.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/app/startup/startup_auth_gate.dart';
import 'package:homeu/core/localization/homeu_l10n.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';
import 'package:homeu/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _languageController =
        widget.languageController ?? HomeULanguageController.instance;
    _themeController = widget.themeController ?? HomeUThemeController.instance;
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
          home: HomeUStartupAuthGate(
            initialDestination: destination,
            resolver: resolver,
          ),
        );
      },
    );
  }
}
