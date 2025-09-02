// lib/screens/settings/about_developer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/l10n.dart';
import 'settings_view.dart'; // 取常數：kDeveloperName、kDeveloperNamePinyin、kDeveloperEmail、kDeveloperAvatarUrl、kAppVersion

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
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
                          l.nameWithPinyin(
                            kDeveloperName,
                            kDeveloperNamePinyin,
                          ),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l.developerRole,
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

          // Hello
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
                      Text(l.helloDeveloperTitle, style: text.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    l.helloDeveloperBody,
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
                  title: Text(l.emailLabel),
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
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: Text(l.versionLabel),
                  subtitle: const Text(kAppVersion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
