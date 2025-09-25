// lib/utils/dex_idol_helper.dart

import 'package:flutter_learning_app/models/mini_card_data.dart';

/// 讀取 tags 裡的 idol:xxx（保留舊相容）
String idolFromTags(List<String> tags, {String fallback = ''}) {
  for (final t in tags) {
    if (t.startsWith('idol:')) {
      final v = t.substring(5).trim();
      if (v.isNotEmpty) return v;
    }
  }
  return fallback;
}

/// 在 tags 中寫入/覆蓋 idol:xxx（保留舊相容）
List<String> upsertIdolTag(List<String> tags, String idol) {
  final List<String> next = [...tags.where((t) => !t.startsWith('idol:'))];
  if (idol.trim().isNotEmpty) next.add('idol:${idol.trim()}');
  return next;
}

/// ===== 新增：與新資料模型對齊 =====

/// 統一取得 idol：優先 mini.idol，其次舊 tags 的 idol:xxx，再退回 fallback
String resolveIdol(MiniCardData m, {String fallback = ''}) {
  final byField = (m.idol ?? '').trim();
  if (byField.isNotEmpty) return byField;
  final byTag = idolFromTags(m.tags);
  if (byTag.isNotEmpty) return byTag;
  return fallback;
}

/// 依 idol 分組；沒有 idol 的歸入 [uncategorized]
Map<String, List<MiniCardData>> groupMiniCardsByIdol(
  Iterable<MiniCardData> items, {
  String uncategorized = 'Uncategorized',
}) {
  final map = <String, List<MiniCardData>>{};
  for (final m in items) {
    final k = resolveIdol(m, fallback: uncategorized);
    (map[k] ??= <MiniCardData>[]).add(m);
  }
  return map;
}

/// ===== 以下為舊的「字串比對／推論」工具（保留，可供其他場景使用）=====

/// 文本標準化：小寫 + 去除非常見文字（含中/日/韓/數字/英字/全形）
String _norm(String s) {
  final lower = s.toLowerCase();
  final only = lower.replaceAll(
    RegExp(
      r'[^a-z0-9\u4e00-\u9fa5\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af\uff00-\uffef]',
    ),
    ' ',
  );
  return only.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// 把一段字串拆成 token（底線/破折號/斜線/點/空白都當切割符）
Iterable<String> _splitTokens(String s) sync* {
  final n = _norm(s);
  if (n.isEmpty) return;
  for (final t in n.split(RegExp(r'[ _\-/\.]+'))) {
    final v = t.trim();
    if (v.isNotEmpty) yield v;
  }
}

/// 從 CardItem 產生可比對的別名集合（含 title 與 categories 作為別名，含拆詞）
Set<String> aliasesForArtist(String title, List<String> categories) {
  final set = <String>{};
  set.addAll(_splitTokens(title));
  for (final c in categories) {
    set.addAll(_splitTokens(c));
  }
  return set;
}

/// 從 MiniCardData 的多處來源湊出待比對的文字（含拆詞）
List<String> extractCandidateStrings({
  String? name,
  String? serial,
  String? localPath,
  String? imageUrl,
}) {
  final out = <String>{};
  for (final s in [name, serial, localPath, imageUrl]) {
    if (s == null || s.trim().isEmpty) continue;
    out.addAll(_splitTokens(s));
  }
  return out.toList();
}

/// 依卡片資訊 + 藝人清單嘗試推論偶像；回傳 `null` 表示推不到
String? inferIdolForCard({
  required List<String> candidateText, // 已拆詞標準化
  required Map<String, Set<String>>
  artistAliasMap, // "TWICE" -> {"twice","tzuyu"...}
  List<String> prefer = const [], // 偏好藝人，命中時重權
}) {
  if (candidateText.isEmpty || artistAliasMap.isEmpty) return null;

  final preferSet = prefer.map(_norm).toSet();
  String? best;
  int bestScore = -1;

  for (final entry in artistAliasMap.entries) {
    final artist = entry.key;
    final aliases = entry.value;
    int score = 0;

    // 命中計分：候選 token 任一包含 alias（或完全相等）即 +1
    for (final token in candidateText) {
      for (final a in aliases) {
        if (token == a || token.contains(a) || a.contains(token)) {
          score++;
        }
      }
    }
    if (score == 0) continue;
    if (preferSet.contains(_norm(artist))) score += 100; // 偏好加權

    if (score > bestScore) {
      bestScore = score;
      best = artist;
    }
  }

  return best;
}
