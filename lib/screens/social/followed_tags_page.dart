// lib/screens/social/followed_tags_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/social/social_api.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart'
    show TagFollowController;

class FollowedTagsPage extends StatefulWidget {
  const FollowedTagsPage({super.key, required SocialApi api});

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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
          children: [
            // ===== Header (no AppBar) =====
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.followedTagsTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.retry,
                  onPressed: loading
                      ? null
                      : () => context.read<TagFollowController>().refresh(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Loading hint
            if (loading)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
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

            // ===== Input card =====
            Card(
              elevation: 0,
              color: cs.surfaceContainerHighest.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: l.addFollowedTagHint,
                          prefixIcon: const Icon(Icons.tag_outlined),
                          filled: true,
                          fillColor: cs.surface.withOpacity(0.65),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withOpacity(0.35),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withOpacity(0.22),
                            ),
                          ),
                          helperText: _normalize(_ctrl.text).isEmpty
                              ? null
                              : '${l.willSaveAs}: #${_normalize(_ctrl.text)}',
                        ),
                        onSubmitted: (_) => _add(),
                      ),
                    ),
                    const SizedBox(width: 10),
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
              ),
            ),

            const SizedBox(height: 14),

            // ===== Tags =====
            if (tags.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Text(
                    l.noFollowedTagsYet,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
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
