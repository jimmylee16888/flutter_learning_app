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
  String get appTitle => 'Pop Card';

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

  @override
  String get retry => 'Retry';

  @override
  String get offlineBanner => 'Offline: some features are unavailable';

  @override
  String get manageFollowedTags => 'Followed tags';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get friendAddAction => 'Add friend';

  @override
  String get friendRemoveAction => 'Remove friend';

  @override
  String get friendAddedStatus => 'Added';

  @override
  String get remove => 'Remove';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get socialLinksTitle => 'Social links';

  @override
  String get showInstagramOnProfile => 'Show Instagram on profile';

  @override
  String get showFacebookOnProfile => 'Show Facebook on profile';

  @override
  String get showLineOnProfile => 'Show Line on profile';

  @override
  String followedTagsCount(int n) {
    return 'Followed tags ($n)';
  }

  @override
  String get addFollowedTag => 'Add followed tag';

  @override
  String get addFollowedTagHint => 'Enter a tag name, then press Enter';

  @override
  String get manageCards => 'Manage cards';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get lineLabel => 'Line';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => 'Search friends or artists';

  @override
  String get followedTagsTitle => 'Followed tags';

  @override
  String get noFollowedTagsYet => 'No followed tags yet';

  @override
  String get addedFollowedTagToast => 'Added followed tag';

  @override
  String addFollowedTagFailed(Object error) {
    return 'Failed to add tag: $error';
  }

  @override
  String get removedFollowedTagToast => 'Removed followed tag';

  @override
  String removeFollowedTagFailed(Object error) {
    return 'Failed to remove tag: $error';
  }

  @override
  String loadFailed(Object error) {
    return 'Failed to load: $error';
  }

  @override
  String miniCardsOf(Object title) {
    return '$title\'s mini cards';
  }

  @override
  String get importFromJsonTooltip => 'Import from JSON';

  @override
  String get exportJsonMultiTooltip => 'Export JSON (multiple)';

  @override
  String get scan => 'Scan';

  @override
  String get share => 'Share';

  @override
  String get shareThisCard => 'Share this card';

  @override
  String importedMiniCardsToast(int n) {
    return 'Imported $n mini card(s)';
  }

  @override
  String get shareMultipleCards => 'Share multiple cards (multi-select)';

  @override
  String get shareMultipleCardsSubtitle =>
      'Select cards, then share photos or export JSON';

  @override
  String get shareOneCard => 'Pick one to share…';

  @override
  String get selectCardsForJsonTitle => 'Select cards to share (JSON)';

  @override
  String get selectCardsForShareOrExportTitle =>
      'Select cards to share / export';

  @override
  String get blockedLocalImageNote =>
      'Contains local image; cannot export to JSON';

  @override
  String shareMultiplePhotos(int n) {
    return 'Share $n photos';
  }

  @override
  String get exportJson => 'Export JSON';

  @override
  String get exportJsonSkipLocalHint =>
      'Cards with local-only images will be skipped';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return 'Tried to share $total, success $ok / failed $fail';
  }

  @override
  String get shareQrCode => 'Share QR code';

  @override
  String get shareQrAutoBackendHint =>
      'Large payloads switch to backend mode automatically';

  @override
  String get cannotShareByQr => 'Cannot share via QR';

  @override
  String get noImageUrl => 'No image URL';

  @override
  String get noImageUrlPhotoOnly =>
      'No image URL; can only share the photo directly';

  @override
  String get shareThisPhoto => 'Share this photo';

  @override
  String shareFailed(Object error) {
    return 'Share failed: $error';
  }

  @override
  String get transportBackendHint => 'Backend mode (via API)';

  @override
  String get transportEmbeddedHint => 'Embedded (local)';

  @override
  String get qrIdOnlyNotice =>
      'This QR contains only the card ID. The receiver will fetch full content from backend.';

  @override
  String get qrGenerationFailed => 'Failed to generate QR image';

  @override
  String get pasteJsonTitle => 'Paste JSON text';

  @override
  String get pasteJsonHint =>
      'Supports mini_card_bundle_v2/v1 or mini_card_v2/v1';

  @override
  String get import => 'Import';

  @override
  String importedFromJsonToast(int n) {
    return 'Imported $n mini card(s) from JSON';
  }

  @override
  String importFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get cannotExportJsonAllLocal =>
      'All selected cards contain local-only images and cannot be exported to JSON';

  @override
  String skippedLocalImagesCount(int n) {
    return 'Skipped $n card(s) that contain local-only images';
  }

  @override
  String get close => 'Close';

  @override
  String get copy => 'Copy';

  @override
  String get copiedJsonToast => 'Copied JSON';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get none => 'None';

  @override
  String get selectCardsToShareTitle => 'Select cards to share';

  @override
  String get hasImageUrlJsonOk => 'Has image URL; can be sent via JSON';

  @override
  String get exportJsonOnlyUrlHint =>
      'Tip: Exported JSON includes only cards with an image URL; local-only images will be skipped.';

  @override
  String get sharePhotos => 'Share photos';

  @override
  String get containsLocalImages => 'Contains local images';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked card(s) cannot be exported to JSON. Export only the usable $allowed card(s)?';
  }

  @override
  String get onlyExportUsable => 'Export usable only';

  @override
  String get shareMiniCardTitle => 'Share mini card';

  @override
  String get qrCodeTab => 'QR code';

  @override
  String get qrTooLargeUseJsonHint =>
      'If the QR code fails to render, the data might be too large. Consider using JSON instead.';

  @override
  String get scanMiniCardQrTitle => 'Scan mini card QR';

  @override
  String get scanFromGallery => 'Scan from gallery';

  @override
  String get noQrFoundInImage => 'No QR found in the image';

  @override
  String get qrFormatInvalid => 'QR format invalid';

  @override
  String get qrTypeUnsupported => 'QR type unsupported';

  @override
  String fetchFromBackendFailed(Object error) {
    return 'Failed to fetch from backend: $error';
  }

  @override
  String get addFollowedTagFailedOffline =>
      'You are offline. Tag added locally.';

  @override
  String get removeFollowedTagFailedOffline =>
      'You are offline. Tag removed locally.';

  @override
  String get loading => 'Loading…';

  @override
  String get networkRequiredTitle => 'Network Required';

  @override
  String get networkRequiredBody =>
      'Sign-in requires an internet connection. Please connect and try again.';

  @override
  String get ok => 'OK';

  @override
  String get willSaveAs => 'Will save as';

  @override
  String get alreadyExists => 'Already exists';

  @override
  String get common_about => 'About';

  @override
  String get settings_menu_general => 'General settings';

  @override
  String get settings_menu_user => 'User settings';

  @override
  String get settings_menu_about => 'About';

  @override
  String get settingsMenuGeneral => 'General settings';

  @override
  String get commonAbout => 'About';

  @override
  String get navMore => 'More';

  @override
  String get exploreReflow => 'Reflow widgets';

  @override
  String get commonAdd => 'Add';

  @override
  String get exploreNoPhoto => 'No photo selected';

  @override
  String get exploreTapToEditQuote => 'Tap to edit quote';

  @override
  String get exploreAdd => 'Add';

  @override
  String get exploreAddPhoto => 'Photo card';

  @override
  String get exploreAddQuote => 'Quote card';

  @override
  String get exploreAddBirthday => 'Birthday countdown';

  @override
  String get exploreAddBall => 'Add ball';

  @override
  String get exploreAdBuiltIn => 'Ad is built-in';

  @override
  String get exploreEnterAQuote => 'Enter a quote';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonOk => 'OK';

  @override
  String get exploreCountdownTitleHint => 'Idol/event (e.g. Sakura Birthday)';

  @override
  String get exploreAddBallDialogTitle => 'Add ball';

  @override
  String get exploreBallEmojiHint => 'Emoji (leave empty to use a photo)';

  @override
  String get exploreSize => 'Size';

  @override
  String get explorePickPhoto => 'Pick a photo…';

  @override
  String get explorePickedPhoto => 'Photo selected';

  @override
  String get navDex => 'Dex';

  @override
  String get dex_title => 'My Dex';

  @override
  String get dex_uncategorized => 'Uncategorized';

  @override
  String get dex_searchHint => 'Search idols or cards…';

  @override
  String dex_cardsCount(Object count) {
    return '$count cards';
  }

  @override
  String get dex_empty => 'No cards collected yet';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get resetZoom => 'Reset zoom';
}
