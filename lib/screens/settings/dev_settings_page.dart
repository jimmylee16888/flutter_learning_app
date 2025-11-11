import 'package:flutter/material.dart';
import 'package:flutter_learning_app/services/subscription_service.dart';

class DevSettingsPage extends StatefulWidget {
  const DevSettingsPage({super.key});

  @override
  State<DevSettingsPage> createState() => _DevSettingsPageState();
}

class _DevSettingsPageState extends State<DevSettingsPage> {
  bool _overrideEnabled = false;
  SubscriptionPlan _simPlan = SubscriptionPlan.free;
  bool _simActive = false;

  @override
  void initState() {
    super.initState();
    final s = SubscriptionService.I;
    _overrideEnabled = s.devOverrideEnabled;
    final st = s.devOverrideState ?? s.state.value;
    _simPlan = st.plan;
    _simActive = st.isActive;
  }

  Future<void> _apply() async {
    await SubscriptionService.I.setDevOverride(
      enabled: _overrideEnabled,
      plan: _simPlan,
      isActive: _simActive,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已套用開發者模擬訂閱狀態')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final eff = SubscriptionService.I.effective.value;

    return Scaffold(
      appBar: AppBar(title: const Text('開發者設定'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 目前有效狀態總覽
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('目前 App 讀到的訂閱狀態（effective）'),
              subtitle: Text(
                'plan: ${eff.plan.name} / active: ${eff.isActive}',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 是否啟用覆寫
          Card(
            child: SwitchListTile(
              title: const Text('使用模擬訂閱狀態覆寫（開發者）'),
              subtitle: const Text('開啟後，App 會忽略真實訂閱，使用下方的模擬值'),
              value: _overrideEnabled,
              onChanged: (v) => setState(() => _overrideEnabled = v),
            ),
          ),
          const SizedBox(height: 12),

          // 模擬方案 / 是否有效
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('模擬的訂閱方案'),
                  const SizedBox(height: 8),
                  DropdownButton<SubscriptionPlan>(
                    value: _simPlan,
                    items: SubscriptionPlan.values
                        .map(
                          (p) =>
                              DropdownMenuItem(value: p, child: Text(p.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _simPlan = v!),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _simActive,
                    onChanged: (v) => setState(() => _simActive = v ?? false),
                    title: const Text('視為有效（isActive=true）'),
                    subtitle: const Text('模擬已付費或權限仍有效'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('儲存並套用'),
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
