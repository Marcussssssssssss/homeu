import 'package:flutter/widgets.dart';
import 'package:homeu/l10n/app_localizations.dart';

extension HomeULocalizationX on BuildContext {
  AppLocalizations get l10n {
    final localized = Localizations.of<AppLocalizations>(
      this,
      AppLocalizations,
    );
    return localized ?? lookupAppLocalizations(const Locale('en'));
  }
}
