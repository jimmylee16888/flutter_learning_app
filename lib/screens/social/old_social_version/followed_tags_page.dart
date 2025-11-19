// lib/screens/social/followed_tags_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:provider/provider.dart';

import '../../../l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart';

class FollowedTagsPage extends StatefulWidget {
  const FollowedTagsPage({super.key, this.api});

  /// 相容舊呼叫點：舊版會傳入 api，但新版頁面改用 TagFollowController。
  final SocialApi? api;

  @override
  State<FollowedTagsPage> createState() => _FollowedTagsPageState();
}

class _FollowedTagsPageState extends State<FollowedTagsPage> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _normalize(String raw) {
    // 去頭尾空白、拿掉「#」、中間多空白收斂成單一空白、轉小寫
    final s = raw
        .trim()
        .replaceAll(RegExp(r'^#+'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
    return s.toLowerCase();
  }

  Future<void> _add() async {
    final l = context.l10n;
    final ctl = context.read<TagFollowController>();

    final t = _normalize(_ctrl.text);
    if (t.isEmpty) return;

    // 重複避免
    if (ctl.followed.contains(t)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.addFollowedTagFailed(l.alreadyExists))),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await ctl.add(t);
      if (!mounted) return;
      _ctrl.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.addedFollowedTagToast)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.addFollowedTagFailed('$e'))));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _remove(String t) async {
    final l = context.l10n;
    try {
      await context.read<TagFollowController>().remove(t);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.removedFollowedTagToast)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.removeFollowedTagFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

    final ctl = context.watch<TagFollowController>();
    final tags = ctl.followed;
    final loading = ctl.loading;

    final canAdd = _normalize(_ctrl.text).isNotEmpty && !_sending && !loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.followedTagsTitle),
        actions: [
          IconButton(
            tooltip: l.retry,
            onPressed: loading
                ? null
                : () => context.read<TagFollowController>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<TagFollowController>().refresh(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (loading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.loading,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: l.addFollowedTagHint,
                      prefixIcon: const Icon(Icons.tag_outlined),
                      // 顯示正規化後會儲存的樣子（僅提示，不改動輸入框內容）
                      helperText: _normalize(_ctrl.text).isEmpty
                          ? null
                          : '${l.willSaveAs}: #${_normalize(_ctrl.text)}',
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: canAdd ? _add : null,
                  child: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tags.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(l.noFollowedTagsYet),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: [
                  for (final t in tags)
                    InputChip(
                      label: Text('#$t'),
                      onDeleted: () => _remove(t),
                      deleteIconColor: cs.error,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
