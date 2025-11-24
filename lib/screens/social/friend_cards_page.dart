// lib/screens/social/friend_cards_page.dart
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/models/friend_card.dart';
import 'package:flutter_learning_app/screens/user/scan_friend_qr_page.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:flutter_learning_app/services/services.dart'
    show FriendFollowController;
import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/social_models.dart';
import 'friend_profile_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

// 👇 產生 QR 用
import 'package:qr_flutter/qr_flutter.dart';

class FriendCardsPage extends StatefulWidget {
  const FriendCardsPage({super.key, required this.api});
  final SocialApi api;

  @override
  State<FriendCardsPage> createState() => _FriendCardsPageState();
}

class _FriendCardsPageState extends State<FriendCardsPage> {
  /// 本地覆蓋資料（以好友 id 為 key）。只覆蓋電話/IG/LINE…等欄位與暱稱；
  /// 追蹤名單本身完全以 FriendFollowController 為準。
  final Map<String, FriendCard> _overrides = <String, FriendCard>{};

  /// 後端名稱快取（id -> name）
  final Map<String, String> _nameById = {};
  String _query = '';

  /// 本地暱稱 / email
  final Map<String, _FriendMeta> _metaById = <String, _FriendMeta>{};

  static const _kFriendMetaKey = 'friend_meta_v1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctl = context.read<FriendFollowController?>();
      if (ctl != null) {
        _prefetchRemoteNames(ctl.friends);
      }
      _loadLocalMeta();
    });
  }

  Future<void> _prefetchRemoteNames(Iterable<String> ids) async {
    for (final id in ids) {
      if (_nameById.containsKey(id)) continue;
      _loadRemoteName(id);
    }
  }

  Future<void> _loadRemoteName(String userId) async {
    try {
      final p = await widget.api.fetchUserProfile(userId);
      final name = (p['name'] ?? p['nickname'] ?? '') as String;
      if (!mounted) return;
      if (name.trim().isNotEmpty) {
        setState(() => _nameById[userId] = name.trim());
      }
    } catch (_) {
      // 安靜失敗
    }
  }

  /// 以追蹤集合建立顯示清單（本地暱稱 > 遠端名稱 > id/email）
  List<FriendCard> _joinedCards(Set<String> following) {
    return following.map((id) {
      final meta = _metaById[id];
      final localNick = meta?.nickname.trim();
      final remoteName = _nameById[id]?.trim();

      final display = (localNick != null && localNick.isNotEmpty)
          ? localNick
          : (remoteName != null && remoteName.isNotEmpty)
          ? remoteName
          : id;

      return _overrides[id] ??
          FriendCard(id: id, nickname: display, artists: const []);
    }).toList();
  }

  List<FriendCard> _filtered(Set<String> following) {
    final list = _joinedCards(following);
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((c) {
      final name = c.nickname.toLowerCase();
      final inName = name.contains(q);
      final inArtists = c.artists.any((a) => a.toLowerCase().contains(q));
      final inPhone = (c.phone ?? '').toLowerCase().contains(q);
      final inLine = (c.lineId ?? '').toLowerCase().contains(q);
      final inFb = (c.facebook ?? '').toLowerCase().contains(q);
      final inIg = (c.instagram ?? '').toLowerCase().contains(q);
      return inName || inArtists || inPhone || inLine || inFb || inIg;
    }).toList();
  }

  /// ✅ 新版：直接輸入 Email + 暱稱 → follow + 建名片
  Future<void> _startAddFlow() async {
    final l = context.l10n;

    final res = await showDialog<_NewFriendInput>(
      context: context,
      builder: (_) => const _AddFriendDialog(),
    );
    if (res == null) return;

    final email = res.email.trim();
    final nickname = res.nickname.trim();
    if (email.isEmpty || nickname.isEmpty) return;

    final friendCtrl = context.read<FriendFollowController>();

    try {
      // 如果還沒追蹤就 follow 一下
      if (!friendCtrl.contains(email)) {
        await friendCtrl.add(email);
      }

      setState(() {
        // 建一張本地 FriendCard 覆蓋
        _overrides[email] = FriendCard(
          id: email,
          nickname: nickname,
          artists: const [],
        );

        // 存本地暱稱（id 就是 email）
        _metaById[email] = _FriendMeta(nickname: nickname, email: email);
      });

      await _saveLocalMeta();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.friendAddedStatus}: $nickname')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新增好友失敗，請稍後再試')));
    }
  }

  Future<void> _addOrEditCardFor(String id) async {
    final initial =
        _overrides[id] ??
        FriendCard(
          id: id,
          nickname: _metaById[id]?.nickname.isNotEmpty == true
              ? _metaById[id]!.nickname
              : (_nameById[id]?.isNotEmpty == true ? _nameById[id]! : id),
          artists: const [],
        );

    final res = await showDialog<FriendCard>(
      context: context,
      builder: (_) => _EditFriendDialog(initial: initial),
    );
    if (res == null) return;

    setState(() {
      // 覆蓋 FriendCard 本身
      _overrides[id] = FriendCard(
        id: id,
        nickname: res.nickname,
        artists: res.artists,
        phone: res.phone,
        lineId: res.lineId,
        facebook: res.facebook,
        instagram: res.instagram,
      );

      // ✅ 本地暱稱 meta（id 就是 email）
      _metaById[id] = _FriendMeta(nickname: res.nickname, email: id);
    });

    await _saveLocalMeta(); // ✅ 寫入 SharedPreferences
    _loadRemoteName(id); // 繼續保留原本行為
  }

  void _deleteLocalOverride(FriendCard c) {
    setState(() => _overrides.remove(c.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final following = context.watch<FriendFollowController>().friends;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.friendCardsTitle),
        actions: [
          IconButton(
            tooltip: l.scanQr,
            onPressed: () async {
              final friendCtrl = context.read<FriendFollowController>();

              final friendId = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) =>
                      ChangeNotifierProvider<FriendFollowController>.value(
                        value: friendCtrl,
                        child: const ScanFriendQrPage(),
                      ),
                ),
              );

              if (friendId != null && context.mounted) {
                if (!friendCtrl.contains(friendId)) {
                  await friendCtrl.toggle(friendId);
                  await friendCtrl.refresh();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${l.friendAddedStatus}: $friendId')),
                );
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: Column(
        children: [
          _frostedSearchBar(),
          Expanded(
            child: _filtered(following).isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '尚未加入任何好友',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    itemCount: _filtered(following).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final c = _filtered(following)[i];
                      if (!_nameById.containsKey(c.id)) {
                        _loadRemoteName(c.id);
                      }
                      final isFollowing = context
                          .watch<FriendFollowController>()
                          .contains(c.id);

                      return _FriendCardTile(
                        card: c,
                        displayName: c.nickname.isNotEmpty
                            ? c.nickname
                            : (_nameById[c.id]?.isNotEmpty == true
                                  ? _nameById[c.id]!
                                  : c.id),
                        initialFollowing: isFollowing,
                        onEdit: () => _addOrEditCardFor(c.id),
                        onDelete: () async {
                          final friendCtrl = context
                              .read<FriendFollowController>();

                          // 先從追蹤清單移除（呼叫後端 /unfollow）
                          if (friendCtrl.contains(c.id)) {
                            await friendCtrl.remove(c.id);
                          }

                          // 再刪掉本地名片覆蓋 + 暱稱 meta
                          setState(() {
                            _overrides.remove(c.id);
                            _metaById.remove(c.id);
                          });
                          await _saveLocalMeta();
                        },
                        onOpenProfile: () {
                          final friendCtrl = context
                              .read<FriendFollowController>();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChangeNotifierProvider<
                                    FriendFollowController
                                  >.value(
                                    value: friendCtrl,
                                    child: FriendProfilePage(
                                      api: widget.api,
                                      userId: c.id,
                                    ),
                                  ),
                            ),
                          );
                        },
                        onToggleFollow: () async {
                          await context.read<FriendFollowController>().toggle(
                            c.id,
                          );
                          _loadRemoteName(c.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startAddFlow,
        icon: const Icon(Icons.add),
        label: Text(l.addFriendCard),
      ),
    );
  }

  Widget _frostedSearchBar() {
    final l = context.l10n;
    final bg = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: bg.withOpacity(0.6),
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: TextField(
              onChanged: (s) => setState(() => _query = s),
              decoration: InputDecoration(
                hintText: l.searchFriendsOrArtistsHint,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _query = ''),
                        tooltip: l.clear,
                      ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadLocalMeta() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kFriendMetaKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _metaById
        ..clear()
        ..addAll(
          decoded.map(
            (id, v) =>
                MapEntry(id, _FriendMeta.fromJson(v as Map<String, dynamic>)),
          ),
        );
      if (mounted) setState(() {});
    } catch (_) {
      // ignore parse errors
    }
  }

  Future<void> _saveLocalMeta() async {
    final sp = await SharedPreferences.getInstance();
    final map = _metaById.map((id, meta) => MapEntry(id, meta.toJson()));
    await sp.setString(_kFriendMetaKey, jsonEncode(map));
  }
}

class _FriendCardTile extends StatefulWidget {
  final FriendCard card;
  final String displayName;
  final bool initialFollowing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onOpenProfile;
  final Future<void> Function() onToggleFollow;

  const _FriendCardTile({
    required this.card,
    required this.displayName,
    required this.initialFollowing,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenProfile,
    required this.onToggleFollow,
  });

  @override
  State<_FriendCardTile> createState() => _FriendCardTileState();
}

class _FriendCardTileState extends State<_FriendCardTile> {
  bool _flipped = false;
  late bool _following = widget.initialFollowing;

  @override
  void didUpdateWidget(covariant _FriendCardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFollowing != widget.initialFollowing) {
      _following = widget.initialFollowing;
    }
  }

  Color _cardColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final b = Theme.of(context).brightness;
    return b == Brightness.dark
        ? Color.alphaBlend(Colors.white.withOpacity(0.08), cs.surface)
        : Color.alphaBlend(Colors.black.withOpacity(0.06), cs.surface);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    const double radius = 16.0;
    const double bgRatio = 0.40;
    const double minBg = 120.0;
    const double maxBg = 220.0;
    const double dragInset = 12.0;
    const double triggerRatio = 0.66;

    print(context.read<FriendFollowController>().friends);

    return Padding(
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, c) {
          final double actionW = (c.maxWidth * bgRatio).clamp(minBg, maxBg);
          final double dragLimit = (actionW - dragInset).clamp(80.0, actionW);
          double dx = 0;

          Future<void> _animateBack(StateSetter sb) async => sb(() => dx = 0);

          Future<void> _handleEnd(StateSetter sb) async {
            final th = dragLimit * triggerRatio;
            if (dx >= th) {
              widget.onEdit();
              await _animateBack(sb);
            } else if (dx <= -th) {
              final ok =
                  await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l.deleteFriendCardTitle),
                      content: Text(
                        l.deleteFriendCardMessage(widget.displayName),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l.delete),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (ok) widget.onDelete();
              await _animateBack(sb);
            } else {
              await _animateBack(sb);
            }
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 背景：左＝編輯；右＝刪除
                Positioned.fill(
                  child: Row(
                    children: [
                      SizedBox(
                        width: actionW,
                        child: Container(
                          color: cs.primaryContainer.withOpacity(0.22),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, color: cs.primary),
                              const SizedBox(width: 6),
                              Text(l.edit, style: TextStyle(color: cs.primary)),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      SizedBox(
                        width: actionW,
                        child: Container(
                          color: cs.errorContainer.withOpacity(0.22),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l.delete, style: TextStyle(color: cs.error)),
                              const SizedBox(width: 6),
                              Icon(Icons.delete_outline, color: cs.error),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 上層：卡片
                StatefulBuilder(
                  builder: (context, sb) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (d) {
                        sb(() {
                          dx = (dx + d.delta.dx).clamp(-dragLimit, dragLimit);
                        });
                      },
                      onHorizontalDragEnd: (_) => _handleEnd(sb),
                      onHorizontalDragCancel: () => _handleEnd(sb),
                      onTap: () => setState(() => _flipped = !_flipped),
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        offset: Offset(dx / c.maxWidth, 0),
                        child: _buildCardShell(
                          context: context,
                          color: _cardColor(context),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            layoutBuilder: (current, previous) => Stack(
                              fit: StackFit.passthrough,
                              children: [
                                ...previous,
                                if (current != null) current,
                              ],
                            ),
                            child: _flipped
                                ? _BackSide(
                                    onEditTap: widget.onEdit,
                                    friendId: widget.card.id,
                                  )
                                : _FrontSide(
                                    displayName: widget.displayName,
                                    card: widget.card,
                                    following: _following,
                                    onToggleFollow: () async {
                                      await widget.onToggleFollow();
                                      if (!mounted) return;
                                      setState(() => _following = !_following);
                                    },
                                    onAvatarTap: widget.onOpenProfile,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardShell({
    required BuildContext context,
    required Color color,
    required Widget child,
    double radius = 16.0,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color,
      elevation: 4,
      shadowColor: cs.shadow.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _FrontSide extends StatelessWidget {
  final FriendCard card;
  final String displayName;
  final bool following;
  final VoidCallback onToggleFollow;
  final VoidCallback onAvatarTap;

  const _FrontSide({
    required this.card,
    required this.displayName,
    required this.following,
    required this.onToggleFollow,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      key: const ValueKey('front'),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: cs.surfaceContainerHighest,
              child: Text(
                displayName.isNotEmpty ? displayName.characters.first : '?',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (card.artists.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: [
                      for (final a in card.artists) Chip(label: Text(a)),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: -8,
                  children: [
                    if ((card.phone ?? '').isNotEmpty)
                      _Info(icon: Icons.phone, text: card.phone!),
                    if ((card.lineId ?? '').isNotEmpty)
                      _Info(icon: Icons.chat_bubble, text: card.lineId!),
                    if ((card.facebook ?? '').isNotEmpty)
                      _Info(icon: Icons.facebook, text: card.facebook!),
                    if ((card.instagram ?? '').isNotEmpty)
                      _Info(icon: Icons.camera_alt, text: card.instagram!),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.qr_code_2),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onToggleFollow,
            icon: Icon(following ? Icons.person_remove : Icons.person_add),
            label: Text(
              following
                  ? context.l10n.friendAddedStatus
                  : context.l10n.friendAddAction,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackSide extends StatelessWidget {
  final VoidCallback onEditTap;
  final String friendId;

  const _BackSide({required this.onEditTap, required this.friendId});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    // {"type": "friend_qr_v1", "id": <好友ID>}
    final qrPayload = jsonEncode({'type': 'friend_qr_v1', 'id': friendId});

    return Container(
      key: const ValueKey('back'),
      color: Color.alphaBlend(
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.06),
        cs.surface,
      ),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: QrImageView(
                    data: qrPayload,
                    version: QrVersions.auto,
                    size: 160,
                    backgroundColor: Colors.transparent,
                    gapless: true,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: cs.onSurface,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  friendId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: 0.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              tooltip: l.edit,
              onPressed: onEditTap,
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

/// ---- 新增好友對話框用的小模型 ----
class _NewFriendInput {
  final String email;
  final String nickname;
  const _NewFriendInput(this.email, this.nickname);
}

/// 名片編輯對話框：結果會被當作「覆蓋資料」儲存；id 由呼叫端決定。
class _EditFriendDialog extends StatefulWidget {
  final FriendCard? initial;
  const _EditFriendDialog({this.initial});
  @override
  State<_EditFriendDialog> createState() => _EditFriendDialogState();
}

class _EditFriendDialogState extends State<_EditFriendDialog> {
  final _nick = TextEditingController();
  final _artistsCtrl = TextEditingController();
  final _phone = TextEditingController();
  final _line = TextEditingController();
  final _fb = TextEditingController();
  final _ig = TextEditingController();
  final Set<String> _artists = {};

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _nick.text = i.nickname;
      _artists.addAll(i.artists);
      _phone.text = i.phone ?? '';
      _line.text = i.lineId ?? '';
      _fb.text = i.facebook ?? '';
      _ig.text = i.instagram ?? '';
    }
  }

  @override
  void dispose() {
    _nick.dispose();
    _artistsCtrl.dispose();
    _phone.dispose();
    _line.dispose();
    _fb.dispose();
    _ig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.initial == null ? l.addFriendCard : l.editFriendCard),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nick,
                decoration: InputDecoration(labelText: l.nicknameLabel),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _artistsCtrl,
                      decoration: const InputDecoration(
                        labelText: '追蹤的藝人（按 Enter 加入）',
                      ),
                      onSubmitted: (v) {
                        final t = v.trim();
                        if (t.isEmpty) return;
                        setState(() => _artists.add(t));
                        _artistsCtrl.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      final t = _artistsCtrl.text.trim();
                      if (t.isEmpty) return;
                      setState(() => _artists.add(t));
                      _artistsCtrl.clear();
                    },
                    child: Text(l.add),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: -8,
                  children: [
                    for (final a in _artists)
                      InputChip(
                        label: Text(a),
                        onDeleted: () => setState(() => _artists.remove(a)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _line,
                decoration: const InputDecoration(labelText: 'Line'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fb,
                decoration: const InputDecoration(labelText: 'Facebook'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ig,
                decoration: const InputDecoration(labelText: 'Instagram'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            final n = _nick.text.trim();
            if (n.isEmpty) return;
            Navigator.pop(
              context,
              FriendCard(
                id: widget.initial?.id ?? 'tmp', // 呼叫端會覆蓋成目標好友 id
                nickname: n,
                artists: _artists.toList(),
                phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                lineId: _line.text.trim().isEmpty ? null : _line.text.trim(),
                facebook: _fb.text.trim().isEmpty ? null : _fb.text.trim(),
                instagram: _ig.text.trim().isEmpty ? null : _ig.text.trim(),
              ),
            );
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

/// 新增好友用的簡單 dialog：Email + 暱稱
class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _email = TextEditingController();
  final _nick = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _nick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.addFriendCard),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nick,
              decoration: InputDecoration(labelText: l.nicknameLabel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () {
            final email = _email.text.trim();
            final nick = _nick.text.trim();
            if (email.isEmpty || nick.isEmpty) return;
            Navigator.pop(context, _NewFriendInput(email, nick));
          },
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _FriendMeta {
  final String nickname;
  final String? email;

  const _FriendMeta({required this.nickname, this.email});

  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    if (email != null && email!.isNotEmpty) 'email': email,
  };

  static _FriendMeta fromJson(Map<String, dynamic> j) {
    return _FriendMeta(
      nickname: (j['nickname'] as String?)?.trim() ?? '',
      email: (j['email'] as String?)?.trim(),
    );
  }
}
