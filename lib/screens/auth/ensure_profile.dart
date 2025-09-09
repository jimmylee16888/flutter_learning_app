import 'package:flutter/material.dart';
import '../../app_settings.dart';
import '../../l10n/l10n.dart';

/// 登入後檢查使用者資料是否完整（暱稱 + 生日）。
/// 若缺一則以「不可關閉」的對話框要求補齊。
Future<void> ensureProfile(BuildContext context, AppSettings settings) async {
  final needNickname = (settings.nickname ?? '').trim().isEmpty;
  final needBirthday = settings.birthday == null;

  if (!needNickname && !needBirthday) return;

  final res = await showEditProfileDialog(
    context,
    initialNickname: settings.nickname ?? '',
    initialBirthday: settings.birthday,
    forceComplete: true, // 首次必填
  );

  if (res == null) return; // forceComplete 時理論上不會發生
  _applyToSettings(settings, res.nickname, res.birthday);
}

/// 嘗試套用到 AppSettings（不綁定特定 API，避免你的命名不同）
void _applyToSettings(AppSettings s, String nick, DateTime bday) {
  try {
    // ignore: avoid_dynamic_calls
    (s as dynamic).setNickname(nick);
  } catch (_) {}
  try {
    // ignore: avoid_dynamic_calls
    (s as dynamic).setBirthday(bday);
  } catch (_) {}
  try {
    // ignore: avoid_dynamic_calls
    (s as dynamic).updateProfile(nick, bday);
  } catch (_) {}
}

/// 回傳物件
class EditProfileResult {
  final String nickname;
  final DateTime birthday;
  const EditProfileResult({required this.nickname, required this.birthday});
}

/// 顯示「暱稱＋生日」編輯對話框
/// [forceComplete] = true 時：不可點背景/返回關閉，也不顯示「取消」。
Future<EditProfileResult?> showEditProfileDialog(
  BuildContext context, {
  String initialNickname = '',
  DateTime? initialBirthday,
  bool forceComplete = false,
  bool useRootNavigator = true,
}) {
  return showDialog<EditProfileResult>(
    context: context,
    barrierDismissible: !forceComplete,
    useRootNavigator: useRootNavigator,
    builder: (_) => _EditProfileDialog(
      initialNickname: initialNickname,
      initialBirthday: initialBirthday,
      forceComplete: forceComplete,
    ),
  );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.initialNickname,
    required this.initialBirthday,
    required this.forceComplete,
  });

  final String initialNickname;
  final DateTime? initialBirthday;
  final bool forceComplete;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _nickCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthday;

  bool get _canSubmit => _nickCtrl.text.trim().isNotEmpty && _birthday != null;

  @override
  void initState() {
    super.initState();
    _nickCtrl.text = widget.initialNickname;
    _birthday = widget.initialBirthday;
    _nickCtrl.addListener(() => setState(() {})); // 更新儲存按鈕狀態
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    super.dispose();
  }

  void _trySubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_canSubmit) return;
    Navigator.of(context).pop(
      EditProfileResult(nickname: _nickCtrl.text.trim(), birthday: _birthday!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();

    final dialog = AlertDialog(
      title: Text(l.userProfileTitle),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nickCtrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _trySubmit(),
                decoration: InputDecoration(
                  labelText: l.nicknameLabel,
                  hintText: l.nicknameLabel,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.nicknameRequired : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        _birthday == null
                            ? l.birthdayPick
                            : '${_birthday!.year}-${_birthday!.month.toString().padLeft(2, '0')}-${_birthday!.day.toString().padLeft(2, '0')}',
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate:
                              _birthday ?? DateTime(now.year - 18, 1, 1),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(now.year + 1),
                          helpText: l.birthdayPick,
                        );
                        if (!mounted) return;
                        if (d != null) setState(() => _birthday = d);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (!widget.forceComplete)
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(l.cancel),
          ),
        FilledButton(
          onPressed: _canSubmit ? _trySubmit : null,
          child: Text(l.save),
        ),
      ],
    );

    // forceComplete：連返回鍵也禁用
    if (!widget.forceComplete) return dialog;
    return WillPopScope(onWillPop: () async => false, child: dialog);
  }
}
