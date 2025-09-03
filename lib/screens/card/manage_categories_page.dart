import 'package:flutter/material.dart';
import '../../app_settings.dart';
import '../../models/card_item.dart';
import '../../l10n/l10n.dart'; // ← i18n

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
    final l = context.l10n;
    final cats = widget.settings.categories;

    return Scaffold(
      appBar: AppBar(title: Text(l.manageCategoriesTitle)),
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
                    decoration: InputDecoration(
                      hintText: l.newCategoryNameHint,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.add),
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
              tooltip: l.deleteCategoryTooltip,
            ),
          );
        },
      ),
    );
  }

  void _addCategory() {
    final l = context.l10n;
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    if (!widget.settings.categories.contains(name)) {
      widget.settings.addCategory(name);
    }
    setState(() {});
    _ctrl.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.addedCategoryToast(name))));
  }

  Future<void> _confirmDelete(String name) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.deleteCategoryTitle),
        content: Text(l.confirmDeleteCategoryMessage(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;

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
    widget.settings.removeCategory(name);

    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.deletedCategoryToast(name))));
  }
}
