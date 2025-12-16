import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:flutter_learning_app/models/social_models.dart';
import 'package:flutter_learning_app/services/services.dart'
    show FriendFollowController;

class FriendProfilePage extends StatefulWidget {
  const FriendProfilePage({super.key, required this.api, required this.userId});
  final SocialApi api;
  final String userId;

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  Map<String, dynamic>? _profile;
  List<SocialPost> _posts = [];
  bool _loading = true;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final profile = await widget.api.fetchUserProfile(widget.userId);

      List<SocialPost> posts = const [];
      try {
        posts = await widget.api.fetchUserPosts(widget.userId);
      } catch (e, st) {
        debugPrint('FriendProfilePage posts error, userId=${widget.userId}');
        debugPrint('$e');
        debugPrint('$st');
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = posts;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('FriendProfilePage profile error, userId=${widget.userId}');
      debugPrint('$e');
      debugPrint('$st');

      if (!mounted) return;
      setState(() {
        _profile = null;
        _posts = const [];
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_toggling) return;
    setState(() => _toggling = true);
    try {
      await context.read<FriendFollowController>().toggle(widget.userId);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final p = _profile;

    final isFriend = context.watch<FriendFollowController>().contains(
      widget.userId,
    );

    final String displayName =
        ((p?['nickname'] ?? p?['name'] ?? 'User') as String);

    final String myId = widget.api.meId;
    final String viewedId = (p?['id']?.toString().isNotEmpty ?? false)
        ? p!['id'].toString()
        : widget.userId;
    final bool isSelf = viewedId == myId || widget.userId == myId;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ no AppBar / 一致風格 header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.userProfileTile,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l.retry,
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : p == null
                  ? Center(child: Text(l.loadFailed(l.notSet)))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final bool isNarrow =
                                    constraints.maxWidth < 360;

                                // 左側：頭像 + 名稱 + 社群資訊
                                Widget leftPart = Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor: cs.surfaceVariant,
                                      foregroundImage:
                                          (p['avatarUrl'] is String &&
                                              (p['avatarUrl'] as String)
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                              p['avatarUrl'] as String,
                                            )
                                          : null,
                                      child: const Icon(
                                        Icons.person_outline,
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: -6,
                                            children: [
                                              if ((p['showInstagram'] ==
                                                      true) &&
                                                  (p['instagram'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                _social(
                                                  cs,
                                                  Icons.camera_alt_outlined,
                                                  p['instagram'],
                                                ),
                                              if ((p['showFacebook'] == true) &&
                                                  (p['facebook'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                _social(
                                                  cs,
                                                  Icons.facebook,
                                                  p['facebook'],
                                                ),
                                              if ((p['showLine'] == true) &&
                                                  (p['lineId'] ?? '')
                                                      .toString()
                                                      .isNotEmpty)
                                                _social(
                                                  cs,
                                                  Icons.chat_bubble_outline,
                                                  p['lineId'],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                // 右側：按鈕
                                Widget? button;
                                if (!isSelf) {
                                  button = FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      minimumSize: const Size(0, 40),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    onPressed: _toggling ? null : _toggleFollow,
                                    icon: _toggling
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            isFriend
                                                ? Icons.person_remove
                                                : Icons.person_add,
                                          ),
                                    label: Text(
                                      isFriend
                                          ? l.friendRemoveAction
                                          : l.friendAddAction,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }

                                if (isNarrow) {
                                  // 窄版：上下排，按鈕在下面
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      leftPart,
                                      if (button != null) ...[
                                        const SizedBox(height: 12),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            width: 180,
                                            child: button,
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                } else {
                                  // 寬版：同一排
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: leftPart),
                                      const SizedBox(width: 8),
                                      if (button != null)
                                        Flexible(
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 180,
                                              ),
                                              child: button,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '貼文',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_posts.isEmpty)
                          Text(
                            '尚無貼文',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          )
                        else
                          ..._posts.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ListTile(
                                tileColor: cs.surfaceVariant.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(e.text),
                                subtitle: e.tags.isEmpty
                                    ? null
                                    : Text(e.tags.map((t) => '#$t').join(' ')),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _social(ColorScheme cs, IconData icon, Object? text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text('$text', style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}
