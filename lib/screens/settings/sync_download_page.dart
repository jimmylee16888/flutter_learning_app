// lib/screens/settings/sync_download_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_learning_app/screens/billing/subscription_page.dart';
import 'package:provider/provider.dart';

import 'package:flutter_learning_app/l10n/l10n.dart';
import 'package:flutter_learning_app/services/library_sync_service.dart';
import 'package:flutter_learning_app/services/subscription_service.dart';

class SyncDownloadPage extends StatefulWidget {
  const SyncDownloadPage({super.key});

  @override
  State<SyncDownloadPage> createState() => _SyncDownloadPageState();
}

class _SyncDownloadPageState extends State<SyncDownloadPage> {
  bool _busy = false;
  bool _expanded = false;
  String? _previewJson; // pretty-print 給 UI 看
  String? _errorText;

  // 訂閱狀態
  bool _hasPaid = false;
  late final VoidCallback _subListener;

  @override
  void initState() {
    super.initState();
    _syncSubStatus();
    _subListener = () {
      if (!mounted) return;
      setState(_syncSubStatus);
    };
    SubscriptionService.I.effective.addListener(_subListener);
  }

  @override
  void dispose() {
    SubscriptionService.I.effective.removeListener(_subListener);
    super.dispose();
  }

  void _syncSubStatus() {
    final eff = SubscriptionService.I.effective.value;
    _hasPaid = eff.isActive && eff.plan != SubscriptionPlan.free;
  }

  Future<void> _guardPaid(Future<void> Function() task) async {
    if (!_hasPaid) {
      _showNeedSubscriptionDialog();
      return;
    }
    await task();
  }

  void _showNeedSubscriptionDialog() {
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.syncNeedSubTitle),
        content: Text(l.syncNeedSubBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.dialogCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            child: Text(l.syncGoToSubscription),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPreview() async {
    final l = context.l10n;
    setState(() {
      _busy = true;
      _errorText = null;
    });

    final service = context.read<LibrarySyncService>();
    final obj = await service.debugFetchSnapshotForUi();

    if (!mounted) return;

    if (obj == null) {
      setState(() {
        _busy = false;
        _previewJson = null;
        _errorText = l.syncNoRemoteData;
      });
      return;
    }

    final pretty = const JsonEncoder.withIndent('  ').convert(obj);
    setState(() {
      _busy = false;
      _previewJson = pretty;
      _errorText = null;
    });
  }

  Future<void> _onUpload() async {
    final l = context.l10n;
    await _guardPaid(() async {
      setState(() {
        _busy = true;
        _errorText = null;
      });

      final service = context.read<LibrarySyncService>();

      try {
        await service.sync(); // 以本機為主做 merge，上傳雲端
        await _refreshPreview(); // 成功後再抓一次雲端檔案來顯示
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.syncUploadSuccess)));
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _errorText = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.syncUploadFailed(e.toString()))),
        );
      }
    });
  }

  Future<void> _onDownload() async {
    final l = context.l10n;
    await _guardPaid(() async {
      setState(() {
        _busy = true;
        _errorText = null;
      });

      final service = context.read<LibrarySyncService>();

      final ok = await service.downloadFromServerAndApply();
      if (!mounted) return;

      if (ok) {
        await _refreshPreview();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.syncDownloadSuccess)));
      } else {
        setState(() {
          _busy = false;
          _errorText = l.syncDownloadFailedGeneric;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.syncDownloadFailedGeneric)));
      }
    });
  }

  Future<void> _onCopy() async {
    final l = context.l10n;
    await _guardPaid(() async {
      if (_previewJson == null || _previewJson!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.syncCopyNoData)));
        return;
      }
      await Clipboard.setData(ClipboardData(text: _previewJson!));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.syncCopySuccess)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.syncPageTitle), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 說明文字
            Text(
              l.syncPageDesc,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
            ),
            const SizedBox(height: 16),

            // 三個按鈕：上傳 / 下載 / 複製
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _onUpload,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: Text(l.syncUploadButton),
                ),
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _onDownload,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: Text(l.syncDownloadButton),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || _previewJson == null ? null : _onCopy,
                  icon: const Icon(Icons.copy_all_outlined),
                  label: Text(l.syncCopyButton),
                ),
                if (_hasPaid)
                  TextButton.icon(
                    onPressed: _busy ? null : _refreshPreview,
                    icon: const Icon(Icons.refresh),
                    label: Text(l.syncRefreshPreview),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            if (!_hasPaid)
              // 未訂閱：提示卡片（不顯示內容）
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_outline, color: cs.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.syncPaidOnlyHint,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              // 已訂閱：可折疊的資料預覽區
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.insert_drive_file_outlined),
                        title: Text(l.syncPreviewTitle),
                        subtitle: Text(
                          _previewJson == null
                              ? l.syncPreviewEmptyHint
                              : l.syncPreviewSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() => _expanded = !_expanded);
                          },
                        ),
                      ),
                      if (_expanded) const Divider(height: 1),
                      if (_expanded)
                        Expanded(
                          child: _busy
                              ? const Center(child: CircularProgressIndicator())
                              : _buildPreviewArea(cs),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea(ColorScheme cs) {
    if (_errorText != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_errorText!, style: TextStyle(color: cs.error)),
        ),
      );
    }
    if (_previewJson == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.syncPreviewEmptyHint,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            _previewJson!,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
