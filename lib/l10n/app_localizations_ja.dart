// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get authSignInWithGoogle => 'Google でサインイン';

  @override
  String get continueAsGuest => 'ゲストとして続行';

  @override
  String get noNetworkGuestTip => '現在オフラインです。ゲストとして利用できます。';

  @override
  String get appTitle => 'Pop Card';

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
  String get languageKo => '韓国語';

  @override
  String get languageDe => 'ドイツ語';

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
  String get accountStatusGuest => 'ゲストモード';

  @override
  String get accountStatusSignedIn => 'ログイン済み';

  @override
  String get accountStatusSignedOut => '未ログイン';

  @override
  String get accountGuestSubtitle => '現在はゲストとして利用中。データはこの端末のみに保存されます';

  @override
  String get accountNoInfo => '（アカウント情報なし）';

  @override
  String get accountBackToLogin => 'ログイン画面へ';

  @override
  String get signOut => 'ログアウト';

  @override
  String get helloDeveloperTitle => 'こんにちは！開発者です';

  @override
  String get helloDeveloperBody =>
      'この小さなサイドプロジェクトを試してくれてありがとう💫 \n\n私は LE SSERAFIM の大ファン（FEARNOT）です！友達にフォトカードの喜びを共有したいけど、たくさんのカードを持ち歩くのは大変なので、このアプリを作りました📱。6.5インチのスマホ1台で簡単にカードを見せたり交換したりできます。\n\nこれからも少しずつアップデートしていくので、ダウンロードして家族（と言ってもいいよね🩷）の一員になってくれて本当にありがとう！もし何かアイデアや意見があれば、いつでも気軽に教えてね💪';

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
  String get welcomeTitle => 'ミニカードへようこそ';

  @override
  String get welcomeSubtitle => '設定とデータを同期するには、サインインまたはアカウント作成してください';

  @override
  String get authSignIn => 'サインイン';

  @override
  String get authRegister => '登録';

  @override
  String get authContinueAsGuest => 'ゲストとして続行';

  @override
  String get authAccount => 'アカウント（メール／任意の文字列）';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authCreateAndSignIn => 'アカウント作成してサインイン';

  @override
  String get authName => '名前';

  @override
  String get authGender => '性別';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => 'その他／無回答';

  @override
  String get birthdayPick => '日付を選択';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => 'サインインに失敗しました';

  @override
  String get errorRegisterFailed => '登録に失敗しました';

  @override
  String get errorPickBirthday => '誕生日を選択してください';

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

  @override
  String get filterAll => 'すべて';

  @override
  String get deleteCategoryTitle => 'カテゴリを削除';

  @override
  String deleteCategoryMessage(Object name) {
    return '「$name」を削除しますか？（すべてのカードからも削除されます）';
  }

  @override
  String deletedCategoryToast(Object name) {
    return 'カテゴリを削除しました：$name';
  }

  @override
  String get searchHint => '名前／カード内容を検索';

  @override
  String get clear => 'クリア';

  @override
  String get noCards => 'カードがありません';

  @override
  String get addCard => 'カードを追加';

  @override
  String get deleteCardTitle => 'カードを削除';

  @override
  String deleteCardMessage(Object title) {
    return '「$title」を削除しますか？';
  }

  @override
  String deletedCardToast(Object title) {
    return '削除しました：$title';
  }

  @override
  String get editCard => 'カードを編集';

  @override
  String get categoryAssignOrAdd => 'カテゴリを割り当て／追加';

  @override
  String get newCardTitle => '新規カード';

  @override
  String get editCardTitle => 'カードを編集';

  @override
  String get nameRequiredLabel => '名前（必須）';

  @override
  String get imageByUrl => 'URL から';

  @override
  String get imageByLocal => 'ローカル写真';

  @override
  String get imageUrl => '画像 URL';

  @override
  String get pickFromGallery => 'ギャラリーから選択';

  @override
  String get quoteOptionalLabel => '引用（任意）';

  @override
  String get pickBirthdayOptional => '誕生日を選択（任意）';

  @override
  String get inputImageUrl => '画像の URL を入力してください';

  @override
  String get downloadFailed => 'ダウンロードに失敗しました';

  @override
  String get pickLocalPhoto => 'ローカル写真を選択してください';

  @override
  String get updatedCardToast => 'カードを更新しました';

  @override
  String get manageCategoriesTitle => 'カテゴリ管理';

  @override
  String get newCategoryNameHint => '新しいカテゴリ名';

  @override
  String get addCategory => 'カテゴリを追加';

  @override
  String get deleteCategoryTooltip => 'カテゴリを削除';

  @override
  String get assignCategoryTitle => 'カテゴリを割り当て';

  @override
  String get confirm => '確認';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return '「$name」を削除しますか？すべてのカードからも削除されます。';
  }

  @override
  String addedCategoryToast(Object name) {
    return 'カテゴリを追加しました：$name';
  }

  @override
  String get noMiniCardsPreviewHint =>
      'まだミニカードはありません。ここをタップするか、上にスワイプして追加してください。';

  @override
  String get detailSwipeHint => '上にスワイプしてミニカードページ（スキャン／QR共有を含む）へ。';

  @override
  String get noMiniCardsEmptyList => '現在、ミニカードはありません。右下の＋をタップして追加してください。';

  @override
  String get miniLocalImageBadge => 'ローカル画像';

  @override
  String get miniHasBackBadge => '裏面画像あり';

  @override
  String get tagsLabel => 'タグ';

  @override
  String tagsCount(int n) {
    return 'タグ $n';
  }

  @override
  String get nameLabel => '名前';

  @override
  String get serialNumber => 'シリアル番号';

  @override
  String get album => 'アルバム';

  @override
  String get addAlbum => 'アルバムを追加';

  @override
  String get enterAlbumName => 'アルバム名を入力';

  @override
  String get cardType => 'カード種別';

  @override
  String get addCardType => 'カード種別を追加';

  @override
  String get enterCardTypeName => 'カード種別名を入力';

  @override
  String get noteLabel => '備考';

  @override
  String get newTagHint => '新しいタグを追加…';

  @override
  String get frontSide => '表面';

  @override
  String get backSide => '裏面';

  @override
  String get frontImageTitle => '表面画像';

  @override
  String get backImageTitleOptional => '裏面画像（任意）';

  @override
  String get frontImageUrlLabel => '表面画像URL';

  @override
  String get backImageUrlLabel => '裏面画像URL';

  @override
  String get clearUrl => 'URLをクリア';

  @override
  String get clearLocal => 'ローカルをクリア';

  @override
  String get clearBackImage => '裏面画像をクリア';

  @override
  String get localPickedLabel => '選択済み：ローカル';

  @override
  String get miniCardEditTitle => 'ミニカードを編集';

  @override
  String get miniCardNewTitle => '新しいミニカード';

  @override
  String get errorFrontImageUrlRequired => '表面画像のURLを入力するか、ローカルに切り替えてください。';

  @override
  String get errorFrontLocalRequired => '表面のローカル写真を選択するか、URLに戻してください。';

  @override
  String get userProfileTitle => 'ユーザー';

  @override
  String get userProfileTile => 'ユーザー';

  @override
  String get nicknameLabel => 'ニックネーム';

  @override
  String get nicknameRequired => 'ニックネームを入力してください';

  @override
  String get notSet => '未設定';

  @override
  String get clearBirthday => '誕生日をクリア';

  @override
  String get userProfileSaved => 'ユーザー設定を保存しました';

  @override
  String get ready => '完了';

  @override
  String get fillNicknameAndBirthday => 'ニックネームと誕生日を入力してください';

  @override
  String get navSocial => 'ソーシャル';

  @override
  String get timeJustNow => 'たった今';

  @override
  String timeMinutesAgo(int n) {
    return '$n 分前';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n 時間前';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n 日前';
  }

  @override
  String get socialFriends => '友達';

  @override
  String get socialHot => '人気';

  @override
  String get socialFollowing => 'フォロー中';

  @override
  String get publish => '投稿';

  @override
  String get socialShareHint => '今なにしてる？';

  @override
  String get leaveACommentHint => 'コメントを入力…';

  @override
  String get commentsTitle => 'コメント';

  @override
  String commentsCount(int n) {
    return 'コメント（$n）';
  }

  @override
  String get addTagHint => 'タグを追加…';

  @override
  String followedTag(Object tag) {
    return '#$tag をフォローしました';
  }

  @override
  String unfollowedTag(Object tag) {
    return '#$tag のフォローを解除しました';
  }

  @override
  String get friendCardsTitle => '友だち名刺';

  @override
  String get addFriendCard => '名刺を追加';

  @override
  String get editFriendCard => '名刺を編集';

  @override
  String get scanQr => 'QRコードをスキャン';

  @override
  String get tapToFlip => 'タップで反転';

  @override
  String get deleteFriendCardTitle => '名刺を削除';

  @override
  String deleteFriendCardMessage(Object name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get followArtistsLabel => 'フォロー中のアーティスト';

  @override
  String limitReached(String text) {
    return '上限に達しました（$text）';
  }

  @override
  String get retry => '再試行';

  @override
  String get offlineBanner => 'オフライン：一部の機能は利用できません';

  @override
  String get manageFollowedTags => 'フォロー中のタグ';

  @override
  String get noFriendsYet => 'まだ友だちがいません';

  @override
  String get friendAddAction => '友だちに追加';

  @override
  String get friendRemoveAction => '友だち解除';

  @override
  String get friendAddedStatus => '追加済み';

  @override
  String get remove => '削除';

  @override
  String get changeAvatar => 'アバターを変更';

  @override
  String get socialLinksTitle => 'ソーシャルリンク';

  @override
  String get showInstagramOnProfile => 'プロフィールに Instagram を表示';

  @override
  String get showFacebookOnProfile => 'プロフィールに Facebook を表示';

  @override
  String get showLineOnProfile => 'プロフィールに LINE を表示';

  @override
  String followedTagsCount(int n) {
    return 'フォロー中のタグ（$n）';
  }

  @override
  String get addFollowedTag => 'フォローするタグを追加';

  @override
  String get addFollowedTagHint => 'タグ名を入力して Enter を押してください';

  @override
  String get manageCards => '名刺を管理';

  @override
  String get phoneLabel => '電話';

  @override
  String get lineLabel => 'LINE';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => '友達やアーティストを検索';

  @override
  String get followedTagsTitle => 'フォロー中のタグ';

  @override
  String get noFollowedTagsYet => 'フォロー中のタグはありません';

  @override
  String get addedFollowedTagToast => 'タグをフォローしました';

  @override
  String addFollowedTagFailed(Object error) {
    return '追加に失敗しました：$error';
  }

  @override
  String get removedFollowedTagToast => 'タグのフォローを解除しました';

  @override
  String removeFollowedTagFailed(Object error) {
    return '削除に失敗しました：$error';
  }

  @override
  String loadFailed(Object error) {
    return '読み込みに失敗しました：$error';
  }

  @override
  String miniCardsOf(Object title) {
    return '$title のミニカード';
  }

  @override
  String get importFromJsonTooltip => 'JSON からインポート';

  @override
  String get exportJsonMultiTooltip => 'JSON をエクスポート（複数）';

  @override
  String get scan => 'スキャン';

  @override
  String get share => '共有';

  @override
  String get shareThisCard => 'このカードを共有';

  @override
  String importedMiniCardsToast(int n) {
    return '$n 枚のミニカードをインポートしました';
  }

  @override
  String get shareMultipleCards => '複数のカードを共有（複数選択）';

  @override
  String get shareMultipleCardsSubtitle => 'カードを選択してから、写真共有または JSON エクスポート';

  @override
  String get shareOneCard => '1 枚を選んで共有…';

  @override
  String get selectCardsForJsonTitle => '共有するカードを選択（JSON）';

  @override
  String get selectCardsForShareOrExportTitle => '共有／エクスポートするカードを選択';

  @override
  String get blockedLocalImageNote => 'ローカル画像を含むため JSON にはエクスポートできません';

  @override
  String shareMultiplePhotos(int n) {
    return '$n 枚の写真を共有';
  }

  @override
  String get exportJson => 'JSON をエクスポート';

  @override
  String get exportJsonSkipLocalHint => 'ローカルのみの画像を含むカードはスキップされます';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return '$total 件の共有を試行、成功 $ok／失敗 $fail';
  }

  @override
  String get shareQrCode => 'QR コードを共有';

  @override
  String get shareQrAutoBackendHint => 'データ量が多い場合は自動でバックエンドモードに切り替わります';

  @override
  String get cannotShareByQr => 'QR では共有できません';

  @override
  String get noImageUrl => '画像 URL がありません';

  @override
  String get noImageUrlPhotoOnly => '画像 URL がないため、写真の直接共有のみ可能です';

  @override
  String get shareThisPhoto => 'この写真を共有';

  @override
  String shareFailed(Object error) {
    return '共有に失敗しました: $error';
  }

  @override
  String get transportBackendHint => 'バックエンドモード（API 経由）';

  @override
  String get transportEmbeddedHint => '埋め込み（ローカル）';

  @override
  String get qrIdOnlyNotice => 'この QR にはカード ID のみが含まれます。受信側はバックエンドから内容を取得します。';

  @override
  String get qrGenerationFailed => 'QR 画像の生成に失敗しました';

  @override
  String get pasteJsonTitle => 'JSON テキストを貼り付け';

  @override
  String get pasteJsonHint =>
      'mini_card_bundle_v2/v1 または mini_card_v2/v1 をサポート';

  @override
  String get import => 'インポート';

  @override
  String importedFromJsonToast(int n) {
    return 'JSON から $n 枚のミニカードをインポートしました';
  }

  @override
  String importFailed(Object error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get cannotExportJsonAllLocal =>
      '選択したカードはすべてローカル画像のみのため、JSON にエクスポートできません';

  @override
  String skippedLocalImagesCount(int n) {
    return 'ローカル画像のみのカード $n 枚をスキップしました';
  }

  @override
  String get close => '閉じる';

  @override
  String get copy => 'コピー';

  @override
  String get copiedJsonToast => 'JSON をコピーしました';

  @override
  String get copyJson => 'JSON をコピー';

  @override
  String get none => 'なし';

  @override
  String get selectCardsToShareTitle => '共有するカードを選択';

  @override
  String get hasImageUrlJsonOk => '画像 URL あり：JSON で送信可能';

  @override
  String get exportJsonOnlyUrlHint =>
      'ヒント：エクスポートされる JSON には画像 URL を持つカードのみ含まれます。ローカルのみの画像はスキップされます。';

  @override
  String get sharePhotos => '写真を共有';

  @override
  String get containsLocalImages => 'ローカル画像を含む';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked 枚は JSON にエクスポートできません。利用可能な $allowed 枚のみをエクスポートしますか？';
  }

  @override
  String get onlyExportUsable => '利用可能なものだけをエクスポート';

  @override
  String get shareMiniCardTitle => 'ミニカードを共有';

  @override
  String get qrCodeTab => 'QR コード';

  @override
  String get qrTooLargeUseJsonHint =>
      'QR コードが表示されない場合、データが大きすぎる可能性があります。JSON の使用を検討してください。';

  @override
  String get scanMiniCardQrTitle => 'ミニカードの QR をスキャン';

  @override
  String get scanFromGallery => 'ギャラリーからスキャン';

  @override
  String get noQrFoundInImage => '画像内に QR が見つかりませんでした';

  @override
  String get qrFormatInvalid => 'QR の形式が不正です';

  @override
  String get qrTypeUnsupported => 'サポートされていない QR 種類です';

  @override
  String fetchFromBackendFailed(Object error) {
    return 'バックエンドからの取得に失敗しました: $error';
  }

  @override
  String get addFollowedTagFailedOffline => 'オフラインです。タグをローカルに追加しました。';

  @override
  String get removeFollowedTagFailedOffline => 'オフラインです。タグをローカルで削除しました。';

  @override
  String get loading => '読み込み中…';

  @override
  String get networkRequiredTitle => 'ネットワーク接続が必要です';

  @override
  String get networkRequiredBody => 'サインインにはインターネット接続が必要です。接続してから、もう一度お試しください。';

  @override
  String get ok => 'OK';

  @override
  String get willSaveAs => '次の名前で保存します';

  @override
  String get alreadyExists => '既に存在します';

  @override
  String get common_about => '概要';

  @override
  String get settings_menu_general => '一般設定';

  @override
  String get settings_menu_user => 'ユーザー設定';

  @override
  String get settings_menu_about => '概要';

  @override
  String get settingsMenuGeneral => '一般設定';

  @override
  String get commonAbout => '概要';

  @override
  String get navMore => 'その他';

  @override
  String get exploreReflow => 'ウィジェットを整列';

  @override
  String get commonAdd => '追加';

  @override
  String get exploreNoPhoto => '写真が未選択です';

  @override
  String get exploreTapToEditQuote => 'タップして引用を編集';

  @override
  String get exploreAdd => '追加';

  @override
  String get exploreAddPhoto => '写真カード';

  @override
  String get exploreAddQuote => '引用カード';

  @override
  String get exploreAddBirthday => '誕生日カウントダウン';

  @override
  String get exploreAddBall => 'ボールを追加';

  @override
  String get exploreAdBuiltIn => '広告は内蔵されています';

  @override
  String get exploreEnterAQuote => '引用文を入力';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonOk => 'OK';

  @override
  String get exploreCountdownTitleHint => 'アイドル／イベント名（例：さくら誕生日）';

  @override
  String get exploreAddBallDialogTitle => 'ボールを追加';

  @override
  String get exploreBallEmojiHint => '絵文字（空なら写真を使用）';

  @override
  String get exploreSize => 'サイズ';

  @override
  String get explorePickPhoto => '写真を選択…';

  @override
  String get explorePickedPhoto => '写真を選択しました';

  @override
  String get navDex => '図鑑';

  @override
  String get dex_title => 'マイ図鑑';

  @override
  String get dex_uncategorized => '未分類';

  @override
  String get dex_searchHint => 'アイドルやカードを検索…';

  @override
  String dex_cardsCount(Object count) {
    return '$count 枚';
  }

  @override
  String get dex_empty => 'まだカードを収集していません';

  @override
  String get zoomIn => '拡大';

  @override
  String get zoomOut => '縮小';

  @override
  String get resetZoom => '拡大率をリセット';

  @override
  String get billing_title => 'サブスクリプションとお支払い';

  @override
  String get plan_free => 'フリー';

  @override
  String get plan_basic => 'ベーシック';

  @override
  String get plan_pro => 'プロ';

  @override
  String get plan_plus => 'プラス';

  @override
  String billing_current_plan(String plan) {
    return '現在のプラン：$plan';
  }

  @override
  String get section_plan_notes => 'プランの説明';

  @override
  String get section_payment_invoice => 'お支払いと領収書（Google Play により提供）';

  @override
  String get section_terms => '利用規約（デモ）';

  @override
  String get upgrade_card_title => '容量をアップして、もっと気軽に収集';

  @override
  String get upgrade_card_desc => '有料プランでローカル画像のアップロード・大容量・複数端末同期が解放されます。';

  @override
  String get badge_coming_soon => '近日公開';

  @override
  String get feature_external_images => 'クラウド容量 5GB（デバイス間同期）';

  @override
  String get feature_small_cloud_space => 'カード分類、カード裏面情報、ミニカード詳細';

  @override
  String get feature_ad_free => '広告なしの没入型体験';

  @override
  String get feature_upload_local_images => 'クラウド容量 10GB（デバイス間同期）';

  @override
  String get feature_priority_support => 'カード分類、カード裏面情報、ミニカード詳細';

  @override
  String get feature_large_storage => 'クラウド容量 50GB（デバイス間同期）';

  @override
  String get feature_album_report => 'カード分類、カード裏面情報、ミニカード詳細';

  @override
  String get feature_roadmap_advance => '上級機能（予告）';

  @override
  String get plan_badge_recommended => 'おすすめ';

  @override
  String price_per_month(Object price) {
    return '$price/月';
  }

  @override
  String get upgrade_now => '今すぐアップグレード';

  @override
  String get manage_plan => 'プラン管理';

  @override
  String get coming_soon_title => '準備中です';

  @override
  String get coming_soon_body =>
      'ローカルクラウド容量は現在リリース準備中です。今はプレースホルダー表示となります。正式版ではローカル画像アップロード・大容量・複数端末同期を提供予定です。お楽しみに！';

  @override
  String get coming_soon_ok => 'OK';

  @override
  String get bullet_free_external => '無料プラン：外部画像（URL）のみ利用可';

  @override
  String get bullet_paid_local_upload => '有料プラン：ローカル画像のアップロードと大容量を提供';

  @override
  String get bullet_future_tiers => '今後、容量の段階を拡充予定';

  @override
  String get bullet_pay_cards => '現在は Google Play の定期購入（アプリ内課金）のみ対応しています';

  @override
  String get bullet_einvoice =>
      '領収書／請求書は Google Play により発行されます。法人向けの請求情報（法人番号等）には対応していません';

  @override
  String get bullet_cancel_anytime => 'いつでも解約可能。次回以降は課金されません';

  @override
  String get bullet_terms => '利用規約・プライバシー・返金ポリシー（後日リンク追加）';

  @override
  String get bullet_abuse => '不正・違法なアップロードはアカウント停止の対象';

  @override
  String get common_ok => 'OK';

  @override
  String get common_okDescription => '汎用のOKボタン';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_cancelDescription => '汎用のキャンセルボタン';

  @override
  String get tutorial_title => '使い方ガイド';

  @override
  String get tutorial_tab_cards => 'カード';

  @override
  String get tutorial_tab_social => 'ソーシャル';

  @override
  String get tutorial_tab_explore => 'エクスプロア';

  @override
  String get tutorial_tab_more => 'その他';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => 'アーティストカードを追加';

  @override
  String get tutorial_cards_tags_addMini => 'ミニカードを追加';

  @override
  String get tutorial_cards_tags_editDelete => '編集 / 削除';

  @override
  String get tutorial_cards_tags_info => 'ミニカード情報';

  @override
  String get tutorial_cards_addArtist_title => '「アーティストカード」を追加';

  @override
  String get tutorial_cards_addArtist_s1 => 'カード画面右下の「＋」をタップ。';

  @override
  String get tutorial_cards_addArtist_s2 => 'ローカル画像を選ぶか、画像URLを貼り付けます。';

  @override
  String get tutorial_cards_addArtist_s3 => '右スワイプ：情報編集、左スワイプ：カード削除。';

  @override
  String get tutorial_cards_addMini_title => '「ミニカード」を追加';

  @override
  String get tutorial_cards_addMini_s1 => '任意の「アーティストカード」をタップして詳細へ。';

  @override
  String get tutorial_cards_addMini_s2 => '下部のミニカード領域をタップ／上スワイプ → ビューアへ。';

  @override
  String get tutorial_cards_addMini_s3 => '最左／最右ページでQR読み取りや編集を開けます。';

  @override
  String get tutorial_cards_addMini_s4 => '編集画面右下の「＋」で追加。同画面で削除も可能。';

  @override
  String get tutorial_cards_info_title => '「ミニカード情報」を管理';

  @override
  String get tutorial_cards_info_s1 => '追加後はビューアに表示。タップで裏返し。';

  @override
  String get tutorial_cards_info_s2 => '裏面右上の「情報」で、名前／番号／アルバム／種類／メモ／タグを編集。';

  @override
  String get tutorial_cards_info_s3 => 'タグで素早く絞り込み、検索精度も向上。';

  @override
  String get tutorial_cards_note_json => 'ヒント：右上からJSONダウンロードと一括インポートに対応。';

  @override
  String get tutorial_social_tags_primary => '友達 / 注目 / フォロー';

  @override
  String get tutorial_social_tags_postComment => '投稿とコメント';

  @override
  String get tutorial_social_tags_lists => 'リスト管理';

  @override
  String get tutorial_social_browse_title => '投稿を閲覧';

  @override
  String get tutorial_social_browse_s1 => '上部タブで「友達」「注目」「フォロー」を切替。';

  @override
  String get tutorial_social_browse_s2 => '各タブで閲覧・いいね・コメントが可能。';

  @override
  String get tutorial_social_post_title => '投稿とコメント';

  @override
  String get tutorial_social_post_s1 => '右下の「えんぴつ」ボタンで投稿。';

  @override
  String get tutorial_social_post_s2 => '投稿は「注目」と「友達」に表示（友達は交流可能）。';

  @override
  String get tutorial_social_list_title => 'リスト管理';

  @override
  String get tutorial_social_list_s1 => '右上の「#」：友達リストを編集。';

  @override
  String get tutorial_social_list_s2 => '右上の「名刺」：フォローリストを編集。';

  @override
  String get tutorial_explore_wall_title => '推し壁紙を自由に作成';

  @override
  String get tutorial_explore_wall_s1 => '写真・スローガン・ステッカーで自分好みに。';

  @override
  String get tutorial_explore_wall_s2 => '「誕生日カウントダウン」ウィジェットも追加可能。';

  @override
  String get tutorial_more_settings_title => '設定とユーザー';

  @override
  String get tutorial_more_settings_s1 => '「設定」：テーマ・言語・通知など。';

  @override
  String get tutorial_more_settings_s2 => '「ユーザー設定」：ニックネーム・アイコン・ログイン方法。';

  @override
  String get tutorial_more_stats_title => '統計';

  @override
  String get tutorial_more_stats_s1 => 'アーティスト数、ミニカード数、出所（ローカル／オンライン）を確認。';

  @override
  String get tutorial_more_stats_s2 => 'ランキングや実績でコレクションの軌跡を記録。';

  @override
  String get tutorial_more_dex_title => '図鑑';

  @override
  String get tutorial_more_dex_s1 => 'すべてのカードを一覧。検索やフィルタに対応。';

  @override
  String get tutorial_faq_q1 => 'ミニカードを一気に追加する方法は？';

  @override
  String get tutorial_faq_a1 =>
      'ミニカード閲覧ページの右上には2つのボタンがあります。左側のボタンはJSONファイルの一括追加に対応し、右側のボタンではそのアーティストのカードJSONファイルをダウンロードできます。';

  @override
  String get tutorial_faq_q2 => 'QR / JSON のインポート場所は？';

  @override
  String get tutorial_faq_a2 => 'ビューアの最左／最右ページ、または「その他」→「インポート」。';

  @override
  String get tutorial_faq_q3 => 'タグの役割は？';

  @override
  String get tutorial_faq_a3 => 'タグで素早く絞り込み、検索もより正確に。';

  @override
  String get tutorial_faq_q4 => '言語とテーマの変更方法は？';

  @override
  String get tutorial_faq_a4 => '「その他 → 設定」でアプリ言語とライト／ダークを切替。';

  @override
  String get tutorial_faq_q5 => '投稿はどこに表示されますか？';

  @override
  String get tutorial_faq_a5 => '「注目」と「友達」に表示。友達が閲覧・交流できます。';

  @override
  String get postHintShareSomething => '何かをシェアしましょう…';

  @override
  String get postAlbum => 'アルバム';

  @override
  String get postPublish => '投稿';

  @override
  String get postTags => 'タグ';

  @override
  String get postAddTagHint => 'タグを追加して Enter を押す';

  @override
  String get postAdd => '追加';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return 'タグは最大 $max 個';
  }

  @override
  String get currentPlan => '現在のプラン';

  @override
  String get filter => '絞り込み';

  @override
  String get filterPanelTitle => 'カードを絞り込む';

  @override
  String get filterClear => 'クリア';

  @override
  String get filterSearchHint => '名前・メモ・シリアル番号で検索…';

  @override
  String get extraInfoSectionTitle => 'その他の情報';

  @override
  String get fieldStageNameLabel => '芸名・ニックネーム';

  @override
  String get fieldGroupLabel => 'グループ・シリーズ';

  @override
  String get fieldOriginLabel => 'カードの入手元';

  @override
  String get fieldNoteLabel => 'メモ';

  @override
  String get profileSectionTitle => '基本プロフィール';

  @override
  String get noQuotePlaceholder => 'まだ一言メッセージがありません';

  @override
  String cardNameAlreadyExists(Object name) {
    return '「$name」という名前のカードは既に存在します。別の名前を入力してください。';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return '「$name」を削除しますか？この人物に関連するすべてのミニカードも削除されます。';
  }

  @override
  String get socialProfileTitle => 'プロフィール';

  @override
  String get userProfileLongPressHint => '長押ししてプロフィールを編集';

  @override
  String get scanFriendQrTitle => '名刺QRをスキャンして友達追加';

  @override
  String get scanFriendQrButtonLabel => '名刺をスキャンして追加';

  @override
  String get filterAlbumNone => 'アルバムなし';

  @override
  String get albumCollectionTitle => 'アルバムコレクション';

  @override
  String get albumCollectionEmptyHint =>
      'まだアルバムがありません。まずはいちばん好きな一枚から追加してみてください。';

  @override
  String get albumSwipeEdit => '編集';

  @override
  String get albumSwipeDelete => '削除';

  @override
  String get albumDialogAddTitle => 'アルバムを追加';

  @override
  String get albumDialogEditTitle => 'アルバムを編集';

  @override
  String get albumDialogFieldTitle => 'アルバム名';

  @override
  String get albumDialogFieldArtist => 'アーティスト／グループ';

  @override
  String get albumDialogFieldYear => '発売年（任意）';

  @override
  String get albumDialogFieldCover => 'ジャケット画像のURL（任意）';

  @override
  String get albumDialogFieldYoutube => 'YouTubeリンク（任意）';

  @override
  String get albumDialogFieldYtmusic => 'YT Musicリンク（任意）';

  @override
  String get albumDialogFieldSpotify => 'Spotifyリンク（任意）';

  @override
  String get albumDialogAddConfirm => '追加';

  @override
  String get albumDialogEditConfirm => '保存';

  @override
  String get albumDeleteConfirmTitle => 'アルバムを削除';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return '「$title」を削除してもよろしいですか？';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return '発売年：$year';
  }

  @override
  String get albumDetailNoStreaming => 'ストリーミングのリンクはまだ設定されていません。';

  @override
  String get albumDetailHint => 'あとでここに曲目リストやコメント、おすすめの理由などを書くことができます。';

  @override
  String get albumTracksSectionTitle => '収録曲';

  @override
  String get albumNoTracksHint => 'このアルバムにはまだ曲が追加されていません。';

  @override
  String get albumFieldLanguage => '言語';

  @override
  String get albumFieldVersion => 'バージョン';

  @override
  String get albumCoverFromUrlLabel => 'URL から';

  @override
  String get albumCoverFromLocalLabel => '端末内の画像';

  @override
  String get albumFieldArtistsLabel => 'アーティスト';

  @override
  String get albumFieldArtistsInputHint => 'アーティスト名を入力して Enter で追加…';

  @override
  String get albumArtistsSuggestionHint => '入力中に候補が表示されます。';

  @override
  String get albumLinksSectionTitle => 'ストリーミングリンク';

  @override
  String get albumLinksCollapsedHint => 'YouTube／YT Music／Spotify…';

  @override
  String get albumAddTrackButtonLabel => '楽曲を追加';

  @override
  String get albumTrackDialogAddTitle => '楽曲を追加';

  @override
  String get albumTrackDialogEditTitle => '楽曲を編集';

  @override
  String get albumTrackFieldTitle => '楽曲名';

  @override
  String get albumTitleRequiredMessage => 'アルバム名を入力してください。';

  @override
  String get albumCoverLocalRequiredMessage => 'ローカルのジャケット画像を選択してください。';

  @override
  String albumDetailLanguage(String lang) {
    return '言語：$lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return 'バージョン：$ver';
  }

  @override
  String get albumTrackImageLabel => '楽曲画像（任意）';

  @override
  String get albumTrackClearImageTooltip => '画像を削除';

  @override
  String get albumTrackImageUseAlbumHint =>
      '画像を設定しない場合、この曲にはアルバムのジャケット画像が表示されます。';

  @override
  String get albumImportJsonTitle => 'アルバム JSON をインポート';

  @override
  String get albumImportJsonHint =>
      'ここにアルバムの JSON を貼り付けてください。1 つのアルバムオブジェクト、または複数アルバムの配列を貼り付けることができます。';

  @override
  String get albumImportSuccess => 'アルバムのインポートが完了しました。';

  @override
  String albumImportFailed(Object error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get albumAddNewAlbum => 'アルバムを追加';

  @override
  String get chatHint => 'メッセージを入力…';

  @override
  String get socialNewConversation => '新しい会話';

  @override
  String get socialMembersHint => 'メンバーを追加…';

  @override
  String get socialConversationNameOptional => '会話名（任意）';

  @override
  String get socialMessagesTitle => 'メッセージ';

  @override
  String get syncMenuTitle => '同期とダウンロード';

  @override
  String get syncMenuSubtitle =>
      'カードとアルバムのデータをクラウドにバックアップ、またはクラウドから端末へダウンロードできます。';

  @override
  String get syncPageTitle => '同期とダウンロード';

  @override
  String get syncPageDesc =>
      'この端末にあるカードとアルバムのデータをクラウドにアップロードしたり、クラウドからダウンロードしてローカルデータを上書きできます。端末を変更したり、アプリを再インストールする前にアップロードすることをおすすめします。';

  @override
  String get syncUploadButton => 'クラウドへアップロード';

  @override
  String get syncDownloadButton => 'クラウドからダウンロード';

  @override
  String get syncCopyButton => 'ファイル内容をコピー';

  @override
  String get syncRefreshPreview => 'プレビューを再読み込み';

  @override
  String get syncPreviewTitle => 'クラウドデータのプレビュー';

  @override
  String get syncPreviewSubtitle => '現在クラウドに保存されている library ファイルの内容（JSON）です。';

  @override
  String get syncPreviewEmptyHint => 'クラウドファイルがありません。「クラウドへアップロード」を押してください。';

  @override
  String get syncNoRemoteData =>
      'クラウドの library ファイルが見つかりません。この端末からアップロードしてください。';

  @override
  String get syncUploadSuccess => 'アップロードと同期が完了しました。';

  @override
  String syncUploadFailed(Object error) {
    return 'アップロード失敗：$error';
  }

  @override
  String get syncDownloadSuccess => 'クラウドからダウンロードし、ローカルに適用しました。';

  @override
  String get syncDownloadFailedGeneric =>
      'クラウドからのダウンロードまたは適用に失敗しました。時間をおいて再試行してください。';

  @override
  String get syncCopyNoData => 'コピーできるデータがありません。まずクラウドファイルを読み込んでください。';

  @override
  String get syncCopySuccess => 'クラウドファイルの内容をクリップボードにコピーしました。';

  @override
  String get syncPaidOnlyHint =>
      'クラウド同期とダウンロードは有料プラン専用です。購読後、完全な library ファイルをバックアップ／ダウンロード／コピーできます。';

  @override
  String get syncNeedSubTitle => '購読が必要です';

  @override
  String get syncNeedSubBody =>
      'クラウド同期とダウンロードは有料プランのみ利用できます。購読ページで Basic / Plus / Pro プランを選択して再試行してください。';

  @override
  String get syncGoToSubscription => '購読ページへ';

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get notice => '通知';

  @override
  String get logout => 'ログアウト';

  @override
  String get socialTabFriends => '友達';

  @override
  String get socialTabHot => '人気';

  @override
  String get socialTabFollowing => 'フォロー中';

  @override
  String get socialEmptyFriends => '友達の投稿はまだありません';

  @override
  String get socialEmptyHot => '人気の投稿はまだありません';

  @override
  String get socialEmptyFollowing => 'フォローしたタグの投稿はまだありません';

  @override
  String socialLoadFailed(Object error) {
    return '読み込みに失敗しました：\\n$error';
  }

  @override
  String get socialPostAction => '投稿';

  @override
  String get socialAddImage => '画像を追加';

  @override
  String get socialRemoveImage => '画像を削除';

  @override
  String get socialComposerTextLabel => '本文';

  @override
  String get socialComposerTagsLabel => 'タグ';

  @override
  String get socialComposerTagsHint => '例：#ive #aespa';

  @override
  String get socialCommentHint => 'コメント…';

  @override
  String get socialNoComments => 'コメントはまだありません';

  @override
  String get socialShowComments => 'コメントを表示';

  @override
  String get socialHideComments => 'コメントを非表示';

  @override
  String get socialDelete => '削除';

  @override
  String get socialDeletePostTitle => '投稿を削除';

  @override
  String get socialDeletePostMessage => 'この投稿を削除しますか？元に戻せません。';

  @override
  String get socialDeleteFailed => '削除に失敗しました';

  @override
  String get socialPostDeleted => '投稿を削除しました';

  @override
  String get socialLikeFailed => 'いいねに失敗しました';

  @override
  String get socialTagAll => 'すべて';

  @override
  String get socialTagControllerNotFound => 'TagFollowController が見つかりません';

  @override
  String get socialUnfollowTagTitle => 'タグのフォロー解除';

  @override
  String socialUnfollowTagMessage(Object tag) {
    return '$tag のフォローを解除しますか？';
  }

  @override
  String socialTagFollowed(Object tag) {
    return '$tag をフォローしました';
  }

  @override
  String socialTagUnfollowed(Object tag) {
    return '$tag のフォローを解除しました';
  }

  @override
  String get socialTimeNow => 'たった今';

  @override
  String socialTimeMinutes(Object m) {
    return '$m分';
  }

  @override
  String socialTimeHours(Object h) {
    return '$h時間';
  }
}
