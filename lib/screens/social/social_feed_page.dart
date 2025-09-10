// lib/screens/social/social_feed_page.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui'; // for ImageFilter
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'friend_cards_page.dart';

// models / services / 本地標籤記憶
import '../../models/social_models.dart';
import '../../services/social_api.dart';
import '../../services/tag_prefs.dart';

// 帖文編輯器
import 'post_composer.dart';

enum FeedTab { friends, hot, following }

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  late final SocialUser _me;
  late final SocialApi _api;

  final Set<String> _myFriendIds = {'u_bob'};
  List<SocialPost> _posts = [];
  FeedTab _tab = FeedTab.friends;

  // 追蹤標籤（最多 30 個）
  List<String> _followed = [];

  bool _loading = false;

  // === 網路狀態 ===
  bool _isOffline = false;
  StreamSubscription<ConnectivityResult>? _connSub;

  @override
  void initState() {
    super.initState();
    _me = SocialUser(
      id: 'u_me',
      name: (widget.settings.nickname ?? 'Me').trim().isEmpty
          ? 'Me'
          : widget.settings.nickname!,
    );
    _api = SocialApi(meId: _me.id, meName: _me.name);
    _setupConnectivity();
    _bootstrap();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  Future<void> _setupConnectivity() async {
    final c = Connectivity();
    // 初始狀態
    final r = await c.checkConnectivity();
    _setOffline(r == ConnectivityResult.none);
    // 監聽變化（不要做任何 cast）
    _connSub =
        c.onConnectivityChanged.listen((result) {
              _setOffline(result == ConnectivityResult.none);
            })
            as StreamSubscription<ConnectivityResult>?;
  }

  void _setOffline(bool v) {
    if (!mounted || v == _isOffline) return;
    setState(() => _isOffline = v);
    if (!v) {
      // 從離線回到線上，自動重試
      _refresh();
    } else {
      _showSnack('目前處於離線狀態', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? cs.error : null),
    );
  }

  // ==== 兩種防護：有回傳值 / 無回傳值 ====

  /// 有回傳值（例如：fetchPosts / toggleLike / addComment）
  Future<T?> _guardValue<T>(Future<T> Function() task) async {
    try {
      return await task().timeout(const Duration(seconds: 15));
    } on SocketException {
      _showSnack('連不上伺服器，請檢查網路或後端服務是否啟動。', isError: true);
    } on TimeoutException {
      _showSnack('連線逾時，請稍後重試。', isError: true);
    } on HttpException catch (e) {
      _showSnack('HTTP 錯誤：${e.message}', isError: true);
    } catch (e) {
      _showSnack('發生錯誤：$e', isError: true);
    }
    return null;
  }

  /// 無回傳值（例如：createPost / updatePost / deletePost 若其回傳型別是 Future<void>）
  Future<bool> _guardVoid(Future<void> Function() task) async {
    try {
      await task().timeout(const Duration(seconds: 15));
      return true;
    } on SocketException {
      _showSnack('連不上伺服器，請檢查網路或後端服務是否啟動。', isError: true);
    } on TimeoutException {
      _showSnack('連線逾時，請稍後重試。', isError: true);
    } on HttpException catch (e) {
      _showSnack('HTTP 錯誤：${e.message}', isError: true);
    } catch (e) {
      _showSnack('發生錯誤：$e', isError: true);
    }
    return false;
  }

  Future<void> _bootstrap() async {
    _followed = await TagPrefs.load();
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

  Future<void> _refresh() async {
    if (_isOffline) {
      _showSnack('目前離線，無法更新貼文。', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      List<SocialPost>? list;
      switch (_tab) {
        case FeedTab.friends:
          list = await _guardValue(
            () => _api.fetchPosts(tab: FeedTabApi.friends),
          );
          if (list != null) {
            list = list
                .where(
                  (p) =>
                      _myFriendIds.contains(p.author.id) ||
                      p.author.id == _me.id,
                )
                .toList();
          }
          break;
        case FeedTab.hot:
          list = await _guardValue(() => _api.fetchPosts(tab: FeedTabApi.hot));
          break;
        case FeedTab.following:
          list = await _guardValue(
            () => _api.fetchPosts(tab: FeedTabApi.following, tags: _followed),
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
    if (_isOffline) {
      _showSnack('離線中，無法發佈貼文。', isError: true);
      return;
    }
    final res = await showPostComposer(context);
    if (res == null) return;

    // 假設 createPost 是 Future<void>；若你回傳 Post，改用 _guardValue<Post>(...)
    final ok = await _guardVoid(
      () =>
          _api.createPost(text: res.text, tags: res.tags, imageFile: res.image),
    );
    if (ok) await _refresh();
  }

  Future<void> _onEdit(SocialPost p) async {
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

    // 假設 updatePost 是 Future<void>；若你回傳 Post，改用 _guardValue<Post>(...)
    final ok = await _guardVoid(
      () => _api.updatePost(
        id: p.id,
        text: res.text,
        tags: res.tags,
        imageFile: res.image,
      ),
    );
    if (ok) await _refresh();
  }

  Future<void> _onDelete(String postId) async {
    if (_isOffline) {
      _showSnack('離線中，無法刪除貼文。', isError: true);
      return;
    }
    // 假設 deletePost 是 Future<void>
    final ok = await _guardVoid(() => _api.deletePost(postId));
    if (ok) await _refresh();
  }

  Future<void> _onToggleLike(SocialPost p) async {
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

  Future<void> _onAddComment(SocialPost p, String text) async {
    if (_isOffline) {
      _showSnack('離線中，無法留言。', isError: true);
      return;
    }
    final updated = await _guardValue(
      () => _api.addComment(postId: p.id, text: text),
    );
    if (updated != null) {
      setState(() {
        _posts = _posts.map((e) => e.id == updated.id ? updated : e).toList();
      });
    }
  }

  Future<void> _followTagAndShow(String tag) async {
    if (_followed.length >= TagPrefs.maxTags &&
        !_followed.contains(tag.toLowerCase())) {
      _showSnack('已達 ${TagPrefs.maxTags} 個追蹤標籤上限', isError: true);
      return;
    }
    _followed = await TagPrefs.add(tag);
    setState(() => _tab = FeedTab.following);
    await _refresh();
  }

  Future<void> _showCommentsSheet(SocialPost p) async {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final cCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
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
                    itemCount: p.comments.length,
                    separatorBuilder: (_, __) =>
                        Divider(color: cs.outlineVariant),
                    itemBuilder: (_, i) {
                      final c = p.comments[i];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: Text(
                              c.author.name.isNotEmpty
                                  ? c.author.name.characters.first.toUpperCase()
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
                          decoration: InputDecoration(
                            hintText: l.leaveACommentHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          final t = cCtrl.text.trim();
                          if (t.isEmpty) return;
                          await _onAddComment(p, t);
                          cCtrl.clear();
                        },
                        icon: const Icon(Icons.send),
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
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      initialIndex: _tab.index,
      child: Scaffold(
        body: Column(
          children: [
            // === 離線提示橫幅 ===
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
                    const Expanded(child: Text('離線中：部分功能不可用')),
                    TextButton(onPressed: _refresh, child: const Text('重試')),
                  ],
                ),
              ),

            // 頁籤 + 朋友名片 + 刷新
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
                    IconButton(
                      tooltip: l.friendCardsTitle,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FriendCardsPage(),
                        ),
                      ),
                      icon: const Icon(Icons.badge_outlined, size: 28),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),

            // 追蹤標籤列（顯示在頁籤與按鈕下方）
            if (_followed.isNotEmpty)
              SizedBox(
                height: 44,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  children: [
                    const SizedBox(width: 4),
                    for (final t in _followed)
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
                          onDeleted: () async {
                            _followed = await TagPrefs.remove(t);
                            setState(() {});
                            if (_tab == FeedTab.following) await _refresh();
                          },
                        ),
                      ),
                  ],
                ),
              ),

            // 貼文列表
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                      itemCount: _posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final p = _posts[i];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: cs.surface.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        CircleAvatar(
                                          child: Text(
                                            p.author.name.isNotEmpty
                                                ? p.author.name.characters.first
                                                      .toUpperCase()
                                                : '?',
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
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                _timeAgo(context, p.createdAt),
                                                style: TextStyle(
                                                  color: cs.onSurfaceVariant,
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
                                              if (v == 'delete')
                                                _onDelete(p.id);
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
                                        style: const TextStyle(fontSize: 15),
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
                                              onPressed: () async {
                                                if (_followed.length >=
                                                        TagPrefs.maxTags &&
                                                    !_followed.contains(
                                                      t.toLowerCase(),
                                                    )) {
                                                  _showSnack(
                                                    '已達 ${TagPrefs.maxTags} 個追蹤標籤上限',
                                                    isError: true,
                                                  );
                                                  return;
                                                }
                                                await _followTagAndShow(t);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // 圖片（後端 imageUrl）
                                  if (p.imageUrl != null) ...[
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          '$kBaseUrl${p.imageUrl!}',
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
                                          style: TextStyle(color: cs.onSurface),
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
                                            '${l.commentsTitle} (${p.comments.length})',
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _onCreate,
          icon: const Icon(Icons.edit),
          label: Text(l.publish),
        ),
      ),
    );
  }
}
