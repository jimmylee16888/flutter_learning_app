import 'dart:convert';
import 'dart:io';
import 'package:flutter_learning_app/screens/explore/explore_item.dart';
import 'package:path_provider/path_provider.dart';

class ExploreStore {
  ExploreStore._();
  static final ExploreStore I = ExploreStore._();

  File? _file;

  Future<File> _ensureFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/explore_items.json');
    if (!await _file!.exists()) {
      await _file!.create(recursive: true);
      await _file!.writeAsString('[]', encoding: utf8);
    }
    return _file!;
  }

  Future<List<ExploreItem>> load() async {
    try {
      final f = await _ensureFile();
      final raw = await f.readAsString();
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(ExploreItem.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ExploreItem> items) async {
    final f = await _ensureFile();
    final list = items.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(list), encoding: utf8);
  }
}
