// lib/screens/social/social_feed_page.dart
import 'dart:io';
import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'friend_cards_page.dart';

/// ───────────────────────────────────────────────────────────────
/// 簡易模型 + 假資料（若你已有 models/social_models.dart，可改用該檔）
/// ───────────────────────────────────────────────────────────────
class SocialUser {
  final String id;
  final String name;
  final String? avatarAsset;
  const SocialUser({required this.id, required this.name, this.avatarAsset});
}

class SocialComment {
  final String id;
  final SocialUser author;
  final String text;
  final DateTime createdAt;
  SocialComment({
    required this.id,
    required this.author,
    required this.text,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class SocialPost {
  final String id;
  final SocialUser author;
  final DateTime createdAt;
  String text;
  List<File?> images;
  int likeCount;
  bool likedByMe;
  final List<SocialComment> comments;
  final List<String> tags;

  SocialPost({
    required this.id,
    required this.author,
    required this.text,
    List<File?>? images,
    DateTime? createdAt,
    this.likeCount = 0,
    this.likedByMe = false,
    List<SocialComment>? comments,
    List<String>? tags,
  }) : images = images ?? <File?>[],
       createdAt = createdAt ?? DateTime.now(),
       comments = comments ?? <SocialComment>[],
       tags = tags ?? <String>[];
}

final _mockAlice = SocialUser(id: 'u_alice', name: 'Alice');
final _mockBob = SocialUser(id: 'u_bob', name: 'Bob');

List<SocialPost> mockPosts(SocialUser current) => [
  SocialPost(
    id: 'p1',
    author: _mockBob,
    text: '今天把 UI 卡片邊角修好了 ✅',
    images: [],
    likeCount: 5,
    comments: [],
    createdAt: DateTime.now().subtract(const Duration(minutes: 60)),
    tags: ['flutter', 'design'],
  ),
  SocialPost(
    id: 'p_me',
    author: current,
    text: '嗨！這是我的第一篇 🙂',
    images: [],
    likeCount: 1,
    comments: [],
    createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
    tags: ['hello'],
  ),
];

/// ───────────────────────────────────────────────────────────────

enum FeedTab { friends, hot, following }

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  SocialUser get _currentUser => SocialUser(
    id: 'u_me',
    name: (widget.settings.nickname ?? 'Me').trim().isEmpty
        ? 'Me'
        : widget.settings.nickname!,
    avatarAsset: null,
  );

  // 假資料：好友名單（包含 Bob）
  final Set<String> _myFriendIds = {'u_bob'};

  // 帖文列表
  final List<SocialPost> _posts = [];

  // 目前頁籤
  FeedTab _tab = FeedTab.friends;

  @override
  void initState() {
    super.initState();
    _posts.addAll(mockPosts(_currentUser));
  }

  String _timeAgo(BuildContext context, DateTime dt) {
    final l = context.l10n;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l.timeJustNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    return l.timeDaysAgo(diff.inDays);
  }

  // 依分頁過濾/排序
  List<SocialPost> _visible() {
    final list = List<SocialPost>.from(_posts);
    switch (_tab) {
      case FeedTab.friends:
        // 好友 + 自己
        return list
            .where(
              (p) =>
                  _myFriendIds.contains(p.author.id) ||
                  p.author.id == _currentUser.id,
            )
            .toList();
      case FeedTab.hot:
        list.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        return list;
      case FeedTab.following:
        final follow = (widget.settings.followedTags ?? const <String>[])
            .map((e) => e.toLowerCase())
            .toSet();
        if (follow.isEmpty) return const <SocialPost>[];
        return list
            .where(
              (p) => p.tags
                  .map((e) => e.toLowerCase())
                  .toSet()
                  .intersection(follow)
                  .isNotEmpty,
            )
            .toList();
    }
  }

  void _toggleLike(SocialPost p) {
    setState(() {
      p.likedByMe = !p.likedByMe;
      p.likeCount += p.likedByMe ? 1 : -1;
    });
  }

  // 建立貼文（每篇標籤最多 5 個）；選圖立刻顯示；底部不留白
  Future<void> _createPost() async {
    const int maxPostTags = 5;

    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final textCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    final Set<String> tags = {};
    File? pickedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSB) {
            void addTag(String raw) {
              final t = raw.trim().toLowerCase();
              if (t.isEmpty) return;
              if (tags.length >= maxPostTags) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tag limit $maxPostTags')),
                );
                return;
              }
              tags.add(t);
              tagCtrl.clear();
              setSB(() {});
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _Avatar(user: _currentUser),
                        const SizedBox(width: 12),
                        Text(
                          _currentUser.name,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: textCtrl,
                      maxLines: 6,
                      style: TextStyle(color: cs.onSurface),
                      decoration: InputDecoration(hintText: l.socialShareHint),
                    ),
                    const SizedBox(height: 8),

                    // 選圖即時預覽
                    if (pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(pickedImage!, fit: BoxFit.cover),
                      ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final x = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );
                            if (x != null) {
                              pickedImage = File(x.path);
                              setSB(() {}); // 立刻刷新預覽
                            }
                          },
                          icon: Icon(Icons.photo, color: cs.onSurface),
                          label: Text(
                            l.pickFromGallery,
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            final text = textCtrl.text.trim();
                            if (text.isEmpty && pickedImage == null) {
                              Navigator.pop(context);
                              return;
                            }
                            setState(() {
                              _posts.insert(
                                0,
                                SocialPost(
                                  id: 'p_${DateTime.now().microsecondsSinceEpoch}',
                                  author: _currentUser,
                                  text: text,
                                  images: [pickedImage],
                                  tags: tags.toList(),
                                ),
                              );
                            });
                            Navigator.pop(context);
                          },
                          child: Text(l.publish),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          l.tagsLabel,
                          style: TextStyle(color: cs.onSurface),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tags.length}/$maxPostTags',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tagCtrl,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(hintText: l.addTagHint),
                            onSubmitted: addTag,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () => addTag(tagCtrl.text),
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
                          for (final t in tags)
                            InputChip(
                              label: Text('#$t'),
                              onDeleted: () {
                                tags.remove(t);
                                setSB(() {});
                              },
                            ),
                        ],
                      ),
                    ),
                    const SafeArea(
                      top: false,
                      minimum: EdgeInsets.only(bottom: 6),
                      child: SizedBox.shrink(),
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

  void _openComments(SocialPost p) {
    final l = context.l10n;
    final cCtrl = TextEditingController();
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
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
                          _Avatar(user: c.author, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.author.name,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  c.text,
                                  style: TextStyle(color: cs.onSurface),
                                ),
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
                      _Avatar(user: _currentUser, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: cCtrl,
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            hintText: l.leaveACommentHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final t = cCtrl.text.trim();
                          if (t.isEmpty) return;
                          setState(() {
                            p.comments.add(
                              SocialComment(
                                id: 'c_${DateTime.now().microsecondsSinceEpoch}',
                                author: _currentUser,
                                text: t,
                              ),
                            );
                          });
                          cCtrl.clear();
                        },
                        icon: Icon(Icons.send, color: cs.onSurface),
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
    final list = _visible();
    final followed = (widget.settings.followedTags ?? const <String>[]);

    return DefaultTabController(
      length: 3,
      initialIndex: _tab.index,
      child: Scaffold(
        // 沒有 AppBar：把頁籤與按鈕放在 body 最上層，避免任何多餘上邊距
        body: Column(
          children: [
            // 頁籤 + 朋友名片按鈕（緊貼螢幕頂部）
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        onTap: (i) => setState(() => _tab = FeedTab.values[i]),
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
                  ],
                ),
              ),
            ),

            // 上方顯示追蹤標籤（僅顯示）
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
                        child: Chip(
                          label: Text('#${t.trim()}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),

            // 貼文列表
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final p = list[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface.withOpacity(0.65), // 半透明
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                              child: Row(
                                children: [
                                  _Avatar(user: p.author),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.author.name,
                                          style: TextStyle(
                                            color: cs.onSurface,
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
                                  if (p.author.id == _currentUser.id)
                                    PopupMenuButton<String>(
                                      color: cs.surface,
                                      itemBuilder: (_) => [
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
                                          setState(
                                            () => _posts.removeWhere(
                                              (x) => x.id == p.id,
                                            ),
                                          );
                                        }
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
                                  style: TextStyle(
                                    color: cs.onSurface,
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
                                      Chip(
                                        label: Text('#$t'),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                  ],
                                ),
                              ),
                            ],

                            if (p.images.isNotEmpty &&
                                p.images.first != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    p.images.first!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _toggleLike(p),
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
                                    onPressed: () => _openComments(p),
                                    icon: Icon(
                                      Icons.mode_comment_outlined,
                                      color: cs.onSurface,
                                    ),
                                    label: Text(
                                      '${l.commentsTitle} (${p.comments.length})',
                                      style: TextStyle(color: cs.onSurface),
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
          onPressed: _createPost,
          icon: const Icon(Icons.edit),
          label: Text(l.publish),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final SocialUser user;
  final double size;
  const _Avatar({required this.user, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = cs.surfaceContainerHighest;
    if (user.avatarAsset != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: bg,
        backgroundImage: AssetImage(user.avatarAsset!),
      );
    }
    final letter = user.name.isNotEmpty
        ? user.name.characters.first.toUpperCase()
        : '?';
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bg,
      child: Text(letter, style: TextStyle(color: cs.onSurface)),
    );
  }
}
