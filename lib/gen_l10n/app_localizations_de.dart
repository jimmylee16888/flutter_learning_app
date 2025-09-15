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
  String get appTitle => 'MyApp Demo';

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
      'Danke, dass du dieses kleine Side-Project ausprobierst. Ich bin ein großer Fan von LE SSERAFIM (hier ein FEARNOT), aber ich möchte nicht jedes Mal einen Stapel Fotokarten mitnehmen, wenn ich die Freude mit Freunden teile. Deshalb habe ich diese App gebaut – damit Fans Karten direkt auf einem 6,5-Zoll-Display zeigen und tauschen können. Ich werde das Projekt weiter pflegen, und der Code bleibt auf GitHub offen. Danke fürs Herunterladen und dafür, dass du Teil dieses Projekts (oder – niedlich gesagt – dieser Familie) bist. Wenn du Fragen oder Ideen zur Verbesserung hast, melde dich gern. — Jimmy Lee';

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
  String get userProfileTitle => 'Benutzereinstellungen';

  @override
  String get userProfileTile => 'Benutzereinstellungen';

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
}
