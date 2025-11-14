import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app_settings.dart';
import '../../l10n/l10n.dart';
import 'package:flutter_learning_app/services/services.dart';

import 'package:flutter_learning_app/navigation.dart';

/// 用來記錄「後端有沒有這兩個欄位」
class _ServerProfileFlags {
  final bool hasNickname;
  final bool hasBirthday;
  const _ServerProfileFlags({
    required this.hasNickname,
    required this.hasBirthday,
  });
}

/// 登入後檢查使用者資料是否完整（暱稱 + 生日）。
/// 流程：
/// 1. 先嘗試從後端 /me 把 nickname + birthday 拉回來寫入 AppSettings（雲端為單一真相）
/// 2. 回傳「後端有沒有 nickname / birthday」的旗標
/// 3. 如果：
///    - 後端沒 nickname 或 本機沒 nickname → 強制要求填暱稱
///    - 後端沒生日 或 本機沒生日       → 強制要求填生日
Future<void> ensureProfile(BuildContext context, AppSettings settings) async {
  // 1) 先從後端同步，並拿到「後端是否有欄位」的狀態
  debugPrint(
    '[ensureProfile] called, nick=${settings.nickname}, bday=${settings.birthday}',
  );
  final flags = await _syncProfileFromServerIfPossible(settings);

  // 2) 檢查本機欄位
  final localHasNickname = (settings.nickname ?? '').trim().isNotEmpty;
  final localHasBirthday = settings.birthday != null;

  // ✅ 規則：只要「後端 or 本地」有一邊缺，就當作需要補
  final needNickname = !localHasNickname || !flags.hasNickname;
  final needBirthday = !localHasBirthday || !flags.hasBirthday;

  if (!needNickname && !needBirthday) {
    // 兩邊都有完整資料 → 直接結束
    return;
  }

  // 這裡的 initialNickname / initialBirthday 是「目前本機（已經先被後端覆蓋過）」
  final res = await showEditProfileDialog(
    context,
    initialNickname: settings.nickname ?? '',
    initialBirthday: settings.birthday,
    forceComplete: true, // ✅ 首次必填，不可取消
  );

  if (res == null) return; // forceComplete=true 理論上不會發生，只是保險

  _applyToSettings(settings, res.nickname, res.birthday);

  // ✅ 同步回後端：讓後端與本機都變成「一定有暱稱＋生日」
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final api = SocialApi(
        meId: (user.email?.toLowerCase() ?? user.uid),
        meName: res.nickname,
        idTokenProvider: () async =>
            FirebaseAuth.instance.currentUser?.getIdToken(),
      );
      final birthdayIso =
          '${res.birthday.year.toString().padLeft(4, '0')}-'
          '${res.birthday.month.toString().padLeft(2, '0')}-'
          '${res.birthday.day.toString().padLeft(2, '0')}';

      await api.updateProfile(nickname: res.nickname, birthdayIso: birthdayIso);
    }
  } catch (_) {
    // 如果這裡失敗，就當作離線，本機還是有值
  }
}

/// 先試著問後端 /me：
/// - 如果有 nickname → 寫入 settings，並回傳 hasNickname = true
/// - 如果有 birthday → 寫入 settings，並回傳 hasBirthday = true
/// - 如果沒有 → 保留本機的值（不覆蓋），hasX = false
Future<_ServerProfileFlags> _syncProfileFromServerIfPossible(
  AppSettings settings,
) async {
  bool serverHasNickname = false;
  bool serverHasBirthday = false;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const _ServerProfileFlags(hasNickname: false, hasBirthday: false);
    }

    final api = SocialApi(
      meId: (user.email?.toLowerCase() ?? user.uid),
      meName: settings.nickname ?? user.displayName ?? 'Me',
      idTokenProvider: () async =>
          FirebaseAuth.instance.currentUser?.getIdToken(),
    );

    final me = await api.fetchMyProfile();

    final nick = (me['nickname'] as String?)?.trim();
    final bdayRaw = (me['birthday'] as String?)?.trim();

    if (nick != null && nick.isNotEmpty) {
      settings.setNickname(nick);
      serverHasNickname = true;
    }

    if (bdayRaw != null && bdayRaw.isNotEmpty) {
      try {
        final parts = bdayRaw.split('-').map(int.parse).toList();
        if (parts.length >= 3) {
          settings.setBirthday(DateTime(parts[0], parts[1], parts[2]));
          serverHasBirthday = true;
        }
      } catch (_) {
        // 生日格式怪怪的就當沒看到
      }
    }
  } catch (_) {
    // 後端掛了/沒網路 → 當作後端都沒有
  }

  return _ServerProfileFlags(
    hasNickname: serverHasNickname,
    hasBirthday: serverHasBirthday,
  );
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
/// 顯示「暱稱＋生日」編輯對話框
/// [forceComplete] = true 時：不可點背景/返回關閉，也不顯示「取消」。
Future<EditProfileResult?> showEditProfileDialog(
  BuildContext context, {
  String initialNickname = '',
  DateTime? initialBirthday,
  bool forceComplete = false,
  bool useRootNavigator = true, // 參數先保留，不一定要用
}) async {
  // ❗ 不再用 Navigator.of(context...)，改用全域 rootNavigatorKey
  final navState = rootNavigatorKey.currentState;
  final overlayContext = navState?.overlay?.context;

  if (overlayContext == null) {
    // 代表 MaterialApp 還沒建好，或正在關閉，直接略過避免 crash
    debugPrint(
      '[ensureProfile] rootNavigatorKey has no overlay context, skip dialog',
    );
    return null;
  }

  return showDialog<EditProfileResult>(
    context: overlayContext,
    barrierDismissible: !forceComplete,
    useRootNavigator: true,
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
      title: Text(l.nicknameLabel),
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

    if (!widget.forceComplete) return dialog;
    // ✅ 不能按返回鍵關閉
    return WillPopScope(onWillPop: () async => false, child: dialog);
  }
}
