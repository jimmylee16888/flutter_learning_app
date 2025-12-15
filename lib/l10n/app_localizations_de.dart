// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get authSignInWithGoogle => 'Mit Google anmelden';

  @override
  String get continueAsGuest => 'Als Gast fortfahren';

  @override
  String get noNetworkGuestTip =>
      'Sie sind offline. Sie können als Gast fortfahren.';

  @override
  String get appTitle => 'Pop Card';

  @override
  String get navCards => 'Karten';

  @override
  String get navExplore => 'Entdecken';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageZhTW => 'Traditionelles Chinesisch';

  @override
  String get languageEn => 'Englisch';

  @override
  String get languageJa => 'Japanisch';

  @override
  String get languageKo => 'Koreanisch';

  @override
  String get languageDe => 'Deutsch';

  @override
  String get aboutTitle => 'Info';

  @override
  String get aboutDeveloper => 'Über den Entwickler';

  @override
  String get developerRole => 'Entwickler';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get versionLabel => 'Version';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get quoteTitle => 'Eine Nachricht an die Fans';

  @override
  String get fanMiniCards => 'Fan-Minikarten';

  @override
  String get noMiniCardsHint =>
      'Noch keine Minikarten. Tippe auf „Bearbeiten“, um welche hinzuzufügen.';

  @override
  String get add => 'Hinzufügen';

  @override
  String get editMiniCards => 'Minikarten bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get previewFailed => 'Vorschau fehlgeschlagen';

  @override
  String get favorite => 'Favorit';

  @override
  String get favorited => 'Als Favorit markiert';

  @override
  String get accountStatusGuest => 'Gastmodus';

  @override
  String get accountStatusSignedIn => 'Angemeldet';

  @override
  String get accountStatusSignedOut => 'Abgemeldet';

  @override
  String get accountGuestSubtitle =>
      'Im Gastmodus; Daten werden nur auf diesem Gerät gespeichert';

  @override
  String get accountNoInfo => '(Keine Kontoinformationen)';

  @override
  String get accountBackToLogin => 'Zur Anmeldung';

  @override
  String get signOut => 'Abmelden';

  @override
  String get helloDeveloperTitle => 'Hallo! Ich bin der Entwickler';

  @override
  String get helloDeveloperBody =>
      'Danke, dass du dieses kleine Side Project ausprobierst 💫 \n\nIch bin ein großer LE SSERAFIM-Fan (FEARNOT)! Jedes Mal, wenn ich die Freude am Photocard-Sammeln mit Freunden teilen will, finde ich es mühsam, einen ganzen Stapel mitzunehmen – also habe ich diese App gemacht 📱. Jetzt kannst du deine Karten ganz einfach mit nur einem 6,5-Zoll-Handy zeigen und tauschen.\n\nIch werde dieses kleine Projekt weiterhin pflegen und verbessern, und ich bin wirklich dankbar, dass du es heruntergeladen und ein Teil davon geworden bist (oder, süßer gesagt, Teil der Familie 🩷). Wenn du Ideen oder Vorschläge hast, schreib mir einfach jederzeit! 💪';

  @override
  String get stats_title => 'Statistiken';

  @override
  String get stats_overview => 'Sammlungsübersicht';

  @override
  String get stats_artist_count => 'Anzahl der Künstler*innen';

  @override
  String get stats_card_total => 'Gesamtzahl der Minikarten';

  @override
  String get stats_front_source => 'Bildquelle der Vorderseite';

  @override
  String stats_cards_per_artist_topN(int n) {
    return 'Minikarten pro Künstler (Top $n)';
  }

  @override
  String get stats_nav_subtitle =>
      'Statistiken ansehen: Gesamtzahlen, Quellen, Top-Artists';

  @override
  String get welcomeTitle => 'Willkommen bei Mini Cards';

  @override
  String get welcomeSubtitle =>
      'Melde dich an oder erstelle ein Konto, um Einstellungen und Daten zu synchronisieren';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authContinueAsGuest => 'Als Gast fortfahren';

  @override
  String get authAccount => 'Konto (E-Mail / beliebige Zeichenfolge)';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authCreateAndSignIn => 'Konto erstellen und anmelden';

  @override
  String get authName => 'Name';

  @override
  String get authGender => 'Geschlecht';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderOther => 'Divers/keine Angabe';

  @override
  String get birthdayPick => 'Datum wählen';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get errorRegisterFailed => 'Registrierung fehlgeschlagen';

  @override
  String get errorPickBirthday => 'Bitte wähle deinen Geburtstag';

  @override
  String get common_local => 'Lokal';

  @override
  String get common_url => 'URL';

  @override
  String get common_unnamed => '(Ohne Namen)';

  @override
  String get common_unit_cards => 'Karten';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name ($pinyin)';
  }

  @override
  String get filterAll => 'Alle';

  @override
  String get deleteCategoryTitle => 'Kategorie löschen';

  @override
  String deleteCategoryMessage(Object name) {
    return '„$name“ wirklich löschen? Die Kategorie wird von allen Karten entfernt.';
  }

  @override
  String deletedCategoryToast(Object name) {
    return 'Kategorie gelöscht: $name';
  }

  @override
  String get searchHint => 'Name/Kartentext suchen';

  @override
  String get clear => 'Löschen';

  @override
  String get noCards => 'Keine Karten';

  @override
  String get addCard => 'Karte hinzufügen';

  @override
  String get deleteCardTitle => 'Karte löschen';

  @override
  String deleteCardMessage(Object title) {
    return '„$title“ wirklich löschen?';
  }

  @override
  String deletedCardToast(Object title) {
    return 'Gelöscht: $title';
  }

  @override
  String get editCard => 'Karte bearbeiten';

  @override
  String get categoryAssignOrAdd => 'Kategorien zuweisen/hinzufügen';

  @override
  String get newCardTitle => 'Neue Karte';

  @override
  String get editCardTitle => 'Karte bearbeiten';

  @override
  String get nameRequiredLabel => 'Name (erforderlich)';

  @override
  String get imageByUrl => 'Per URL';

  @override
  String get imageByLocal => 'Lokales Foto';

  @override
  String get imageUrl => 'Bild-URL';

  @override
  String get pickFromGallery => 'Aus Galerie wählen';

  @override
  String get quoteOptionalLabel => 'Zitat (optional)';

  @override
  String get pickBirthdayOptional => 'Geburtstag wählen (optional)';

  @override
  String get inputImageUrl => 'Bitte Bild-URL eingeben';

  @override
  String get downloadFailed => 'Download fehlgeschlagen';

  @override
  String get pickLocalPhoto => 'Bitte lokales Foto wählen';

  @override
  String get updatedCardToast => 'Karte aktualisiert';

  @override
  String get manageCategoriesTitle => 'Kategorien verwalten';

  @override
  String get newCategoryNameHint => 'Neuer Kategoriename';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get deleteCategoryTooltip => 'Kategorie löschen';

  @override
  String get assignCategoryTitle => 'Kategorien zuweisen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return '„$name“ wirklich löschen? Die Kategorie wird von allen Karten entfernt.';
  }

  @override
  String addedCategoryToast(Object name) {
    return 'Kategorie hinzugefügt: $name';
  }

  @override
  String get noMiniCardsPreviewHint =>
      'Noch keine Mini-Karten. Klicken Sie hier oder wischen Sie nach oben, um eine hinzuzufügen.';

  @override
  String get detailSwipeHint =>
      'Wischen Sie nach oben, um zur Mini-Karten-Seite zu gelangen (einschließlich Scan/QR-Teilen).';

  @override
  String get noMiniCardsEmptyList =>
      'Derzeit keine Mini-Karten. Klicken Sie unten rechts auf +, um eine hinzuzufügen.';

  @override
  String get miniLocalImageBadge => 'Lokales Bild';

  @override
  String get miniHasBackBadge => 'Mit Bild der Rückseite';

  @override
  String get tagsLabel => 'Tags';

  @override
  String tagsCount(int n) {
    return 'Tags $n';
  }

  @override
  String get nameLabel => 'Name';

  @override
  String get serialNumber => 'Seriennummer';

  @override
  String get album => 'Album';

  @override
  String get addAlbum => 'Album hinzufügen';

  @override
  String get enterAlbumName => 'Albumnamen eingeben';

  @override
  String get cardType => 'Kartentyp';

  @override
  String get addCardType => 'Kartentyp hinzufügen';

  @override
  String get enterCardTypeName => 'Kartentypnamen eingeben';

  @override
  String get noteLabel => 'Anmerkung';

  @override
  String get newTagHint => 'Neuen Tag hinzufügen…';

  @override
  String get frontSide => 'Vorderseite';

  @override
  String get backSide => 'Rückseite';

  @override
  String get frontImageTitle => 'Bild der Vorderseite';

  @override
  String get backImageTitleOptional => 'Bild der Rückseite (optional)';

  @override
  String get frontImageUrlLabel => 'URL des Bildes der Vorderseite';

  @override
  String get backImageUrlLabel => 'URL des Bildes der Rückseite';

  @override
  String get clearUrl => 'URL löschen';

  @override
  String get clearLocal => 'Lokal löschen';

  @override
  String get clearBackImage => 'Bild der Rückseite löschen';

  @override
  String get localPickedLabel => 'Ausgewählt: Lokal';

  @override
  String get miniCardEditTitle => 'Mini-Karte bearbeiten';

  @override
  String get miniCardNewTitle => 'Neue Mini-Karte';

  @override
  String get errorFrontImageUrlRequired =>
      'Bitte geben Sie eine URL für das Bild der Vorderseite ein oder wechseln Sie zu lokal.';

  @override
  String get errorFrontLocalRequired =>
      'Bitte wählen Sie ein lokales Foto der Vorderseite aus oder wechseln Sie zurück zur URL.';

  @override
  String get userProfileTitle => 'Benutzer';

  @override
  String get userProfileTile => 'Benutzer';

  @override
  String get nicknameLabel => 'Spitzname';

  @override
  String get nicknameRequired => 'Spitzname ist erforderlich';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get clearBirthday => 'Geburtstag löschen';

  @override
  String get userProfileSaved => 'Benutzereinstellungen gespeichert';

  @override
  String get ready => 'Fertig';

  @override
  String get fillNicknameAndBirthday =>
      'Bitte Spitzname und Geburtstag ausfüllen';

  @override
  String get navSocial => 'Sozial';

  @override
  String get timeJustNow => 'Gerade eben';

  @override
  String timeMinutesAgo(int n) {
    return 'vor $n Min.';
  }

  @override
  String timeHoursAgo(int n) {
    return 'vor $n Std.';
  }

  @override
  String timeDaysAgo(int n) {
    return 'vor $n Tagen';
  }

  @override
  String get socialFriends => 'Freunde';

  @override
  String get socialHot => 'Beliebt';

  @override
  String get socialFollowing => 'Folge ich';

  @override
  String get publish => 'Veröffentlichen';

  @override
  String get socialShareHint => 'Woran denkst du gerade?';

  @override
  String get leaveACommentHint => 'Einen Kommentar schreiben…';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String commentsCount(int n) {
    return 'Kommentare ($n)';
  }

  @override
  String get addTagHint => 'Tag hinzufügen…';

  @override
  String followedTag(Object tag) {
    return '#$tag gefolgt';
  }

  @override
  String unfollowedTag(Object tag) {
    return 'Folgen für #$tag entfernt';
  }

  @override
  String get friendCardsTitle => 'Freundekarten';

  @override
  String get addFriendCard => 'Karte hinzufügen';

  @override
  String get editFriendCard => 'Karte bearbeiten';

  @override
  String get scanQr => 'QR-Code scannen';

  @override
  String get tapToFlip => 'Tippen zum Umdrehen';

  @override
  String get deleteFriendCardTitle => 'Karte löschen';

  @override
  String deleteFriendCardMessage(Object name) {
    return '„$name“ löschen?';
  }

  @override
  String get followArtistsLabel => 'Verfolgte Künstler';

  @override
  String limitReached(String text) {
    return 'Limit erreicht ($text)';
  }

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get offlineBanner => 'Offline: Einige Funktionen sind nicht verfügbar';

  @override
  String get manageFollowedTags => 'Verfolgte Tags';

  @override
  String get noFriendsYet => 'Noch keine Freunde';

  @override
  String get friendAddAction => 'Freund hinzufügen';

  @override
  String get friendRemoveAction => 'Freund entfernen';

  @override
  String get friendAddedStatus => 'Hinzugefügt';

  @override
  String get remove => 'Entfernen';

  @override
  String get changeAvatar => 'Avatar ändern';

  @override
  String get socialLinksTitle => 'Soziale Links';

  @override
  String get showInstagramOnProfile => 'Instagram im Profil anzeigen';

  @override
  String get showFacebookOnProfile => 'Facebook im Profil anzeigen';

  @override
  String get showLineOnProfile => 'LINE im Profil anzeigen';

  @override
  String followedTagsCount(int n) {
    return 'Verfolgte Tags ($n)';
  }

  @override
  String get addFollowedTag => 'Verfolgten Tag hinzufügen';

  @override
  String get addFollowedTagHint => 'Gib einen Tagnamen ein und drücke Enter';

  @override
  String get manageCards => 'Visitenkarten verwalten';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get lineLabel => 'LINE';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => 'Freunde oder Künstler suchen';

  @override
  String get followedTagsTitle => 'Verfolgte Tags';

  @override
  String get noFollowedTagsYet => 'Noch keine verfolgten Tags';

  @override
  String get addedFollowedTagToast => 'Tag wurde hinzugefügt';

  @override
  String addFollowedTagFailed(Object error) {
    return 'Hinzufügen fehlgeschlagen: $error';
  }

  @override
  String get removedFollowedTagToast => 'Tag wurde entfernt';

  @override
  String removeFollowedTagFailed(Object error) {
    return 'Entfernen fehlgeschlagen: $error';
  }

  @override
  String loadFailed(Object error) {
    return 'Laden fehlgeschlagen: $error';
  }

  @override
  String miniCardsOf(Object title) {
    return 'Mini-Cards von $title';
  }

  @override
  String get importFromJsonTooltip => 'Aus JSON importieren';

  @override
  String get exportJsonMultiTooltip => 'JSON exportieren (mehrere)';

  @override
  String get scan => 'Scannen';

  @override
  String get share => 'Teilen';

  @override
  String get shareThisCard => 'Diese Karte teilen';

  @override
  String importedMiniCardsToast(int n) {
    return '$n Mini-Cards importiert';
  }

  @override
  String get shareMultipleCards => 'Mehrere Karten teilen (Mehrfachauswahl)';

  @override
  String get shareMultipleCardsSubtitle =>
      'Karten auswählen, dann Fotos teilen oder JSON exportieren';

  @override
  String get shareOneCard => 'Eine Karte zum Teilen auswählen…';

  @override
  String get selectCardsForJsonTitle => 'Karten zum Teilen auswählen (JSON)';

  @override
  String get selectCardsForShareOrExportTitle =>
      'Karten zum Teilen/Exportieren auswählen';

  @override
  String get blockedLocalImageNote =>
      'Enthält lokale Bilder; Export nach JSON nicht möglich';

  @override
  String shareMultiplePhotos(int n) {
    return '$n Fotos teilen';
  }

  @override
  String get exportJson => 'JSON exportieren';

  @override
  String get exportJsonSkipLocalHint =>
      'Karten mit ausschließlich lokalen Bildern werden übersprungen';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return '$total Freigaben versucht, erfolgreich $ok / fehlgeschlagen $fail';
  }

  @override
  String get shareQrCode => 'QR-Code teilen';

  @override
  String get shareQrAutoBackendHint =>
      'Bei großer Datenmenge wird automatisch in den Backend-Modus gewechselt';

  @override
  String get cannotShareByQr => 'Teilen per QR nicht möglich';

  @override
  String get noImageUrl => 'Keine Bild-URL';

  @override
  String get noImageUrlPhotoOnly =>
      'Keine Bild-URL; nur direktes Teilen des Fotos möglich';

  @override
  String get shareThisPhoto => 'Dieses Foto teilen';

  @override
  String shareFailed(Object error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String get transportBackendHint => 'Backend-Modus (über API)';

  @override
  String get transportEmbeddedHint => 'Eingebettet (lokal)';

  @override
  String get qrIdOnlyNotice =>
      'Dieser QR enthält nur die Karten-ID. Der Empfänger ruft die Inhalte vom Backend ab.';

  @override
  String get qrGenerationFailed => 'QR-Bild konnte nicht erzeugt werden';

  @override
  String get pasteJsonTitle => 'JSON-Text einfügen';

  @override
  String get pasteJsonHint =>
      'Unterstützt mini_card_bundle_v2/v1 oder mini_card_v2/v1';

  @override
  String get import => 'Importieren';

  @override
  String importedFromJsonToast(int n) {
    return '$n Mini-Cards aus JSON importiert';
  }

  @override
  String importFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get cannotExportJsonAllLocal =>
      'Alle ausgewählten Karten enthalten nur lokale Bilder und können nicht als JSON exportiert werden';

  @override
  String skippedLocalImagesCount(int n) {
    return '$n Karte(n) mit nur lokalen Bildern übersprungen';
  }

  @override
  String get close => 'Schließen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copiedJsonToast => 'JSON kopiert';

  @override
  String get copyJson => 'JSON kopieren';

  @override
  String get none => 'Keine';

  @override
  String get selectCardsToShareTitle => 'Karten zum Teilen auswählen';

  @override
  String get hasImageUrlJsonOk =>
      'Bild-URL vorhanden; Versand per JSON möglich';

  @override
  String get exportJsonOnlyUrlHint =>
      'Hinweis: Exportiertes JSON enthält nur Karten mit Bild-URL; nur lokale Bilder werden übersprungen.';

  @override
  String get sharePhotos => 'Fotos teilen';

  @override
  String get containsLocalImages => 'Enthält lokale Bilder';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked Karte(n) können nicht als JSON exportiert werden. Nur die verwendbaren $allowed Karte(n) exportieren?';
  }

  @override
  String get onlyExportUsable => 'Nur verwendbare exportieren';

  @override
  String get shareMiniCardTitle => 'Mini-Card teilen';

  @override
  String get qrCodeTab => 'QR-Code';

  @override
  String get qrTooLargeUseJsonHint =>
      'Wenn der QR-Code nicht angezeigt wird, sind die Daten evtl. zu groß. Nutzen Sie stattdessen JSON.';

  @override
  String get scanMiniCardQrTitle => 'Mini-Card-QR scannen';

  @override
  String get scanFromGallery => 'Aus Galerie scannen';

  @override
  String get noQrFoundInImage => 'Kein QR im Bild gefunden';

  @override
  String get qrFormatInvalid => 'QR-Format ungültig';

  @override
  String get qrTypeUnsupported => 'QR-Typ wird nicht unterstützt';

  @override
  String fetchFromBackendFailed(Object error) {
    return 'Abruf vom Backend fehlgeschlagen: $error';
  }

  @override
  String get addFollowedTagFailedOffline =>
      'Du bist offline. Tag wurde lokal hinzugefügt.';

  @override
  String get removeFollowedTagFailedOffline =>
      'Du bist offline. Tag wurde lokal entfernt.';

  @override
  String get loading => 'Wird geladen …';

  @override
  String get networkRequiredTitle => 'Netzwerkverbindung erforderlich';

  @override
  String get networkRequiredBody =>
      'Für die Anmeldung ist eine Internetverbindung erforderlich. Bitte verbinden Sie sich und versuchen Sie es erneut.';

  @override
  String get ok => 'OK';

  @override
  String get willSaveAs => 'Wird gespeichert als';

  @override
  String get alreadyExists => 'Bereits vorhanden';

  @override
  String get common_about => 'Info';

  @override
  String get settings_menu_general => 'Allgemeine Einstellungen';

  @override
  String get settings_menu_user => 'Benutzereinstellungen';

  @override
  String get settings_menu_about => 'Info';

  @override
  String get settingsMenuGeneral => 'Allgemeine Einstellungen';

  @override
  String get commonAbout => 'Info';

  @override
  String get navMore => 'Mehr';

  @override
  String get exploreReflow => 'Widgets neu anordnen';

  @override
  String get commonAdd => 'Hinzufügen';

  @override
  String get exploreNoPhoto => 'Kein Foto ausgewählt';

  @override
  String get exploreTapToEditQuote => 'Tippen, um Zitat zu bearbeiten';

  @override
  String get exploreAdd => 'Hinzufügen';

  @override
  String get exploreAddPhoto => 'Foto-Karte';

  @override
  String get exploreAddQuote => 'Zitat-Karte';

  @override
  String get exploreAddBirthday => 'Geburtstags-Countdown';

  @override
  String get exploreAddBall => 'Ball hinzufügen';

  @override
  String get exploreAdBuiltIn => 'Anzeigen sind integriert';

  @override
  String get exploreEnterAQuote => 'Ein Zitat eingeben';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonOk => 'OK';

  @override
  String get exploreCountdownTitleHint =>
      'Idol/Ereignis (z. B. Sakura Geburtstag)';

  @override
  String get exploreAddBallDialogTitle => 'Ball hinzufügen';

  @override
  String get exploreBallEmojiHint => 'Emoji (leer lassen für Foto)';

  @override
  String get exploreSize => 'Größe';

  @override
  String get explorePickPhoto => 'Foto auswählen…';

  @override
  String get explorePickedPhoto => 'Foto ausgewählt';

  @override
  String get navDex => 'Pokédex';

  @override
  String get dex_title => 'Mein Pokédex';

  @override
  String get dex_uncategorized => 'Nicht kategorisiert';

  @override
  String get dex_searchHint => 'Idole oder Karten suchen…';

  @override
  String dex_cardsCount(Object count) {
    return '$count Karten';
  }

  @override
  String get dex_empty => 'Noch keine Karten gesammelt';

  @override
  String get zoomIn => 'Vergrößern';

  @override
  String get zoomOut => 'Verkleinern';

  @override
  String get resetZoom => 'Zoom zurücksetzen';

  @override
  String get billing_title => 'Abonnement & Zahlung';

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
    return 'Aktueller Plan: $plan';
  }

  @override
  String get section_plan_notes => 'Hinweise zu den Plänen';

  @override
  String get section_payment_invoice => 'Zahlung und Belege (über Google Play)';

  @override
  String get section_terms => 'Bedingungen (Demo)';

  @override
  String get upgrade_card_title => 'Speicher erweitern, entspannt sammeln';

  @override
  String get upgrade_card_desc =>
      'Mit den Bezahlplänen kommen lokale Uploads, mehr Speicher und Geräte-Sync.';

  @override
  String get badge_coming_soon => 'Bald verfügbar';

  @override
  String get feature_external_images =>
      '5 GB Cloud-Speicher (geräteübergreifende Synchronisierung)';

  @override
  String get feature_small_cloud_space =>
      'Kartenkategorisierung, Kartenrückseite, Mini-Karten-Details';

  @override
  String get feature_ad_free => 'Werbefreies, immersives Erlebnis';

  @override
  String get feature_upload_local_images =>
      '10 GB Cloud-Speicher (geräteübergreifende Synchronisierung)';

  @override
  String get feature_priority_support =>
      'Kartenkategorisierung, Kartenrückseite, Mini-Karten-Details';

  @override
  String get feature_large_storage =>
      '50 GB Cloud-Speicher (geräteübergreifende Synchronisierung)';

  @override
  String get feature_album_report =>
      'Kartenkategorisierung, Kartenrückseite, Mini-Karten-Details';

  @override
  String get feature_roadmap_advance => 'Erweiterte Funktionen (Vorschau)';

  @override
  String get plan_badge_recommended => 'Empfohlen';

  @override
  String price_per_month(Object price) {
    return '$price/Monat';
  }

  @override
  String get upgrade_now => 'Jetzt upgraden';

  @override
  String get manage_plan => 'Plan verwalten';

  @override
  String get coming_soon_title => 'Noch nicht verfügbar';

  @override
  String get coming_soon_body =>
      'Der lokale Cloud-Speicher wird derzeit für den Start vorbereitet. Dies ist eine Platzhalter-Ansicht. In der finalen Version gibt es lokale Uploads, mehr Speicher und Geräte-Sync.';

  @override
  String get coming_soon_ok => 'OK';

  @override
  String get bullet_free_external =>
      'Gratis-Plan: Nur externe Bilder (URL) erlaubt';

  @override
  String get bullet_paid_local_upload =>
      'Bezahlplan: Lokale Uploads in die Cloud mit mehr Speicher';

  @override
  String get bullet_future_tiers => 'Weitere Speicherstufen folgen';

  @override
  String get bullet_pay_cards =>
      'Es werden nur Abonnements über Google Play Billing unterstützt';

  @override
  String get bullet_einvoice =>
      'Quittungen/Rechnungen werden von Google Play ausgestellt; Unternehmens-Steuernummern werden nicht unterstützt';

  @override
  String get bullet_cancel_anytime =>
      'Jederzeit kündbar – keine Verlängerung im nächsten Monat';

  @override
  String get bullet_terms =>
      'Nutzungsbedingungen, Datenschutz, Rückerstattungen (Links folgen)';

  @override
  String get bullet_abuse =>
      'Missbräuchliche/illegale Uploads führen zur Sperrung';

  @override
  String get common_ok => 'OK';

  @override
  String get common_okDescription => 'Allgemeine OK-Schaltfläche';

  @override
  String get common_cancel => 'Abbrechen';

  @override
  String get common_cancelDescription => 'Allgemeine Abbrechen-Schaltfläche';

  @override
  String get tutorial_title => 'Anleitung';

  @override
  String get tutorial_tab_cards => 'Karten';

  @override
  String get tutorial_tab_social => 'Social';

  @override
  String get tutorial_tab_explore => 'Entdecken';

  @override
  String get tutorial_tab_more => 'Mehr';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => 'Artist-Karte hinzufügen';

  @override
  String get tutorial_cards_tags_addMini => 'Mini-Karte hinzufügen';

  @override
  String get tutorial_cards_tags_editDelete => 'Bearbeiten / Löschen';

  @override
  String get tutorial_cards_tags_info => 'Mini-Karteninfos';

  @override
  String get tutorial_cards_addArtist_title => '„Artist-Karte“ hinzufügen';

  @override
  String get tutorial_cards_addArtist_s1 =>
      'Tippe rechts unten auf „＋ Artist-Karte hinzufügen“.';

  @override
  String get tutorial_cards_addArtist_s2 =>
      'Wähle ein lokales Bild oder füge eine Bild-URL ein.';

  @override
  String get tutorial_cards_addArtist_s3 =>
      'Wische rechts zum Bearbeiten, links zum Löschen der Karte.';

  @override
  String get tutorial_cards_addMini_title => '„Mini-Karte“ hinzufügen';

  @override
  String get tutorial_cards_addMini_s1 =>
      'Tippe eine beliebige „Artist-Karte“, um Details zu öffnen.';

  @override
  String get tutorial_cards_addMini_s2 =>
      'Tippe den Mini-Kartenbereich oder wische nach oben → Viewer.';

  @override
  String get tutorial_cards_addMini_s3 =>
      'Ganz links/rechts: QR scannen oder Editor zum Hinzufügen öffnen.';

  @override
  String get tutorial_cards_addMini_s4 =>
      '„＋“ unten rechts im Editor zum Hinzufügen; Löschen auf derselben Seite.';

  @override
  String get tutorial_cards_info_title => '„Mini-Karteninfos“ verwalten';

  @override
  String get tutorial_cards_info_s1 =>
      'Nach dem Hinzufügen erscheint die Karte im Viewer; tippe zum Umdrehen.';

  @override
  String get tutorial_cards_info_s2 =>
      'Oben rechts „Info“: Name, Nummer, Album, Typ, Notiz, Tags bearbeiten.';

  @override
  String get tutorial_cards_info_s3 =>
      'Mit Tags filterst du schneller und suchst präziser.';

  @override
  String get tutorial_cards_note_json =>
      'Tipp: Rechts oben kannst du JSON herunterladen und Stapelimport nutzen.';

  @override
  String get tutorial_social_tags_primary => 'Freunde / Trends / Folgen';

  @override
  String get tutorial_social_tags_postComment => 'Posten & kommentieren';

  @override
  String get tutorial_social_tags_lists => 'Listen verwalten';

  @override
  String get tutorial_social_browse_title => 'Beiträge ansehen';

  @override
  String get tutorial_social_browse_s1 =>
      'Oben zwischen „Freunde“, „Trends“, „Folgen“ wechseln.';

  @override
  String get tutorial_social_browse_s2 =>
      'In allen Tabs kannst du ansehen, liken und kommentieren.';

  @override
  String get tutorial_social_post_title => 'Posten & kommentieren';

  @override
  String get tutorial_social_post_s1 => 'Rechts unten mit dem „Stift“ posten.';

  @override
  String get tutorial_social_post_s2 =>
      'Dein Beitrag erscheint in „Trends“ und „Freunde“ (Freunde können interagieren).';

  @override
  String get tutorial_social_list_title => 'Listen verwalten';

  @override
  String get tutorial_social_list_s1 =>
      'Oben rechts „#“: Freundesliste bearbeiten.';

  @override
  String get tutorial_social_list_s2 =>
      'Oben rechts „Karte“: Following-Liste bearbeiten.';

  @override
  String get tutorial_explore_wall_title => 'Idol-Wallpaper gestalten';

  @override
  String get tutorial_explore_wall_s1 =>
      'Fotos, Slogans, Sticker – ganz nach deinem Stil.';

  @override
  String get tutorial_explore_wall_s2 =>
      '„Geburtstags-Countdown“-Widget hinzufügen.';

  @override
  String get tutorial_more_settings_title => 'Einstellungen & Benutzer';

  @override
  String get tutorial_more_settings_s1 =>
      '„Einstellungen“: Thema, Sprache, Benachrichtigungen.';

  @override
  String get tutorial_more_settings_s2 =>
      '„Benutzereinstellungen“: Spitzname, Avatar, Login-Methoden.';

  @override
  String get tutorial_more_stats_title => 'Statistik';

  @override
  String get tutorial_more_stats_s1 =>
      'Künstler, Mini-Kartenzahl, Quelle (lokal/online) ansehen.';

  @override
  String get tutorial_more_stats_s2 =>
      'Ranglisten & Achievements zeichnen deine Sammlung nach.';

  @override
  String get tutorial_more_dex_title => 'Dex';

  @override
  String get tutorial_more_dex_s1 =>
      'Alle Karten im Überblick; Suche & Filter verfügbar.';

  @override
  String get tutorial_faq_q1 => 'Wie füge ich schnell viele Mini-Karten hinzu?';

  @override
  String get tutorial_faq_a1 =>
      'Auf der Mini-Karten-Ansichtsseite befinden sich oben rechts zwei Schaltflächen. Die linke Schaltfläche unterstützt das Batch-Importieren von JSON-Dateien, und über die rechte Schaltfläche kannst du die JSON-Datei der Karten dieses Künstlers herunterladen.';

  @override
  String get tutorial_faq_q2 => 'Wo importiere ich QR / JSON?';

  @override
  String get tutorial_faq_a2 =>
      'Ganz links/rechts im Viewer oder im „Mehr“-Menü unter „Importieren“.';

  @override
  String get tutorial_faq_q3 => 'Wofür sind Tags?';

  @override
  String get tutorial_faq_a3 =>
      'Zum schnellen Filtern und präziseren Suchen im Viewer.';

  @override
  String get tutorial_faq_q4 => 'Wie ändere ich Sprache & Thema?';

  @override
  String get tutorial_faq_a4 =>
      'Über „Mehr → Einstellungen“ Sprache und Hell/Dunkel wechseln.';

  @override
  String get tutorial_faq_q5 => 'Wo erscheinen Social-Beiträge?';

  @override
  String get tutorial_faq_a5 =>
      'In „Trends“ und „Freunde“; Freunde können interagieren.';

  @override
  String get postHintShareSomething => 'Teile etwas …';

  @override
  String get postAlbum => 'Album';

  @override
  String get postPublish => 'Veröffentlichen';

  @override
  String get postTags => 'Tags';

  @override
  String get postAddTagHint => 'Tag hinzufügen und Enter drücken';

  @override
  String get postAdd => 'Hinzufügen';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return 'Max. $max Tags';
  }

  @override
  String get currentPlan => 'Aktueller Plan';

  @override
  String get filter => 'Filter';

  @override
  String get filterPanelTitle => 'Karten filtern';

  @override
  String get filterClear => 'Zurücksetzen';

  @override
  String get filterSearchHint => 'Nach Name, Notiz oder Seriennummer suchen…';

  @override
  String get extraInfoSectionTitle => 'Weitere Details';

  @override
  String get fieldStageNameLabel => 'Künstlername / Spitzname';

  @override
  String get fieldGroupLabel => 'Gruppe / Serie';

  @override
  String get fieldOriginLabel => 'Kartenquelle';

  @override
  String get fieldNoteLabel => 'Notizen';

  @override
  String get profileSectionTitle => 'Grunddaten';

  @override
  String get noQuotePlaceholder => 'Noch kein Zitat eingetragen';

  @override
  String cardNameAlreadyExists(Object name) {
    return 'Eine Karte mit dem Namen „$name“ existiert bereits. Bitte verwenden Sie einen anderen Namen.';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return 'Möchten Sie „$name“ wirklich löschen? Alle zugehörigen Mini-Karten werden ebenfalls entfernt.';
  }

  @override
  String get socialProfileTitle => 'Profil';

  @override
  String get userProfileLongPressHint =>
      'Lange drücken, um dein Profil zu bearbeiten.';

  @override
  String get scanFriendQrTitle =>
      'Visitenkarten-QR scannen, um Freund hinzuzufügen';

  @override
  String get scanFriendQrButtonLabel => 'Visitenkarte scannen';

  @override
  String get filterAlbumNone => 'Kein Album';

  @override
  String get albumCollectionTitle => 'Albensammlung';

  @override
  String get albumCollectionEmptyHint =>
      'Du hast noch keine Alben. Fang damit an, dein Lieblingsalbum hinzuzufügen.';

  @override
  String get albumSwipeEdit => 'Bearbeiten';

  @override
  String get albumSwipeDelete => 'Löschen';

  @override
  String get albumDialogAddTitle => 'Album hinzufügen';

  @override
  String get albumDialogEditTitle => 'Album bearbeiten';

  @override
  String get albumDialogFieldTitle => 'Albumtitel';

  @override
  String get albumDialogFieldArtist => 'Künstler / Gruppe';

  @override
  String get albumDialogFieldYear => 'Erscheinungsjahr (optional)';

  @override
  String get albumDialogFieldCover => 'Cover-Bild-URL (optional)';

  @override
  String get albumDialogFieldYoutube => 'YouTube-Link (optional)';

  @override
  String get albumDialogFieldYtmusic => 'YT-Music-Link (optional)';

  @override
  String get albumDialogFieldSpotify => 'Spotify-Link (optional)';

  @override
  String get albumDialogAddConfirm => 'Hinzufügen';

  @override
  String get albumDialogEditConfirm => 'Speichern';

  @override
  String get albumDeleteConfirmTitle => 'Album löschen';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return 'Möchtest du „$title“ wirklich löschen?';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return 'Erscheinungsjahr: $year';
  }

  @override
  String get albumDetailNoStreaming =>
      'Es wurden noch keine Streaming-Links hinterlegt.';

  @override
  String get albumDetailHint =>
      'Später kannst du hier die Trackliste, deine Kommentare oder Gründe für deine Empfehlung eintragen.';

  @override
  String get albumTracksSectionTitle => 'Titel';

  @override
  String get albumNoTracksHint =>
      'Diesem Album wurden bisher noch keine Titel hinzugefügt.';

  @override
  String get albumFieldLanguage => 'Sprache';

  @override
  String get albumFieldVersion => 'Version';

  @override
  String get albumCoverFromUrlLabel => 'Aus URL';

  @override
  String get albumCoverFromLocalLabel => 'Lokales Bild verwenden';

  @override
  String get albumFieldArtistsLabel => 'Künstler*innen';

  @override
  String get albumFieldArtistsInputHint =>
      'Künstlernamen eingeben und mit Enter hinzufügen…';

  @override
  String get albumArtistsSuggestionHint =>
      'Während der Eingabe werden Vorschläge angezeigt.';

  @override
  String get albumLinksSectionTitle => 'Streaming-Links';

  @override
  String get albumLinksCollapsedHint => 'YouTube / YT Music / Spotify…';

  @override
  String get albumAddTrackButtonLabel => 'Titel hinzufügen';

  @override
  String get albumTrackDialogAddTitle => 'Titel hinzufügen';

  @override
  String get albumTrackDialogEditTitle => 'Titel bearbeiten';

  @override
  String get albumTrackFieldTitle => 'Titelname';

  @override
  String get albumTitleRequiredMessage => 'Bitte einen Albumnamen eingeben.';

  @override
  String get albumCoverLocalRequiredMessage =>
      'Bitte ein lokales Coverbild auswählen.';

  @override
  String albumDetailLanguage(String lang) {
    return 'Sprache: $lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return 'Version: $ver';
  }

  @override
  String get albumTrackImageLabel => 'Titelbild (optional)';

  @override
  String get albumTrackClearImageTooltip => 'Bild entfernen';

  @override
  String get albumTrackImageUseAlbumHint =>
      'Wenn kein Bild festgelegt ist, wird für diesen Titel das Albumcover verwendet.';

  @override
  String get albumImportJsonTitle => 'Album-JSON importieren';

  @override
  String get albumImportJsonHint =>
      'Fügen Sie hier das Album-JSON ein. Sie können ein einzelnes Albumobjekt oder eine Liste von Alben einfügen.';

  @override
  String get albumImportSuccess => 'Alben wurden erfolgreich importiert.';

  @override
  String albumImportFailed(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get albumAddNewAlbum => 'Album hinzufügen';

  @override
  String get chatHint => 'Nachricht eingeben…';

  @override
  String get socialNewConversation => 'Neues Gespräch';

  @override
  String get socialMembersHint => 'Mitglieder hinzufügen…';

  @override
  String get socialConversationNameOptional => 'Gesprächsname (optional)';

  @override
  String get socialMessagesTitle => 'Nachrichten';

  @override
  String get syncMenuTitle => 'Synchronisieren & Herunterladen';

  @override
  String get syncMenuSubtitle =>
      'Sichere deine Karten- und Albendaten in der Cloud oder lade sie auf dieses Gerät herunter.';

  @override
  String get syncPageTitle => 'Synchronisieren & Herunterladen';

  @override
  String get syncPageDesc =>
      'Du kannst die Karten und Alben dieses Geräts manuell als Cloud-Datei hochladen oder aus der Cloud herunterladen, um die lokalen Daten zu überschreiben. Wir empfehlen, vor einem Gerätewechsel oder einer Neuinstallation hochzuladen.';

  @override
  String get syncUploadButton => 'In die Cloud hochladen';

  @override
  String get syncDownloadButton => 'Aus der Cloud herunterladen';

  @override
  String get syncCopyButton => 'Dateiinhalt kopieren';

  @override
  String get syncRefreshPreview => 'Vorschau neu laden';

  @override
  String get syncPreviewTitle => 'Cloud-Datenvorschau';

  @override
  String get syncPreviewSubtitle =>
      'Dies ist der Inhalt der aktuell in der Cloud gespeicherten Library-Datei (JSON).';

  @override
  String get syncPreviewEmptyHint =>
      'Noch keine Cloud-Datei vorhanden. Bitte zuerst „In die Cloud hochladen“.';

  @override
  String get syncNoRemoteData =>
      'Keine Cloud-Library-Datei gefunden. Bitte zuerst von diesem Gerät hochladen.';

  @override
  String get syncUploadSuccess =>
      'Hochladen und Synchronisieren abgeschlossen.';

  @override
  String syncUploadFailed(Object error) {
    return 'Upload fehlgeschlagen: $error';
  }

  @override
  String get syncDownloadSuccess =>
      'Aus der Cloud heruntergeladen und lokal angewendet.';

  @override
  String get syncDownloadFailedGeneric =>
      'Download oder Anwenden aus der Cloud fehlgeschlagen. Bitte später erneut versuchen.';

  @override
  String get syncCopyNoData =>
      'Kein Inhalt zum Kopieren. Bitte zuerst die Cloud-Datei laden.';

  @override
  String get syncCopySuccess =>
      'Cloud-Dateiinhalt in die Zwischenablage kopiert.';

  @override
  String get syncPaidOnlyHint =>
      'Cloud-Synchronisation und Download sind nur für kostenpflichtige Pläne verfügbar. Nach dem Abonnement kannst du die vollständige Library-Datei sichern, herunterladen und kopieren.';

  @override
  String get syncNeedSubTitle => 'Abonnement erforderlich';

  @override
  String get syncNeedSubBody =>
      'Cloud-Synchronisation und Download sind nur für kostenpflichtige Pläne verfügbar. Bitte gehe zur Abonnementseite und wähle Basic / Plus / Pro aus.';

  @override
  String get syncGoToSubscription => 'Zum Abonnement';

  @override
  String get dialogCancel => 'Abbrechen';
}
