// lib/app_settings.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/card_item.dart';

class AppSettings extends ChangeNotifier {
  // ====== Storage keys ======
  static const _kThemeMode = 'app_theme_mode';
  static const _kLocale = 'app_locale';
  static const _kCategories = 'categories';
  static const _kCardItems = 'card_items';

  // 使用者資訊
  static const _kNickname = 'user_nickname';
  static const _kBirthdayISO = 'user_birthday_iso'; // yyyy-MM-dd

  // ★ 追蹤標籤（全域設定，Follow 分頁會用到）
  static const _kFollowedTags = 'followed_tags'; // json array<string>
  static const int followedTagsMax = 30;

  SharedPreferences? _prefs;

  // ====== Theme / Locale ======
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale? _locale;
  Locale? get locale => _locale;

  // ====== 分類 + 卡片 ======
  List<String> _categories = [];
  List<CardItem> _cardItems = [];

  List<String> get categories => List.unmodifiable(_categories);
  List<CardItem> get cardItems => List.unmodifiable(_cardItems);

  // 使用者資訊
  String? _nickname;
  DateTime? _birthday;

  String? get nickname => _nickname;
  DateTime? get birthday => _birthday;

  // ★ 追蹤標籤
  List<String> _followedTags = [];
  List<String> get followedTags => List.unmodifiable(_followedTags);

  AppSettings._();

  static Future<AppSettings> load() async {
    final s = AppSettings._();
    await s._init();
    return s;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    // ThemeMode
    final tm = _prefs!.getString(_kThemeMode);
    switch (tm) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    // Locale
    final loc = _prefs!.getString(_kLocale);
    if (loc != null && loc.isNotEmpty) {
      final parts = loc.split('_');
      _locale = parts.length == 2
          ? Locale(parts[0], parts[1])
          : Locale(parts[0]);
    }

    // Collections
    final cats = _prefs!.getString(_kCategories);
    final cards = _prefs!.getString(_kCardItems);
    _categories = cats == null ? [] : (jsonDecode(cats) as List).cast<String>();
    _cardItems = cards == null
        ? []
        : (jsonDecode(cards) as List)
              .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
              .toList();

    // 使用者資訊
    _nickname = _prefs!.getString(_kNickname);
    final bIso = _prefs!.getString(_kBirthdayISO);
    if (bIso != null && bIso.isNotEmpty) {
      try {
        final p = bIso.split('-').map(int.parse).toList();
        _birthday = DateTime(p[0], p[1], p[2]);
      } catch (_) {
        _birthday = null;
      }
    }

    // ★ 追蹤標籤
    final f = _prefs!.getString(_kFollowedTags);
    if (f != null && f.isNotEmpty) {
      final arr = (jsonDecode(f) as List).map((e) => '$e').toList();
      // 去重、去空白、lowercase、長度限制 30
      final norm = <String>{};
      for (final raw in arr) {
        final t = raw.trim().toLowerCase();
        if (t.isNotEmpty) norm.add(t);
        if (norm.length >= followedTagsMax) break;
      }
      _followedTags = norm.toList();
    } else {
      _followedTags = [];
    }
  }

  // ====== Theme / Locale setters ======
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs?.setString(_kThemeMode, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
    notifyListeners();
  }

  void setLocale(Locale? l) {
    _locale = l;
    if (l == null) {
      _prefs?.remove(_kLocale);
    } else {
      final tag = (l.countryCode == null || l.countryCode!.isEmpty)
          ? l.languageCode
          : '${l.languageCode}_${l.countryCode}';
      _prefs?.setString(_kLocale, tag);
    }
    notifyListeners();
  }

  // ====== 使用者資訊 ======
  void setNickname(String? name) {
    _nickname = (name ?? '').trim().isEmpty ? null : name!.trim();
    if (_nickname == null) {
      _prefs?.remove(_kNickname);
    } else {
      _prefs?.setString(_kNickname, _nickname!);
    }
    notifyListeners();
  }

  void setBirthday(DateTime? date) {
    _birthday = date;
    if (date == null) {
      _prefs?.remove(_kBirthdayISO);
    } else {
      final iso =
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
      _prefs?.setString(_kBirthdayISO, iso);
    }
    notifyListeners();
  }

