// lib/screens/manage_categories_page.dart
import 'package:flutter/material.dart';
import '../../app_settings.dart';
import '../../models/card_item.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.settings.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('管理分類')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: cats.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: '新增分類名稱',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  onPressed: _addCategory,
                ),
              ],
            );
          }
          final name = cats[i - 1];
          return ListTile(
            title: Text(name),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(name),
              tooltip: '刪除分類',
            ),
          );
        },
      ),
    );
  }

  void _addCategory() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    if (!widget.settings.categories.contains(name)) {
      widget.settings.addCategory(name); // 你的 AppSettings 應該已提供
    }
    setState(() {});
    _ctrl.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已新增分類：$name')));
  }

  Future<void> _confirmDelete(String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('刪除分類'),
        content: Text('確定刪除「$name」？此分類會從所有卡片移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    // 從所有卡片移除此分類
    final updated = <CardItem>[];
    for (final c in widget.settings.cardItems) {
      if (c.categories.contains(name)) {
        final newCats = c.categories.where((x) => x != name).toList();
        updated.add(c.copyWith(categories: newCats));
      }
    }
    for (final u in updated) {
      widget.settings.upsertCard(u);
    }

    // 從設定中移除分類（你的 AppSettings 需要有 removeCategory）
    widget.settings.removeCategory(name);

    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已刪除分類：$name')));
  }
}
