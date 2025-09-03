import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart'; // context.l10n
import '../statistics/statistics_view.dart';
import 'about_developer_page.dart';

import 'package:provider/provider.dart';
import '../../services/auth_controller.dart';

// ===== Developer profile =====
const String kDeveloperName = 'Jimmy Lee';
const String kDeveloperNamePinyin = 'LEE, PIN-FAN';
const String kDeveloperEmail = 'jimmylee16888@gmail.com';
const String kDeveloperAvatarUrl =
    'https://avatars.githubusercontent.com/u/204156154?s=400&u=e6b3149c987b1e918122f9fc8af4ea6789e543ae&v=4';
const String kAppVersion = '1.0.0';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final auth = context.watch<AuthController>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== Theme =====
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(l.theme),
          subtitle: Text(_themeModeLabel(context, settings.themeMode)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(l.themeLight),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(l.themeDark),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(l.themeSystem),
                icon: const Icon(Icons.settings_suggest_outlined),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
        ),

        const SizedBox(height: 12),

        // ===== Language (單一區塊，含韓語) =====
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l.language),
          subtitle: Text(_localeLabel(context, settings.locale)),
          trailing: DropdownButton<Locale?>(
            value: settings.locale, // null = follow system
            items: [
              DropdownMenuItem(value: null, child: Text(l.languageSystem)),
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text('English'),
              ),
              DropdownMenuItem(value: const Locale('zh'), child: Text('中文（繁體')),
              DropdownMenuItem(value: const Locale('ja'), child: Text('日本語')),
              DropdownMenuItem(value: const Locale('ko'), child: Text('한국어')),
              DropdownMenuItem(
                value: const Locale('de'),
                child: Text('Deutsch'),
              ),
            ],
            onChanged: (v) => settings.setLocale(v),
          ),
        ),
        const Divider(height: 12),

        // ===== Statistics =====
        ListTile(
          leading: const Icon(Icons.insights_outlined),
          title: Text(l.stats_title),
          subtitle: Text(l.stats_nav_subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StatisticsView(settings: settings),
              ),
            );
          },
        ),

        const Divider(height: 12),

        // ===== Account =====
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(
            auth.isGuest
                ? l.accountStatusGuest
                : (auth.isAuthenticated
                      ? l.accountStatusSignedIn
                      : l.accountStatusSignedOut),
          ),
          subtitle: Text(
            auth.isGuest
                ? l.accountGuestSubtitle
                : (auth.isAuthenticated
                      ? (auth.account ?? l.accountNoInfo)
                      : l.accountBackToLogin),
          ),
          trailing: TextButton(
            child: Text(
              auth.isAuthenticated && !auth.isGuest
                  ? l.signOut
                  : l.accountBackToLogin,
            ),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ),
        const Divider(height: 12),

        // ===== About developer =====
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Icons.person_outline),
          ),
          title: Text(l.aboutDeveloper),
          subtitle: Text(
            l.nameWithPinyin(kDeveloperName, kDeveloperNamePinyin),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutDeveloperPage())),
        ),
      ],
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode m) {
    final l = context.l10n;
    switch (m) {
      case ThemeMode.light:
        return l.themeLight;
      case ThemeMode.dark:
        return l.themeDark;
      case ThemeMode.system:
        return l.themeSystem;
    }
  }

  String _localeLabel(BuildContext context, Locale? lcl) {
    final l = context.l10n;
    if (lcl == null) return l.languageSystem;
    switch (lcl.languageCode) {
      case 'en':
        return l.languageEn;
      case 'zh':
        return l.languageZhTW;
      case 'ja':
        return l.languageJa;
      case 'ko':
        return l.languageKo;
      case 'de':
        return l.languageDe;
      default:
        return lcl.toLanguageTag();
    }
  }
}
