// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

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
}
