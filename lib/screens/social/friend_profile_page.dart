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
    try {
      final profile = await widget.api.fetchUserProfile(widget.userId);
      final posts = await widget.api.fetchUserPosts(widget.userId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
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
      appBar: AppBar(title: Text(l.userProfileTile)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : p == null
          ? Center(child: Text(l.loadFailed(l.notSet)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: cs.surfaceVariant,
                          foregroundImage:
                              (p['avatarUrl'] is String &&
                                  (p['avatarUrl'] as String).isNotEmpty)
                              ? NetworkImage(p['avatarUrl'] as String)
                              : null,
                          child: const Icon(Icons.person_outline, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  if ((p['showInstagram'] == true) &&
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
                                    _social(cs, Icons.facebook, p['facebook']),
                                  if ((p['showLine'] == true) &&
                                      (p['lineId'] ?? '').toString().isNotEmpty)
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
                        const SizedBox(width: 8),
                        if (!isSelf)
                          FilledButton.icon(
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
                            ),
                          ),
                      ],
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
                  Text('尚無貼文', style: TextStyle(color: cs.onSurfaceVariant))
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