  // ====== 追蹤標籤（上限 30） ======
  void setFollowedTags(List<String> tags) {
    final s = <String>{};
    for (final raw in tags) {
      if (s.length >= followedTagsMax) break;
      final t = raw.trim().toLowerCase();
      if (t.isNotEmpty) s.add(t);
    }
    _followedTags = s.toList();
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
  }

  bool addFollowedTag(String tag) {
    final t = tag.trim().toLowerCase();
    if (t.isEmpty) return false;
    if (_followedTags.contains(t)) return false;
    if (_followedTags.length >= followedTagsMax) return false;
    _followedTags = [..._followedTags, t];
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
    return true;
  }

  void removeFollowedTag(String tag) {
    final t = tag.trim().toLowerCase();
    _followedTags = _followedTags.where((e) => e != t).toList();
    _prefs?.setString(_kFollowedTags, jsonEncode(_followedTags));
    notifyListeners();
  }

  // ====== 分類與卡片：載入 / 儲存 ======
  Future<void> loadCollections() async {
    await _init();
    notifyListeners();
  }

  Future<void> _saveCollections() async {
    await _prefs?.setString(_kCategories, jsonEncode(_categories));
    await _prefs?.setString(
      _kCardItems,
      jsonEncode(_cardItems.map((e) => e.toJson()).toList()),
    );
  }

  // ====== 分類操作 ======
  void addCategory(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_categories.contains(n)) return;
    _categories = [..._categories, n];
    _saveCollections();
    notifyListeners();
  }

  void removeCategory(String name) {
    _categories = _categories.where((c) => c != name).toList();
    _cardItems = _cardItems
        .map(
          (c) => c.copyWith(
            categories: c.categories.where((x) => x != name).toList(),
          ),
        )
        .toList();
    _saveCollections();
    notifyListeners();
  }

  // ====== 卡片操作 ======
  void upsertCard(CardItem item) {
    final idx = _cardItems.indexWhere((c) => c.id == item.id);
    if (idx >= 0) {
      _cardItems = List.of(_cardItems)..[idx] = item;
    } else {
      _cardItems = [..._cardItems, item];
    }
    _saveCollections();
    notifyListeners();
  }

  void setCardCategories(String cardId, List<String> cats) {
    final idx = _cardItems.indexWhere((c) => c.id == cardId);
    if (idx < 0) return;
    _cardItems = List.of(_cardItems)
      ..[idx] = _cardItems[idx].copyWith(categories: cats);
    _saveCollections();
    notifyListeners();
  }

  void removeCard(String cardId) {
    _cardItems = _cardItems.where((c) => c.id != cardId).toList();
    _saveCollections();
    notifyListeners();
  }
}

// // // lib/app_settings.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'models/card_item.dart';
// import 'models/friend_card.dart';

// class AppSettings extends ChangeNotifier {
//   // ====== Storage keys ======
//   static const _kThemeMode = 'app_theme_mode';
//   static const _kLocale = 'app_locale'; // e.g. 'zh_TW' / 'en'
//   static const _kCategories = 'categories';
//   static const _kCardItems = 'card_items';

//   // 使用者資訊
//   static const _kNickname = 'user_nickname';
//   static const _kBirthdayISO = 'user_birthday_iso'; // yyyy-MM-dd

//   // 社交／名片與追蹤
//   static const _kFriendCards = 'friend_cards';
//   static const _kFollowedTags = 'followed_tags';

//   SharedPreferences? _prefs;

//   // ====== Theme / Locale ======
//   ThemeMode _themeMode = ThemeMode.system;
//   ThemeMode get themeMode => _themeMode;

//   Locale? _locale;
//   Locale? get locale => _locale;

//   // ====== 分類 + 卡片 ======
//   List<String> _categories = [];
//   List<CardItem> _cardItems = [];

//   List<String> get categories => List.unmodifiable(_categories);
//   List<CardItem> get cardItems => List.unmodifiable(_cardItems);

//   // ====== 使用者資訊（暱稱 / 生日） ======
//   String? _nickname;
//   DateTime? _birthday;

