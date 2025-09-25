// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get authSignInWithGoogle => '使用 Google 登入';

  @override
  String get continueAsGuest => '以訪客使用';

  @override
  String get noNetworkGuestTip => '目前離線，您可改以訪客使用';

  @override
  String get appTitle => 'Pop Card';

  @override
  String get navCards => '卡片';

  @override
  String get navExplore => '探索';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageZhTW => '繁體中文';

  @override
  String get languageEn => '英文';

  @override
  String get languageJa => '日文';

  @override
  String get languageKo => '韓語';

  @override
  String get languageDe => '德語';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutDeveloper => '關於開發者';

  @override
  String get developerRole => '開發者';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get versionLabel => '版本';

  @override
  String get birthday => '生日';

  @override
  String get quoteTitle => '給粉絲的一句話';

  @override
  String get fanMiniCards => '粉絲小卡';

  @override
  String get noMiniCardsHint => '尚無小卡，點「編輯」新增。';

  @override
  String get add => '新增';

  @override
  String get editMiniCards => '編輯小卡';

  @override
  String get save => '儲存';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get previewFailed => '預覽失敗';

  @override
  String get favorite => '收藏';

  @override
  String get favorited => '已收藏';

  @override
  String get accountStatusGuest => '訪客模式';

  @override
  String get accountStatusSignedIn => '已登入';

  @override
  String get accountStatusSignedOut => '未登入';

  @override
  String get accountGuestSubtitle => '目前以訪客登入，資料僅存在本機';

  @override
  String get accountNoInfo => '（無帳號資訊）';

  @override
  String get accountBackToLogin => '回到登入頁';

  @override
  String get signOut => '登出';

  @override
  String get helloDeveloperTitle => '嗨！開發者在這裡';

  @override
  String get helloDeveloperBody =>
      '謝謝你願意試試這個小 side project。我是 LE SSERAFIM 的忠實粉絲（FEARNOT），但每次想跟朋友分享喜悅，都不想背一疊小卡，所以做了這個 App——讓大家用一支 6.5 吋手機就能展示、交換小卡。我會持續維護，也會把程式碼開源在 GitHub。再次感謝下載，成為這個專案的一小份子（可愛一點說，就是家人）。如果有任何問題或改進想法，隨時聯絡我。— Jimmy Lee';

  @override
  String get stats_title => '統計';

  @override
  String get stats_overview => '收藏概覽';

  @override
  String get stats_artist_count => '藝人數量';

  @override
  String get stats_card_total => '小卡總數';

  @override
  String get stats_front_source => '正面圖片來源';

  @override
  String stats_cards_per_artist_topN(int n) {
    return '各藝人小卡數（前 $n 名）';
  }

  @override
  String get stats_nav_subtitle => '查看收藏統計：總數、來源分布、各藝人 Top';

  @override
  String get welcomeTitle => '歡迎使用小卡管理';

  @override
  String get welcomeSubtitle => '登入或建立帳號以同步設定與資料';

  @override
  String get authSignIn => '登入';

  @override
  String get authRegister => '註冊';

  @override
  String get authContinueAsGuest => '以訪客登入';

  @override
  String get authAccount => '帳號（Email/任意字串）';

  @override
  String get authPassword => '密碼';

  @override
  String get authCreateAndSignIn => '建立帳號並登入';

  @override
  String get authName => '姓名';

  @override
  String get authGender => '性別';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => '其他/不透露';

  @override
  String get birthdayPick => '選擇日期';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => '登入失敗';

  @override
  String get errorRegisterFailed => '註冊失敗';

  @override
  String get errorPickBirthday => '請選擇生日';

  @override
  String get common_local => '本地';

  @override
  String get common_url => '網址';

  @override
  String get common_unnamed => '（未命名）';

  @override
  String get common_unit_cards => '張';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name（$pinyin）';
  }

  @override
  String get filterAll => '全部';

  @override
  String get deleteCategoryTitle => '刪除分類';

  @override
  String deleteCategoryMessage(Object name) {
    return '確定要刪除「$name」嗎？（會從所有卡片移除）';
  }

  @override
  String deletedCategoryToast(Object name) {
    return '已刪除分類：$name';
  }

  @override
  String get searchHint => '搜尋人名／卡片內容';

  @override
  String get clear => '清除';

  @override
  String get noCards => '沒有卡片';

  @override
  String get addCard => '新增藝人卡';

  @override
  String get deleteCardTitle => '刪除卡片';

  @override
  String deleteCardMessage(Object title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String deletedCardToast(Object title) {
    return '已刪除：$title';
  }

  @override
  String get editCard => '編輯卡片';

  @override
  String get categoryAssignOrAdd => '指派／新增分類';

  @override
  String get newCardTitle => '新增藝人卡';

  @override
  String get editCardTitle => '編輯卡片';

  @override
  String get nameRequiredLabel => '名稱（必填）';

  @override
  String get imageByUrl => '以網址';

  @override
  String get imageByLocal => '本地照片';

  @override
  String get imageUrl => '圖片 URL';

  @override
  String get pickFromGallery => '從相簿選擇';

  @override
  String get quoteOptionalLabel => '語錄（可選）';

  @override
  String get pickBirthdayOptional => '選擇生日（可選）';

  @override
  String get inputImageUrl => '請輸入圖片網址';

  @override
  String get downloadFailed => '下載失敗';

  @override
  String get pickLocalPhoto => '請選擇本地照片';

  @override
  String get updatedCardToast => '已更新卡片';

  @override
  String get manageCategoriesTitle => '管理分類';

  @override
  String get newCategoryNameHint => '新增分類名稱';

  @override
  String get addCategory => '新增分類';

  @override
  String get deleteCategoryTooltip => '刪除分類';

  @override
  String get assignCategoryTitle => '指派分類';

  @override
  String get confirm => '確定';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return '確定刪除「$name」？此分類會從所有卡片移除。';
  }

  @override
  String addedCategoryToast(Object name) {
    return '已新增分類：$name';
  }

  @override
  String get noMiniCardsPreviewHint => '尚無小卡，點此或上滑進入新增。';

  @override
  String get detailSwipeHint => '上滑進入小卡頁（內含掃描／分享 QR）';

  @override
  String get noMiniCardsEmptyList => '目前沒有小卡，點右下＋新增。';

  @override
  String get miniLocalImageBadge => '本地圖片';

  @override
  String get miniHasBackBadge => '含背面圖片';

  @override
  String get tagsLabel => '標籤';

  @override
  String tagsCount(int n) {
    return '標籤 $n';
  }

  @override
  String get nameLabel => '名稱';

  @override
  String get serialNumber => '序號';

  @override
  String get album => '專輯';

  @override
  String get addAlbum => '新增專輯';

  @override
  String get enterAlbumName => '輸入專輯名稱';

  @override
  String get cardType => '卡種';

  @override
  String get addCardType => '新增卡種';

  @override
  String get enterCardTypeName => '輸入卡種名稱';

  @override
  String get noteLabel => '備註';

  @override
  String get newTagHint => '新增標籤…';

  @override
  String get frontSide => '正面';

  @override
  String get backSide => '背面';

  @override
  String get frontImageTitle => '正面圖片';

  @override
  String get backImageTitleOptional => '背面圖片（可留空）';

  @override
  String get frontImageUrlLabel => '正面圖片網址';

  @override
  String get backImageUrlLabel => '背面圖片網址';

  @override
  String get clearUrl => '清除網址';

  @override
  String get clearLocal => '清除本地';

  @override
  String get clearBackImage => '清除背面圖';

  @override
  String get localPickedLabel => '已選：本地';

  @override
  String get miniCardEditTitle => '編輯小卡';

  @override
  String get miniCardNewTitle => '新增小卡';

  @override
  String get errorFrontImageUrlRequired => '請輸入正面圖片網址或切換為本地。';

  @override
  String get errorFrontLocalRequired => '請選擇正面本地照片或切回網址。';

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
  String get navSocial => '社群';

  @override
  String get timeJustNow => '剛剛';

  @override
  String timeMinutesAgo(int n) {
    return '$n 分鐘前';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n 小時前';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n 天前';
  }

  @override
  String get socialFriends => '好友';

  @override
  String get socialHot => '熱門';

  @override
  String get socialFollowing => '追蹤';

  @override
  String get publish => '發佈';

  @override
  String get socialShareHint => '想分享什麼？';

  @override
  String get leaveACommentHint => '留下你的想法…';

  @override
  String get commentsTitle => '留言';

  @override
  String commentsCount(int n) {
    return '留言（$n）';
  }

  @override
  String get addTagHint => '新增標籤…';

  @override
  String followedTag(Object tag) {
    return '已追蹤 #$tag';
  }

  @override
  String unfollowedTag(Object tag) {
    return '已取消追蹤 #$tag';
  }

  @override
  String get friendCardsTitle => '好友名片';

  @override
  String get addFriendCard => '新增名片';

  @override
  String get editFriendCard => '編輯名片';

  @override
  String get scanQr => '掃描 QRCode';

  @override
  String get tapToFlip => '點擊可翻面';

  @override
  String get deleteFriendCardTitle => '刪除名片';

  @override
  String deleteFriendCardMessage(Object name) {
    return '確定刪除「$name」嗎？';
  }

  @override
  String get followArtistsLabel => '追蹤的藝人';

  @override
  String limitReached(String text) {
    return '已達上限（$text）';
  }

  @override
  String get retry => '重試';

  @override
  String get offlineBanner => '離線中：部分功能不可用';

  @override
  String get manageFollowedTags => '追蹤標籤';

  @override
  String get noFriendsYet => '尚未加入任何好友';

  @override
  String get friendAddAction => '加入好友';

  @override
  String get friendRemoveAction => '解除好友';

  @override
  String get friendAddedStatus => '已加入';

  @override
  String get remove => '移除';

  @override
  String get changeAvatar => '更換頭像';

  @override
  String get socialLinksTitle => '社群連結';

  @override
  String get showInstagramOnProfile => '在個人頁顯示 Instagram';

  @override
  String get showFacebookOnProfile => '在個人頁顯示 Facebook';

  @override
  String get showLineOnProfile => '在個人頁顯示 Line';

  @override
  String followedTagsCount(int n) {
    return '追蹤的標籤（$n）';
  }

  @override
  String get addFollowedTag => '新增追蹤標籤';

  @override
  String get addFollowedTagHint => '輸入標籤名稱，按 Enter 加入';

  @override
  String get manageCards => '管理名片';

  @override
  String get phoneLabel => '電話';

  @override
  String get lineLabel => 'LINE';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => '搜尋好友或藝人';

  @override
  String get followedTagsTitle => '追蹤的標籤';

  @override
  String get noFollowedTagsYet => '尚未追蹤任何標籤';

  @override
  String get addedFollowedTagToast => '已加入追蹤標籤';

  @override
  String addFollowedTagFailed(Object error) {
    return '新增失敗：$error';
  }

  @override
  String get removedFollowedTagToast => '已移除追蹤標籤';

  @override
  String removeFollowedTagFailed(Object error) {
    return '移除失敗：$error';
  }

  @override
  String loadFailed(Object error) {
    return '讀取失敗：$error';
  }

  @override
  String miniCardsOf(Object title) {
    return '$title 的小卡';
  }

  @override
  String get importFromJsonTooltip => '從 JSON 匯入';

  @override
  String get exportJsonMultiTooltip => '匯出 JSON（多張）';

  @override
  String get scan => '掃描';

  @override
  String get share => '分享';

  @override
  String get shareThisCard => '分享此卡';

  @override
  String importedMiniCardsToast(int n) {
    return '已匯入 $n 張小卡';
  }

  @override
  String get shareMultipleCards => '分享多張卡片（多選）';

  @override
  String get shareMultipleCardsSubtitle => '先勾選卡片，之後分享照片或匯出 JSON';

  @override
  String get shareOneCard => '選一張分享…';

  @override
  String get selectCardsForJsonTitle => '選擇要分享的卡片（JSON）';

  @override
  String get selectCardsForShareOrExportTitle => '選擇要分享／匯出的卡片';

  @override
  String get blockedLocalImageNote => '包含本地圖片；無法匯出為 JSON';

  @override
  String shareMultiplePhotos(int n) {
    return '分享 $n 張照片';
  }

  @override
  String get exportJson => '匯出 JSON';

  @override
  String get exportJsonSkipLocalHint => '只含本地圖片的卡片將被略過';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return '已嘗試分享 $total 張，成功 $ok／失敗 $fail';
  }

  @override
  String get shareQrCode => '分享 QR code';

  @override
  String get shareQrAutoBackendHint => '資料過大會自動切換為後端模式';

  @override
  String get cannotShareByQr => '無法以 QR 分享';

  @override
  String get noImageUrl => '沒有圖片網址';

  @override
  String get noImageUrlPhotoOnly => '沒有圖片網址；僅能直接分享照片';

  @override
  String get shareThisPhoto => '分享此張照片';

  @override
  String shareFailed(Object error) {
    return '分享失敗：$error';
  }

  @override
  String get transportBackendHint => '後端模式（透過 API）';

  @override
  String get transportEmbeddedHint => '內嵌（本地）';

  @override
  String get qrIdOnlyNotice => '此 QR 僅包含卡片 ID。接收端會向後端取得完整內容。';

  @override
  String get qrGenerationFailed => '產生 QR 影像失敗';

  @override
  String get pasteJsonTitle => '貼上 JSON 文字';

  @override
  String get pasteJsonHint => '支援 mini_card_bundle_v2/v1 或 mini_card_v2/v1';

  @override
  String get import => '匯入';

  @override
  String importedFromJsonToast(int n) {
    return '已自 JSON 匯入 $n 張小卡';
  }

  @override
  String importFailed(Object error) {
    return '匯入失敗：$error';
  }

  @override
  String get cannotExportJsonAllLocal => '所選卡片皆為僅含本地圖片，無法匯出為 JSON';

  @override
  String skippedLocalImagesCount(int n) {
    return '已略過 $n 張僅含本地圖片的卡片';
  }

  @override
  String get close => '關閉';

  @override
  String get copy => '複製';

  @override
  String get copiedJsonToast => '已複製 JSON';

  @override
  String get copyJson => '複製 JSON';

  @override
  String get none => '無';

  @override
  String get selectCardsToShareTitle => '選擇要分享的卡片';

  @override
  String get hasImageUrlJsonOk => '有圖片網址；可用 JSON 傳送';

  @override
  String get exportJsonOnlyUrlHint => '提示：匯出的 JSON 只包含有圖片網址的卡片；僅本地圖片將被略過。';

  @override
  String get sharePhotos => '分享照片';

  @override
  String get containsLocalImages => '包含本地圖片';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked 張卡片無法匯出為 JSON。是否只匯出可用的 $allowed 張？';
  }

  @override
  String get onlyExportUsable => '僅匯出可用項目';

  @override
  String get shareMiniCardTitle => '分享小卡';

  @override
  String get qrCodeTab => 'QR code';

  @override
  String get qrTooLargeUseJsonHint => '若 QR 無法顯示，可能資料過大，建議改用 JSON。';

  @override
  String get scanMiniCardQrTitle => '掃描小卡 QR';

  @override
  String get scanFromGallery => '從相簿掃描';

  @override
  String get noQrFoundInImage => '圖片中未偵測到 QR';

  @override
  String get qrFormatInvalid => 'QR 格式不正確';

  @override
  String get qrTypeUnsupported => '不支援的 QR 類型';

  @override
  String fetchFromBackendFailed(Object error) {
    return '向後端取資料失敗：$error';
  }

  @override
  String get addFollowedTagFailedOffline => '目前離線，已先在本機加入標籤';

  @override
  String get removeFollowedTagFailedOffline => '目前離線，已先在本機移除標籤';

  @override
  String get loading => '載入中…';

  @override
  String get networkRequiredTitle => '需要網路連線';

  @override
  String get networkRequiredBody => '登入需要網路連線，請連線後再試一次。';

  @override
  String get ok => '知道了';

  @override
  String get willSaveAs => '將會儲存為';

  @override
  String get alreadyExists => '已存在';

  @override
  String get common_about => '關於';

  @override
  String get settings_menu_general => '一般設定';

  @override
  String get settings_menu_user => '使用者設定';

  @override
  String get settings_menu_about => '關於';

  @override
  String get settingsMenuGeneral => '一般設定';

  @override
  String get commonAbout => '關於';

  @override
  String get navMore => '更多';

  @override
  String get exploreReflow => '元件歸位';

  @override
  String get commonAdd => '新增';

  @override
  String get exploreNoPhoto => '未選擇照片';

  @override
  String get exploreTapToEditQuote => '點一下編輯引言';

  @override
  String get exploreAdd => '新增';

  @override
  String get exploreAddPhoto => '照片卡';

  @override
  String get exploreAddQuote => '引言卡';

  @override
  String get exploreAddBirthday => '生日倒數';

  @override
  String get exploreAddBall => '新增小球';

  @override
  String get exploreAdBuiltIn => '廣告已內建';

  @override
  String get exploreEnterAQuote => '輸入一句話';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '確定';

  @override
  String get exploreCountdownTitleHint => '偶像／事件名稱（例如：Sakura 生日）';

  @override
  String get exploreAddBallDialogTitle => '新增小球';

  @override
  String get exploreBallEmojiHint => 'Emoji（留空則使用相片）';

  @override
  String get exploreSize => '大小';

  @override
  String get explorePickPhoto => '選擇相片…';

  @override
  String get explorePickedPhoto => '已選擇相片';

  @override
  String get navDex => '圖鑑';

  @override
  String get dex_title => '我的圖鑑';

  @override
  String get dex_uncategorized => '未分類';

  @override
  String get dex_searchHint => '搜尋偶像或卡片…';

  @override
  String dex_cardsCount(Object count) {
    return '$count 張';
  }

  @override
  String get dex_empty => '目前還沒有蒐集到卡片';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '縮小';

  @override
  String get resetZoom => '重設縮放';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get authSignInWithGoogle => '使用 Google 登入';

  @override
  String get continueAsGuest => '以訪客使用';

  @override
  String get noNetworkGuestTip => '目前離線，您可改以訪客使用';

  @override
  String get appTitle => 'Pop Card';

  @override
  String get navCards => '卡片';

  @override
  String get navExplore => '探索';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get theme => '主題';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '語言';

  @override
  String get languageSystem => '跟隨系統';

  @override
  String get languageZhTW => '繁體中文';

  @override
  String get languageEn => '英文';

  @override
  String get languageJa => '日文';

  @override
  String get languageKo => '韓語';

  @override
  String get languageDe => '德語';

  @override
  String get aboutTitle => '關於';

  @override
  String get aboutDeveloper => '關於開發者';

  @override
  String get developerRole => '開發者';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get versionLabel => '版本';

  @override
  String get birthday => '生日';

  @override
  String get quoteTitle => '給粉絲的一句話';

  @override
  String get fanMiniCards => '粉絲小卡';

  @override
  String get noMiniCardsHint => '尚無小卡，點「編輯」新增。';

  @override
  String get add => '新增';

  @override
  String get editMiniCards => '編輯小卡';

  @override
  String get save => '儲存';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get cancel => '取消';

  @override
  String get previewFailed => '預覽失敗';

  @override
  String get favorite => '收藏';

  @override
  String get favorited => '已收藏';

  @override
  String get accountStatusGuest => '訪客模式';

  @override
  String get accountStatusSignedIn => '已登入';

  @override
  String get accountStatusSignedOut => '未登入';

  @override
  String get accountGuestSubtitle => '目前以訪客登入，資料僅存在本機';

  @override
  String get accountNoInfo => '（無帳號資訊）';

  @override
  String get accountBackToLogin => '回到登入頁';

  @override
  String get signOut => '登出';

  @override
  String get helloDeveloperTitle => '嗨！開發者在這裡';

  @override
  String get helloDeveloperBody =>
      '謝謝你願意試試這個小 side project。我是 LE SSERAFIM 的忠實粉絲（FEARNOT），但每次想跟朋友分享喜悅，都不想背一疊小卡，所以做了這個 App——讓大家用一支 6.5 吋手機就能展示、交換小卡。我會持續維護，也會把程式碼開源在 GitHub。再次感謝下載，成為這個專案的一小份子（可愛一點說，就是家人）。如果有任何問題或改進想法，隨時聯絡我。— Jimmy Lee';

  @override
  String get stats_title => '統計';

  @override
  String get stats_overview => '收藏概覽';

  @override
  String get stats_artist_count => '藝人數量';

  @override
  String get stats_card_total => '小卡總數';

  @override
  String get stats_front_source => '正面圖片來源';

  @override
  String stats_cards_per_artist_topN(int n) {
    return '各藝人小卡數（前 $n 名）';
  }

  @override
  String get stats_nav_subtitle => '查看收藏統計：總數、來源分布、各藝人 Top';

  @override
  String get welcomeTitle => '歡迎使用小卡管理';

  @override
  String get welcomeSubtitle => '登入或建立帳號以同步設定與資料';

  @override
  String get authSignIn => '登入';

  @override
  String get authRegister => '註冊';

  @override
  String get authContinueAsGuest => '以訪客登入';

  @override
  String get authAccount => '帳號（Email/任意字串）';

  @override
  String get authPassword => '密碼';

  @override
  String get authCreateAndSignIn => '建立帳號並登入';

  @override
  String get authName => '姓名';

  @override
  String get authGender => '性別';

  @override
  String get genderMale => '男性';

  @override
  String get genderFemale => '女性';

  @override
  String get genderOther => '其他/不透露';

  @override
  String get birthdayPick => '選擇日期';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => '登入失敗';

  @override
  String get errorRegisterFailed => '註冊失敗';

  @override
  String get errorPickBirthday => '請選擇生日';

  @override
  String get common_local => '本地';

  @override
  String get common_url => '網址';

  @override
  String get common_unnamed => '（未命名）';

  @override
  String get common_unit_cards => '張';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name（$pinyin）';
  }

  @override
  String get filterAll => '全部';

  @override
  String get deleteCategoryTitle => '刪除分類';

  @override
  String deleteCategoryMessage(Object name) {
    return '確定要刪除「$name」嗎？（會從所有卡片移除）';
  }

  @override
  String deletedCategoryToast(Object name) {
    return '已刪除分類：$name';
  }

  @override
  String get searchHint => '搜尋人名／卡片內容';

  @override
  String get clear => '清除';

  @override
  String get noCards => '沒有卡片';

  @override
  String get addCard => '新增藝人卡';

  @override
  String get deleteCardTitle => '刪除卡片';

  @override
  String deleteCardMessage(Object title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String deletedCardToast(Object title) {
    return '已刪除：$title';
  }

  @override
  String get editCard => '編輯卡片';

  @override
  String get categoryAssignOrAdd => '指派／新增分類';

  @override
  String get newCardTitle => '新增藝人卡';

  @override
  String get editCardTitle => '編輯卡片';

  @override
  String get nameRequiredLabel => '名稱（必填）';

  @override
  String get imageByUrl => '以網址';

  @override
  String get imageByLocal => '本地照片';

  @override
  String get imageUrl => '圖片 URL';

  @override
  String get pickFromGallery => '從相簿選擇';

  @override
  String get quoteOptionalLabel => '語錄（可選）';

  @override
  String get pickBirthdayOptional => '選擇生日（可選）';

  @override
  String get inputImageUrl => '請輸入圖片網址';

  @override
  String get downloadFailed => '下載失敗';

  @override
  String get pickLocalPhoto => '請選擇本地照片';

  @override
  String get updatedCardToast => '已更新卡片';

  @override
  String get manageCategoriesTitle => '管理分類';

  @override
  String get newCategoryNameHint => '新增分類名稱';

  @override
  String get addCategory => '新增分類';

  @override
  String get deleteCategoryTooltip => '刪除分類';

  @override
  String get assignCategoryTitle => '指派分類';

  @override
  String get confirm => '確定';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return '確定刪除「$name」？此分類會從所有卡片移除。';
  }

  @override
  String addedCategoryToast(Object name) {
    return '已新增分類：$name';
  }

  @override
  String get noMiniCardsPreviewHint => '尚無小卡，點此或上滑進入新增。';

  @override
  String get detailSwipeHint => '上滑進入小卡頁（內含掃描／分享 QR）';

  @override
  String get noMiniCardsEmptyList => '目前沒有小卡，點右下＋新增。';

  @override
  String get miniLocalImageBadge => '本地圖片';

  @override
  String get miniHasBackBadge => '含背面圖片';

  @override
  String get tagsLabel => '標籤';

  @override
  String tagsCount(int n) {
    return '標籤 $n';
  }

  @override
  String get nameLabel => '名稱';

  @override
  String get serialNumber => '序號';

  @override
  String get album => '專輯';

  @override
  String get addAlbum => '新增專輯';

  @override
  String get enterAlbumName => '輸入專輯名稱';

  @override
  String get cardType => '卡種';

  @override
  String get addCardType => '新增卡種';

  @override
  String get enterCardTypeName => '輸入卡種名稱';

  @override
  String get noteLabel => '備註';

  @override
  String get newTagHint => '新增標籤…';

  @override
  String get frontSide => '正面';

  @override
  String get backSide => '背面';

  @override
  String get frontImageTitle => '正面圖片';

  @override
  String get backImageTitleOptional => '背面圖片（可留空）';

  @override
  String get frontImageUrlLabel => '正面圖片網址';

  @override
  String get backImageUrlLabel => '背面圖片網址';

  @override
  String get clearUrl => '清除網址';

  @override
  String get clearLocal => '清除本地';

  @override
  String get clearBackImage => '清除背面圖';

  @override
  String get localPickedLabel => '已選：本地';

  @override
  String get miniCardEditTitle => '編輯小卡';

  @override
  String get miniCardNewTitle => '新增小卡';

  @override
  String get errorFrontImageUrlRequired => '請輸入正面圖片網址或切換為本地。';

  @override
  String get errorFrontLocalRequired => '請選擇正面本地照片或切回網址。';

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
  String get navSocial => '社群';

  @override
  String get timeJustNow => '剛剛';

  @override
  String timeMinutesAgo(int n) {
    return '$n 分鐘前';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n 小時前';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n 天前';
  }

  @override
  String get socialFriends => '好友';

  @override
  String get socialHot => '熱門';

  @override
  String get socialFollowing => '追蹤';

  @override
  String get publish => '發佈';

  @override
  String get socialShareHint => '想分享什麼？';

  @override
  String get leaveACommentHint => '留下你的想法…';

  @override
  String get commentsTitle => '留言';

  @override
  String commentsCount(int n) {
    return '留言（$n）';
  }

  @override
  String get addTagHint => '新增標籤…';

  @override
  String followedTag(Object tag) {
    return '已追蹤 #$tag';
  }

  @override
  String unfollowedTag(Object tag) {
    return '已取消追蹤 #$tag';
  }

  @override
  String get friendCardsTitle => '好友名片';

  @override
  String get addFriendCard => '新增名片';

  @override
  String get editFriendCard => '編輯名片';

  @override
  String get scanQr => '掃描 QRCode';

  @override
  String get tapToFlip => '點擊可翻面';

  @override
  String get deleteFriendCardTitle => '刪除名片';

  @override
  String deleteFriendCardMessage(Object name) {
    return '確定刪除「$name」嗎？';
  }

  @override
  String get followArtistsLabel => '追蹤的藝人';

  @override
  String limitReached(String text) {
    return '已達上限（$text）';
  }

  @override
  String get retry => '重試';

  @override
  String get offlineBanner => '離線中：部分功能不可用';

  @override
  String get manageFollowedTags => '追蹤標籤';

  @override
  String get noFriendsYet => '尚未加入任何好友';

  @override
  String get friendAddAction => '加入好友';

  @override
  String get friendRemoveAction => '解除好友';

  @override
  String get friendAddedStatus => '已加入';

  @override
  String get remove => '移除';

  @override
  String get changeAvatar => '更換頭像';

  @override
  String get socialLinksTitle => '社群連結';

  @override
  String get showInstagramOnProfile => '在個人頁顯示 Instagram';

  @override
  String get showFacebookOnProfile => '在個人頁顯示 Facebook';

  @override
  String get showLineOnProfile => '在個人頁顯示 Line';

  @override
  String followedTagsCount(int n) {
    return '追蹤的標籤（$n）';
  }

  @override
  String get addFollowedTag => '新增追蹤標籤';

  @override
  String get addFollowedTagHint => '輸入標籤名稱，按 Enter 加入';

  @override
  String get manageCards => '管理名片';

  @override
  String get phoneLabel => '電話';

  @override
  String get lineLabel => 'LINE';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => '搜尋好友或藝人';

  @override
  String get followedTagsTitle => '追蹤的標籤';

  @override
  String get noFollowedTagsYet => '尚未追蹤任何標籤';

  @override
  String get addedFollowedTagToast => '已加入追蹤標籤';

  @override
  String addFollowedTagFailed(Object error) {
    return '新增失敗：$error';
  }

  @override
  String get removedFollowedTagToast => '已移除追蹤標籤';

  @override
  String removeFollowedTagFailed(Object error) {
    return '移除失敗：$error';
  }

  @override
  String loadFailed(Object error) {
    return '讀取失敗：$error';
  }

  @override
  String miniCardsOf(Object title) {
    return '$title 的小卡';
  }

  @override
  String get importFromJsonTooltip => '從 JSON 匯入';

  @override
  String get exportJsonMultiTooltip => '匯出 JSON（多張）';

  @override
  String get scan => '掃描';

  @override
  String get share => '分享';

  @override
  String get shareThisCard => '分享此卡';

  @override
  String importedMiniCardsToast(int n) {
    return '已匯入 $n 張小卡';
  }

  @override
  String get shareMultipleCards => '分享多張卡片（多選）';

  @override
  String get shareMultipleCardsSubtitle => '先勾選卡片，之後分享照片或匯出 JSON';

  @override
  String get shareOneCard => '選一張分享…';

  @override
  String get selectCardsForJsonTitle => '選擇要分享的卡片（JSON）';

  @override
  String get selectCardsForShareOrExportTitle => '選擇要分享／匯出的卡片';

  @override
  String get blockedLocalImageNote => '包含本地圖片；無法匯出為 JSON';

  @override
  String shareMultiplePhotos(int n) {
    return '分享 $n 張照片';
  }

  @override
  String get exportJson => '匯出 JSON';

  @override
  String get exportJsonSkipLocalHint => '只含本地圖片的卡片將被略過';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return '已嘗試分享 $total 張，成功 $ok／失敗 $fail';
  }

  @override
  String get shareQrCode => '分享 QR code';

  @override
  String get shareQrAutoBackendHint => '資料過大會自動切換為後端模式';

  @override
  String get cannotShareByQr => '無法以 QR 分享';

  @override
  String get noImageUrl => '沒有圖片網址';

  @override
  String get noImageUrlPhotoOnly => '沒有圖片網址；僅能直接分享照片';

  @override
  String get shareThisPhoto => '分享此張照片';

  @override
  String shareFailed(Object error) {
    return '分享失敗：$error';
  }

  @override
  String get transportBackendHint => '後端模式（透過 API）';

  @override
  String get transportEmbeddedHint => '內嵌（本地）';

  @override
  String get qrIdOnlyNotice => '此 QR 僅包含卡片 ID。接收端會向後端取得完整內容。';

  @override
  String get qrGenerationFailed => '產生 QR 影像失敗';

  @override
  String get pasteJsonTitle => '貼上 JSON 文字';

  @override
  String get pasteJsonHint => '支援 mini_card_bundle_v2/v1 或 mini_card_v2/v1';

  @override
  String get import => '匯入';

  @override
  String importedFromJsonToast(int n) {
    return '已自 JSON 匯入 $n 張小卡';
  }

  @override
  String importFailed(Object error) {
    return '匯入失敗：$error';
  }

  @override
  String get cannotExportJsonAllLocal => '所選卡片皆為僅含本地圖片，無法匯出為 JSON';

  @override
  String skippedLocalImagesCount(int n) {
    return '已略過 $n 張僅含本地圖片的卡片';
  }

  @override
  String get close => '關閉';

  @override
  String get copy => '複製';

  @override
  String get copiedJsonToast => '已複製 JSON';

  @override
  String get copyJson => '複製 JSON';

  @override
  String get none => '無';

  @override
  String get selectCardsToShareTitle => '選擇要分享的卡片';

  @override
  String get hasImageUrlJsonOk => '有圖片網址；可用 JSON 傳送';

  @override
  String get exportJsonOnlyUrlHint => '提示：匯出的 JSON 只包含有圖片網址的卡片；僅本地圖片將被略過。';

  @override
  String get sharePhotos => '分享照片';

  @override
  String get containsLocalImages => '包含本地圖片';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked 張卡片無法匯出為 JSON。是否只匯出可用的 $allowed 張？';
  }

  @override
  String get onlyExportUsable => '僅匯出可用項目';

  @override
  String get shareMiniCardTitle => '分享小卡';

  @override
  String get qrCodeTab => 'QR code';

  @override
  String get qrTooLargeUseJsonHint => '若 QR 無法顯示，可能資料過大，建議改用 JSON。';

  @override
  String get scanMiniCardQrTitle => '掃描小卡 QR';

  @override
  String get scanFromGallery => '從相簿掃描';

  @override
  String get noQrFoundInImage => '圖片中未偵測到 QR';

  @override
  String get qrFormatInvalid => 'QR 格式不正確';

  @override
  String get qrTypeUnsupported => '不支援的 QR 類型';

  @override
  String fetchFromBackendFailed(Object error) {
    return '向後端取資料失敗：$error';
  }

  @override
  String get addFollowedTagFailedOffline => '目前離線，已先在本機加入標籤';

  @override
  String get removeFollowedTagFailedOffline => '目前離線，已先在本機移除標籤';

  @override
  String get loading => '載入中…';

  @override
  String get networkRequiredTitle => '需要網路連線';

  @override
  String get networkRequiredBody => '登入需要網路連線，請連線後再試一次。';

  @override
  String get ok => '知道了';

  @override
  String get willSaveAs => '將會儲存為';

  @override
  String get alreadyExists => '已存在';

  @override
  String get common_about => '關於';

  @override
  String get settings_menu_general => '一般設定';

  @override
  String get settings_menu_user => '使用者設定';

  @override
  String get settings_menu_about => '關於';

  @override
  String get settingsMenuGeneral => '一般設定';

  @override
  String get commonAbout => '關於';

  @override
  String get navMore => '更多';

  @override
  String get exploreReflow => '元件歸位';

  @override
  String get commonAdd => '新增';

  @override
  String get exploreNoPhoto => '未選擇照片';

  @override
  String get exploreTapToEditQuote => '點一下編輯引言';

  @override
  String get exploreAdd => '新增';

  @override
  String get exploreAddPhoto => '照片卡';

  @override
  String get exploreAddQuote => '引言卡';

  @override
  String get exploreAddBirthday => '生日倒數';

  @override
  String get exploreAddBall => '新增小球';

  @override
  String get exploreAdBuiltIn => '廣告已內建';

  @override
  String get exploreEnterAQuote => '輸入一句話';

  @override
  String get commonCancel => '取消';

  @override
  String get commonOk => '確定';

  @override
  String get exploreCountdownTitleHint => '偶像／事件名稱（例如：Sakura 生日）';

  @override
  String get exploreAddBallDialogTitle => '新增小球';

  @override
  String get exploreBallEmojiHint => 'Emoji（留空則使用相片）';

  @override
  String get exploreSize => '大小';

  @override
  String get explorePickPhoto => '選擇相片…';

  @override
  String get explorePickedPhoto => '已選擇相片';

  @override
  String get navDex => '圖鑑';

  @override
  String get dex_title => '我的圖鑑';

  @override
  String get dex_uncategorized => '未分類';

  @override
  String get dex_searchHint => '搜尋偶像或卡片…';

  @override
  String dex_cardsCount(Object count) {
    return '$count 張';
  }

  @override
  String get dex_empty => '目前還沒有蒐集到卡片';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '縮小';

  @override
  String get resetZoom => '重設縮放';
}
