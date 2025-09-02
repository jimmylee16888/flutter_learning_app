// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyApp Demo';

  @override
  String get navCards => 'Cards';

  @override
  String get navExplore => 'Explore';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageZhTW => 'Traditional Chinese';

  @override
  String get languageEn => 'English';

  @override
  String get languageJa => 'Japanese';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDeveloper => 'About Developer';

  @override
  String get developerRole => 'Developer';

  @override
  String get emailLabel => 'Email';

  @override
  String get versionLabel => 'Version';

  @override
  String get birthday => 'Birthday';

  @override
  String get quoteTitle => 'A message to fans';

  @override
  String get fanMiniCards => 'Fan mini cards';

  @override
  String get noMiniCardsHint => 'No mini cards yet. Tap \"Edit\" to add.';

  @override
  String get add => 'Add';

  @override
  String get editMiniCards => 'Edit mini cards';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get previewFailed => 'Preview failed';

  @override
  String get favorite => 'Favorite';

  @override
  String get favorited => 'Favorited';

  @override
  String get helloDeveloperTitle => 'Hello! I\'m the developer';

  @override
  String get helloDeveloperBody =>
      'Thanks for giving this little side project a try. I’m a big fan of LE SSERAFIM (FEARNOT here!), but I don’t want to carry a whole stack of photocards every time I share the joy with friends. That’s why I built this app—so fans can show and trade cards right from a 6.5\" screen. I’ll keep maintaining it and the code will stay open on GitHub. Thanks again for downloading and being part of this project (or, to say it cutely, the family). If you have questions or ideas to improve it, don’t hesitate to contact me. — Jimmy Lee';

  @override
  String get stats_title => 'Statistics';

  @override
  String get stats_overview => 'Collection Overview';

  @override
  String get stats_artist_count => 'Number of artists';

  @override
  String get stats_card_total => 'Total mini cards';

  @override
  String get stats_front_source => 'Front image source';

  @override
  String stats_cards_per_artist_topN(int n) {
    return 'Mini cards per artist (Top $n)';
  }

  @override
  String get stats_nav_subtitle =>
      'See collection stats: totals, sources, top artists';

  @override
  String get common_local => 'Local';

  @override
  String get common_url => 'URL';

  @override
  String get common_unnamed => '(Unnamed)';

  @override
  String get common_unit_cards => 'cards';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name ($pinyin)';
  }
}
