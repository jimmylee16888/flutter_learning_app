// lib/widgets/app_popups.dart
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';

/// 全域：敬請期待
Future<void> showComingSoon(BuildContext context, {String? title, String? body, String? okLabel}) {
  final l = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppAlertDialog(
      title: Text(title ?? l.coming_soon_title),
      content: Text(body ?? l.coming_soon_body),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).maybePop(), child: Text(okLabel ?? l.coming_soon_ok))],
    ),
  );
}

/// 通用確認對話框：回傳 true/false（關閉視窗或返回鍵 -> false）
Future<bool> showConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String? okLabel,
  String? cancelLabel,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AppAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).maybePop(false), child: Text(cancelLabel ?? l.common_cancel)),
        FilledButton(onPressed: () => Navigator.of(ctx).maybePop(true), child: Text(okLabel ?? l.common_ok)),
      ],
    ),
  );
  return result ?? false;
}

/// 資訊提示（只有一個 OK）
Future<void> showInfo(BuildContext context, {required String title, required String message, String? okLabel}) {
  final l = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).maybePop(), child: Text(okLabel ?? l.common_ok))],
    ),
  );
}

/// 錯誤提示（紅色重點）
Future<void> showError(BuildContext context, {required String title, required String message, String? okLabel}) {
  final l = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppAlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 8),
          Flexible(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).maybePop(), child: Text(okLabel ?? l.common_ok))],
    ),
  );
}

/// 統一外觀的 AlertDialog（玻璃感/圓角/邊框）
/// - 讓所有彈窗長得一致；要改風格只改這一處就好。
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({super.key, this.title, this.content, this.actions});
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      backgroundColor: cs.surface.withOpacity(.98),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.3)),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    );
  }
}

Future<String?> showPrompt(
  BuildContext context, {
  required String title,
  String? hintText,
  String? okLabel,
  String? cancelLabel,
}) {
  final l = context.l10n;
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AppAlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: hintText),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).maybePop(), child: Text(cancelLabel ?? l.common_cancel)),
        FilledButton(onPressed: () => Navigator.of(ctx).maybePop(ctrl.text), child: Text(okLabel ?? l.common_ok)),
      ],
    ),
  );
}
