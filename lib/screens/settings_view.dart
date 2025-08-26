// lib/screens/settings_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../app_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== Theme =====
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Theme'),
          subtitle: Text(_themeModeLabel(settings.themeMode)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_suggest_outlined),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
        ),

        const SizedBox(height: 24),

        // ===== Language =====
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(_localeLabel(settings.locale)),
          trailing: DropdownButton<Locale?>(
            value: settings.locale, // null 代表跟隨系統
            items: const [
              DropdownMenuItem(value: null, child: Text('System')),
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
              DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
            ],
            onChanged: (v) => settings.setLocale(v),
          ),
        ),

        const Divider(height: 32),

        // ===== About =====
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About developer'),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AboutDeveloperPage())),
        ),
      ],
    );
  }

  String _themeModeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _localeLabel(Locale? l) {
    if (l == null) return 'System';
    switch (l.languageCode) {
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      default:
        return l.toLanguageTag();
    }
  }
}

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Developer'),
            subtitle: Text('Jimmy Lee'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined),
            title: Text('Email'),
            subtitle: Text('jimmylee16888@gmail.com'),
          ),
          ListTile(
            leading: Icon(Icons.code_outlined),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
