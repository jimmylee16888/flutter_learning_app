// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MyApp デモ';

  @override
  String get navCards => 'カード';

  @override
  String get navExplore => '探索';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageZhTW => '繁体字中国語';

  @override
  String get languageEn => '英語';

  @override
  String get languageJa => '日本語';

  @override
  String get aboutTitle => '情報';

  @override
  String get aboutDeveloper => '開発者について';

  @override
  String get developerRole => '開発者';

  @override
  String get emailLabel => 'メール';

  @override
  String get versionLabel => 'バージョン';

  @override
  String get birthday => '誕生日';

  @override
  String get quoteTitle => 'ファンへのメッセージ';

  @override
  String get fanMiniCards => 'ファンミニカード';

  @override
  String get noMiniCardsHint => 'ミニカードはまだありません。「編集」をタップして追加してください。';

  @override
  String get add => '追加';

  @override
  String get editMiniCards => 'ミニカードを編集';

  @override
  String get save => '保存';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get previewFailed => 'プレビューに失敗しました';

  @override
  String get favorite => 'お気に入り';

  @override
  String get favorited => 'お気に入り済み';

  @override
  String get helloDeveloperTitle => 'こんにちは！開発者です';

  @override
  String get helloDeveloperBody =>
      'この小さなサイドプロジェクトを試してくれて、ありがとうございます。私は LE SSERAFIM の大ファン（FEARNOT）ですが、友だちと喜びを分かち合うたびにフォトカードを山ほど持ち歩くのは大変。そこでこのアプリを作りました。6.5インチの画面だけでカードの表示や交換ができます。今後もメンテナンスを続け、コードは GitHub で公開します。ダウンロードして、このプロジェクト――かわいく言えば“ファミリー”――の一員になってくれて本当に感謝します。改善のアイデアや質問があれば、いつでも気軽に連絡してください。— Jimmy Lee';

  @override
  String get stats_title => '統計';

  @override
  String get stats_overview => 'コレクション概要';

  @override
  String get stats_artist_count => 'アーティスト数';

  @override
  String get stats_card_total => 'ミニカード総数';

  @override
  String get stats_front_source => '表面画像のソース';

  @override
  String stats_cards_per_artist_topN(int n) {
    return 'アーティストごとのミニカード数（トップ $n）';
  }

  @override
  String get stats_nav_subtitle => 'コレクション統計：総数・ソース分布・トップアーティスト';

  @override
  String get common_local => 'ローカル';

  @override
  String get common_url => 'URL';

  @override
  String get common_unnamed => '（無名）';

  @override
  String get common_unit_cards => '枚';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name（$pinyin）';
  }
}
