import 'package:flutter/widgets.dart';
import 'app_localizations.dart'; // ← 改這個

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
