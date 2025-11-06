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
  String get userProfileTitle => '使用者設定';

  @override
  String get userProfileTile => '使用者設定';

  @override
  String get nicknameLabel => '暱稱';

  @override
  String get nicknameRequired => '暱稱不可空白';

  @override
  String get notSet => '未設定';

  @override
  String get clearBirthday => '清除生日';

  @override
  String get userProfileSaved => '已儲存使用者設定';

  @override
  String get ready => '已完成';

  @override
  String get fillNicknameAndBirthday => '請填寫暱稱與生日';

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
  String get section_payment_invoice => '支払いと請求（デモ）';

  @override
  String get section_terms => '利用規約（デモ）';

  @override
  String get upgrade_card_title => '容量をアップして、もっと気軽に収集';

  @override
  String get upgrade_card_desc => '有料プランでローカル画像のアップロード・大容量・複数端末同期が解放されます。';

  @override
  String get badge_coming_soon => '近日公開';

  @override
  String get feature_external_images => '外部画像（URL）';

  @override
  String get feature_small_cloud_space => '少量クラウド容量';

  @override
  String get feature_multi_device_sync => '複数端末同期';

  @override
  String get feature_upload_local_images => 'ローカル画像アップロード';

  @override
  String get feature_priority_support => '優先サポート';

  @override
  String get feature_large_storage => '大容量クラウド';

  @override
  String get feature_album_report => 'アルバムレポート（予告）';

  @override
  String get feature_roadmap_advance => '高度機能（予告）';

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
  String get bullet_pay_cards => '対応：クレジットカード（VISA／Master／JCB）';

  @override
  String get bullet_einvoice => '国内はクラウド請求書に対応。企業は税番号の入力可';

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
}
