import 'package:flutter/material.dart';
import 'package:flutter_learning_app/screens/settings/dev_settings_page.dart';
import 'package:flutter_learning_app/screens/settings/sync_download_page.dart';
import 'package:flutter_learning_app/screens/settings/tutorial_page.dart';
import 'package:flutter_learning_app/services/auth/auth_controller.dart';
import 'package:flutter_learning_app/services/dev_mode.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'about_developer_page.dart';
import '../user/user_profile_settings_page.dart';

const String kDeveloperName = 'Jimmy Lee';
const String kDeveloperNamePinyin = 'LEE, PIN-FAN';
const String kDeveloperEmail = 'jimmylee16888@gmail.com';
const String kDeveloperAvatarUrl =
    'https://avatars.githubusercontent.com/u/204156154?s=400&u=e6b3149c987b1e918122f9fc8af4ea6789e543ae&v=4';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.settings,
    this.onOpenUserProfile, // 由 RootNav 傳入，避免 push 造成 Provider 範圍丟失
  });

  final AppSettings settings;
  final VoidCallback? onOpenUserProfile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    final auth = context.watch<AuthController>();
    final isSignedIn = auth.isAuthenticated;
    final user = FirebaseAuth.instance.currentUser;

    final photoUrl = user?.photoURL;
    final email = auth.account ?? user?.email ?? l.accountNoInfo;

    final rawNick = settings.nickname?.trim();
    final nicknameText = (rawNick == null || rawNick.isEmpty)
        ? l.notSet
        : rawNick;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // ===== 外觀（Theme + 語言）=====
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette_outlined),
                    const SizedBox(width: 8),
                    Text(
                      l.theme,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _themeModeLabel(context, settings.themeMode),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(
                      l.language,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _localeLabel(context, settings.locale),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<Locale?>(
                    value: settings.locale, // null = follow system
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l.languageSystem),
                      ),
                      const DropdownMenuItem(
                        value: Locale('en'),
                        child: Text('English'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('zh'),
                        child: Text('中文（繁體）'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('ja'),
                        child: Text('日本語'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('ko'),
                        child: Text('한국어'),
                      ),
                      const DropdownMenuItem(
                        value: Locale('de'),
                        child: Text('Deutsch'),
                      ),
                    ],
                    onChanged: (v) => settings.setLocale(v),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ===== 使用者資料（整張卡可點 -> 要求切到 More > User）=====
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (onOpenUserProfile != null) {
                onOpenUserProfile!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfileSettingsPage(settings: settings),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.userProfileTile,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: cs.surfaceVariant,
                        foregroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : null,
                        child: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nicknameText,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: TextStyle(color: cs.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        child: Text(
                          isSignedIn ? l.signOut : l.authSignInWithGoogle,
                        ),
                        onPressed: () async {
                          if (isSignedIn) {
                            await auth.signOut();
                          } else {
                            final (ok, reason) = await auth.loginWithGoogle();
                            if (!context.mounted) return;
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '登入失敗：${reason ?? l.errorLoginFailed}',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),
        // ===== 使用教學 =====
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l.tutorial_title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TutorialPage()));
            },
          ),
        ),

        const SizedBox(height: 12),

        // ===== 同步與下載 =====
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            leading: const Icon(Icons.cloud_sync_outlined),
            title: Text(l.syncMenuTitle), // l10n
            subtitle: Text(
              l.syncMenuSubtitle, // l10n
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SyncDownloadPage()),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ===== 關於開發者 =====
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            leading: const Icon(Icons.badge_outlined),
            title: Text(l.aboutDeveloper),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutDeveloperPage()),
              );
            },
          ),
        ),
        FutureBuilder<bool>(
          future: DevMode.isEnabled(),
          builder: (context, snap) {
            if (snap.data != true) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    leading: const Icon(Icons.developer_mode_outlined),
                    title: const Text('開發者設定'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DevSettingsPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
