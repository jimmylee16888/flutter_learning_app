// lib/screens/social/conversations_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/social_models.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';

import 'chat_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key, required this.api, required this.me});

  final SocialApi api;
  final SocialUser me;

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  bool _loading = false;
  List<Conversation> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final list = await widget.api.fetchConversations();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入對話失敗：$e'), backgroundColor: cs.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _timeAgo(BuildContext context, DateTime? t) {
    final l = context.l10n;
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return l.timeJustNow;
    if (diff.inMinutes < 60) return l.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l.timeHoursAgo(diff.inHours);
    return l.timeDaysAgo(diff.inDays);
  }

  /// 沒有自訂名稱時，用成員列表（排除自己）簡單組一個。
  String _fallbackTitle(Conversation c) {
    final name = c.name?.trim() ?? '';
    if (name.isNotEmpty) return name;

    final others = c.memberIds.where((id) => id != widget.me.id).toList();
    if (others.isEmpty) return '備忘錄'; // 只有自己
    if (others.length == 1) return others.first;
    return others.join(', ');
  }

  Future<void> _onOpenConversation(Conversation c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ChatPage(api: widget.api, me: widget.me, conversation: c),
      ),
    );
    // 回來之後刷新一次，更新 lastMessage / 排序
    await _refresh();
  }

  Future<void> _onNewConversation() async {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final memberCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l.socialNewConversation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: memberCtrl,
                decoration: InputDecoration(
                  labelText: l.socialMembersHint,
                  hintText: 'user1@example.com, user2...',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: l.socialConversationNameOptional,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.ok),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    final raw = memberCtrl.text;
    final members = raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      final conv = await widget.api.openConversation(
        memberIds: members,
        name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
      );
      if (!mounted) return;
      await _onOpenConversation(conv);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('建立對話失敗：$e'), backgroundColor: cs.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.socialMessagesTitle), // ex: 「訊息」
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _loading && _items.isEmpty
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final c = _items[i];
                  final title = _fallbackTitle(c);

                  // lastMessagePreview 可能為 null
                  final preview = (c.lastMessagePreview ?? '').trim();
                  final t = c.lastMessageAt ?? c.createdAt;

                  return ListTile(
                    onTap: () => _onOpenConversation(c),
                    leading: CircleAvatar(
                      child: Text(title.characters.first.toUpperCase()),
                    ),
                    title: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: preview.isNotEmpty
                        ? Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: Text(
                      _timeAgo(context, t),
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onNewConversation,
        child: const Icon(Icons.chat),
      ),
    );
  }
}
