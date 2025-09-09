import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInWithGoogle;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @noNetworkGuestTip.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. You can continue as a guest.'**
  String get noNetworkGuestTip;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MyApp Demo'**
  String get appTitle;

  /// No description provided for @navCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get navCards;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageZhTW.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageZhTW;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJa;

  /// No description provided for @languageKo.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKo;

  /// No description provided for @languageDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageDe;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @developerRole.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developerRole;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @quoteTitle.
  ///
  /// In en, this message translates to:
  /// **'A message to fans'**
  String get quoteTitle;

  /// No description provided for @fanMiniCards.
  ///
  /// In en, this message translates to:
  /// **'Fan mini cards'**
  String get fanMiniCards;

  /// No description provided for @noMiniCardsHint.
  ///
  /// In en, this message translates to:
  /// **'No mini cards yet. Tap \"Edit\" to add.'**
  String get noMiniCardsHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editMiniCards.
  ///
  /// In en, this message translates to:
  /// **'Edit mini cards'**
  String get editMiniCards;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @previewFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed'**
  String get previewFailed;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @favorited.
  ///
  /// In en, this message translates to:
  /// **'Favorited'**
  String get favorited;

  /// No description provided for @accountStatusGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest mode'**
  String get accountStatusGuest;

  /// No description provided for @accountStatusSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get accountStatusSignedIn;

  /// No description provided for @accountStatusSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get accountStatusSignedOut;

  /// No description provided for @accountGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Using guest mode; data is stored only on this device'**
  String get accountGuestSubtitle;

  /// No description provided for @accountNoInfo.
  ///
  /// In en, this message translates to:
  /// **'(No account info)'**
  String get accountNoInfo;

  /// No description provided for @accountBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to sign-in'**
  String get accountBackToLogin;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @helloDeveloperTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m the developer'**
  String get helloDeveloperTitle;

  /// No description provided for @helloDeveloperBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks for giving this little side project a try. I’m a big fan of LE SSERAFIM (FEARNOT here!), but I don’t want to carry a whole stack of photocards every time I share the joy with friends. That’s why I built this app—so fans can show and trade cards right from a 6.5\" screen. I’ll keep maintaining it and the code will stay open on GitHub. Thanks again for downloading and being part of this project (or, to say it cutely, the family). If you have questions or ideas to improve it, don’t hesitate to contact me. — Jimmy Lee'**
  String get helloDeveloperBody;

  /// No description provided for @stats_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats_title;

  /// No description provided for @stats_overview.
  ///
  /// In en, this message translates to:
  /// **'Collection Overview'**
  String get stats_overview;

  /// No description provided for @stats_artist_count.
  ///
  /// In en, this message translates to:
  /// **'Number of artists'**
  String get stats_artist_count;

  /// No description provided for @stats_card_total.
  ///
  /// In en, this message translates to:
  /// **'Total mini cards'**
  String get stats_card_total;

  /// No description provided for @stats_front_source.
  ///
  /// In en, this message translates to:
  /// **'Front image source'**
  String get stats_front_source;

  /// No description provided for @stats_cards_per_artist_topN.
  ///
  /// In en, this message translates to:
  /// **'Mini cards per artist (Top {n})'**
  String stats_cards_per_artist_topN(int n);

  /// No description provided for @stats_nav_subtitle.
  ///
  /// In en, this message translates to:
  /// **'See collection stats: totals, sources, top artists'**
  String get stats_nav_subtitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mini Cards'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account to sync settings and data'**
  String get welcomeSubtitle;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueAsGuest;

  /// No description provided for @authAccount.
  ///
  /// In en, this message translates to:
  /// **'Account (Email / any string)'**
  String get authAccount;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authCreateAndSignIn.
  ///
  /// In en, this message translates to:
  /// **'Create account and sign in'**
  String get authCreateAndSignIn;

  /// No description provided for @authName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authName;

  /// No description provided for @authGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get authGender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other/Prefer not to say'**
  String get genderOther;

  /// No description provided for @birthdayPick.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get birthdayPick;

  /// No description provided for @birthdayNotChosen.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get birthdayNotChosen;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get errorLoginFailed;

  /// No description provided for @errorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Register failed'**
  String get errorRegisterFailed;

  /// No description provided for @errorPickBirthday.
  ///
  /// In en, this message translates to:
  /// **'Please select your birthday'**
  String get errorPickBirthday;

  /// No description provided for @common_local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get common_local;

  /// No description provided for @common_url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get common_url;

  /// No description provided for @common_unnamed.
  ///
  /// In en, this message translates to:
  /// **'(Unnamed)'**
  String get common_unnamed;

  /// No description provided for @common_unit_cards.
  ///
  /// In en, this message translates to:
  /// **'cards'**
  String get common_unit_cards;

  /// No description provided for @nameWithPinyin.
  ///
  /// In en, this message translates to:
  /// **'{name} ({pinyin})'**
  String nameWithPinyin(Object name, Object pinyin);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This will also be removed from all cards.'**
  String deleteCategoryMessage(Object name);

  /// No description provided for @deletedCategoryToast.
  ///
  /// In en, this message translates to:
  /// **'Deleted category: {name}'**
  String deletedCategoryToast(Object name);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name / card text'**
  String get searchHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get noCards;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addCard;

  /// No description provided for @deleteCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCardTitle;

  /// No description provided for @deleteCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{title}”?'**
  String deleteCardMessage(Object title);

  /// No description provided for @deletedCardToast.
  ///
  /// In en, this message translates to:
  /// **'Deleted: {title}'**
  String deletedCardToast(Object title);

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCard;

  /// No description provided for @categoryAssignOrAdd.
  ///
  /// In en, this message translates to:
  /// **'Assign / add categories'**
  String get categoryAssignOrAdd;

  /// No description provided for @newCardTitle.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get newCardTitle;

  /// No description provided for @editCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editCardTitle;

  /// No description provided for @nameRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (required)'**
  String get nameRequiredLabel;

  /// No description provided for @imageByUrl.
  ///
  /// In en, this message translates to:
  /// **'By URL'**
  String get imageByUrl;

  /// No description provided for @imageByLocal.
  ///
  /// In en, this message translates to:
  /// **'Local photo'**
  String get imageByLocal;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get pickFromGallery;

  /// No description provided for @quoteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote (optional)'**
  String get quoteOptionalLabel;

  /// No description provided for @pickBirthdayOptional.
  ///
  /// In en, this message translates to:
  /// **'Pick birthday (optional)'**
  String get pickBirthdayOptional;

  /// No description provided for @inputImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter image URL'**
  String get inputImageUrl;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @pickLocalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please choose a local photo'**
  String get pickLocalPhoto;

  /// No description provided for @updatedCardToast.
  ///
  /// In en, this message translates to:
  /// **'Card updated'**
  String get updatedCardToast;

  /// No description provided for @manageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategoriesTitle;

  /// No description provided for @newCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get newCategoryNameHint;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @deleteCategoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTooltip;

  /// No description provided for @assignCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign categories'**
  String get assignCategoryTitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDeleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This category will be removed from all cards.'**
  String confirmDeleteCategoryMessage(Object name);

  /// No description provided for @addedCategoryToast.
  ///
  /// In en, this message translates to:
  /// **'Added category: {name}'**
  String addedCategoryToast(Object name);

  /// No description provided for @noMiniCardsPreviewHint.
  ///
  /// In en, this message translates to:
  /// **'No mini cards yet. Tap here or swipe up to add.'**
  String get noMiniCardsPreviewHint;

  /// No description provided for @detailSwipeHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up to open mini-cards (scan/share QR inside)'**
  String get detailSwipeHint;

  /// No description provided for @noMiniCardsEmptyList.
  ///
  /// In en, this message translates to:
  /// **'No mini cards yet. Tap + to add.'**
  String get noMiniCardsEmptyList;

  /// No description provided for @miniLocalImageBadge.
  ///
  /// In en, this message translates to:
  /// **'Local image'**
  String get miniLocalImageBadge;

  /// No description provided for @miniHasBackBadge.
  ///
  /// In en, this message translates to:
  /// **'Has back image'**
  String get miniHasBackBadge;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @tagsCount.
  ///
  /// In en, this message translates to:
  /// **'Tags {n}'**
  String tagsCount(int n);

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial number'**
  String get serialNumber;

  /// No description provided for @album.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @addAlbum.
  ///
  /// In en, this message translates to:
  /// **'Add album'**
  String get addAlbum;

  /// No description provided for @enterAlbumName.
  ///
  /// In en, this message translates to:
  /// **'Enter album name'**
  String get enterAlbumName;

  /// No description provided for @cardType.
  ///
  /// In en, this message translates to:
  /// **'Card type'**
  String get cardType;

  /// No description provided for @addCardType.
  ///
  /// In en, this message translates to:
  /// **'Add card type'**
  String get addCardType;

  /// No description provided for @enterCardTypeName.
  ///
  /// In en, this message translates to:
  /// **'Enter card type name'**
  String get enterCardTypeName;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @newTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag…'**
  String get newTagHint;

  /// No description provided for @frontSide.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get frontSide;

  /// No description provided for @backSide.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backSide;

  /// No description provided for @frontImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Front image'**
  String get frontImageTitle;

  /// No description provided for @backImageTitleOptional.
  ///
  /// In en, this message translates to:
  /// **'Back image (optional)'**
  String get backImageTitleOptional;

  /// No description provided for @frontImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Front image URL'**
  String get frontImageUrlLabel;

  /// No description provided for @backImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Back image URL'**
  String get backImageUrlLabel;

  /// No description provided for @clearUrl.
  ///
  /// In en, this message translates to:
  /// **'Clear URL'**
  String get clearUrl;

  /// No description provided for @clearLocal.
  ///
  /// In en, this message translates to:
  /// **'Clear local'**
  String get clearLocal;

  /// No description provided for @clearBackImage.
  ///
  /// In en, this message translates to:
  /// **'Clear back image'**
  String get clearBackImage;

  /// No description provided for @localPickedLabel.
  ///
  /// In en, this message translates to:
  /// **'Picked: Local'**
  String get localPickedLabel;

  /// No description provided for @miniCardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit mini card'**
  String get miniCardEditTitle;

  /// No description provided for @miniCardNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New mini card'**
  String get miniCardNewTitle;

  /// No description provided for @errorFrontImageUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the front image URL or switch to Local.'**
  String get errorFrontImageUrlRequired;

  /// No description provided for @errorFrontLocalRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a local front photo or switch to URL.'**
  String get errorFrontLocalRequired;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get userProfileTitle;

  /// No description provided for @userProfileTile.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get userProfileTile;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Nickname is required'**
  String get nicknameRequired;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @clearBirthday.
  ///
  /// In en, this message translates to:
  /// **'Clear birthday'**
  String get clearBirthday;

  /// No description provided for @userProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get userProfileSaved;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'All set'**
  String get ready;

  /// No description provided for @fillNicknameAndBirthday.
  ///
  /// In en, this message translates to:
  /// **'Please fill in nickname and birthday'**
  String get fillNicknameAndBirthday;

  /// No description provided for @navSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get navSocial;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} min ago'**
  String timeMinutesAgo(int n);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} hr ago'**
  String timeHoursAgo(int n);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n} day(s) ago'**
  String timeDaysAgo(int n);

  /// No description provided for @socialFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get socialFriends;

  /// No description provided for @socialHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get socialHot;

  /// No description provided for @socialFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get socialFollowing;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @socialShareHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get socialShareHint;

  /// No description provided for @leaveACommentHint.
  ///
  /// In en, this message translates to:
  /// **'Leave a comment…'**
  String get leaveACommentHint;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments ({n})'**
  String commentsCount(int n);

  /// No description provided for @addTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag…'**
  String get addTagHint;

  /// No description provided for @followedTag.
  ///
  /// In en, this message translates to:
  /// **'Followed #{tag}'**
  String followedTag(Object tag);

  /// No description provided for @unfollowedTag.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed #{tag}'**
  String unfollowedTag(Object tag);

  /// No description provided for @friendCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Friend cards'**
  String get friendCardsTitle;

  /// No description provided for @addFriendCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get addFriendCard;

  /// No description provided for @editFriendCard.
  ///
  /// In en, this message translates to:
  /// **'Edit card'**
  String get editFriendCard;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQr;

  /// No description provided for @tapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get tapToFlip;

  /// No description provided for @deleteFriendCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteFriendCardTitle;

  /// No description provided for @deleteFriendCardMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String deleteFriendCardMessage(Object name);

  /// No description provided for @followArtistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Followed artists'**
  String get followArtistsLabel;

  /// Shown when the user tries to add more than the allowed tags.
  ///
  /// In en, this message translates to:
  /// **'Limit reached ({text})'**
  String limitReached(String text);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
