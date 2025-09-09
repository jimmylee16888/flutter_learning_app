// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get noNetworkGuestTip =>
      'You\'re offline. You can continue as a guest.';

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
  String get languageKo => 'Korean';

  @override
  String get languageDe => 'German';

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
  String get accountStatusGuest => 'Guest mode';

  @override
  String get accountStatusSignedIn => 'Signed in';

  @override
  String get accountStatusSignedOut => 'Signed out';

  @override
  String get accountGuestSubtitle =>
      'Using guest mode; data is stored only on this device';

  @override
  String get accountNoInfo => '(No account info)';

  @override
  String get accountBackToLogin => 'Go to sign-in';

  @override
  String get signOut => 'Sign out';

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
  String get welcomeTitle => 'Welcome to Mini Cards';

  @override
  String get welcomeSubtitle =>
      'Sign in or create an account to sync settings and data';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authRegister => 'Register';

  @override
  String get authContinueAsGuest => 'Continue as guest';

  @override
  String get authAccount => 'Account (Email / any string)';

  @override
  String get authPassword => 'Password';

  @override
  String get authCreateAndSignIn => 'Create account and sign in';

  @override
  String get authName => 'Name';

  @override
  String get authGender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other/Prefer not to say';

  @override
  String get birthdayPick => 'Pick date';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => 'Login failed';

  @override
  String get errorRegisterFailed => 'Register failed';

  @override
  String get errorPickBirthday => 'Please select your birthday';

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

  @override
  String get filterAll => 'All';

  @override
  String get deleteCategoryTitle => 'Delete category';

  @override
  String deleteCategoryMessage(Object name) {
    return 'Delete “$name”? This will also be removed from all cards.';
  }

  @override
  String deletedCategoryToast(Object name) {
    return 'Deleted category: $name';
  }

  @override
  String get searchHint => 'Search name / card text';

  @override
  String get clear => 'Clear';

  @override
  String get noCards => 'No cards';

  @override
  String get addCard => 'Add card';

  @override
  String get deleteCardTitle => 'Delete card';

  @override
  String deleteCardMessage(Object title) {
    return 'Delete “$title”?';
  }

  @override
  String deletedCardToast(Object title) {
    return 'Deleted: $title';
  }

  @override
  String get editCard => 'Edit card';

  @override
  String get categoryAssignOrAdd => 'Assign / add categories';

  @override
  String get newCardTitle => 'New card';

  @override
  String get editCardTitle => 'Edit card';

  @override
  String get nameRequiredLabel => 'Name (required)';

  @override
  String get imageByUrl => 'By URL';

  @override
  String get imageByLocal => 'Local photo';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get quoteOptionalLabel => 'Quote (optional)';

  @override
  String get pickBirthdayOptional => 'Pick birthday (optional)';

  @override
  String get inputImageUrl => 'Please enter image URL';

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get pickLocalPhoto => 'Please choose a local photo';

  @override
  String get updatedCardToast => 'Card updated';

  @override
  String get manageCategoriesTitle => 'Manage categories';

  @override
  String get newCategoryNameHint => 'New category name';

  @override
  String get addCategory => 'Add category';

  @override
  String get deleteCategoryTooltip => 'Delete category';

  @override
  String get assignCategoryTitle => 'Assign categories';

  @override
  String get confirm => 'Confirm';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return 'Delete “$name”? This category will be removed from all cards.';
  }

  @override
  String addedCategoryToast(Object name) {
    return 'Added category: $name';
  }

  @override
  String get noMiniCardsPreviewHint =>
      'No mini cards yet. Tap here or swipe up to add.';

  @override
  String get detailSwipeHint =>
      'Swipe up to open mini-cards (scan/share QR inside)';

  @override
  String get noMiniCardsEmptyList => 'No mini cards yet. Tap + to add.';

  @override
  String get miniLocalImageBadge => 'Local image';

  @override
  String get miniHasBackBadge => 'Has back image';

  @override
  String get tagsLabel => 'Tags';

  @override
  String tagsCount(int n) {
    return 'Tags $n';
  }

  @override
  String get nameLabel => 'Name';

  @override
  String get serialNumber => 'Serial number';

  @override
  String get album => 'Album';

  @override
  String get addAlbum => 'Add album';

  @override
  String get enterAlbumName => 'Enter album name';

  @override
  String get cardType => 'Card type';

  @override
  String get addCardType => 'Add card type';

  @override
  String get enterCardTypeName => 'Enter card type name';

  @override
  String get noteLabel => 'Note';

  @override
  String get newTagHint => 'Add a tag…';

  @override
  String get frontSide => 'Front';

  @override
  String get backSide => 'Back';

  @override
  String get frontImageTitle => 'Front image';

  @override
  String get backImageTitleOptional => 'Back image (optional)';

  @override
  String get frontImageUrlLabel => 'Front image URL';

  @override
  String get backImageUrlLabel => 'Back image URL';

  @override
  String get clearUrl => 'Clear URL';

  @override
  String get clearLocal => 'Clear local';

  @override
  String get clearBackImage => 'Clear back image';

  @override
  String get localPickedLabel => 'Picked: Local';

  @override
  String get miniCardEditTitle => 'Edit mini card';

  @override
  String get miniCardNewTitle => 'New mini card';

  @override
  String get errorFrontImageUrlRequired =>
      'Please enter the front image URL or switch to Local.';

  @override
  String get errorFrontLocalRequired =>
      'Please choose a local front photo or switch to URL.';

  @override
  String get userProfileTitle => 'User profile';

  @override
  String get userProfileTile => 'User profile';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameRequired => 'Nickname is required';

  @override
  String get notSet => 'Not set';

  @override
  String get clearBirthday => 'Clear birthday';

  @override
  String get userProfileSaved => 'Profile saved';

  @override
  String get ready => 'All set';

  @override
  String get fillNicknameAndBirthday => 'Please fill in nickname and birthday';

  @override
  String get navSocial => 'Social';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int n) {
    return '$n min ago';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n hr ago';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n day(s) ago';
  }

  @override
  String get socialFriends => 'Friends';

  @override
  String get socialHot => 'Hot';

  @override
  String get socialFollowing => 'Following';

  @override
  String get publish => 'Publish';

  @override
  String get socialShareHint => 'What\'s on your mind?';

  @override
  String get leaveACommentHint => 'Leave a comment…';

  @override
  String get commentsTitle => 'Comments';

  @override
  String commentsCount(int n) {
    return 'Comments ($n)';
  }

  @override
  String get addTagHint => 'Add a tag…';

  @override
  String followedTag(Object tag) {
    return 'Followed #$tag';
  }

  @override
  String unfollowedTag(Object tag) {
    return 'Unfollowed #$tag';
  }

  @override
  String get friendCardsTitle => 'Friend cards';

  @override
  String get addFriendCard => 'Add card';

  @override
  String get editFriendCard => 'Edit card';

  @override
  String get scanQr => 'Scan QR code';

  @override
  String get tapToFlip => 'Tap to flip';

  @override
  String get deleteFriendCardTitle => 'Delete card';

  @override
  String deleteFriendCardMessage(Object name) {
    return 'Delete “$name”?';
  }

  @override
  String get followArtistsLabel => 'Followed artists';

  @override
  String limitReached(String text) {
    return 'Limit reached ($text)';
  }
}
