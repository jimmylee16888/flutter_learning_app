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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('zh', 'TW'),
    Locale('ja'),
    Locale('ko'),
    Locale('de'),
    Locale('zh'),
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
  /// **'Pop Card'**
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
  /// **'Thank you for trying out this little side project 💫 \n\nI’m a proud FEARNOT (LE SSERAFIM fan)! Every time I want to share the joy of collecting photocards with friends, I hate having to carry a whole stack around — so I made this app 💡. Now you can easily show and trade your cards with just a 6.5-inch phone.\n\nI’ll keep updating and improving this tiny project, and I’m truly grateful that you downloaded it and became part of it (or, cutely put, part of the family 🩷). If you have any ideas or feedback, feel free to reach out anytime! 💪'**
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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline: some features are unavailable'**
  String get offlineBanner;

  /// No description provided for @manageFollowedTags.
  ///
  /// In en, this message translates to:
  /// **'Followed tags'**
  String get manageFollowedTags;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @friendAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add friend'**
  String get friendAddAction;

  /// No description provided for @friendRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove friend'**
  String get friendRemoveAction;

  /// No description provided for @friendAddedStatus.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get friendAddedStatus;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @socialLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Social links'**
  String get socialLinksTitle;

  /// No description provided for @showInstagramOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show Instagram on profile'**
  String get showInstagramOnProfile;

  /// No description provided for @showFacebookOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show Facebook on profile'**
  String get showFacebookOnProfile;

  /// No description provided for @showLineOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Show Line on profile'**
  String get showLineOnProfile;

  /// No description provided for @followedTagsCount.
  ///
  /// In en, this message translates to:
  /// **'Followed tags ({n})'**
  String followedTagsCount(int n);

  /// No description provided for @addFollowedTag.
  ///
  /// In en, this message translates to:
  /// **'Add followed tag'**
  String get addFollowedTag;

  /// No description provided for @addFollowedTagHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a tag name, then press Enter'**
  String get addFollowedTagHint;

  /// No description provided for @manageCards.
  ///
  /// In en, this message translates to:
  /// **'Manage cards'**
  String get manageCards;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @lineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get lineLabel;

  /// No description provided for @facebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebookLabel;

  /// No description provided for @instagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// Hint text in the friend cards search bar
  ///
  /// In en, this message translates to:
  /// **'Search friends or artists'**
  String get searchFriendsOrArtistsHint;

  /// No description provided for @followedTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Followed tags'**
  String get followedTagsTitle;

  /// No description provided for @noFollowedTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No followed tags yet'**
  String get noFollowedTagsYet;

  /// No description provided for @addedFollowedTagToast.
  ///
  /// In en, this message translates to:
  /// **'Added followed tag'**
  String get addedFollowedTagToast;

  /// No description provided for @addFollowedTagFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add tag: {error}'**
  String addFollowedTagFailed(Object error);

  /// No description provided for @removedFollowedTagToast.
  ///
  /// In en, this message translates to:
  /// **'Removed followed tag'**
  String get removedFollowedTagToast;

  /// No description provided for @removeFollowedTagFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove tag: {error}'**
  String removeFollowedTagFailed(Object error);

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: {error}'**
  String loadFailed(Object error);

  /// No description provided for @miniCardsOf.
  ///
  /// In en, this message translates to:
  /// **'{title}\'s mini cards'**
  String miniCardsOf(Object title);

  /// No description provided for @importFromJsonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import from JSON'**
  String get importFromJsonTooltip;

  /// No description provided for @exportJsonMultiTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export JSON (multiple)'**
  String get exportJsonMultiTooltip;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareThisCard.
  ///
  /// In en, this message translates to:
  /// **'Share this card'**
  String get shareThisCard;

  /// No description provided for @importedMiniCardsToast.
  ///
  /// In en, this message translates to:
  /// **'Imported {n} mini card(s)'**
  String importedMiniCardsToast(int n);

  /// No description provided for @shareMultipleCards.
  ///
  /// In en, this message translates to:
  /// **'Share multiple cards (multi-select)'**
  String get shareMultipleCards;

  /// No description provided for @shareMultipleCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select cards, then share photos or export JSON'**
  String get shareMultipleCardsSubtitle;

  /// No description provided for @shareOneCard.
  ///
  /// In en, this message translates to:
  /// **'Pick one to share…'**
  String get shareOneCard;

  /// No description provided for @selectCardsForJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cards to share (JSON)'**
  String get selectCardsForJsonTitle;

  /// No description provided for @selectCardsForShareOrExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cards to share / export'**
  String get selectCardsForShareOrExportTitle;

  /// No description provided for @blockedLocalImageNote.
  ///
  /// In en, this message translates to:
  /// **'Contains local image; cannot export to JSON'**
  String get blockedLocalImageNote;

  /// No description provided for @shareMultiplePhotos.
  ///
  /// In en, this message translates to:
  /// **'Share {n} photos'**
  String shareMultiplePhotos(int n);

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @exportJsonSkipLocalHint.
  ///
  /// In en, this message translates to:
  /// **'Cards with local-only images will be skipped'**
  String get exportJsonSkipLocalHint;

  /// No description provided for @triedShareSummary.
  ///
  /// In en, this message translates to:
  /// **'Tried to share {total}, success {ok} / failed {fail}'**
  String triedShareSummary(int total, int ok, int fail);

  /// No description provided for @shareQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share QR code'**
  String get shareQrCode;

  /// No description provided for @shareQrAutoBackendHint.
  ///
  /// In en, this message translates to:
  /// **'Large payloads switch to backend mode automatically'**
  String get shareQrAutoBackendHint;

  /// No description provided for @cannotShareByQr.
  ///
  /// In en, this message translates to:
  /// **'Cannot share via QR'**
  String get cannotShareByQr;

  /// No description provided for @noImageUrl.
  ///
  /// In en, this message translates to:
  /// **'No image URL'**
  String get noImageUrl;

  /// No description provided for @noImageUrlPhotoOnly.
  ///
  /// In en, this message translates to:
  /// **'No image URL; can only share the photo directly'**
  String get noImageUrlPhotoOnly;

  /// No description provided for @shareThisPhoto.
  ///
  /// In en, this message translates to:
  /// **'Share this photo'**
  String get shareThisPhoto;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(Object error);

  /// No description provided for @transportBackendHint.
  ///
  /// In en, this message translates to:
  /// **'Backend mode (via API)'**
  String get transportBackendHint;

  /// No description provided for @transportEmbeddedHint.
  ///
  /// In en, this message translates to:
  /// **'Embedded (local)'**
  String get transportEmbeddedHint;

  /// No description provided for @qrIdOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'This QR contains only the card ID. The receiver will fetch full content from backend.'**
  String get qrIdOnlyNotice;

  /// No description provided for @qrGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate QR image'**
  String get qrGenerationFailed;

  /// No description provided for @pasteJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON text'**
  String get pasteJsonTitle;

  /// No description provided for @pasteJsonHint.
  ///
  /// In en, this message translates to:
  /// **'Supports mini_card_bundle_v2/v1 or mini_card_v2/v1'**
  String get pasteJsonHint;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importedFromJsonToast.
  ///
  /// In en, this message translates to:
  /// **'Imported {n} mini card(s) from JSON'**
  String importedFromJsonToast(int n);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(Object error);

  /// No description provided for @cannotExportJsonAllLocal.
  ///
  /// In en, this message translates to:
  /// **'All selected cards contain local-only images and cannot be exported to JSON'**
  String get cannotExportJsonAllLocal;

  /// No description provided for @skippedLocalImagesCount.
  ///
  /// In en, this message translates to:
  /// **'Skipped {n} card(s) that contain local-only images'**
  String skippedLocalImagesCount(int n);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copiedJsonToast.
  ///
  /// In en, this message translates to:
  /// **'Copied JSON'**
  String get copiedJsonToast;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @selectCardsToShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cards to share'**
  String get selectCardsToShareTitle;

  /// No description provided for @hasImageUrlJsonOk.
  ///
  /// In en, this message translates to:
  /// **'Has image URL; can be sent via JSON'**
  String get hasImageUrlJsonOk;

  /// No description provided for @exportJsonOnlyUrlHint.
  ///
  /// In en, this message translates to:
  /// **'Tip: Exported JSON includes only cards with an image URL; local-only images will be skipped.'**
  String get exportJsonOnlyUrlHint;

  /// No description provided for @sharePhotos.
  ///
  /// In en, this message translates to:
  /// **'Share photos'**
  String get sharePhotos;

  /// No description provided for @containsLocalImages.
  ///
  /// In en, this message translates to:
  /// **'Contains local images'**
  String get containsLocalImages;

  /// No description provided for @containsLocalImagesDetail.
  ///
  /// In en, this message translates to:
  /// **'{blocked} card(s) cannot be exported to JSON. Export only the usable {allowed} card(s)?'**
  String containsLocalImagesDetail(int blocked, int allowed);

  /// No description provided for @onlyExportUsable.
  ///
  /// In en, this message translates to:
  /// **'Export usable only'**
  String get onlyExportUsable;

  /// No description provided for @shareMiniCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Share mini card'**
  String get shareMiniCardTitle;

  /// No description provided for @qrCodeTab.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCodeTab;

  /// No description provided for @qrTooLargeUseJsonHint.
  ///
  /// In en, this message translates to:
  /// **'If the QR code fails to render, the data might be too large. Consider using JSON instead.'**
  String get qrTooLargeUseJsonHint;

  /// No description provided for @scanMiniCardQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan mini card QR'**
  String get scanMiniCardQrTitle;

  /// No description provided for @scanFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Scan from gallery'**
  String get scanFromGallery;

  /// No description provided for @noQrFoundInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR found in the image'**
  String get noQrFoundInImage;

  /// No description provided for @qrFormatInvalid.
  ///
  /// In en, this message translates to:
  /// **'QR format invalid'**
  String get qrFormatInvalid;

  /// No description provided for @qrTypeUnsupported.
  ///
  /// In en, this message translates to:
  /// **'QR type unsupported'**
  String get qrTypeUnsupported;

  /// No description provided for @fetchFromBackendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch from backend: {error}'**
  String fetchFromBackendFailed(Object error);

  /// No description provided for @addFollowedTagFailedOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Tag added locally.'**
  String get addFollowedTagFailedOffline;

  /// No description provided for @removeFollowedTagFailedOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Tag removed locally.'**
  String get removeFollowedTagFailedOffline;

  /// Shown while the login screen is initializing
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Title for dialog when user tries to sign in without network
  ///
  /// In en, this message translates to:
  /// **'Network Required'**
  String get networkRequiredTitle;

  /// Body text for dialog when sign-in attempted offline
  ///
  /// In en, this message translates to:
  /// **'Sign-in requires an internet connection. Please connect and try again.'**
  String get networkRequiredBody;

  /// Generic confirmation button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @willSaveAs.
  ///
  /// In en, this message translates to:
  /// **'Will save as'**
  String get willSaveAs;

  /// No description provided for @alreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Already exists'**
  String get alreadyExists;

  /// About page/menu title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get common_about;

  /// Bottom sheet item: general settings
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get settings_menu_general;

  /// Bottom sheet item: user settings
  ///
  /// In en, this message translates to:
  /// **'User settings'**
  String get settings_menu_user;

  /// Bottom sheet item: about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_menu_about;

  /// Bottom sheet item: general settings
  ///
  /// In en, this message translates to:
  /// **'General settings'**
  String get settingsMenuGeneral;

  /// About page/menu title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get commonAbout;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @exploreReflow.
  ///
  /// In en, this message translates to:
  /// **'Reflow widgets'**
  String get exploreReflow;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @exploreNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo selected'**
  String get exploreNoPhoto;

  /// No description provided for @exploreTapToEditQuote.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit quote'**
  String get exploreTapToEditQuote;

  /// No description provided for @exploreAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get exploreAdd;

  /// No description provided for @exploreAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo card'**
  String get exploreAddPhoto;

  /// No description provided for @exploreAddQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote card'**
  String get exploreAddQuote;

  /// No description provided for @exploreAddBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday countdown'**
  String get exploreAddBirthday;

  /// No description provided for @exploreAddBall.
  ///
  /// In en, this message translates to:
  /// **'Add ball'**
  String get exploreAddBall;

  /// No description provided for @exploreAdBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Ad is built-in'**
  String get exploreAdBuiltIn;

  /// No description provided for @exploreEnterAQuote.
  ///
  /// In en, this message translates to:
  /// **'Enter a quote'**
  String get exploreEnterAQuote;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @exploreCountdownTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Idol/event (e.g. Sakura Birthday)'**
  String get exploreCountdownTitleHint;

  /// No description provided for @exploreAddBallDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add ball'**
  String get exploreAddBallDialogTitle;

  /// No description provided for @exploreBallEmojiHint.
  ///
  /// In en, this message translates to:
  /// **'Emoji (leave empty to use a photo)'**
  String get exploreBallEmojiHint;

  /// No description provided for @exploreSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get exploreSize;

  /// No description provided for @explorePickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick a photo…'**
  String get explorePickPhoto;

  /// No description provided for @explorePickedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo selected'**
  String get explorePickedPhoto;

  /// No description provided for @navDex.
  ///
  /// In en, this message translates to:
  /// **'Dex'**
  String get navDex;

  /// No description provided for @dex_title.
  ///
  /// In en, this message translates to:
  /// **'My Dex'**
  String get dex_title;

  /// No description provided for @dex_uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get dex_uncategorized;

  /// No description provided for @dex_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search idols or cards…'**
  String get dex_searchHint;

  /// No description provided for @dex_cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String dex_cardsCount(Object count);

  /// No description provided for @dex_empty.
  ///
  /// In en, this message translates to:
  /// **'No cards collected yet'**
  String get dex_empty;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @resetZoom.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom'**
  String get resetZoom;

  /// No description provided for @billing_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Billing'**
  String get billing_title;

  /// No description provided for @plan_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get plan_free;

  /// No description provided for @plan_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get plan_basic;

  /// No description provided for @plan_pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get plan_pro;

  /// No description provided for @plan_plus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get plan_plus;

  /// No description provided for @billing_current_plan.
  ///
  /// In en, this message translates to:
  /// **'Current plan: {plan}'**
  String billing_current_plan(String plan);

  /// No description provided for @section_plan_notes.
  ///
  /// In en, this message translates to:
  /// **'Plan notes'**
  String get section_plan_notes;

  /// No description provided for @section_payment_invoice.
  ///
  /// In en, this message translates to:
  /// **'Payment and receipts (via Google Play)'**
  String get section_payment_invoice;

  /// No description provided for @section_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms (demo)'**
  String get section_terms;

  /// No description provided for @upgrade_card_title.
  ///
  /// In en, this message translates to:
  /// **'Upgrade storage, collect freely'**
  String get upgrade_card_title;

  /// No description provided for @upgrade_card_desc.
  ///
  /// In en, this message translates to:
  /// **'Paid plans will unlock local uploads, larger storage, and multi-device sync.'**
  String get upgrade_card_desc;

  /// No description provided for @badge_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get badge_coming_soon;

  /// No description provided for @feature_external_images.
  ///
  /// In en, this message translates to:
  /// **'5 GB cloud storage (multi-device sync)'**
  String get feature_external_images;

  /// No description provided for @feature_small_cloud_space.
  ///
  /// In en, this message translates to:
  /// **'Card categorization, card back info, mini-card details'**
  String get feature_small_cloud_space;

  /// No description provided for @feature_ad_free.
  ///
  /// In en, this message translates to:
  /// **'Ad-free immersive experience'**
  String get feature_ad_free;

  /// No description provided for @feature_upload_local_images.
  ///
  /// In en, this message translates to:
  /// **'10 GB cloud storage (multi-device sync)'**
  String get feature_upload_local_images;

  /// No description provided for @feature_priority_support.
  ///
  /// In en, this message translates to:
  /// **'Card categorization, card back info, mini-card details'**
  String get feature_priority_support;

  /// No description provided for @feature_large_storage.
  ///
  /// In en, this message translates to:
  /// **'50 GB cloud storage (multi-device sync)'**
  String get feature_large_storage;

  /// No description provided for @feature_album_report.
  ///
  /// In en, this message translates to:
  /// **'Card categorization, card back info, mini-card details'**
  String get feature_album_report;

  /// No description provided for @feature_roadmap_advance.
  ///
  /// In en, this message translates to:
  /// **'Advanced features (coming soon)'**
  String get feature_roadmap_advance;

  /// No description provided for @plan_badge_recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get plan_badge_recommended;

  /// No description provided for @price_per_month.
  ///
  /// In en, this message translates to:
  /// **'{price}/mo'**
  String price_per_month(Object price);

  /// No description provided for @upgrade_now.
  ///
  /// In en, this message translates to:
  /// **'Upgrade now'**
  String get upgrade_now;

  /// No description provided for @manage_plan.
  ///
  /// In en, this message translates to:
  /// **'Manage plan'**
  String get manage_plan;

  /// No description provided for @coming_soon_title.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get coming_soon_title;

  /// No description provided for @coming_soon_body.
  ///
  /// In en, this message translates to:
  /// **'Local cloud storage is being prepared for launch. This is a placeholder. The official release will include local uploads, larger capacity, and multi-device sync. Stay tuned!'**
  String get coming_soon_body;

  /// No description provided for @coming_soon_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get coming_soon_ok;

  /// No description provided for @bullet_free_external.
  ///
  /// In en, this message translates to:
  /// **'Free plan: external images (URLs) only'**
  String get bullet_free_external;

  /// No description provided for @bullet_paid_local_upload.
  ///
  /// In en, this message translates to:
  /// **'Paid plans: upload local images to cloud with larger storage'**
  String get bullet_paid_local_upload;

  /// No description provided for @bullet_future_tiers.
  ///
  /// In en, this message translates to:
  /// **'More storage tiers will be available later'**
  String get bullet_future_tiers;

  /// No description provided for @bullet_pay_cards.
  ///
  /// In en, this message translates to:
  /// **'Only Google Play Billing subscriptions are supported'**
  String get bullet_pay_cards;

  /// No description provided for @bullet_einvoice.
  ///
  /// In en, this message translates to:
  /// **'Receipts/invoices are issued by Google Play; corporate tax IDs are not supported'**
  String get bullet_einvoice;

  /// No description provided for @bullet_cancel_anytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime; no renewal next cycle'**
  String get bullet_cancel_anytime;

  /// No description provided for @bullet_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service, Privacy Policy, Refund Policy (links to be added)'**
  String get bullet_terms;

  /// No description provided for @bullet_abuse.
  ///
  /// In en, this message translates to:
  /// **'Abusive/illegal uploads may lead to suspension'**
  String get bullet_abuse;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_okDescription.
  ///
  /// In en, this message translates to:
  /// **'Generic OK/confirm button label.'**
  String get common_okDescription;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_cancelDescription.
  ///
  /// In en, this message translates to:
  /// **'Generic cancel button label.'**
  String get common_cancelDescription;

  /// No description provided for @tutorial_title.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorial_title;

  /// No description provided for @tutorial_tab_cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get tutorial_tab_cards;

  /// No description provided for @tutorial_tab_social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get tutorial_tab_social;

  /// No description provided for @tutorial_tab_explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tutorial_tab_explore;

  /// No description provided for @tutorial_tab_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tutorial_tab_more;

  /// No description provided for @tutorial_tab_faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get tutorial_tab_faq;

  /// No description provided for @tutorial_cards_tags_addArtist.
  ///
  /// In en, this message translates to:
  /// **'Add artist card'**
  String get tutorial_cards_tags_addArtist;

  /// No description provided for @tutorial_cards_tags_addMini.
  ///
  /// In en, this message translates to:
  /// **'Add mini card'**
  String get tutorial_cards_tags_addMini;

  /// No description provided for @tutorial_cards_tags_editDelete.
  ///
  /// In en, this message translates to:
  /// **'Edit / Delete'**
  String get tutorial_cards_tags_editDelete;

  /// No description provided for @tutorial_cards_tags_info.
  ///
  /// In en, this message translates to:
  /// **'Mini card info'**
  String get tutorial_cards_tags_info;

  /// No description provided for @tutorial_cards_addArtist_title.
  ///
  /// In en, this message translates to:
  /// **'Add “Artist Card”'**
  String get tutorial_cards_addArtist_title;

  /// No description provided for @tutorial_cards_addArtist_s1.
  ///
  /// In en, this message translates to:
  /// **'Tap “＋ Add artist card” at the bottom-right of the Cards page.'**
  String get tutorial_cards_addArtist_s1;

  /// No description provided for @tutorial_cards_addArtist_s2.
  ///
  /// In en, this message translates to:
  /// **'Choose a local image or paste an online image URL.'**
  String get tutorial_cards_addArtist_s2;

  /// No description provided for @tutorial_cards_addArtist_s3.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to edit artist info; swipe left to delete the artist card.'**
  String get tutorial_cards_addArtist_s3;

  /// No description provided for @tutorial_cards_addMini_title.
  ///
  /// In en, this message translates to:
  /// **'Add “Mini Card”'**
  String get tutorial_cards_addMini_title;

  /// No description provided for @tutorial_cards_addMini_s1.
  ///
  /// In en, this message translates to:
  /// **'Tap any “artist card” to enter its detail.'**
  String get tutorial_cards_addMini_s1;

  /// No description provided for @tutorial_cards_addMini_s2.
  ///
  /// In en, this message translates to:
  /// **'Tap the mini-card area or swipe up → enter mini-card viewer.'**
  String get tutorial_cards_addMini_s2;

  /// No description provided for @tutorial_cards_addMini_s3.
  ///
  /// In en, this message translates to:
  /// **'The leftmost/rightmost pages let you scan QR or open editor to add.'**
  String get tutorial_cards_addMini_s3;

  /// No description provided for @tutorial_cards_addMini_s4.
  ///
  /// In en, this message translates to:
  /// **'Tap the “＋” on the editor to add; the same page supports delete.'**
  String get tutorial_cards_addMini_s4;

  /// No description provided for @tutorial_cards_info_title.
  ///
  /// In en, this message translates to:
  /// **'Manage “Mini Card Info”'**
  String get tutorial_cards_info_title;

  /// No description provided for @tutorial_cards_info_s1.
  ///
  /// In en, this message translates to:
  /// **'After adding, the mini card appears in the viewer; tap to flip.'**
  String get tutorial_cards_info_s1;

  /// No description provided for @tutorial_cards_info_s2.
  ///
  /// In en, this message translates to:
  /// **'On the back → “Info” to edit: name, serial, album, type, notes, tags.'**
  String get tutorial_cards_info_s2;

  /// No description provided for @tutorial_cards_info_s3.
  ///
  /// In en, this message translates to:
  /// **'With tags, you can filter faster and search more precisely.'**
  String get tutorial_cards_info_s3;

  /// No description provided for @tutorial_cards_note_json.
  ///
  /// In en, this message translates to:
  /// **'Tip: The mini-card viewer (top-right) supports JSON download and batch import.'**
  String get tutorial_cards_note_json;

  /// No description provided for @tutorial_social_tags_primary.
  ///
  /// In en, this message translates to:
  /// **'Friends / Hot / Following'**
  String get tutorial_social_tags_primary;

  /// No description provided for @tutorial_social_tags_postComment.
  ///
  /// In en, this message translates to:
  /// **'Post & comment'**
  String get tutorial_social_tags_postComment;

  /// No description provided for @tutorial_social_tags_lists.
  ///
  /// In en, this message translates to:
  /// **'List management'**
  String get tutorial_social_tags_lists;

  /// No description provided for @tutorial_social_browse_title.
  ///
  /// In en, this message translates to:
  /// **'Browse posts'**
  String get tutorial_social_browse_title;

  /// No description provided for @tutorial_social_browse_s1.
  ///
  /// In en, this message translates to:
  /// **'Switch tabs on top: “Friends”, “Hot”, “Following”.'**
  String get tutorial_social_browse_s1;

  /// No description provided for @tutorial_social_browse_s2.
  ///
  /// In en, this message translates to:
  /// **'All tabs support browsing, liking, and commenting.'**
  String get tutorial_social_browse_s2;

  /// No description provided for @tutorial_social_post_title.
  ///
  /// In en, this message translates to:
  /// **'Post & comment'**
  String get tutorial_social_post_title;

  /// No description provided for @tutorial_social_post_s1.
  ///
  /// In en, this message translates to:
  /// **'Use the bottom-right “pencil” to post.'**
  String get tutorial_social_post_s1;

  /// No description provided for @tutorial_social_post_s2.
  ///
  /// In en, this message translates to:
  /// **'Your post appears in “Hot” and “Friends” (friends can interact).'**
  String get tutorial_social_post_s2;

  /// No description provided for @tutorial_social_list_title.
  ///
  /// In en, this message translates to:
  /// **'Manage lists'**
  String get tutorial_social_list_title;

  /// No description provided for @tutorial_social_list_s1.
  ///
  /// In en, this message translates to:
  /// **'Top-right “#”: edit friends list.'**
  String get tutorial_social_list_s1;

  /// No description provided for @tutorial_social_list_s2.
  ///
  /// In en, this message translates to:
  /// **'Top-right “card”: edit following list.'**
  String get tutorial_social_list_s2;

  /// No description provided for @tutorial_explore_wall_title.
  ///
  /// In en, this message translates to:
  /// **'Create idol wallpapers'**
  String get tutorial_explore_wall_title;

  /// No description provided for @tutorial_explore_wall_s1.
  ///
  /// In en, this message translates to:
  /// **'Place photos, slogans, stickers to craft your style.'**
  String get tutorial_explore_wall_s1;

  /// No description provided for @tutorial_explore_wall_s2.
  ///
  /// In en, this message translates to:
  /// **'Add a “Birthday countdown” widget for support projects.'**
  String get tutorial_explore_wall_s2;

  /// No description provided for @tutorial_more_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings & User'**
  String get tutorial_more_settings_title;

  /// No description provided for @tutorial_more_settings_s1.
  ///
  /// In en, this message translates to:
  /// **'“Settings”: theme, language, notification preferences.'**
  String get tutorial_more_settings_s1;

  /// No description provided for @tutorial_more_settings_s2.
  ///
  /// In en, this message translates to:
  /// **'“User settings”: nickname, avatar, sign-in methods.'**
  String get tutorial_more_settings_s2;

  /// No description provided for @tutorial_more_stats_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tutorial_more_stats_title;

  /// No description provided for @tutorial_more_stats_s1.
  ///
  /// In en, this message translates to:
  /// **'See collected artists, mini-card count, and source (local / online).'**
  String get tutorial_more_stats_s1;

  /// No description provided for @tutorial_more_stats_s2.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards and achievements record your collection journey.'**
  String get tutorial_more_stats_s2;

  /// No description provided for @tutorial_more_dex_title.
  ///
  /// In en, this message translates to:
  /// **'Dex'**
  String get tutorial_more_dex_title;

  /// No description provided for @tutorial_more_dex_s1.
  ///
  /// In en, this message translates to:
  /// **'Quickly overview all cards; supports search and filters.'**
  String get tutorial_more_dex_s1;

  /// No description provided for @tutorial_faq_q1.
  ///
  /// In en, this message translates to:
  /// **'How to quickly add many mini cards?'**
  String get tutorial_faq_q1;

  /// No description provided for @tutorial_faq_a1.
  ///
  /// In en, this message translates to:
  /// **'In the mini card view page, there are two buttons at the top right. The left button supports batch importing JSON files, and the right button allows you to download the JSON file for this artist’s cards.'**
  String get tutorial_faq_a1;

  /// No description provided for @tutorial_faq_q2.
  ///
  /// In en, this message translates to:
  /// **'Where to import QR / JSON?'**
  String get tutorial_faq_q2;

  /// No description provided for @tutorial_faq_a2.
  ///
  /// In en, this message translates to:
  /// **'The leftmost/rightmost entry in the mini-card viewer, or “More” menu → “Import”.'**
  String get tutorial_faq_a2;

  /// No description provided for @tutorial_faq_q3.
  ///
  /// In en, this message translates to:
  /// **'What are tags for?'**
  String get tutorial_faq_q3;

  /// No description provided for @tutorial_faq_a3.
  ///
  /// In en, this message translates to:
  /// **'Tags help quick filtering in the mini-card viewer; search becomes more precise.'**
  String get tutorial_faq_a3;

  /// No description provided for @tutorial_faq_q4.
  ///
  /// In en, this message translates to:
  /// **'How to change language & theme?'**
  String get tutorial_faq_q4;

  /// No description provided for @tutorial_faq_a4.
  ///
  /// In en, this message translates to:
  /// **'Go to “More → Settings” to switch app language and light/dark theme.'**
  String get tutorial_faq_a4;

  /// No description provided for @tutorial_faq_q5.
  ///
  /// In en, this message translates to:
  /// **'Where do social posts appear?'**
  String get tutorial_faq_q5;

  /// No description provided for @tutorial_faq_a5.
  ///
  /// In en, this message translates to:
  /// **'Your posts appear in “Hot” and “Friends”; friends can see and interact.'**
  String get tutorial_faq_a5;

  /// No description provided for @postHintShareSomething.
  ///
  /// In en, this message translates to:
  /// **'Share something…'**
  String get postHintShareSomething;

  /// No description provided for @postAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get postAlbum;

  /// No description provided for @postPublish.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postPublish;

  /// No description provided for @postTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get postTags;

  /// No description provided for @postAddTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag and press Enter'**
  String get postAddTagHint;

  /// No description provided for @postAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get postAdd;

  /// No description provided for @postTagsCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String postTagsCount(int count, int max);

  /// No description provided for @postTagLimit.
  ///
  /// In en, this message translates to:
  /// **'Tag limit {max}'**
  String postTagLimit(int max);

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter cards'**
  String get filterPanelTitle;

  /// No description provided for @filterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClear;

  /// No description provided for @filterSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search name, note, serial…'**
  String get filterSearchHint;

  /// No description provided for @extraInfoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'More details'**
  String get extraInfoSectionTitle;

  /// No description provided for @fieldStageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Stage name / nickname'**
  String get fieldStageNameLabel;

  /// No description provided for @fieldGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group / series'**
  String get fieldGroupLabel;

  /// No description provided for @fieldOriginLabel.
  ///
  /// In en, this message translates to:
  /// **'Card source'**
  String get fieldOriginLabel;

  /// No description provided for @fieldNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNoteLabel;

  /// No description provided for @profileSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSectionTitle;

  /// No description provided for @noQuotePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No quote yet'**
  String get noQuotePlaceholder;

  /// No description provided for @cardNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A card named \"{name}\" already exists. Please use another name.'**
  String cardNameAlreadyExists(Object name);

  /// No description provided for @deleteCardAndMiniCardsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? All mini cards under this person will also be removed.'**
  String deleteCardAndMiniCardsMessage(Object name);

  /// No description provided for @socialProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get socialProfileTitle;

  /// No description provided for @userProfileLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press to edit your profile'**
  String get userProfileLongPressHint;

  /// No description provided for @scanFriendQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan name card QR to add friend'**
  String get scanFriendQrTitle;

  /// No description provided for @scanFriendQrButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan card to add friend'**
  String get scanFriendQrButtonLabel;

  /// No description provided for @filterAlbumNone.
  ///
  /// In en, this message translates to:
  /// **'No album'**
  String get filterAlbumNone;

  /// No description provided for @albumCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Album collection'**
  String get albumCollectionTitle;

  /// No description provided for @albumCollectionEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any albums yet. Start by adding your favorite one.'**
  String get albumCollectionEmptyHint;

  /// No description provided for @albumSwipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get albumSwipeEdit;

  /// No description provided for @albumSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get albumSwipeDelete;

  /// No description provided for @albumDialogAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add album'**
  String get albumDialogAddTitle;

  /// No description provided for @albumDialogEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit album'**
  String get albumDialogEditTitle;

  /// No description provided for @albumDialogFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Album title'**
  String get albumDialogFieldTitle;

  /// No description provided for @albumDialogFieldArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist / group'**
  String get albumDialogFieldArtist;

  /// No description provided for @albumDialogFieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year (optional)'**
  String get albumDialogFieldYear;

  /// No description provided for @albumDialogFieldCover.
  ///
  /// In en, this message translates to:
  /// **'Cover image URL (optional)'**
  String get albumDialogFieldCover;

  /// No description provided for @albumDialogFieldYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube link (optional)'**
  String get albumDialogFieldYoutube;

  /// No description provided for @albumDialogFieldYtmusic.
  ///
  /// In en, this message translates to:
  /// **'YT Music link (optional)'**
  String get albumDialogFieldYtmusic;

  /// No description provided for @albumDialogFieldSpotify.
  ///
  /// In en, this message translates to:
  /// **'Spotify link (optional)'**
  String get albumDialogFieldSpotify;

  /// No description provided for @albumDialogAddConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get albumDialogAddConfirm;

  /// No description provided for @albumDialogEditConfirm.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get albumDialogEditConfirm;

  /// No description provided for @albumDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete album'**
  String get albumDeleteConfirmTitle;

  /// No description provided for @albumDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String albumDeleteConfirmMessage(Object title);

  /// No description provided for @albumDetailReleaseYear.
  ///
  /// In en, this message translates to:
  /// **'Release year: {year}'**
  String albumDetailReleaseYear(Object year);

  /// No description provided for @albumDetailNoStreaming.
  ///
  /// In en, this message translates to:
  /// **'No streaming links set yet.'**
  String get albumDetailNoStreaming;

  /// No description provided for @albumDetailHint.
  ///
  /// In en, this message translates to:
  /// **'You can later add the track list, your comments, or reasons for recommendation here.'**
  String get albumDetailHint;

  /// No description provided for @albumTracksSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get albumTracksSectionTitle;

  /// No description provided for @albumNoTracksHint.
  ///
  /// In en, this message translates to:
  /// **'No tracks have been added to this album yet.'**
  String get albumNoTracksHint;

  /// No description provided for @albumFieldLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get albumFieldLanguage;

  /// No description provided for @albumFieldVersion.
  ///
  /// In en, this message translates to:
  /// **'Version / Edition'**
  String get albumFieldVersion;

  /// No description provided for @albumCoverFromUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'From URL'**
  String get albumCoverFromUrlLabel;

  /// No description provided for @albumCoverFromLocalLabel.
  ///
  /// In en, this message translates to:
  /// **'From local image'**
  String get albumCoverFromLocalLabel;

  /// No description provided for @albumFieldArtistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get albumFieldArtistsLabel;

  /// No description provided for @albumFieldArtistsInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type an artist name and press Enter to add…'**
  String get albumFieldArtistsInputHint;

  /// No description provided for @albumArtistsSuggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Suggestions will appear while you type.'**
  String get albumArtistsSuggestionHint;

  /// No description provided for @albumLinksSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Streaming links'**
  String get albumLinksSectionTitle;

  /// No description provided for @albumLinksCollapsedHint.
  ///
  /// In en, this message translates to:
  /// **'YouTube / YT Music / Spotify…'**
  String get albumLinksCollapsedHint;

  /// No description provided for @albumAddTrackButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Add track'**
  String get albumAddTrackButtonLabel;

  /// No description provided for @albumTrackDialogAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add track'**
  String get albumTrackDialogAddTitle;

  /// No description provided for @albumTrackDialogEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit track'**
  String get albumTrackDialogEditTitle;

  /// No description provided for @albumTrackFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Track title'**
  String get albumTrackFieldTitle;

  /// No description provided for @albumTitleRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter an album title.'**
  String get albumTitleRequiredMessage;

  /// No description provided for @albumCoverLocalRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please choose a local cover image.'**
  String get albumCoverLocalRequiredMessage;

  /// No description provided for @albumDetailLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language: {lang}'**
  String albumDetailLanguage(String lang);

  /// No description provided for @albumDetailVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {ver}'**
  String albumDetailVersion(String ver);

  /// No description provided for @albumTrackImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Track image (optional)'**
  String get albumTrackImageLabel;

  /// No description provided for @albumTrackClearImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear image'**
  String get albumTrackClearImageTooltip;

  /// No description provided for @albumTrackImageUseAlbumHint.
  ///
  /// In en, this message translates to:
  /// **'If no image is set, this track will use the album cover.'**
  String get albumTrackImageUseAlbumHint;
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
