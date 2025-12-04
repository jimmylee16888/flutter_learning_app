// lib/screens/social/social_feed_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui'; // for ImageFilter

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/dev_mode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_learning_app/services/services.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import '../../models/social_models.dart';

// 帖文編輯器 / 好友名片 / 追蹤標籤 / 使用者頁
import 'post_composer.dart';
import 'followed_tags_page.dart' as tags;
import 'friend_profile_page.dart';
import 'conversations_page.dart';

enum FeedTab { friends, hot, following }

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  // === 身分 / API ===
  late SocialUser _me;
  late SocialApi _api;
  static const _kDebugUidKey = 'debug_uid';
  bool _identityReady = false;

  // === 狀態 ===
  late final TagFollowController _tagCtl;
  Set<String> _myFriendIds = {};
  List<SocialPost> _posts = [];
  FeedTab _tab = FeedTab.friends;
  bool _loading = false;

  // === 網路狀態 ===
  bool _isOffline = false;
  StreamSubscription<dynamic>? _connSub;

  @override
  void initState() {
    super.initState();
    _tagCtl = context.read<TagFollowController>();
    _tagCtl.addListener(_onTagsChanged);

    Future.microtask(() async {
      await _initIdentityAndApi();
      if (!mounted) return;
      await _setupConnectivity();
      await _bootstrap();
    });
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _tagCtl.removeListener(_onTagsChanged);
    super.dispose();
  }

  // ================ 身分初始化 =================
  Future<void> _initIdentityAndApi() async {
    final auth = FirebaseAuth.instance;
    User? u = auth.currentUser;

    String? email = u?.email?.trim();
    String? uid = u?.uid;

    if (email == null && uid == null) {
      final sp = await SharedPreferences.getInstance();
      var debugUid = sp.getString(_kDebugUidKey);
      debugUid ??= 'dev_${const Uuid().v4()}';
      await sp.setString(_kDebugUidKey, debugUid);
      uid = debugUid; // 之後以 Authorization: Debug <uid>
    }

    final meId = (email != null && email.isNotEmpty)
        ? email.toLowerCase()
        : (uid ?? 'dev_unknown');

    final meName = (widget.settings.nickname?.trim().isNotEmpty == true)
        ? widget.settings.nickname!.trim()
        : (u?.displayName?.trim().isNotEmpty == true)
        ? u!.displayName!.trim()
        : (email != null ? email.split('@').first : meId);

    _me = SocialUser(id: meId, name: meName);

    _api = SocialApi(
      meId: _me.id,
      meName: _me.name,
      idTokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );

    if (mounted) {
      setState(() {
        _identityReady = true;
      });
    }
  }

  // ============== Tag 變更 / 連線變更 =================
  void _onTagsChanged() {
    if (!mounted) return;
    if (_tab == FeedTab.following) {
      _refresh();
    } else {
      setState(() {}); // 讓上方 chips 即時更新
    }
  }

  Future<void> _setupConnectivity() async {
    final c = Connectivity();

    final initial = await c.checkConnectivity();
    _applyConnectivity(initial);

    _connSub = c.onConnectivityChanged.listen(_applyConnectivity);
  }

  void _applyConnectivity(dynamic value) {
    final list = value is List<ConnectivityResult>
        ? value
        : value is ConnectivityResult
        ? <ConnectivityResult>[value]
        : const <ConnectivityResult>[];

    final offline =
        list.isEmpty || list.every((r) => r == ConnectivityResult.none);
    if (!mounted || offline == _isOffline) return;

    setState(() => _isOffline = offline);
    if (!offline) {
      _refresh();
    } else {
      _showSnack('目前處於離線狀態', isError: true);
    }
  }

  // ============== 共用提示 / 守門 =================
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? cs.error : null),
    );
  }

  Future<T?> _guardValue<T>(Future<T> Function() task) async {
    try {
      return await task().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      _showSnack('連線逾時，請稍後重試。', isError: true);
    } catch (e) {
      final isDev = await DevMode.isEnabled();
      if (isDev) {
        _showSnack('發生錯誤：$e', isError: true);
      }
    }
    return null;
  }

  Future<bool> _guardVoid(Future<void> Function() task) async {
    try {
      await task().timeout(const Duration(seconds: 15));
      return true;
    } on TimeoutException {
      _showSnack('連線逾時，請稍後重試。', isError: true);
    } catch (e) {
      final isDev = await DevMode.isEnabled();
      if (isDev) {
        _showSnack('發生錯誤：$e', isError: true);
      }
    }
    return false;
  }

  // ============== 首次初始化 =================
  Future<void> _bootstrap() async {
    if (!_identityReady) return;

    final friends = await _guardValue(() => _api.fetchMyFriends());
    if (!mounted) return;
    setState(() {
      _myFriendIds = (friends ?? []).toSet()..add(_me.id); // 把自己也視為「好友來源」
    });

    final nick = widget.settings.nickname?.trim();
    if (nick != null && nick.isNotEmpty) {
      await _guardVoid(() => _api.updateProfile(nickname: nick));
    }

    await _refresh();
  }

  String _timeAgo(BuildContext context, DateTime dt) {
    final l = context.l10n;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l.timeJustNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    return l.timeDaysAgo(diff.inDays);
  }

  // ============== 資料流程 =================
  Future<void> _refresh() async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('目前離線，無法更新貼文。', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      List<SocialPost>? list;
      switch (_tab) {
        case FeedTab.friends:
          final friendIds = {..._myFriendIds, _me.id}.toList();
          list = await _guardValue(
            () =>
                _api.fetchPosts(tab: FeedTabApi.friends, friendIds: friendIds),
          );
          break;
        case FeedTab.hot:
          list = await _guardValue(() => _api.fetchPosts(tab: FeedTabApi.hot));
          break;
        case FeedTab.following:
          final tags = _tagCtl.followed;
          list = await _guardValue(
            () => _api.fetchPosts(tab: FeedTabApi.following, tags: tags),
          );
          break;
      }
      if (list != null) {
        setState(() => _posts = list!);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onCreate() async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法發佈貼文。', isError: true);
      return;
    }
    final res = await showPostComposer(context);
    if (res == null) return;

    final Uint8List? bytes = await res.image?.readAsBytes();
    final String? filename = res.image?.name;

    final ok = await _guardVoid(
      () => _api.createPost(
        text: res.text,
        tags: res.tags,
        imageBytes: bytes,
        filename: filename,
      ),
    );
    if (ok) await _refresh();
  }

  Future<void> _onEdit(SocialPost p) async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法編輯貼文。', isError: true);
      return;
    }
    final res = await showPostComposer(
      context,
      initialText: p.text,
      initialTags: p.tags,
    );
    if (res == null) return;

    final Uint8List? bytes = await res.image?.readAsBytes();
    final String? filename = res.image?.name;

    final ok = await _guardVoid(
      () => _api.updatePost(
        id: p.id,
        text: res.text,
        tags: res.tags,
        imageBytes: bytes,
        filename: filename,
      ),
    );
    if (ok) await _refresh();
  }

  Future<void> _onDelete(String postId) async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法刪除貼文。', isError: true);
      return;
    }
    final ok = await _guardVoid(() => _api.deletePost(postId));
    if (ok) await _refresh();
  }

  Future<void> _onToggleLike(SocialPost p) async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法按讚。', isError: true);
      return;
    }
    final updated = await _guardValue(() => _api.toggleLike(p.id));
    if (updated != null) {
      setState(() {
        _posts = _posts.map((e) => e.id == updated.id ? updated : e).toList();
      });
    }
  }

  Future<SocialPost?> _onAddComment(SocialPost p, String text) async {
    if (!_identityReady) return null;
    if (_isOffline) {
      _showSnack('離線中，無法留言。', isError: true);
      return null;
    }
    final updated = await _guardValue(
      () => _api.addComment(postId: p.id, text: text),
    );
    if (updated != null) {
      setState(() {
        _posts = _posts.map((e) => e.id == updated.id ? updated : e).toList();
      });
    }
    return updated;
  }

  Future<void> _followTagAndShow(String tag) async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法更新追蹤標籤。', isError: true);
      return;
    }
    await _tagCtl.add(tag);
    if (!mounted) return;
    setState(() => _tab = FeedTab.following);
    await _refresh();
  }

  Future<void> _removeTag(String tag) async {
    if (!_identityReady) return;
    if (_isOffline) {
      _showSnack('離線中，無法更新追蹤標籤。', isError: true);
      return;
    }
    await _tagCtl.remove(tag);
    if (_tab == FeedTab.following) await _refresh();
  }

  // ===== 進入個人頁：把 FriendFollowController 帶入子路由 =====
  Future<void> _openProfile(String userId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<FriendFollowController>.value(
          value: context.read<FriendFollowController>(),
          child: FriendProfilePage(api: _api, userId: userId),
        ),
      ),
    );

    final ids = await _guardValue(() => _api.fetchMyFriends());
    if (ids != null) _myFriendIds = ids.toSet()..add(_me.id);
    if (_tab == FeedTab.friends) await _refresh();
  }

  // ===== 進入 DM 對話列表 =====
  Future<void> _openConversations() async {
    if (!_identityReady) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationsPage(api: _api, me: _me),
      ),
    );
    // 回來後如果在 friends tab，可以順便更新一次貼文（例如 DM 影響好友關係之類）
    if (mounted && _tab == FeedTab.friends) {
      await _refresh();
    }
  }

  // ============== UI =================
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    if (!_identityReady) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    final followed = context.watch<TagFollowController>().followed;

    return DefaultTabController(
      length: 3,
      initialIndex: _tab.index,
      child: Scaffold(
        // ✅ 沒有 AppBar，只用 body
        body: Stack(
          children: [
            Column(
              children: [
                if (_isOffline)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: cs.errorContainer,
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.offlineBanner)),
                        TextButton(onPressed: _refresh, child: Text(l.retry)),
                      ],
                    ),
                  ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            onTap: (i) async {
                              setState(() => _tab = FeedTab.values[i]);
                              await _refresh();
                            },
                            indicatorWeight: 3,
                            indicatorColor: cs.primary,
                            labelColor: cs.onSurface,
                            unselectedLabelColor: cs.onSurfaceVariant,
                            tabs: [
                              Tab(text: l.socialFriends),
                              Tab(text: l.socialHot),
                              Tab(text: l.socialFollowing),
                            ],
                          ),
                        ),
                        // 追蹤標籤管理
                        IconButton.filledTonal(
                          tooltip: l.manageFollowedTags,
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ChangeNotifierProvider<
                                      TagFollowController
                                    >.value(
                                      value: context
                                          .read<TagFollowController>(),
                                      child: tags.FollowedTagsPage(api: _api),
                                    ),
                              ),
                            );
                            await context.read<TagFollowController>().refresh();
                            if (_tab == FeedTab.following) await _refresh();
                          },
                          icon: const Icon(Icons.tag),
                        ),
                        const SizedBox(width: 4),
                        // ✅ DM / 訊息入口
                        IconButton(
                          tooltip: l.socialMessagesTitle,
                          onPressed: _openConversations,
                          icon: const Icon(Icons.chat_bubble_outline),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: l.retry,
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                ),

                if (followed.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      children: [
                        const SizedBox(width: 4),
                        for (final t in followed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InputChip(
                              label: Text('#${t.trim()}'),
                              visualDensity: VisualDensity.compact,
                              onPressed: () async {
                                if (_tab != FeedTab.following) {
                                  setState(() => _tab = FeedTab.following);
                                }
                                await _refresh();
                              },
                              onDeleted: () => _removeTag(t),
                            ),
                          ),
                      ],
                    ),
                  ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                          itemCount: _posts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final p = _posts[i];

                            String? imgUrl;
                            if (p.imageUrl != null) {
                              final img = p.imageUrl!;
                              imgUrl = _api.resolveUrl(img);
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.surface.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: cs.outlineVariant,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          12,
                                          12,
                                          8,
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  _openProfile(p.author.id),
                                              customBorder:
                                                  const CircleBorder(),
                                              child: CircleAvatar(
                                                child: Text(
                                                  p.author.name.isNotEmpty
                                                      ? p
                                                            .author
                                                            .name
                                                            .characters
                                                            .first
                                                            .toUpperCase()
                                                      : '?',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.author.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  Text(
                                                    _timeAgo(
                                                      context,
                                                      p.createdAt,
                                                    ),
                                                    style: TextStyle(
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (p.author.id == _me.id)
                                              PopupMenuButton<String>(
                                                color: cs.surface,
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Text(
                                                      l.edit,
                                                      style: TextStyle(
                                                        color: cs.onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text(
                                                      l.delete,
                                                      style: TextStyle(
                                                        color: cs.onSurface,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (v) {
                                                  if (v == 'delete') {
                                                    _onDelete(p.id);
                                                  }
                                                  if (v == 'edit') _onEdit(p);
                                                },
                                                icon: Icon(
                                                  Icons.more_horiz,
                                                  color: cs.onSurface,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (p.text.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            p.text,
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      if (p.tags.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: -8,
                                            children: [
                                              for (final t in p.tags)
                                                ActionChip(
                                                  label: Text('#$t'),
                                                  onPressed: () =>
                                                      _followTagAndShow(t),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      if (imgUrl != null) ...[
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              imgUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const SizedBox.shrink(),
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          4,
                                          0,
                                          4,
                                          4,
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () => _onToggleLike(p),
                                              icon: Icon(
                                                p.likedByMe
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: p.likedByMe
                                                    ? cs.primary
                                                    : cs.onSurface,
                                              ),
                                            ),
                                            Text(
                                              '${p.likeCount}',
                                              style: TextStyle(
                                                color: cs.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () =>
                                                  _showCommentsSheet(p),
                                              icon: Icon(
                                                Icons.mode_comment_outlined,
                                                color: cs.onSurface,
                                              ),
                                              label: Text(
                                                l.commentsCount(
                                                  p.comments.length,
                                                ),
                                                style: TextStyle(
                                                  color: cs.onSurface,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // 右下：發文按鈕
            Positioned(
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: FloatingActionButton(
                heroTag: 'fab_main',
                tooltip: l.publish,
                onPressed: _onCreate,
                child: const Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCommentsSheet(SocialPost p) async {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final cCtrl = TextEditingController();

    SocialPost localPost = p;
    bool sending = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.65,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.commentsTitle,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Divider(color: cs.outlineVariant, height: 24),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: localPost.comments.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: cs.outlineVariant),
                        itemBuilder: (_, i) {
                          final c = localPost.comments[i];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                child: Text(
                                  c.author.name.isNotEmpty
                                      ? c.author.name.characters.first
                                            .toUpperCase()
                                      : '?',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.author.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(c.text),
                                    const SizedBox(height: 4),
                                    Text(
                                      _timeAgo(context, c.createdAt),
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Divider(color: cs.outlineVariant, height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cCtrl,
                              enabled: !sending,
                              decoration: InputDecoration(
                                hintText: l.leaveACommentHint,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          sending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () async {
                                    final t = cCtrl.text.trim();
                                    if (t.isEmpty) return;
                                    setStateSB(() => sending = true);
                                    final updated = await _onAddComment(
                                      localPost,
                                      t,
                                    );
                                    if (updated != null) {
                                      setStateSB(() {
                                        localPost = updated;
                                        cCtrl.clear();
                                      });
                                    }
                                    await Future.delayed(
                                      const Duration(milliseconds: 300),
                                    );
                                    setStateSB(() => sending = false);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 由外部（RootNav）在「進入社群頁」時呼叫
  Future<void> refreshOnEnter() async {
    if (!_identityReady) return;
    if (_loading) return;
    await _refresh();
  }
}