//   String? get nickname => _nickname;
//   DateTime? get birthday => _birthday;

//   // ====== 朋友名片與追蹤標籤 ======
//   List<FriendCard> _friendCards = [];
//   Set<String> _followedTags = {};

//   List<FriendCard> get friendCards => List.unmodifiable(_friendCards);
//   Set<String> get followedTags => Set.unmodifiable(_followedTags);

//   AppSettings._();

//   /// 供 main.dart 呼叫：讀取所有設定
//   static Future<AppSettings> load() async {
//     final s = AppSettings._();
//     await s._init();
//     return s;
//   }

//   Future<void> _init() async {
//     _prefs = await SharedPreferences.getInstance();

//     // ---- ThemeMode ----
//     final tm = _prefs!.getString(_kThemeMode);
//     switch (tm) {
//       case 'light':
//         _themeMode = ThemeMode.light;
//         break;
//       case 'dark':
//         _themeMode = ThemeMode.dark;
//         break;
//       default:
//         _themeMode = ThemeMode.system;
//     }

//     // ---- Locale ----
//     final loc = _prefs!.getString(_kLocale);
//     if (loc != null && loc.isNotEmpty) {
//       final parts = loc.split('_');
//       _locale = parts.length == 2
//           ? Locale(parts[0], parts[1])
//           : Locale(parts[0]);
//     }

//     // ---- Collections (categories & cards) ----
//     final cats = _prefs!.getString(_kCategories);
//     final cards = _prefs!.getString(_kCardItems);

//     _categories = cats == null ? [] : (jsonDecode(cats) as List).cast<String>();

//     _cardItems = cards == null
//         ? []
//         : (jsonDecode(cards) as List)
//               .map((e) => CardItem.fromJson(e as Map<String, dynamic>))
//               .toList();

//     // ---- 使用者資訊 ----
//     _nickname = _prefs!.getString(_kNickname);

//     final bIso = _prefs!.getString(_kBirthdayISO);
//     if (bIso != null && bIso.isNotEmpty) {
//       try {
//         // yyyy-MM-dd
//         final parts = bIso.split('-').map(int.parse).toList();
//         _birthday = DateTime(parts[0], parts[1], parts[2]);
//       } catch (_) {
//         _birthday = null;
//       }
//     }

//     // ---- 朋友名片 ----
//     final fc = _prefs!.getString(_kFriendCards);
//     _friendCards = fc == null
//         ? []
//         : (jsonDecode(fc) as List)
//               .map((e) => FriendCard.fromJson(e as Map<String, dynamic>))
//               .toList();

//     // ---- 追蹤標籤 ----
//     final tags = _prefs!.getStringList(_kFollowedTags);
//     _followedTags = {...(tags ?? const [])};
//   }

//   // ====== Theme / Locale setters ======
//   void setThemeMode(ThemeMode mode) {
//     if (_themeMode == mode) return;
//     _themeMode = mode;
//     _prefs?.setString(_kThemeMode, switch (mode) {
//       ThemeMode.light => 'light',
//       ThemeMode.dark => 'dark',
//       _ => 'system',
//     });
//     notifyListeners();
//   }

//   void setLocale(Locale? l) {
//     _locale = l;
//     if (l == null) {
//       _prefs?.remove(_kLocale);
//     } else {
//       final tag = (l.countryCode == null || l.countryCode!.isEmpty)
//           ? l.languageCode
//           : '${l.languageCode}_${l.countryCode}';
//       _prefs?.setString(_kLocale, tag);
//     }
//     notifyListeners();
//   }

//   // ====== 使用者資訊：暱稱 / 生日 ======
//   void setNickname(String? name) {
//     _nickname = (name ?? '').trim().isEmpty ? null : name!.trim();
//     if (_nickname == null) {
//       _prefs?.remove(_kNickname);
//     } else {
//       _prefs?.setString(_kNickname, _nickname!);
//     }
//     notifyListeners();
//   }

