// lib/screens/settings/settings_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart'; // 取得 context.l10n
import '../statistics/statistics_view.dart'; // 新增：統計頁面
import 'about_developer_page.dart'; // 新增：獨立檔案

import 'package:provider/provider.dart';
import '../../services/mini_card_store.dart';
import '../../models/card_item.dart';
import '../../models/mini_card_data.dart';

/// Developer profile
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

        const SizedBox(height: 24),

        // ===== Language =====
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l.language),
          subtitle: Text(_localeLabel(context, settings.locale)),
          trailing: DropdownButton<Locale?>(
            value: settings.locale, // null = follow system
            items: [
              DropdownMenuItem(value: null, child: Text(l.languageSystem)),
              const DropdownMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: const Locale('zh'),
                child: Text(l.languageZhTW),
              ),
              DropdownMenuItem(
                value: const Locale('ja'),
                child: Text(l.languageJa),
              ),
            ],
            onChanged: (v) => settings.setLocale(v),
          ),
        ),

        const Divider(height: 32),

        // ===== Statistics =====
        ListTile(
          leading: const Icon(Icons.insights_outlined),
          title: Text(l.stats_title), // ← 用 i18n
          subtitle: Text(l.stats_nav_subtitle), // ← 用 i18n，文案改成新的說明
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StatisticsView(settings: settings),
              ),
            );
          },
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
        return 'English';
      case 'zh':
        return l.languageZhTW; // 以繁中顯示
      case 'ja':
        return '日本語';
      default:
        return lcl.toLanguageTag();
    }
  }
}

// // lib/screens/settings_view.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../app_settings.dart';
// import '../../l10n/l10n.dart'; // <- 加這行，取得 context.l10n

// /// Developer profile
// const String kDeveloperName = 'Jimmy Lee';
// const String kDeveloperNamePinyin = 'LEE, PIN-FAN';
// const String kDeveloperEmail = 'jimmylee16888@gmail.com';
// const String kDeveloperAvatarUrl =
//     'https://avatars.githubusercontent.com/u/204156154?s=400&u=e6b3149c987b1e918122f9fc8af4ea6789e543ae&v=4';
// const String kAppVersion = '1.0.0';

// class SettingsView extends StatelessWidget {
//   const SettingsView({super.key, required this.settings});
//   final AppSettings settings;

//   @override
//   Widget build(BuildContext context) {
//     final l = context.l10n;

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         // ===== Theme =====
//         ListTile(
//           leading: const Icon(Icons.palette_outlined),
//           title: Text(l.theme),
//           subtitle: Text(_themeModeLabel(context, settings.themeMode)),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: SegmentedButton<ThemeMode>(
//             segments: [
//               ButtonSegment(
//                 value: ThemeMode.light,
//                 label: Text(l.themeLight),
//                 icon: const Icon(Icons.light_mode_outlined),
//               ),
//               ButtonSegment(
//                 value: ThemeMode.dark,
//                 label: Text(l.themeDark),
//                 icon: const Icon(Icons.dark_mode_outlined),
//               ),
//               ButtonSegment(
//                 value: ThemeMode.system,
//                 label: Text(l.themeSystem),
//                 icon: const Icon(Icons.settings_suggest_outlined),
//               ),
//             ],
//             selected: {settings.themeMode},
//             onSelectionChanged: (s) => settings.setThemeMode(s.first),
//           ),
//         ),

//         const SizedBox(height: 24),

//         // ===== Language =====
//         ListTile(
//           leading: const Icon(Icons.language),
//           title: Text(l.language),
//           subtitle: Text(_localeLabel(context, settings.locale)),
//           trailing: DropdownButton<Locale?>(
//             value: settings.locale, // null = follow system
//             items: [
//               DropdownMenuItem(value: null, child: Text(l.languageSystem)),
//               DropdownMenuItem(
//                 value: const Locale('en'),
//                 child: Text(l.languageEn),
//               ),
//               DropdownMenuItem(
//                 value: const Locale('zh'),
//                 child: Text(l.languageZhTW),
//               ),
//               DropdownMenuItem(
//                 value: const Locale('ja'),
//                 child: Text(l.languageJa),
//               ),
//             ],
//             onChanged: (v) => settings.setLocale(v),
//           ),
//         ),

//         const Divider(height: 32),

//         // ===== About developer (with avatar) =====
//         ListTile(
//           leading: CircleAvatar(
//             radius: 18,
//             foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
//             backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
//             child: const Icon(Icons.person_outline),
//           ),
//           title: Text(l.aboutDeveloper),
//           subtitle: Text(
//             l.nameWithPinyin(kDeveloperName, kDeveloperNamePinyin),
//           ),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () => Navigator.of(
//             context,
//           ).push(MaterialPageRoute(builder: (_) => const AboutDeveloperPage())),
//         ),
//       ],
//     );
//   }

//   String _themeModeLabel(BuildContext context, ThemeMode m) {
//     final l = context.l10n;
//     switch (m) {
//       case ThemeMode.light:
//         return l.themeLight;
//       case ThemeMode.dark:
//         return l.themeDark;
//       case ThemeMode.system:
//         return l.themeSystem;
//     }
//   }

//   String _localeLabel(BuildContext context, Locale? lcl) {
//     final l = context.l10n;
//     if (lcl == null) return l.languageSystem;
//     switch (lcl.languageCode) {
//       case 'en':
//         return l.languageEn;
//       case 'zh':
//         return l.languageZhTW; // 以繁中顯示
//       case 'ja':
//         return l.languageJa;
//       default:
//         return lcl.toLanguageTag();
//     }
//   }
// }

// class AboutDeveloperPage extends StatelessWidget {
//   const AboutDeveloperPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final color = Theme.of(context).colorScheme;
//     final text = Theme.of(context).textTheme;
//     final l = context.l10n;

//     return Scaffold(
//       appBar: AppBar(title: Text(l.aboutTitle)),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Header card with big avatar & name
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 36,
//                     foregroundImage: const NetworkImage(kDeveloperAvatarUrl),
//                     backgroundColor: color.surfaceVariant,
//                     child: const Icon(Icons.person_outline, size: 32),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           l.nameWithPinyin(
//                             kDeveloperName,
//                             kDeveloperNamePinyin,
//                           ),
//                           style: text.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           l.developerRole,
//                           style: text.bodyMedium?.copyWith(
//                             color: color.outline,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: const [
//                             Chip(label: Text('Flutter')),
//                             Chip(label: Text('Open Source')),
//                             Chip(label: Text('Side Project')),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // Polished "Hello" copy
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.waving_hand),
//                       const SizedBox(width: 8),
//                       Text(l.helloDeveloperTitle, style: text.titleMedium),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   SelectableText(
//                     l.helloDeveloperBody,
//                     textAlign: TextAlign.start,
//                   ),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       '— $kDeveloperName',
//                       style: text.bodySmall?.copyWith(color: color.outline),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // Contact / Version
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.email_outlined),
//                   title: Text(l.emailLabel),
//                   subtitle: const Text(kDeveloperEmail),
//                   onTap: () async {
//                     await Clipboard.setData(
//                       const ClipboardData(text: kDeveloperEmail),
//                     );
//                     if (context.mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Email copied')),
//                       );
//                     }
//                   },
//                 ),
//                 const Divider(height: 0),
//                 ListTile(
//                   leading: const Icon(Icons.code_outlined),
//                   title: Text(l.versionLabel),
//                   subtitle: const Text(kAppVersion),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
