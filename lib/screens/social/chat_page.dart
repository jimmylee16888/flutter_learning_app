// lib/screens/social/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/models/social_models.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.api,
    required this.me,
    required this.conversation,
  });

  final SocialApi api;
  final SocialUser me;
  final Conversation conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  bool _loading = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    try {
      final list = await widget.api.fetchMessages(
        widget.conversation.id,
        limit: 100, // MVP: 先抓 100 筆
      );
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(list);
      });

      // 稍微 delay 等 ListView build 完，再捲到最底
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('載入訊息失敗：$e'), backgroundColor: cs.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 根據 MessageType 產生要顯示的文字（一定回傳非 null）
  String _displayText(Message m, BuildContext context) {
    final l = context.l10n;

    switch (m.type) {
      case MessageType.text:
        // 純文字訊息：text 是 String?，用 ??'' 保證非 null
        return m.text?.trim().isNotEmpty == true ? m.text!.trim() : '';

      case MessageType.miniCard:
        // TODO: 之後可以改成 l10n
        return '[Mini Card]';

      case MessageType.album:
        return '[Album]';

      default:
        // 預防未來多一種 type，用 enum.name 顯示
        final typeName = m.type.name; // Dart enum 內建 name
        return '[$typeName]';
    }
  }

  Future<void> _send() async {
    final raw = _textCtrl.text.trim();
    if (raw.isEmpty) return;
    if (_sending) return;

    setState(() => _sending = true);
    try {
      final m = await widget.api.sendTextMessage(widget.conversation.id, raw);
      if (!mounted) return;
      setState(() {
        _messages.add(m);
        _textCtrl.clear();
      });
      await Future.delayed(const Duration(milliseconds: 80));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('傳送失敗：$e'), backgroundColor: cs.error),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _title() {
    // name 可能為 null，所以要先安全處理
    final name = widget.conversation.name?.trim() ?? '';
    if (name.isNotEmpty) return name;

    final others = widget.conversation.memberIds
        .where((id) => id != widget.me.id)
        .toList();

    if (others.isEmpty) return '備忘錄'; // 只有自己
    if (others.length == 1) return others.first;
    return others.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        // 之後可以在 actions 放「查看成員」等功能
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading && _messages.isEmpty
                ? Center(child: CircularProgressIndicator(color: cs.primary))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final m = _messages[i];
                      final isMe = m.senderId == widget.me.id;
                      final text = _displayText(m, ctx);
                      final timeStr = TimeOfDay.fromDateTime(
                        m.createdAt,
                      ).format(ctx);

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(ctx).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? cs.primaryContainer
                                        : cs.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: isMe
                                          ? cs.onPrimaryContainer
                                          : cs.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  timeStr,
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
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
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  // 之後可以在這裡放 attachment button（小卡 / 專輯）
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: l.chatHint, // ex: 「輸入訊息…」
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _sending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _send,
                          color: cs.primary,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
