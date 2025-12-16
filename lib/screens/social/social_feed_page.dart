// lib/screens/social/social_feed_page.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart'; // 你專案的 BuildContext.l10n extension
import '../../models/social_models.dart';
import '../../services/social/social_api.dart';
import '../../services/services.dart'
    show FriendFollowController, TagFollowController;
import 'friend_profile_page.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key, required this.settings, this.api});

  final AppSettings settings;
  final SocialApi? api;

  @override
  State<SocialFeedPage> createState() => SocialFeedPageState();
}

class SocialFeedPageState extends State<SocialFeedPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final SocialApi _api;

  final _state = <FeedTab, _FeedState>{
    FeedTab.friends: _FeedState(),
    FeedTab.hot: _FeedState(),
    FeedTab.following: _FeedState(),
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      _ensureLoaded(_currentTab);
    });

    _api =
        widget.api ??
        SocialApi(meId: 'jimmylee16888@gmail.com', meName: 'Jimmy Lee');

    scheduleMicrotask(() => _ensureLoaded(_currentTab));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  FeedTab get _currentTab {
    switch (_tabCtrl.index) {
      case 0:
        return FeedTab.friends;
      case 1:
        return FeedTab.hot;
      case 2:
      default:
        return FeedTab.following;
    }
  }

  Future<void> refreshOnEnter() async => _refresh(_currentTab, force: true);

  Future<void> _ensureLoaded(FeedTab tab) async {
    final s = _state[tab]!;
    if (s.hasLoadedOnce) return;
    await _refresh(tab, force: true);
  }

  String _normalizeTag(String raw) {
    return raw.trim().replaceAll(RegExp(r'^#+'), '').toLowerCase();
  }

  // ✅ 乾淨版 callback：點作者/留言頭像 → 進使用者資訊頁
  void _openUserProfile(String userId) {
    final friendCtrl = context.read<FriendFollowController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<FriendFollowController>.value(
          value: friendCtrl,
          child: FriendProfilePage(api: _api, userId: userId),
        ),
      ),
    );
  }

  // ✅ 點標籤：加入追蹤 + 切到 Following（Following 預設顯示所有追蹤 tags 的貼文）
  Future<void> _onTagTapped(String rawTag) async {
    final l = context.l10n;
    final tag = _normalizeTag(rawTag);
    if (tag.isEmpty) return;

    final tagCtrl = context.read<TagFollowController?>();
    if (tagCtrl == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.socialTagControllerNotFound)));
      return;
    }

    if (!tagCtrl.followed.contains(tag)) {
      await tagCtrl.add(tag);
      // optional: 讓使用者知道已追蹤
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.socialTagFollowed('#$tag'))));
      }
    }

    if (!mounted) return;

    _tabCtrl.animateTo(2);
    await _refresh(FeedTab.following, force: true);
  }

  Future<void> _refresh(FeedTab tab, {bool force = false}) async {
    final s = _state[tab]!;
    if (s.loading && !force) return;

    setState(() {
      s.loading = true;
      s.error = null;
      if (force) {
        s.items = const [];
        s.hasLoadedOnce = true;
      }
    });

    try {
      final friendCtrl = context.read<FriendFollowController?>();
      final tagCtrl = context.read<TagFollowController?>();

      try {
        await (friendCtrl as dynamic?)?.refresh();
      } catch (_) {}
      try {
        await (tagCtrl as dynamic?)?.refresh();
      } catch (_) {}

      final friendIds = friendCtrl?.friends.toList();
      final followed = tagCtrl?.followed ?? <String>{};

      final raw = await _api.fetchPosts(
        tab: tab.toApi(),
        friendIds: tab == FeedTab.friends ? friendIds : null,
        // ✅ Following：用所有已追蹤 tags
        tags: tab == FeedTab.following ? followed.toList() : null,
      );

      if (!mounted) return;

      // ===== client-side tab 差異（即使後端不分 tab 也能跑）=====
      List<SocialPost> filtered = raw;

      if (tab == FeedTab.friends) {
        final friends = friendCtrl?.friends ?? <String>{};
        filtered = raw.where((p) => friends.contains(p.author.id)).toList();
      } else if (tab == FeedTab.following) {
        if (followed.isNotEmpty) {
          filtered = raw
              .where((p) => p.tags.any((t) => followed.contains(t)))
              .toList();
        } else {
          filtered = const [];
        }
      } else if (tab == FeedTab.hot) {
        filtered = [...raw]
          ..sort((a, b) {
            final la = a.likeCount;
            final lb = b.likeCount;
            if (la != lb) return lb.compareTo(la);
            return b.createdAt.compareTo(a.createdAt);
          });
      }

      setState(() {
        s.items = filtered;
        s.loading = false;
        s.hasLoadedOnce = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        s.loading = false;
        s.error = e;
        s.hasLoadedOnce = true;
      });
    }
  }

  Future<void> _openComposer() async {
    final l = context.l10n;
    final res = await showModalBottomSheet<_ComposeResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => _ComposeSheet(title: l.navSocial),
    );
    if (res == null) return;

    try {
      final created = await _api.createPost(
        text: res.text.trim(),
        tags: res.tags,
        imageBytes: res.imageBytes,
        filename: res.imageName,
      );

      if (!mounted) return;
      final tab = _currentTab;
      final s = _state[tab]!;
      setState(() => s.items = [created, ...s.items]);
    } catch (e) {
      if (!mounted) return;
      final l = context.l10n;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.notice}: $e')));
    }
  }

  Future<void> _toggleLike(SocialPost p) async {
    try {
      final updated = await _api.toggleLike(p.id);
      if (!mounted) return;

      final tab = _currentTab;
      final s = _state[tab]!;
      final idx = s.items.indexWhere((x) => x.id == p.id);
      if (idx < 0) return;

      setState(() {
        final list = [...s.items];
        list[idx] = updated;
        s.items = list;
      });
    } catch (e) {
      if (!mounted) return;
      final l = context.l10n;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.socialLikeFailed}: $e')));
    }
  }

  void _replacePostInAllTabs(SocialPost updated) {
    for (final tab in FeedTab.values) {
      final s = _state[tab]!;
      final idx = s.items.indexWhere((x) => x.id == updated.id);
      if (idx >= 0) {
        final list = [...s.items];
        list[idx] = updated;
        s.items = list;
      }
    }
  }

  void _removePostFromAllTabs(String postId) {
    for (final tab in FeedTab.values) {
      final s = _state[tab]!;
      if (s.items.any((x) => x.id == postId)) {
        s.items = s.items.where((x) => x.id != postId).toList(growable: false);
      }
    }
  }

  // ✅ Following tab：標籤控制條（只顯示已追蹤 tags；長按 = 取消追蹤）
  Widget _followingControls() {
    final l = context.l10n;
    final tagCtrl = context.watch<TagFollowController?>();
    final tags = (tagCtrl?.followed.toList() ?? <String>[])..sort();
    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ✅ All（只是提示用途；Following 本來就預設顯示全部追蹤 tags 的貼文）
            FilterChip(
              label: Text(l.socialTagAll),
              selected: true,
              onSelected: (_) => _refresh(FeedTab.following, force: true),
            ),
            const SizedBox(width: 8),
            for (final t in tags) ...[
              _LongPressChip(
                label: '#$t',
                onTap: () => _refresh(FeedTab.following, force: true),
                onLongPress: () async {
                  final ok = await _confirm(
                    context,
                    title: l.socialUnfollowTagTitle,
                    message: l.socialUnfollowTagMessage('#$t'),
                    okText: l.socialDelete,
                    cancelText: MaterialLocalizations.of(
                      context,
                    ).cancelButtonLabel,
                  );
                  if (ok != true) return;

                  await tagCtrl?.remove(t);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.socialTagUnfollowed('#$t'))),
                  );

                  await _refresh(FeedTab.following, force: true);
                },
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openComposer,
        icon: const Icon(Icons.edit),
        label: Text(l.socialPostAction),
      ),

      // ✅ 不要上方 AppBar：只保留 Tab strip + list
      body: Column(
        children: [
          _TopTabStrip(
            controller: _tabCtrl,
            tabs: [l.socialTabFriends, l.socialTabHot, l.socialTabFollowing],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _FeedList(
                  state: _state[FeedTab.friends]!,
                  onRefresh: () => _refresh(FeedTab.friends, force: true),
                  emptyText: l.socialEmptyFriends,
                  itemBuilder: (p) => _PostCard(
                    post: p,
                    api: _api,
                    myUserId: _api.meId,
                    onLike: () => _toggleLike(p),
                    onOpenProfile: _openUserProfile,
                    onTagTap: _onTagTapped,
                    onPostUpdated: (u) =>
                        setState(() => _replacePostInAllTabs(u)),
                    onPostDeleted: (id) =>
                        setState(() => _removePostFromAllTabs(id)),
                  ),
                ),
                _FeedList(
                  state: _state[FeedTab.hot]!,
                  onRefresh: () => _refresh(FeedTab.hot, force: true),
                  emptyText: l.socialEmptyHot,
                  itemBuilder: (p) => _PostCard(
                    post: p,
                    api: _api,
                    myUserId: _api.meId,
                    onLike: () => _toggleLike(p),
                    onOpenProfile: _openUserProfile,
                    onTagTap: _onTagTapped,
                    onPostUpdated: (u) =>
                        setState(() => _replacePostInAllTabs(u)),
                    onPostDeleted: (id) =>
                        setState(() => _removePostFromAllTabs(id)),
                  ),
                ),
                Column(
                  children: [
                    _followingControls(),
                    Expanded(
                      child: _FeedList(
                        state: _state[FeedTab.following]!,
                        onRefresh: () =>
                            _refresh(FeedTab.following, force: true),
                        emptyText: l.socialEmptyFollowing,
                        itemBuilder: (p) => _PostCard(
                          post: p,
                          api: _api,
                          myUserId: _api.meId,
                          onLike: () => _toggleLike(p),
                          onOpenProfile: _openUserProfile,
                          onTagTap: _onTagTapped,
                          onPostUpdated: (u) =>
                              setState(() => _replacePostInAllTabs(u)),
                          onPostDeleted: (id) =>
                              setState(() => _removePostFromAllTabs(id)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================
// Tabs
// ===========================

enum FeedTab { friends, hot, following }

extension on FeedTab {
  FeedTabApi toApi() {
    switch (this) {
      case FeedTab.friends:
        return FeedTabApi.friends;
      case FeedTab.hot:
        return FeedTabApi.hot;
      case FeedTab.following:
        return FeedTabApi.following;
    }
  }
}

// ===========================
// Tab strip
// ===========================

class _TopTabStrip extends StatelessWidget {
  const _TopTabStrip({required this.controller, required this.tabs});

  final TabController controller;
  final List<String> tabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.55),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
            ),
            child: TabBar(
              controller: controller,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                    color: Colors.black.withOpacity(0.08),
                  ),
                ],
              ),
              labelColor: cs.onSurface,
              unselectedLabelColor: cs.onSurface.withOpacity(0.65),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: [for (final t in tabs) Tab(text: t)],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================
// Feed list
// ===========================

class _FeedState {
  bool loading = false;
  bool hasLoadedOnce = false;
  Object? error;
  List<SocialPost> items = const [];
}

class _FeedList extends StatelessWidget {
  const _FeedList({
    required this.state,
    required this.onRefresh,
    required this.itemBuilder,
    required this.emptyText,
  });

  final _FeedState state;
  final Future<void> Function() onRefresh;
  final Widget Function(SocialPost post) itemBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

    Widget content;

    if (state.loading && state.items.isEmpty) {
      content = const Center(child: CircularProgressIndicator());
    } else if (state.error != null && state.items.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, color: cs.error, size: 28),
              const SizedBox(height: 10),
              Text(
                l.socialLoadFailed('${state.error}'),
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: Text(l.retry),
              ),
            ],
          ),
        ),
      );
    } else if (state.items.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum_outlined, color: cs.outline),
              const SizedBox(height: 10),
              Text(emptyText, style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    } else {
      content = ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 92),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => itemBuilder(state.items[i]),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.items.isEmpty
          ? ListView(children: [SizedBox(height: 560, child: content)])
          : content,
    );
  }
}

