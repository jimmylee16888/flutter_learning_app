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
      'Thank you for trying out this little side project 💫 \n\nI’m a proud FEARNOT (LE SSERAFIM fan)! Every time I want to share the joy of collecting photocards with friends, I hate having to carry a whole stack around — so I made this app 💡. Now you can easily show and trade your cards with just a 6.5-inch phone.\n\nI’ll keep updating and improving this tiny project, and I’m truly grateful that you downloaded it and became part of it (or, cutely put, part of the family 🩷). If you have any ideas or feedback, feel free to reach out anytime! 💪';

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

  @override
  String get billing_title => 'Subscription & Billing';

  @override
  String get plan_free => 'Free';

  @override
  String get plan_basic => 'Basic';

  @override
  String get plan_pro => 'Pro';

  @override
  String get plan_plus => 'Plus';

  @override
  String billing_current_plan(String plan) {
    return 'Current plan: $plan';
  }

  @override
  String get section_plan_notes => 'Plan notes';

  @override
  String get section_payment_invoice =>
      'Payment and receipts (via Google Play)';

  @override
  String get section_terms => 'Terms (demo)';

  @override
  String get upgrade_card_title => 'Upgrade storage, collect freely';

  @override
  String get upgrade_card_desc =>
      'Paid plans will unlock local uploads, larger storage, and multi-device sync.';

  @override
  String get badge_coming_soon => 'Coming soon';

  @override
  String get feature_external_images =>
      '5 GB cloud storage (multi-device sync)';

  @override
  String get feature_small_cloud_space =>
      'Card categorization, card back info, mini-card details';

  @override
  String get feature_ad_free => 'Ad-free immersive experience';

  @override
  String get feature_upload_local_images =>
      '10 GB cloud storage (multi-device sync)';

  @override
  String get feature_priority_support =>
      'Card categorization, card back info, mini-card details';

  @override
  String get feature_large_storage => '50 GB cloud storage (multi-device sync)';

  @override
  String get feature_album_report =>
      'Card categorization, card back info, mini-card details';

  @override
  String get feature_roadmap_advance => 'Advanced features (coming soon)';

  @override
  String get plan_badge_recommended => 'Recommended';

  @override
  String price_per_month(Object price) {
    return '$price/mo';
  }

  @override
  String get upgrade_now => 'Upgrade now';

  @override
  String get manage_plan => 'Manage plan';

  @override
  String get coming_soon_title => 'Not available yet';

  @override
  String get coming_soon_body =>
      'Local cloud storage is being prepared for launch. This is a placeholder. The official release will include local uploads, larger capacity, and multi-device sync. Stay tuned!';

  @override
  String get coming_soon_ok => 'OK';

  @override
  String get bullet_free_external => 'Free plan: external images (URLs) only';

  @override
  String get bullet_paid_local_upload =>
      'Paid plans: upload local images to cloud with larger storage';

  @override
  String get bullet_future_tiers =>
      'More storage tiers will be available later';

  @override
  String get bullet_pay_cards =>
      'Only Google Play Billing subscriptions are supported';

  @override
  String get bullet_einvoice =>
      'Receipts/invoices are issued by Google Play; corporate tax IDs are not supported';

  @override
  String get bullet_cancel_anytime => 'Cancel anytime; no renewal next cycle';

  @override
  String get bullet_terms =>
      'Terms of Service, Privacy Policy, Refund Policy (links to be added)';

  @override
  String get bullet_abuse => 'Abusive/illegal uploads may lead to suspension';

  @override
  String get common_ok => 'OK';

  @override
  String get common_okDescription => 'Generic OK/confirm button label.';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_cancelDescription => 'Generic cancel button label.';

  @override
  String get tutorial_title => 'Tutorial';

  @override
  String get tutorial_tab_cards => 'Cards';

  @override
  String get tutorial_tab_social => 'Social';

  @override
  String get tutorial_tab_explore => 'Explore';

  @override
  String get tutorial_tab_more => 'More';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => 'Add artist card';

  @override
  String get tutorial_cards_tags_addMini => 'Add mini card';

  @override
  String get tutorial_cards_tags_editDelete => 'Edit / Delete';

  @override
  String get tutorial_cards_tags_info => 'Mini card info';

  @override
  String get tutorial_cards_addArtist_title => 'Add “Artist Card”';

  @override
  String get tutorial_cards_addArtist_s1 =>
      'Tap “＋ Add artist card” at the bottom-right of the Cards page.';

  @override
  String get tutorial_cards_addArtist_s2 =>
      'Choose a local image or paste an online image URL.';

  @override
  String get tutorial_cards_addArtist_s3 =>
      'Swipe right to edit artist info; swipe left to delete the artist card.';

  @override
  String get tutorial_cards_addMini_title => 'Add “Mini Card”';

  @override
  String get tutorial_cards_addMini_s1 =>
      'Tap any “artist card” to enter its detail.';

  @override
  String get tutorial_cards_addMini_s2 =>
      'Tap the mini-card area or swipe up → enter mini-card viewer.';

  @override
  String get tutorial_cards_addMini_s3 =>
      'The leftmost/rightmost pages let you scan QR or open editor to add.';

  @override
  String get tutorial_cards_addMini_s4 =>
      'Tap the “＋” on the editor to add; the same page supports delete.';

  @override
  String get tutorial_cards_info_title => 'Manage “Mini Card Info”';

  @override
  String get tutorial_cards_info_s1 =>
      'After adding, the mini card appears in the viewer; tap to flip.';

  @override
  String get tutorial_cards_info_s2 =>
      'On the back → “Info” to edit: name, serial, album, type, notes, tags.';

  @override
  String get tutorial_cards_info_s3 =>
      'With tags, you can filter faster and search more precisely.';

  @override
  String get tutorial_cards_note_json =>
      'Tip: The mini-card viewer (top-right) supports JSON download and batch import.';

  @override
  String get tutorial_social_tags_primary => 'Friends / Hot / Following';

  @override
  String get tutorial_social_tags_postComment => 'Post & comment';

  @override
  String get tutorial_social_tags_lists => 'List management';

  @override
  String get tutorial_social_browse_title => 'Browse posts';

  @override
  String get tutorial_social_browse_s1 =>
      'Switch tabs on top: “Friends”, “Hot”, “Following”.';

  @override
  String get tutorial_social_browse_s2 =>
      'All tabs support browsing, liking, and commenting.';

  @override
  String get tutorial_social_post_title => 'Post & comment';

  @override
  String get tutorial_social_post_s1 =>
      'Use the bottom-right “pencil” to post.';

  @override
  String get tutorial_social_post_s2 =>
      'Your post appears in “Hot” and “Friends” (friends can interact).';

  @override
  String get tutorial_social_list_title => 'Manage lists';

  @override
  String get tutorial_social_list_s1 => 'Top-right “#”: edit friends list.';

  @override
  String get tutorial_social_list_s2 =>
      'Top-right “card”: edit following list.';

  @override
  String get tutorial_explore_wall_title => 'Create idol wallpapers';

  @override
  String get tutorial_explore_wall_s1 =>
      'Place photos, slogans, stickers to craft your style.';

  @override
  String get tutorial_explore_wall_s2 =>
      'Add a “Birthday countdown” widget for support projects.';

  @override
  String get tutorial_more_settings_title => 'Settings & User';

  @override
  String get tutorial_more_settings_s1 =>
      '“Settings”: theme, language, notification preferences.';

  @override
  String get tutorial_more_settings_s2 =>
      '“User settings”: nickname, avatar, sign-in methods.';

  @override
  String get tutorial_more_stats_title => 'Statistics';

  @override
  String get tutorial_more_stats_s1 =>
      'See collected artists, mini-card count, and source (local / online).';

  @override
  String get tutorial_more_stats_s2 =>
      'Leaderboards and achievements record your collection journey.';

  @override
  String get tutorial_more_dex_title => 'Dex';

  @override
  String get tutorial_more_dex_s1 =>
      'Quickly overview all cards; supports search and filters.';

  @override
  String get tutorial_faq_q1 => 'How to quickly add many mini cards?';

  @override
  String get tutorial_faq_a1 =>
      'In the mini card view page, there are two buttons at the top right. The left button supports batch importing JSON files, and the right button allows you to download the JSON file for this artist’s cards.';

  @override
  String get tutorial_faq_q2 => 'Where to import QR / JSON?';

  @override
  String get tutorial_faq_a2 =>
      'The leftmost/rightmost entry in the mini-card viewer, or “More” menu → “Import”.';

  @override
  String get tutorial_faq_q3 => 'What are tags for?';

  @override
  String get tutorial_faq_a3 =>
      'Tags help quick filtering in the mini-card viewer; search becomes more precise.';

  @override
  String get tutorial_faq_q4 => 'How to change language & theme?';

  @override
  String get tutorial_faq_a4 =>
      'Go to “More → Settings” to switch app language and light/dark theme.';

  @override
  String get tutorial_faq_q5 => 'Where do social posts appear?';

  @override
  String get tutorial_faq_a5 =>
      'Your posts appear in “Hot” and “Friends”; friends can see and interact.';

  @override
  String get postHintShareSomething => 'Share something…';

  @override
  String get postAlbum => 'Album';

  @override
  String get postPublish => 'Post';

  @override
  String get postTags => 'Tags';

  @override
  String get postAddTagHint => 'Add a tag and press Enter';

  @override
  String get postAdd => 'Add';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return 'Tag limit $max';
  }

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get filter => 'Filter';

  @override
  String get filterPanelTitle => 'Filter cards';

  @override
  String get filterClear => 'Clear';

  @override
  String get filterSearchHint => 'Search name, note, serial…';

  @override
  String get extraInfoSectionTitle => 'More details';

  @override
  String get fieldStageNameLabel => 'Stage name / nickname';

  @override
  String get fieldGroupLabel => 'Group / series';

  @override
  String get fieldOriginLabel => 'Card source';

  @override
  String get fieldNoteLabel => 'Notes';

  @override
  String get profileSectionTitle => 'Profile';

  @override
  String get noQuotePlaceholder => 'No quote yet';

  @override
  String cardNameAlreadyExists(Object name) {
    return 'A card named \"$name\" already exists. Please use another name.';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return 'Are you sure you want to delete \"$name\"? All mini cards under this person will also be removed.';
  }

  @override
  String get socialProfileTitle => 'Profile';

  @override
  String get userProfileLongPressHint => 'Long-press to edit your profile';

  @override
  String get scanFriendQrTitle => 'Scan name card QR to add friend';

  @override
  String get scanFriendQrButtonLabel => 'Scan card to add friend';

  @override
  String get filterAlbumNone => 'No album';

  @override
  String get albumCollectionTitle => 'Album collection';

  @override
  String get albumCollectionEmptyHint =>
      'You don\'t have any albums yet. Start by adding your favorite one.';

  @override
  String get albumSwipeEdit => 'Edit';

  @override
  String get albumSwipeDelete => 'Delete';

  @override
  String get albumDialogAddTitle => 'Add album';

  @override
  String get albumDialogEditTitle => 'Edit album';

  @override
  String get albumDialogFieldTitle => 'Album title';

  @override
  String get albumDialogFieldArtist => 'Artist / group';

  @override
  String get albumDialogFieldYear => 'Year (optional)';

  @override
  String get albumDialogFieldCover => 'Cover image URL (optional)';

  @override
  String get albumDialogFieldYoutube => 'YouTube link (optional)';

  @override
  String get albumDialogFieldYtmusic => 'YT Music link (optional)';

  @override
  String get albumDialogFieldSpotify => 'Spotify link (optional)';

  @override
  String get albumDialogAddConfirm => 'Add';

  @override
  String get albumDialogEditConfirm => 'Save';

  @override
  String get albumDeleteConfirmTitle => 'Delete album';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return 'Release year: $year';
  }

  @override
  String get albumDetailNoStreaming => 'No streaming links set yet.';

  @override
  String get albumDetailHint =>
      'You can later add the track list, your comments, or reasons for recommendation here.';

  @override
  String get albumTracksSectionTitle => 'Tracks';

  @override
  String get albumNoTracksHint =>
      'No tracks have been added to this album yet.';

  @override
  String get albumFieldLanguage => 'Language';

  @override
  String get albumFieldVersion => 'Version / Edition';

  @override
  String get albumCoverFromUrlLabel => 'From URL';

  @override
  String get albumCoverFromLocalLabel => 'From local image';

  @override
  String get albumFieldArtistsLabel => 'Artists';

  @override
  String get albumFieldArtistsInputHint =>
      'Type an artist name and press Enter to add…';

  @override
  String get albumArtistsSuggestionHint =>
      'Suggestions will appear while you type.';

  @override
  String get albumLinksSectionTitle => 'Streaming links';

  @override
  String get albumLinksCollapsedHint => 'YouTube / YT Music / Spotify…';

  @override
  String get albumAddTrackButtonLabel => 'Add track';

  @override
  String get albumTrackDialogAddTitle => 'Add track';

  @override
  String get albumTrackDialogEditTitle => 'Edit track';

  @override
  String get albumTrackFieldTitle => 'Track title';

  @override
  String get albumTitleRequiredMessage => 'Please enter an album title.';

  @override
  String get albumCoverLocalRequiredMessage =>
      'Please choose a local cover image.';

  @override
  String albumDetailLanguage(String lang) {
    return 'Language: $lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return 'Version: $ver';
  }

  @override
  String get albumTrackImageLabel => 'Track image (optional)';

  @override
  String get albumTrackClearImageTooltip => 'Clear image';

  @override
  String get albumTrackImageUseAlbumHint =>
      'If no image is set, this track will use the album cover.';

  @override
  String get albumImportJsonTitle => 'Import album JSON';

  @override
  String get albumImportJsonHint =>
      'Paste the album JSON here. You can paste a single album object or a list of albums.';

  @override
  String get albumImportSuccess => 'Albums imported successfully.';

  @override
  String albumImportFailed(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get albumAddNewAlbum => 'Add Album';

  @override
  String get chatHint => 'Type a message…';

  @override
  String get socialNewConversation => 'New Conversation';

  @override
  String get socialMembersHint => 'Add members…';

  @override
  String get socialConversationNameOptional => 'Conversation name (optional)';

  @override
  String get socialMessagesTitle => 'Messages';

  @override
  String get syncMenuTitle => 'Sync & Download';

  @override
  String get syncMenuSubtitle =>
      'Back up your cards and albums to the cloud, or download them back to this device.';

  @override
  String get syncPageTitle => 'Sync & Download';

  @override
  String get syncPageDesc =>
      'You can manually upload the cards and albums on this device as a cloud file, or download it from the cloud to overwrite local data. We recommend uploading before changing devices or reinstalling the app.';

  @override
  String get syncUploadButton => 'Upload to Cloud';

  @override
  String get syncDownloadButton => 'Download from Cloud';

  @override
  String get syncCopyButton => 'Copy File Content';

  @override
  String get syncRefreshPreview => 'Reload Preview';

  @override
  String get syncPreviewTitle => 'Cloud Data Preview';

  @override
  String get syncPreviewSubtitle =>
      'Below is the content of the library file currently stored in the cloud (JSON).';

  @override
  String get syncPreviewEmptyHint =>
      'No cloud file found. Try uploading first.';

  @override
  String get syncNoRemoteData =>
      'No cloud library file found. Please upload from this device first.';

  @override
  String get syncUploadSuccess => 'Upload and sync completed.';

  @override
  String syncUploadFailed(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get syncDownloadSuccess =>
      'Downloaded from cloud and applied to local data.';

  @override
  String get syncDownloadFailedGeneric =>
      'Failed to download or apply from the cloud. Please try again later.';

  @override
  String get syncCopyNoData =>
      'No data to copy. Please load the cloud file first.';

  @override
  String get syncCopySuccess => 'Cloud file content copied to clipboard.';

  @override
  String get syncPaidOnlyHint =>
      'Cloud sync and download are available only for paid plans. After subscribing, you can back up, download, and copy the full library file.';

  @override
  String get syncNeedSubTitle => 'Subscription Required';

  @override
  String get syncNeedSubBody =>
      'Cloud sync and download are only available for paid plans. Please go to the subscription page and select Basic / Plus / Pro before trying again.';

  @override
  String get syncGoToSubscription => 'Go to Subscription';

  @override
  String get dialogCancel => 'Cancel';
}
