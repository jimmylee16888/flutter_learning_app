// lib/screens/settings/user_profile_settings_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart';
import '../social/friend_cards_page.dart';
import '../social/followed_tags_page.dart';

class UserProfileSettingsPage extends StatefulWidget {
  const UserProfileSettingsPage({
    super.key,
    required this.settings,
    this.forceComplete = false,
  });

  final AppSettings settings;
  final bool forceComplete;

  @override
  State<UserProfileSettingsPage> createState() =>
      _UserProfileSettingsPageState();
}

class _UserProfileSettingsPageState extends State<UserProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nickCtrl;
  String _emailText = '';
  String? _avatarUrl;

  final _tagInput = TextEditingController();
  late SocialApi _api;

  // 顯示名稱快取（id -> name）
  final Map<String, String> _nameById = {};

  final _igCtrl = TextEditingController();
  final _fbCtrl = TextEditingController();
  final _lineCtrl = TextEditingController();
  bool _showIG = false;
  bool _showFB = false;
  bool _showLINE = false;

  bool _saving = false;
  bool _loading = true;

  static const _kIG = 'user.social.instagram';
  static const _kFB = 'user.social.facebook';
  static const _kLINE = 'user.social.line';
  static const _kIG_SHOW = 'user.social.instagram.show';
  static const _kFB_SHOW = 'user.social.facebook.show';
  static const _kLINE_SHOW = 'user.social.line.show';
  static const _kAVATAR_URL = 'user.avatar.url';

  @override
  void initState() {
    super.initState();
    _nickCtrl = TextEditingController(text: widget.settings.nickname ?? '');

    final user = FirebaseAuth.instance.currentUser;
    _emailText = user?.email ?? context.l10n.accountNoInfo;

    final meId = (user?.email?.toLowerCase() ?? user?.uid ?? 'u_me');
    final meName = (_nickCtrl.text.trim().isEmpty)
        ? (user?.displayName ?? 'Me')
        : _nickCtrl.text.trim();
    _api = SocialApi(
      meId: meId,
      meName: meName,
      idTokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );
    _bootstrap();
  }

  /// 啟動時以伺服器為準同步頭像與設定，並回寫本機快取
  /// 啟動時以伺服器為準同步頭像與設定，並回寫本機快取
  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 先預設為本機快取（避免白屏）
      String? avatarLocal = prefs.getString(_kAVATAR_URL);
      String igLocal = prefs.getString(_kIG) ?? '';
      String fbLocal = prefs.getString(_kFB) ?? '';
      String lineLocal = prefs.getString(_kLINE) ?? '';
      bool showIGLocal = prefs.getBool(_kIG_SHOW) ?? false;
      bool showFBLocal = prefs.getBool(_kFB_SHOW) ?? false;
      bool showLINELocal = prefs.getBool(_kLINE_SHOW) ?? false;

      // 嘗試從雲端讀 /me，雲端為單一真相
      String? serverAvatar;
      String? serverNickname;
      String? serverIG;
      String? serverFB;
      String? serverLINE;
      bool? serverShowIG;
      bool? serverShowFB;
      bool? serverShowLINE;

      try {
        final me = await _api
            .fetchMyProfile(); // { avatarUrl, nickname, instagram, ... }

        serverAvatar = (me['avatarUrl'] as String?)?.trim();
        serverNickname = (me['nickname'] as String?)?.trim();

        serverIG = (me['instagram'] as String?)?.trim();
        serverFB = (me['facebook'] as String?)?.trim();
        serverLINE = (me['lineId'] as String?)?.trim();

        // 後端若傳 null 就維持 null，讓下面用 ?? 回退到本機
        if (me['showInstagram'] is bool)
          serverShowIG = me['showInstagram'] as bool;
        if (me['showFacebook'] is bool)
          serverShowFB = me['showFacebook'] as bool;
        if (me['showLine'] is bool) serverShowLINE = me['showLine'] as bool;

        // 把雲端有值的項目同步寫回本機快取（加速下次開啟）
        if (serverAvatar != null && serverAvatar!.isNotEmpty) {
          await prefs.setString(_kAVATAR_URL, serverAvatar!);
          avatarLocal = serverAvatar;
        }
        if (serverIG != null) {
          await prefs.setString(_kIG, serverIG!);
          igLocal = serverIG!;
        }
        if (serverFB != null) {
          await prefs.setString(_kFB, serverFB!);
          fbLocal = serverFB!;
        }
        if (serverLINE != null) {
          await prefs.setString(_kLINE, serverLINE!);
          lineLocal = serverLINE!;
        }
        if (serverShowIG != null) {
          await prefs.setBool(_kIG_SHOW, serverShowIG!);
          showIGLocal = serverShowIG!;
        }
        if (serverShowFB != null) {
          await prefs.setBool(_kFB_SHOW, serverShowFB!);
          showFBLocal = serverShowFB!;
        }
        if (serverShowLINE != null) {
          await prefs.setBool(_kLINE_SHOW, serverShowLINE!);
          showLINELocal = serverShowLINE!;
        }

        // 暱稱：如果雲端有值就直接覆蓋輸入框與設定
        if (serverNickname != null && serverNickname!.isNotEmpty) {
          _nickCtrl.text = serverNickname!;
          widget.settings.setNickname(serverNickname!);
        } else if (_nickCtrl.text.trim().isEmpty &&
            widget.settings.nickname != null) {
          _nickCtrl.text = widget.settings.nickname!;
        }
      } catch (_) {
        // 雲端讀取失敗 → 沿用本機快取
      }

      if (!mounted) return;
      setState(() {
        _avatarUrl = avatarLocal;
        _igCtrl.text = igLocal;
        _fbCtrl.text = fbLocal;
        _lineCtrl.text = lineLocal;
        _showIG = showIGLocal;
        _showFB = showFBLocal;
        _showLINE = showLINELocal;
        _loading = false;
      });

      // 初次預抓好友名稱
      _prefetchFriendNames(context.read<FriendFollowController>().friends);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _prefetchFriendNames(Iterable<String> ids) {
    for (final id in ids) {
      if (!_nameById.containsKey(id)) _loadFriendName(id);
    }
  }

  Future<void> _loadFriendName(String id) async {
    try {
      final p = await _api.fetchUserProfile(id);
      final name = ((p['nickname'] ?? p['name'] ?? '') as String).trim();
      if (name.isEmpty) return;
      if (!mounted) return;
      setState(() => _nameById[id] = name);
    } catch (_) {}
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    _tagInput.dispose();
    _igCtrl.dispose();
    _fbCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nickCtrl.text.trim().isNotEmpty;

  /// 換頭像（Web 相容：用 bytes 上傳），並立即永久化（/me.avatarUrl）
  Future<void> _changeAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
      );
      if (picked == null) return;

      final Uint8List bytes = await picked.readAsBytes();

      // 1) 上傳到伺服器（後端永久存放，回傳絕對網址或可解析之相對路徑）
      final uploadedUrl = await _api.uploadAvatarBytes(
        bytes,
        filename: picked.name,
      );

      // 2) 立刻更新 /me（雲端為單一真相）
      await _api.updateProfile(avatarUrl: uploadedUrl);

      // 3) 同步本機快取
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kAVATAR_URL, uploadedUrl);

      if (!mounted) return;
      setState(() => _avatarUrl = uploadedUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.userProfileSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.downloadFailed}: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_canSave) return;

    final l = context.l10n;
    setState(() => _saving = true);

    try {
      widget.settings.setNickname(_nickCtrl.text.trim());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kIG, _igCtrl.text.trim());
      await prefs.setString(_kFB, _fbCtrl.text.trim());
      await prefs.setString(_kLINE, _lineCtrl.text.trim());
      await prefs.setBool(_kIG_SHOW, _showIG);
      await prefs.setBool(_kFB_SHOW, _showFB);
      await prefs.setBool(_kLINE_SHOW, _showLINE);

      // 從 Provider 取目前好友清單
      final following = context.read<FriendFollowController>().friends.toList();

      await _api.updateProfile(
        nickname: _nickCtrl.text.trim(),
        avatarUrl: _avatarUrl, // 冪等：已於 _changeAvatar 寫回雲端，這裡再帶一次也可
        instagram: _igCtrl.text.trim(),
        facebook: _fbCtrl.text.trim(),
        lineId: _lineCtrl.text.trim(),
        showInstagram: _showIG,
        showFacebook: _showFB,
        showLine: _showLINE,
        followingUserIds: following,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.userProfileSaved)));
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.previewFailed}: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addTag() async {
    final t = _tagInput.text.trim();
    if (t.isEmpty) return;
    await context.read<TagFollowController>().add(t);
    if (!mounted) return;
    _tagInput.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.addedFollowedTagToast)));
  }

  Future<void> _removeTag(String t) async {
    await context.read<TagFollowController>().remove(t);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.removedFollowedTagToast)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final followedTags = context.watch<TagFollowController>().followed;
    final followingIds = context.watch<FriendFollowController>().friends;

    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // ===== 基本資料卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: cs.surfaceVariant,
                                  foregroundImage:
                                      (_avatarUrl != null &&
                                          _avatarUrl!.isNotEmpty)
                                      ? NetworkImage(_avatarUrl!)
                                      : null,
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 36,
                                  ),
                                ),
                                IconButton.filled(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.edit, size: 16),
                                  tooltip: l.changeAvatar,
                                  onPressed: _changeAvatar,
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nickCtrl,
                                decoration: InputDecoration(
                                  labelText: l.nicknameLabel,
                                  hintText: 'e.g. Jenny',
                                ),
                                onChanged: (_) => setState(() {}),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? l.nicknameRequired
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(Icons.mail_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _emailText,
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 社群連結卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.socialLinksTitle,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _igCtrl,
                        decoration: InputDecoration(
                          labelText: l.instagramLabel,
                          hintText: '@your_ig',
                          prefixIcon: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                      SwitchListTile(
                        value: _showIG,
                        onChanged: (v) => setState(() => _showIG = v),
                        title: Text(l.showInstagramOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fbCtrl,
                        decoration: InputDecoration(
                          labelText: l.facebookLabel,
                          hintText: 'fb.me/yourname',
                          prefixIcon: const Icon(Icons.facebook),
                        ),
                      ),
                      SwitchListTile(
                        value: _showFB,
                        onChanged: (v) => setState(() => _showFB = v),
                        title: Text(l.showFacebookOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _lineCtrl,
                        decoration: InputDecoration(
                          labelText: l.lineLabel,
                          hintText: 'your_line_id',
                          prefixIcon: const Icon(Icons.chat_bubble_outline),
                        ),
                      ),
                      SwitchListTile(
                        value: _showLINE,
                        onChanged: (v) => setState(() => _showLINE = v),
                        title: Text(l.showLineOnProfile),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 追蹤標籤卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tag_outlined),
                          const SizedBox(width: 8),
                          Text(
                            l.followedTagsCount(followedTags.length),
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangeNotifierProvider<
                                        TagFollowController
                                      >.value(
                                        value: context
                                            .read<TagFollowController>(),
                                        child: FollowedTagsPage(api: _api),
                                      ),
                                ),
                              );
                              await context
                                  .read<TagFollowController>()
                                  .refresh();
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l.manageFollowedTags),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagInput,
                              decoration: InputDecoration(
                                labelText: l.addFollowedTag,
                                hintText: l.addFollowedTagHint,
                                prefixIcon: const Icon(Icons.add),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: _addTag,
                            child: Text(l.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: [
                          for (final t in followedTags)
                            InputChip(
                              label: Text('#$t'),
                              onDeleted: () => _removeTag(t),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== 已加入好友卡 =====
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_outline),
                          const SizedBox(width: 8),
                          Text(
                            '${l.socialFriends} (${followingIds.length})',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChangeNotifierProvider<
                                        FriendFollowController
                                      >.value(
                                        value: context
                                            .read<FriendFollowController>(),
                                        child: FriendCardsPage(api: _api),
                                      ),
                                ),
                              );
                              // 回來時若有改動，Provider 會自動反映；這裡保險再 refresh 一次
                              await context
                                  .read<FriendFollowController>()
                                  .refresh();
                              // 預抓名稱
                              _prefetchFriendNames(
                                context.read<FriendFollowController>().friends,
                              );
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: Text(l.manageCards),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (followingIds.isEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l.noFriendsYet,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        )
                      else
                        Column(
                          children: followingIds.map((id) {
                            if (!_nameById.containsKey(id)) _loadFriendName(id);
                            final display = (_nameById[id]?.isNotEmpty ?? false)
                                ? _nameById[id]!
                                : id;
                            return Dismissible(
                              key: ValueKey('friend_$id'),
                              background: Container(
                                color: cs.errorContainer,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 16),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_remove, color: cs.error),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.remove,
                                      style: TextStyle(color: cs.error),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: cs.errorContainer,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l.remove,
                                      style: TextStyle(color: cs.error),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.person_remove, color: cs.error),
                                  ],
                                ),
                              ),
                              onDismissed: (_) async {
                                await context
                                    .read<FriendFollowController>()
                                    .remove(id);
                              },
                              child: ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(display),
                                subtitle: Text(
                                  l.accountNoInfo,
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                trailing: IconButton(
                                  tooltip: l.remove,
                                  icon: const Icon(Icons.close),
                                  onPressed: () async {
                                    await context
                                        .read<FriendFollowController>()
                                        .remove(id);
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );

    final scaffold = Scaffold(
      body: Stack(
        children: [
          content,
          Positioned(
            right: 12,
            top: MediaQuery.of(context).padding.top + 12,
            child: FloatingActionButton.extended(
              heroTag: 'save_profile_fab_top_right',
              onPressed: _canSave && !_saving ? _saveProfile : null,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l.save),
            ),
          ),
        ],
      ),
    );

    if (!widget.forceComplete) return scaffold;
    return WillPopScope(onWillPop: () async => _canSave, child: scaffold);
  }

  /// 由外部（RootNav）在「進入本頁」時呼叫：重新從後端刷新並套到欄位
  Future<void> refreshOnEnter() async {
    if (!mounted) return;
    setState(() => _loading = true); // 顯示進度圈
    await _bootstrap(); // 直接重跑你已有的抓取邏輯
  }
}