//   void setBirthday(DateTime? date) {
//     _birthday = date;
//     if (date == null) {
//       _prefs?.remove(_kBirthdayISO);
//     } else {
//       final iso =
//           '${date.year.toString().padLeft(4, '0')}-'
//           '${date.month.toString().padLeft(2, '0')}-'
//           '${date.day.toString().padLeft(2, '0')}';
//       _prefs?.setString(_kBirthdayISO, iso);
//     }
//     notifyListeners();
//   }

//   // ====== 分類與卡片：載入 / 儲存 ======
//   Future<void> loadCollections() async {
//     await _init();
//     notifyListeners();
//   }

//   Future<void> _saveCollections() async {
//     await _prefs?.setString(_kCategories, jsonEncode(_categories));
//     await _prefs?.setString(
//       _kCardItems,
//       jsonEncode(_cardItems.map((e) => e.toJson()).toList()),
//     );
//   }

//   // ====== 分類操作 ======
//   void addCategory(String name) {
//     final n = name.trim();
//     if (n.isEmpty) return;
//     if (_categories.contains(n)) return;
//     _categories = [..._categories, n];
//     _saveCollections();
//     notifyListeners();
//   }

//   void removeCategory(String name) {
//     _categories = _categories.where((c) => c != name).toList();
//     // 同步將卡片中被刪除的分類清掉
//     _cardItems = _cardItems
//         .map(
//           (c) => c.copyWith(
//             categories: c.categories.where((x) => x != name).toList(),
//           ),
//         )
//         .toList();
//     _saveCollections();
//     notifyListeners();
//   }

//   // ====== 卡片操作 ======
//   void upsertCard(CardItem item) {
//     final idx = _cardItems.indexWhere((c) => c.id == item.id);
//     if (idx >= 0) {
//       _cardItems = List.of(_cardItems)..[idx] = item;
//     } else {
//       _cardItems = [..._cardItems, item];
//     }
//     _saveCollections();
//     notifyListeners();
//   }

//   void setCardCategories(String cardId, List<String> cats) {
//     final idx = _cardItems.indexWhere((c) => c.id == cardId);
//     if (idx < 0) return;
//     _cardItems = List.of(_cardItems)
//       ..[idx] = _cardItems[idx].copyWith(categories: cats);
//     _saveCollections();
//     notifyListeners();
//   }

//   void removeCard(String cardId) {
//     _cardItems = _cardItems.where((c) => c.id != cardId).toList();
//     _saveCollections();
//     notifyListeners();
//   }

//   // ====== 朋友名片操作 ======
//   void upsertFriendCard(FriendCard item) {
//     final i = _friendCards.indexWhere((x) => x.id == item.id);
//     if (i >= 0) {
//       _friendCards = List.of(_friendCards)..[i] = item;
//     } else {
//       _friendCards = [..._friendCards, item];
//     }
//     _saveFriendCards();
//     notifyListeners();
//   }

//   void removeFriendCard(String id) {
//     _friendCards = _friendCards.where((x) => x.id != id).toList();
//     _saveFriendCards();
//     notifyListeners();
//   }

//   void _saveFriendCards() {
//     _prefs?.setString(
//       _kFriendCards,
//       jsonEncode(_friendCards.map((e) => e.toJson()).toList()),
//     );
//   }

//   // ====== 追蹤標籤（社群用） ======
//   bool isTagFollowed(String tag) => _followedTags.contains(tag);

//   void followTag(String tag) {
//     if (tag.trim().isEmpty) return;
//     if (_followedTags.add(tag.trim())) _saveFollowedTags();
//   }

//   void unfollowTag(String tag) {
//     if (_followedTags.remove(tag)) _saveFollowedTags();
//   }

//   void toggleFollowTag(String tag) {
//     if (isTagFollowed(tag)) {
//       _followedTags.remove(tag);
//     } else {
//       if (tag.trim().isEmpty) return;
//       _followedTags.add(tag.trim());
//     }
//     _saveFollowedTags();
//   }

//   void setFollowedTags(Set<String> tags) {
//     _followedTags = {
//       ...tags.where((e) => e.trim().isNotEmpty).map((e) => e.trim()),
//     };
//     _saveFollowedTags();
//   }

//   void _saveFollowedTags() {
//     _prefs?.setStringList(_kFollowedTags, _followedTags.toList());
//     notifyListeners();
//   }
// }
