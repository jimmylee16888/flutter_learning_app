// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MyApp 範例';

  @override
  String get navCards => '卡片';

  @override
  String get navExplore => '探索';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageZhTW => '繁體中文';

  @override
  String get languageEn => '英文';

  @override
  String get languageJa => '日文';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutDeveloper => '關於開發者';

  @override
  String get developerRole => '開發者';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get versionLabel => '版本';

  @override
  String get birthday => '生日';

  @override
  String get quoteTitle => '給粉絲的一句話';

  @override
  String get fanMiniCards => '粉絲小卡';

  @override
  String get noMiniCardsHint => '尚無小卡，點「編輯」新增。';

  @override
  String get add => '新增';

  @override
  String get editMiniCards => '編輯小卡';

  @override
  String get save => '儲存';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get previewFailed => '預覽失敗';

  @override
  String get favorite => '收藏';

  @override
  String get favorited => '已收藏';

  @override
  String get helloDeveloperTitle => '嗨！開發者在這裡';

  @override
  String get helloDeveloperBody =>
      '謝謝你願意試試這個小 side project。我是 LE SSERAFIM 的忠實粉絲（FEARNOT），但每次想跟朋友分享喜悅，都不想背一疊小卡，所以做了這個 App——讓大家用一支 6.5 吋手機就能展示、交換小卡。我會持續維護，也會把程式碼開源在 GitHub。再次感謝下載，成為這個專案的一小份子（可愛一點說，就是家人）。如果有任何問題或改進想法，隨時聯絡我。— Jimmy Lee';

  @override
  String get stats_title => '統計';

  @override
  String get stats_overview => '收藏概覽';

  @override
  String get stats_artist_count => '藝人數量';

  @override
  String get stats_card_total => '小卡總數';

  @override
  String get stats_front_source => '正面圖片來源';

  @override
  String stats_cards_per_artist_topN(int n) {
    return '各藝人小卡數（前 $n 名）';
  }

  @override
  String get stats_nav_subtitle => '查看收藏統計：總數、來源分布、各藝人 Top';

  @override
  String get common_local => '本地';

  @override
  String get common_url => '網址';

  @override
  String get common_unnamed => '（未命名）';

  @override
  String get common_unit_cards => '張';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name（$pinyin）';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'MyApp 範例';

  @override
  String get navCards => '卡片';

  @override
  String get navExplore => '探索';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageZhTW => '繁體中文';

  @override
  String get languageEn => '英文';

  @override
  String get languageJa => '日文';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutDeveloper => '關於開發者';

  @override
  String get developerRole => '開發者';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get versionLabel => '版本';

  @override
  String get birthday => '生日';

  @override
  String get quoteTitle => '給粉絲的一句話';

  @override
  String get fanMiniCards => '粉絲小卡';

  @override
  String get noMiniCardsHint => '尚無小卡，點「編輯」新增。';

  @override
  String get add => '新增';

  @override
  String get editMiniCards => '編輯小卡';

  @override
  String get save => '儲存';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get previewFailed => '預覽失敗';

  @override
  String get favorite => '收藏';

  @override
  String get favorited => '已收藏';

  @override
  String get helloDeveloperTitle => '嗨！開發者在這裡';

  @override
  String get helloDeveloperBody =>
      '謝謝你願意試試這個小 side project。我是 LE SSERAFIM 的忠實粉絲（FEARNOT），但每次想跟朋友分享喜悅，都不想背一疊小卡，所以做了這個 App——讓大家用一支 6.5 吋手機就能展示、交換小卡。我會持續維護，也會把程式碼開源在 GitHub。再次感謝下載，成為這個專案的一小份子（可愛一點說，就是家人）。如果有任何問題或改進想法，隨時聯絡我。— Jimmy Lee';

  @override
  String get stats_title => '統計';

  @override
  String get stats_overview => '收藏概覽';

  @override
  String get stats_artist_count => '藝人數量';

  @override
  String get stats_card_total => '小卡總數';

  @override
  String get stats_front_source => '正面圖片來源';

  @override
  String stats_cards_per_artist_topN(int n) {
    return '各藝人小卡數（前 $n 名）';
  }

  @override
  String get stats_nav_subtitle => '查看收藏統計：總數、來源分布、各藝人 Top';

  @override
  String get common_local => '本地';

  @override
  String get common_url => '網址';

  @override
  String get common_unnamed => '（未命名）';

  @override
  String get common_unit_cards => '張';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name（$pinyin）';
  }
}
