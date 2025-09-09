import 'package:flutter/material.dart';
import '../../app_settings.dart';
import '../../l10n/l10n.dart';

class UserProfileSettingsPage extends StatefulWidget {
  const UserProfileSettingsPage({
    super.key,
    required this.settings,
    this.forceComplete = false, // 登入後補齊可設 true：未完成不得離開
  });

  final AppSettings settings;
  final bool forceComplete;

  @override
  State<UserProfileSettingsPage> createState() =>
      _UserProfileSettingsPageState();
}

class _UserProfileSettingsPageState extends State<UserProfileSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nickCtrl;
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    _nickCtrl = TextEditingController(text: widget.settings.nickname ?? '');
    _birthday = widget.settings.birthday;
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(now.year - 18, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
      helpText: context.l10n.birthdayPick,
    );
    if (!mounted) return;
    if (picked != null) setState(() => _birthday = picked);
  }

  bool get _canSave {
    final nickOk = _nickCtrl.text.trim().isNotEmpty;
    final bdOk = widget.forceComplete ? _birthday != null : true;
    return nickOk && bdOk;
  }

  void _save() {
    final l = context.l10n;
    if (!_formKey.currentState!.validate()) return;
    if (!_canSave) {
      if (widget.forceComplete && _birthday == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.errorPickBirthday)));
      }
      return;
    }
    widget.settings.setNickname(_nickCtrl.text.trim());
    widget.settings.setBirthday(_birthday);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.userProfileSaved)));
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(l.userProfileTitle),
        automaticallyImplyLeading: !widget.forceComplete,
        actions: [
          TextButton.icon(
            onPressed: _canSave ? _save : null,
            icon: const Icon(Icons.save),
            label: Text(l.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 暱稱
                    TextFormField(
                      controller: _nickCtrl,
                      decoration: InputDecoration(
                        labelText: l.nicknameLabel,
                        hintText: l.nicknameLabel,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.nicknameRequired
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // 生日（可清除）
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cake_outlined),
                            label: Text(
                              _birthday == null
                                  ? l.birthdayPick
                                  : _fmt(_birthday!),
                            ),
                            onPressed: _pickBirthday,
                          ),
                        ),
                        if (_birthday != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: l.clearBirthday,
                            onPressed: () => setState(() => _birthday = null),
                            icon: Icon(Icons.clear, color: cs.error),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.forceComplete) return scaffold;
    // 未完成資料不可返回
    return WillPopScope(
      onWillPop: () async => _canSave, // 還沒填好就不讓返回
      child: scaffold,
    );
  }
}