// ===========================
// Post card
// ===========================

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.post,
    required this.api,
    required this.myUserId,
    required this.onLike,
    required this.onOpenProfile,
    required this.onTagTap,
    required this.onPostUpdated,
    required this.onPostDeleted,
  });

  final SocialPost post;
  final SocialApi api;
  final String myUserId;
  final VoidCallback onLike;

  // ✅ 乾淨 callback
  final ValueChanged<String> onOpenProfile;
  final ValueChanged<String> onTagTap;

  final ValueChanged<SocialPost> onPostUpdated;
  final ValueChanged<String> onPostDeleted;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _commentsOpen = false;
  bool _sending = false;
  bool _deleting = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isMine => widget.post.author.id == widget.myUserId;

  Future<void> _sendComment() async {
    final l = context.l10n;
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final updated = await widget.api.addComment(
        postId: widget.post.id,
        text: text,
      );
      widget.onPostUpdated(updated);
      _ctrl.clear();
      if (mounted) setState(() => _commentsOpen = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.notice}: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    if (_deleting) return;

    final l = context.l10n;
    final ok = await _confirm(
      context,
      title: l.socialDeletePostTitle,
      message: l.socialDeletePostMessage,
      okText: l.socialDelete,
      cancelText: MaterialLocalizations.of(context).cancelButtonLabel,
    );
    if (ok != true) return;

    setState(() => _deleting = true);
    try {
      await widget.api.deletePost(widget.post.id);
      widget.onPostDeleted(widget.post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.socialPostDeleted)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l.socialDeleteFailed}: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final post = widget.post;
    final cs = Theme.of(context).colorScheme;

    final author = post.author;
    final avatarUrl = author.avatarUrl;
    final authorName = author.name.isNotEmpty ? author.name : author.id;

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 10),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => widget.onOpenProfile(author.id),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: cs.surfaceContainerHighest,
                            backgroundImage:
                                (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(widget.api.resolveUrl(avatarUrl))
                                : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                    authorName.isNotEmpty ? authorName[0] : '?',
                                    style: const TextStyle(fontSize: 14),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onOpenProfile(author.id),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authorName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(context, post.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: cs.outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isMine)
                          IconButton(
                            onPressed: _deleting ? null : _confirmAndDelete,
                            tooltip: l.socialDelete,
                            icon: _deleting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline),
                          ),
                      ],
                    ),

                    if (post.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        post.text,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.35),
                      ),
                    ],

                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final t in post.tags)
                            _TagChip(
                              text: '#$t',
                              onTap: () => widget.onTagTap(t),
                            ),
                        ],
                      ),
                    ],

                    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.network(
                            widget.api.resolveUrl(post.imageUrl!),
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: cs.surfaceContainerHighest.withOpacity(
                                  0.35,
                                ),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: cs.surfaceContainerHighest.withOpacity(
                                0.35,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _ActionPill(
                          icon: post.likedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: '${post.likeCount}',
                          active: post.likedByMe,
                          activeColor: cs.error,
                          onTap: widget.onLike,
                        ),
                        const SizedBox(width: 10),
                        _ActionPill(
                          icon: Icons.mode_comment_outlined,
                          label: '${post.comments.length}',
                          onTap: () =>
                              setState(() => _commentsOpen = !_commentsOpen),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              setState(() => _commentsOpen = !_commentsOpen),
                          tooltip: _commentsOpen
                              ? l.socialHideComments
                              : l.socialShowComments,
                          icon: Icon(
                            _commentsOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: _commentsOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withOpacity(0.26),
                    border: Border(
                      top: BorderSide(
                        color: cs.outlineVariant.withOpacity(0.45),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    children: [
                      if (post.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            l.socialNoComments,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        )
                      else
                        ...post.comments.map(
                          (c) => _CommentRow(
                            api: widget.api,
                            c: c,
                            onOpenProfile: widget.onOpenProfile,
                          ),
                        ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                hintText: l.socialCommentHint,
                                filled: true,
                                fillColor: cs.surface.withOpacity(0.75),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: cs.outlineVariant.withOpacity(0.6),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: cs.outlineVariant.withOpacity(0.35),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _sending ? null : _sendComment,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                            child: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(BuildContext context, DateTime t) {
    final l = context.l10n;
    final now = DateTime.now().toUtc();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return l.socialTimeNow;
    if (diff.inMinutes < 60) return l.socialTimeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l.socialTimeHours(diff.inHours);
    return '${t.month}/${t.day}';
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    this.onTap,
    this.active = false,
    this.activeColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? (activeColor ?? cs.primary) : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _LongPressChip extends StatelessWidget {
  const _LongPressChip({
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.api,
    required this.c,
    required this.onOpenProfile,
  });

  final SocialApi api;
  final SocialComment c;
  final ValueChanged<String> onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarUrl = c.author.avatarUrl;
    final name = c.author.name.isNotEmpty ? c.author.name : c.author.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onOpenProfile(c.author.id),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: cs.surface,
              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? NetworkImage(api.resolveUrl(avatarUrl))
                  : null,
              child: (avatarUrl == null || avatarUrl.isEmpty)
                  ? Text(name.isNotEmpty ? name[0] : '?')
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.78),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => onOpenProfile(c.author.id),
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.text,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.25),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================
// Compose sheet
// ===========================

class _ComposeResult {
  final String text;
  final List<String> tags;
  final Uint8List? imageBytes;
  final String? imageName;
  const _ComposeResult(this.text, this.tags, {this.imageBytes, this.imageName});
}

class _ComposeSheet extends StatefulWidget {
  const _ComposeSheet({required this.title});
  final String title;

  @override
  State<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends State<_ComposeSheet> {
  final _textCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageName;
  bool _picking = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    final s = raw
        .replaceAll('#', ' ')
        .replaceAll(',', ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .map((e) => e.trim().toLowerCase())
        .toList();
    final seen = <String>{};
    return [
      for (final t in s)
        if (seen.add(t)) t,
    ];
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = x.name;
      });
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final canPost = _textCtrl.text.trim().isNotEmpty || _imageBytes != null;
    final cancelLabel = MaterialLocalizations.of(context).cancelButtonLabel;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 12 + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: _picking ? null : _pickImage,
                tooltip: l.socialAddImage,
                icon: const Icon(Icons.image_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_imageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(_imageBytes!, fit: BoxFit.cover),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton.filledTonal(
                        onPressed: () => setState(() {
                          _imageBytes = null;
                          _imageName = null;
                        }),
                        tooltip: l.socialRemoveImage,
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          TextField(
            controller: _textCtrl,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.socialComposerTextLabel,
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tagsCtrl,
            decoration: InputDecoration(
              labelText: l.socialComposerTagsLabel,
              hintText: l.socialComposerTagsHint,
              filled: true,
              fillColor: cs.surfaceContainerHighest.withOpacity(0.35),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: canPost
                      ? () {
                          Navigator.pop(
                            context,
                            _ComposeResult(
                              _textCtrl.text.trim(),
                              _parseTags(_tagsCtrl.text),
                              imageBytes: _imageBytes,
                              imageName: _imageName,
                            ),
                          );
                        }
                      : null,
                  child: Text(l.socialPostAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================
// helpers
// ===========================

Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String okText,
  required String cancelText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(okText),
        ),
      ],
    ),
  );
}
