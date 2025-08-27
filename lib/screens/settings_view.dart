// lib/screens/settings_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for Clipboard
import '../app_settings.dart';

/// Developer profile
const String kDeveloperName = 'Jimmy Lee';
const String kDeveloperEmail = 'jimmylee16888@gmail.com';
const String kDeveloperAvatarUrl =
    'https://avatars.githubusercontent.com/u/204156154?s=400&u=e6b3149c987b1e918122f9fc8af4ea6789e543ae&v=4';
const String kAppVersion = '1.0.0';

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
            value: settings.locale, // null = follow system
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

        // ===== About developer (with avatar) =====
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            child: const Icon(Icons.person_outline),
          ),
          title: const Text('About developer'),
          subtitle: const Text(kDeveloperName),
          trailing: const Icon(Icons.chevron_right),
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
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card with big avatar & name
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
                    backgroundColor: color.surfaceVariant,
                    child: const Icon(Icons.person_outline, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kDeveloperName,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Developer',
                          style: text.bodyMedium?.copyWith(
                            color: color.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            Chip(label: Text('Flutter')),
                            Chip(label: Text('Open Source')),
                            Chip(label: Text('Side Project')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Polished "Hello" copy
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.waving_hand),
                      const SizedBox(width: 8),
                      Text(
                        "Hello! I'm the developer 👋",
                        style: text.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const SelectableText(
                    "Thanks for checking out this little side project!\n\n"
                    "I’m a big fan of LE SSERAFIM (FEARNOT here) and wanted an easier way to share photocards without carrying a stack of them. "
                    "This app lets you keep and share your cards right from a 6.5\" screen—show, trade, and send via QR in seconds.\n\n"
                    "I’ll keep the app maintained and the code open to the community. "
                    "If you have ideas or spot a bug, I’d love to hear from you. "
                    "Thanks for being part of this project!",
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— $kDeveloperName',
                      style: text.bodySmall?.copyWith(color: color.outline),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Contact / Version
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: const Text(kDeveloperEmail),
                  onTap: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: kDeveloperEmail),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied')),
                      );
                    }
                  },
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(Icons.code_outlined),
                  title: Text('Version'),
                  subtitle: Text(kAppVersion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
