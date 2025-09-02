// lib/services/stats_service.dart
import '../models/card_item.dart';
import '../models/mini_card_data.dart';

class StatsSummary {
  final int artistCount;
  final int totalCards;
  final int frontLocalCount;
  final int frontUrlCount;

  // 可選：若也要把「背面」來源列入（示範）
  final int backLocalCount;
  final int backUrlCount;

  // 依藝人分組的小卡數（未來可做排行榜/圖表）
  final Map<String, int> cardsPerArtist;

  const StatsSummary({
    required this.artistCount,
    required this.totalCards,
    required this.frontLocalCount,
    required this.frontUrlCount,
    required this.backLocalCount,
    required this.backUrlCount,
    required this.cardsPerArtist,
  });
}

class StatsService {
  /// 計算總表統計：
  /// - [artists]：用 title 當唯一鍵（如你有穩定 id，可自行改）
  /// - [allCards]：全專案所有小卡
  /// - [artistOf]：傳回一張卡屬於哪位藝人（預設用 c.name，如果沒有 name 就回 '未知'）
  static StatsSummary summarize({
    required List<CardItem> artists,
    required List<MiniCardData> allCards,
    String Function(MiniCardData c)? artistOf,
  }) {
    final artistKey =
        artistOf ??
        (c) => (c.name ?? '').trim().isEmpty ? '未知' : c.name!.trim();

    // 藝人數（title 去重）
    final artistSet = <String>{};
    for (final a in artists) {
      final k = a.title.trim();
      if (k.isNotEmpty) artistSet.add(k);
    }

    int frontLocal = 0, frontUrl = 0, backLocal = 0, backUrl = 0;
    final perArtist = <String, int>{};

    for (final c in allCards) {
      // front
      final hasFrontLocal = (c.localPath != null && c.localPath!.isNotEmpty);
      final hasFrontUrl = (c.imageUrl != null && c.imageUrl!.isNotEmpty);
      if (hasFrontLocal) frontLocal++;
      if (hasFrontUrl) frontUrl++;

      // back（示範：若你要把背面也統計來源）
      final hasBackLocal =
          (c.backLocalPath != null && c.backLocalPath!.isNotEmpty);
      final hasBackUrl = (c.backImageUrl != null && c.backImageUrl!.isNotEmpty);
      if (hasBackLocal) backLocal++;
      if (hasBackUrl) backUrl++;

      // 分組：這張卡屬於哪位藝人
      final key = artistKey(c);
      perArtist.update(key, (v) => v + 1, ifAbsent: () => 1);
    }

    return StatsSummary(
      artistCount: artistSet.length,
      totalCards: allCards.length,
      frontLocalCount: frontLocal,
      frontUrlCount: frontUrl,
      backLocalCount: backLocal,
      backUrlCount: backUrl,
      cardsPerArtist: perArtist,
    );
  }
}
