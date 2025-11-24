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
      '謝謝你願意試試這個小 side project。我是 LE SSERAFIM 的忠實粉絲（FEARNOT），但每次想跟朋友分享喜悅，都不想背一疊小卡，所以做了這個 App——讓大家用一支 6.5 吋手機就能展示、交換小卡。我會持續維護，再次感謝下載，成為這個專案的一小份子（可愛一點說，就是家人）。如果有任何問題或改進想法，隨時聯絡我。— Jimmy Lee';

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
  String get userProfileTitle => '使用者';

  @override
  String get userProfileTile => '使用者';

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

  @override
  String get billing_title => '訂閱與付款';

  @override
  String get plan_free => '免費';

  @override
  String get plan_basic => '基本';

  @override
  String get plan_pro => '專業';

  @override
  String get plan_plus => '進階';

  @override
  String billing_current_plan(String plan) {
    return '目前方案：$plan';
  }

  @override
  String get section_plan_notes => '方案說明';

  @override
  String get section_payment_invoice => '付款與發票（由 Google Play 提供）';

  @override
  String get section_terms => '條款（示意）';

  @override
  String get upgrade_card_title => '升級空間，收藏無負擔';

  @override
  String get upgrade_card_desc => '付費方案將開放本地圖片上傳與更大空間，並支援多裝置同步。';

  @override
  String get badge_coming_soon => '即將上線';

  @override
  String get feature_external_images => '雲端空間 5 GB ( 跨裝置同步 )';

  @override
  String get feature_small_cloud_space => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_ad_free => '無廣告沉浸體驗';

  @override
  String get feature_upload_local_images => '雲端空間 10 GB ( 跨裝置同步 )';

  @override
  String get feature_priority_support => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_large_storage => '雲端空間 50 GB ( 跨裝置同步 )';

  @override
  String get feature_album_report => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_roadmap_advance => '進階功能（預告）';

  @override
  String get plan_badge_recommended => '推薦';

  @override
  String price_per_month(Object price) {
    return '$price/月';
  }

  @override
  String get upgrade_now => '立即升級';

  @override
  String get manage_plan => '管理方案';

  @override
  String get coming_soon_title => '功能即將開放';

  @override
  String get coming_soon_body =>
      '目前「本地雲端空間」仍在加緊上線準備中，現在僅做佔位展示。正式版本將開放本地圖片上傳、更大容量與多裝置同步，敬請期待！';

  @override
  String get coming_soon_ok => '好';

  @override
  String get bullet_free_external => '免費方案：僅允許使用「外部圖片（網址）」';

  @override
  String get bullet_paid_local_upload => '付費方案：可上傳本地圖片到雲端，提供更大容量';

  @override
  String get bullet_future_tiers => '未來將提供更多容量級距';

  @override
  String get bullet_pay_cards => '目前僅支援 Google Play 內建訂閱與付款';

  @override
  String get bullet_einvoice => '收據／發票由 Google Play 開立；企業統編不適用';

  @override
  String get bullet_cancel_anytime => '可隨時取消，下期不續扣';

  @override
  String get bullet_terms => '服務條款、隱私權政策、退款政策（之後補連結）';

  @override
  String get bullet_abuse => '濫用上傳（如違法內容）將被停權';

  @override
  String get common_ok => '確定';

  @override
  String get common_okDescription => '通用確定按鈕';

  @override
  String get common_cancel => '取消';

  @override
  String get common_cancelDescription => '通用取消按鈕';

  @override
  String get tutorial_title => '使用教學';

  @override
  String get tutorial_tab_cards => '卡片';

  @override
  String get tutorial_tab_social => '社群';

  @override
  String get tutorial_tab_explore => '探索';

  @override
  String get tutorial_tab_more => '更多';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => '新增藝人卡';

  @override
  String get tutorial_cards_tags_addMini => '新增小卡';

  @override
  String get tutorial_cards_tags_editDelete => '編輯 / 刪除';

  @override
  String get tutorial_cards_tags_info => '小卡資訊';

  @override
  String get tutorial_cards_addArtist_title => '新增「藝人卡」';

  @override
  String get tutorial_cards_addArtist_s1 => '在卡片頁右下角點「＋ 新增藝人卡」。';

  @override
  String get tutorial_cards_addArtist_s2 => '可選本機圖片或貼上網路圖片網址。';

  @override
  String get tutorial_cards_addArtist_s3 => '向右滑：編輯藝人資訊；向左滑：刪除藝人卡。';

  @override
  String get tutorial_cards_addMini_title => '新增「小卡」';

  @override
  String get tutorial_cards_addMini_s1 => '點任一「藝人卡」進入內容。';

  @override
  String get tutorial_cards_addMini_s2 => '點下方小卡區域或上滑 → 進入小卡檢視頁。';

  @override
  String get tutorial_cards_addMini_s3 => '最左 / 最右頁可掃描 QR 或開啟小卡編輯新增。';

  @override
  String get tutorial_cards_addMini_s4 => '編輯頁右下角「＋」新增；同頁可刪除。';

  @override
  String get tutorial_cards_info_title => '管理「小卡資訊」';

  @override
  String get tutorial_cards_info_s1 => '小卡新增後出現在小卡檢視頁，點擊可翻面。';

  @override
  String get tutorial_cards_info_s2 => '背面右上「資訊」可編輯：名稱、序號、專輯、卡種、備註、標籤。';

  @override
  String get tutorial_cards_info_s3 => '加上標籤後，在檢視頁可快速分類、搜尋更精準。';

  @override
  String get tutorial_cards_note_json => '提示：小卡檢視頁右上支援 JSON 下載與批次匯入。';

  @override
  String get tutorial_social_tags_primary => '好友 / 熱門 / 追蹤';

  @override
  String get tutorial_social_tags_postComment => '發文與評論';

  @override
  String get tutorial_social_tags_lists => '名單管理';

  @override
  String get tutorial_social_browse_title => '瀏覽貼文';

  @override
  String get tutorial_social_browse_s1 => '上方分頁切換到「好友」、「熱門」、「追蹤」。';

  @override
  String get tutorial_social_browse_s2 => '各分頁皆可瀏覽、按讚與留言互動。';

  @override
  String get tutorial_social_post_title => '發文與評論';

  @override
  String get tutorial_social_post_s1 => '右下角「鉛筆」按鈕發文。';

  @override
  String get tutorial_social_post_s2 => '你的文章會出現在「熱門」與「好友」分頁（好友可互動）。';

  @override
  String get tutorial_social_list_title => '名單管理';

  @override
  String get tutorial_social_list_s1 => '右上「#」：編輯好友名單。';

  @override
  String get tutorial_social_list_s2 => '右上「名片」：編輯追蹤名單。';

  @override
  String get tutorial_explore_wall_title => '自由打造偶像桌布';

  @override
  String get tutorial_explore_wall_s1 => '放上照片與標語、貼紙，建立個人化風格。';

  @override
  String get tutorial_explore_wall_s2 => '可加入「生日倒數」小工具，做應援佈置。';

  @override
  String get tutorial_more_settings_title => '設定與使用者';

  @override
  String get tutorial_more_settings_s1 => '「設定」：主題、語言、通知等偏好。';

  @override
  String get tutorial_more_settings_s2 => '「使用者設定」：暱稱、頭像、登入方式等。';

  @override
  String get tutorial_more_stats_title => '統計';

  @override
  String get tutorial_more_stats_s1 => '查看蒐集的藝人、小卡張數、來源（本地 / 線上）。';

  @override
  String get tutorial_more_stats_s2 => '排行榜與成就，記錄你的收藏歷程。';

  @override
  String get tutorial_more_dex_title => '圖鑑';

  @override
  String get tutorial_more_dex_s1 => '快速總覽所有卡片；支援搜尋與篩選。';

  @override
  String get tutorial_faq_q1 => '如何快速新增多張小卡？';

  @override
  String get tutorial_faq_a1 => '在小卡檢視頁右下角按「＋」可連續新增，完成後回到檢視頁批次管理。';

  @override
  String get tutorial_faq_q2 => '匯入 QR / JSON 在哪裡？';

  @override
  String get tutorial_faq_a2 => '小卡檢視頁最左或最右的入口；或在更多選單找到「匯入」。';

  @override
  String get tutorial_faq_q3 => '標籤有什麼用？';

  @override
  String get tutorial_faq_a3 => '標籤可在小卡檢視頁做快速篩選，搜尋也更精準。';

  @override
  String get tutorial_faq_q4 => '如何變更語言與主題？';

  @override
  String get tutorial_faq_a4 => '前往「更多 → 設定」切換 App 語言與深 / 淺色主題。';

  @override
  String get tutorial_faq_q5 => '社群貼文在哪出現？';

  @override
  String get tutorial_faq_a5 => '你的貼文會出現在「熱門」與「好友」分頁；好友可看到並互動。';

  @override
  String get postHintShareSomething => '分享點什麼…';

  @override
  String get postAlbum => '相簿';

  @override
  String get postPublish => '發佈';

  @override
  String get postTags => '標籤';

  @override
  String get postAddTagHint => '新增標籤，按 Enter';

  @override
  String get postAdd => '加入';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return '標籤最多 $max 個';
  }

  @override
  String get currentPlan => '目前方案';

  @override
  String get filter => '篩選';

  @override
  String get filterPanelTitle => '篩選卡片';

  @override
  String get filterClear => '清除';

  @override
  String get filterSearchHint => '搜尋名稱、備註、序號…';

  @override
  String get extraInfoSectionTitle => '其他資訊';

  @override
  String get fieldStageNameLabel => '暱稱／藝名';

  @override
  String get fieldGroupLabel => '團體／系列';

  @override
  String get fieldOriginLabel => '卡片來源';

  @override
  String get fieldNoteLabel => '備註';

  @override
  String get profileSectionTitle => '基本資訊';

  @override
  String get noQuotePlaceholder => '尚未寫下句子';

  @override
  String cardNameAlreadyExists(Object name) {
    return '已經有名為「$name」的人物卡了，請換一個名稱。';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return '確定要刪除「$name」嗎？此動作也會一併刪除此人物底下的所有小卡。';
  }

  @override
  String get socialProfileTitle => '個人資料';

  @override
  String get userProfileLongPressHint => '長按編輯個人資料';

  @override
  String get scanFriendQrTitle => '掃描名片 QR 加好友';

  @override
  String get scanFriendQrButtonLabel => '掃描名片加好友';

  @override
  String get filterAlbumNone => '沒有專輯';

  @override
  String get albumCollectionTitle => '專輯收藏';

  @override
  String get albumCollectionEmptyHint => '目前還沒有專輯，先從你最喜歡的一張開始新增吧。';

  @override
  String get albumSwipeEdit => '編輯';

  @override
  String get albumSwipeDelete => '刪除';

  @override
  String get albumDialogAddTitle => '新增專輯';

  @override
  String get albumDialogEditTitle => '編輯專輯';

  @override
  String get albumDialogFieldTitle => '專輯名稱';

  @override
  String get albumDialogFieldArtist => '藝人／團體';

  @override
  String get albumDialogFieldYear => '年份（選填）';

  @override
  String get albumDialogFieldCover => '封面圖片 URL（選填）';

  @override
  String get albumDialogFieldYoutube => 'YouTube 連結（選填）';

  @override
  String get albumDialogFieldYtmusic => 'YT Music 連結（選填）';

  @override
  String get albumDialogFieldSpotify => 'Spotify 連結（選填）';

  @override
  String get albumDialogAddConfirm => '加入';

  @override
  String get albumDialogEditConfirm => '儲存';

  @override
  String get albumDeleteConfirmTitle => '刪除專輯';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return '發行年份：$year';
  }

  @override
  String get albumDetailNoStreaming => '尚未設定串流連結';

  @override
  String get albumDetailHint => '之後可以在這裡放曲目列表、你的評語或推薦理由等等。';

  @override
  String get albumTracksSectionTitle => '收錄歌曲';

  @override
  String get albumNoTracksHint => '這張專輯目前還沒有新增任何歌曲。';

  @override
  String get albumFieldLanguage => '語言';

  @override
  String get albumFieldVersion => '版本';

  @override
  String get albumCoverFromUrlLabel => '使用網址';

  @override
  String get albumCoverFromLocalLabel => '使用本機圖片';

  @override
  String get albumFieldArtistsLabel => '演出者';

  @override
  String get albumFieldArtistsInputHint => '輸入演出者名稱後按 Enter 新增…';

  @override
  String get albumArtistsSuggestionHint => '輸入時會顯示建議名稱。';

  @override
  String get albumLinksSectionTitle => '串流連結';

  @override
  String get albumLinksCollapsedHint => 'YouTube／YT Music／Spotify…';

  @override
  String get albumAddTrackButtonLabel => '新增歌曲';

  @override
  String get albumTrackDialogAddTitle => '新增歌曲';

  @override
  String get albumTrackDialogEditTitle => '編輯歌曲';

  @override
  String get albumTrackFieldTitle => '歌曲名稱';

  @override
  String get albumTitleRequiredMessage => '請輸入專輯名稱。';

  @override
  String get albumCoverLocalRequiredMessage => '請選擇本機封面圖片。';

  @override
  String albumDetailLanguage(String lang) {
    return '語言：$lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return '版本：$ver';
  }

  @override
  String get albumTrackImageLabel => '歌曲圖片（可選）';

  @override
  String get albumTrackClearImageTooltip => '清除圖片';

  @override
  String get albumTrackImageUseAlbumHint => '若未設定圖片，將會使用專輯封面顯示這首歌曲。';
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
      '謝謝你願意試試這個小 side project 💫 \n\n我是 LE SSERAFIM 的忠實 (FEARNOT)，每次想跟朋友分享開卡的喜悅，卻又不想帶著一疊小卡到處跑，所以就誕生了這個 App —— 希望能讓大家只用一支 6.5 吋手機，就能輕鬆展示、交換小卡。\n\n我會持續更新、改進這個小作品，也感謝下載並成為這個專案的一份子（可愛一點說，就是家人🩷）。 如果有任何想法或建議，隨時都可以找我聊聊！💪';

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
  String get userProfileTitle => '使用者';

  @override
  String get userProfileTile => '使用者';

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

  @override
  String get billing_title => '訂閱與付款';

  @override
  String get plan_free => '免費';

  @override
  String get plan_basic => '基本';

  @override
  String get plan_pro => '專業';

  @override
  String get plan_plus => '進階';

  @override
  String billing_current_plan(String plan) {
    return '目前方案：$plan';
  }

  @override
  String get section_plan_notes => '方案說明';

  @override
  String get section_payment_invoice => '付款與發票（由 Google Play 提供）';

  @override
  String get section_terms => '條款（示意）';

  @override
  String get upgrade_card_title => '升級空間，收藏無負擔';

  @override
  String get upgrade_card_desc => '付費方案將開放本地圖片上傳與更大空間，並支援多裝置同步。';

  @override
  String get badge_coming_soon => '即將上線';

  @override
  String get feature_external_images => '雲端空間 5 GB ( 跨裝置同步 )';

  @override
  String get feature_small_cloud_space => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_ad_free => '無廣告沉浸體驗';

  @override
  String get feature_upload_local_images => '雲端空間 10 GB ( 跨裝置同步 )';

  @override
  String get feature_priority_support => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_large_storage => '雲端空間 50 GB ( 跨裝置同步 )';

  @override
  String get feature_album_report => '卡片分類功能，卡背、小卡詳細資訊';

  @override
  String get feature_roadmap_advance => '進階功能（預告）';

  @override
  String get plan_badge_recommended => '推薦';

  @override
  String price_per_month(Object price) {
    return '$price/月';
  }

  @override
  String get upgrade_now => '立即升級';

  @override
  String get manage_plan => '管理方案';

  @override
  String get coming_soon_title => '功能即將開放';

  @override
  String get coming_soon_body =>
      '目前「本地雲端空間」仍在加緊上線準備中，現在僅做佔位展示。正式版本將開放本地圖片上傳、更大容量與多裝置同步，敬請期待！';

  @override
  String get coming_soon_ok => '好';

  @override
  String get bullet_free_external => '免費方案：僅允許使用「外部圖片（網址）」';

  @override
  String get bullet_paid_local_upload => '付費方案：可上傳本地圖片到雲端，提供更大容量';

  @override
  String get bullet_future_tiers => '未來將提供更多容量級距';

  @override
  String get bullet_pay_cards => '目前僅支援 Google Play 內建訂閱與付款';

  @override
  String get bullet_einvoice => '收據／發票由 Google Play 開立；企業統編不適用';

  @override
  String get bullet_cancel_anytime => '可隨時取消，下期不續扣';

  @override
  String get bullet_terms => '服務條款、隱私權政策、退款政策（之後補連結）';

  @override
  String get bullet_abuse => '濫用上傳（如違法內容）將被停權';

  @override
  String get common_ok => '確定';

  @override
  String get common_okDescription => '通用確定按鈕';

  @override
  String get common_cancel => '取消';

  @override
  String get common_cancelDescription => '通用取消按鈕';

  @override
  String get tutorial_title => '使用教學';

  @override
  String get tutorial_tab_cards => '卡片';

  @override
  String get tutorial_tab_social => '社群';

  @override
  String get tutorial_tab_explore => '探索';

  @override
  String get tutorial_tab_more => '更多';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => '新增藝人卡';

  @override
  String get tutorial_cards_tags_addMini => '新增小卡';

  @override
  String get tutorial_cards_tags_editDelete => '編輯 / 刪除';

  @override
  String get tutorial_cards_tags_info => '小卡資訊';

  @override
  String get tutorial_cards_addArtist_title => '新增「藝人卡」';

  @override
  String get tutorial_cards_addArtist_s1 => '在卡片頁右下角點「＋ 新增藝人卡」。';

  @override
  String get tutorial_cards_addArtist_s2 => '可選本機圖片或貼上網路圖片網址。';

  @override
  String get tutorial_cards_addArtist_s3 => '向右滑：編輯藝人資訊；向左滑：刪除藝人卡。';

  @override
  String get tutorial_cards_addMini_title => '新增「小卡」';

  @override
  String get tutorial_cards_addMini_s1 => '點任一「藝人卡」進入內容。';

  @override
  String get tutorial_cards_addMini_s2 => '點下方小卡區域或上滑 → 進入小卡檢視頁。';

  @override
  String get tutorial_cards_addMini_s3 => '最左 / 最右頁可掃描 QR 或開啟小卡編輯新增。';

  @override
  String get tutorial_cards_addMini_s4 => '編輯頁右下角「＋」新增；同頁可刪除。';

  @override
  String get tutorial_cards_info_title => '管理「小卡資訊」';

  @override
  String get tutorial_cards_info_s1 => '小卡新增後出現在小卡檢視頁，點擊可翻面。';

  @override
  String get tutorial_cards_info_s2 => '背面右上「資訊」可編輯：名稱、序號、專輯、卡種、備註、標籤。';

  @override
  String get tutorial_cards_info_s3 => '加上標籤後，在檢視頁可快速分類、搜尋更精準。';

  @override
  String get tutorial_cards_note_json => '提示：小卡檢視頁右上支援 JSON 下載與批次匯入。';

  @override
  String get tutorial_social_tags_primary => '好友 / 熱門 / 追蹤';

  @override
  String get tutorial_social_tags_postComment => '發文與評論';

  @override
  String get tutorial_social_tags_lists => '名單管理';

  @override
  String get tutorial_social_browse_title => '瀏覽貼文';

  @override
  String get tutorial_social_browse_s1 => '上方分頁切換到「好友」、「熱門」、「追蹤」。';

  @override
  String get tutorial_social_browse_s2 => '各分頁皆可瀏覽、按讚與留言互動。';

  @override
  String get tutorial_social_post_title => '發文與評論';

  @override
  String get tutorial_social_post_s1 => '右下角「鉛筆」按鈕發文。';

  @override
  String get tutorial_social_post_s2 => '你的文章會出現在「熱門」與「好友」分頁（好友可互動）。';

  @override
  String get tutorial_social_list_title => '名單管理';

  @override
  String get tutorial_social_list_s1 => '右上「#」：編輯好友名單。';

  @override
  String get tutorial_social_list_s2 => '右上「名片」：編輯追蹤名單。';

  @override
  String get tutorial_explore_wall_title => '自由打造偶像桌布';

  @override
  String get tutorial_explore_wall_s1 => '放上照片與標語、貼紙，建立個人化風格。';

  @override
  String get tutorial_explore_wall_s2 => '可加入「生日倒數」小工具，做應援佈置。';

  @override
  String get tutorial_more_settings_title => '設定與使用者';

  @override
  String get tutorial_more_settings_s1 => '「設定」：主題、語言、通知等偏好。';

  @override
  String get tutorial_more_settings_s2 => '「使用者設定」：暱稱、頭像、登入方式等。';

  @override
  String get tutorial_more_stats_title => '統計';

  @override
  String get tutorial_more_stats_s1 => '查看蒐集的藝人、小卡張數、來源（本地 / 線上）。';

  @override
  String get tutorial_more_stats_s2 => '排行榜與成就，記錄你的收藏歷程。';

  @override
  String get tutorial_more_dex_title => '圖鑑';

  @override
  String get tutorial_more_dex_s1 => '快速總覽所有卡片；支援搜尋與篩選。';

  @override
  String get tutorial_faq_q1 => '如何快速新增多張小卡？';

  @override
  String get tutorial_faq_a1 =>
      '在小卡檢視頁右上角有兩個按鈕，左方按鈕支援JSON檔案的批次新增，右側按鈕可下載該藝人的卡片JSON檔案。';

  @override
  String get tutorial_faq_q2 => '匯入 QR / JSON 在哪裡？';

  @override
  String get tutorial_faq_a2 => '小卡檢視頁最左或最右的入口；或在更多選單找到「匯入」。';

  @override
  String get tutorial_faq_q3 => '標籤有什麼用？';

  @override
  String get tutorial_faq_a3 => '標籤可在小卡檢視頁做快速篩選，搜尋也更精準。';

  @override
  String get tutorial_faq_q4 => '如何變更語言與主題？';

  @override
  String get tutorial_faq_a4 => '前往「更多 → 設定」切換 App 語言與深 / 淺色主題。';

  @override
  String get tutorial_faq_q5 => '社群貼文在哪出現？';

  @override
  String get tutorial_faq_a5 => '你的貼文會出現在「熱門」與「好友」分頁；好友可看到並互動。';

  @override
  String get postHintShareSomething => '分享點什麼…';

  @override
  String get postAlbum => '相簿';

  @override
  String get postPublish => '發佈';

  @override
  String get postTags => '標籤';

  @override
  String get postAddTagHint => '新增標籤，按 Enter';

  @override
  String get postAdd => '加入';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return '標籤最多 $max 個';
  }

  @override
  String get currentPlan => '目前方案';

  @override
  String get filter => '篩選';

  @override
  String get filterPanelTitle => '篩選卡片';

  @override
  String get filterClear => '清除';

  @override
  String get filterSearchHint => '搜尋名稱、備註、序號…';

  @override
  String get extraInfoSectionTitle => '其他資訊';

  @override
  String get fieldStageNameLabel => '暱稱／藝名';

  @override
  String get fieldGroupLabel => '團體／系列';

  @override
  String get fieldOriginLabel => '卡片來源';

  @override
  String get fieldNoteLabel => '備註';

  @override
  String get profileSectionTitle => '基本資訊';

  @override
  String get noQuotePlaceholder => '尚未寫下句子';

  @override
  String cardNameAlreadyExists(Object name) {
    return '已經有名為「$name」的人物卡了，請換一個名稱。';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return '確定要刪除「$name」嗎？此動作也會一併刪除此人物底下的所有小卡。';
  }

  @override
  String get socialProfileTitle => '個人資料';

  @override
  String get userProfileLongPressHint => '長按編輯個人資料';

  @override
  String get scanFriendQrTitle => '掃描名片 QR 加好友';

  @override
  String get scanFriendQrButtonLabel => '掃描名片加好友';

  @override
  String get filterAlbumNone => '沒有專輯';

  @override
  String get albumCollectionTitle => '專輯收藏';

  @override
  String get albumCollectionEmptyHint => '目前還沒有專輯，先從你最喜歡的一張開始新增吧。';

  @override
  String get albumSwipeEdit => '編輯';

  @override
  String get albumSwipeDelete => '刪除';

  @override
  String get albumDialogAddTitle => '新增專輯';

  @override
  String get albumDialogEditTitle => '編輯專輯';

  @override
  String get albumDialogFieldTitle => '專輯名稱';

  @override
  String get albumDialogFieldArtist => '藝人／團體';

  @override
  String get albumDialogFieldYear => '年份（選填）';

  @override
  String get albumDialogFieldCover => '封面圖片 URL（選填）';

  @override
  String get albumDialogFieldYoutube => 'YouTube 連結（選填）';

  @override
  String get albumDialogFieldYtmusic => 'YT Music 連結（選填）';

  @override
  String get albumDialogFieldSpotify => 'Spotify 連結（選填）';

  @override
  String get albumDialogAddConfirm => '加入';

  @override
  String get albumDialogEditConfirm => '儲存';

  @override
  String get albumDeleteConfirmTitle => '刪除專輯';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return '確定要刪除「$title」嗎？';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return '發行年份：$year';
  }

  @override
  String get albumDetailNoStreaming => '尚未設定串流連結';

  @override
  String get albumDetailHint => '之後可以在這裡放曲目列表、你的評語或推薦理由等等。';

  @override
  String get albumTracksSectionTitle => '收錄歌曲';

  @override
  String get albumNoTracksHint => '這張專輯目前還沒有新增任何歌曲。';

  @override
  String get albumFieldLanguage => '語言';

  @override
  String get albumFieldVersion => '版本';

  @override
  String get albumCoverFromUrlLabel => '使用網址';

  @override
  String get albumCoverFromLocalLabel => '使用本機圖片';

  @override
  String get albumFieldArtistsLabel => '演出者';

  @override
  String get albumFieldArtistsInputHint => '輸入演出者名稱後按 Enter 新增…';

  @override
  String get albumArtistsSuggestionHint => '輸入時會顯示建議名稱。';

  @override
  String get albumLinksSectionTitle => '串流連結';

  @override
  String get albumLinksCollapsedHint => 'YouTube／YT Music／Spotify…';

  @override
  String get albumAddTrackButtonLabel => '新增歌曲';

  @override
  String get albumTrackDialogAddTitle => '新增歌曲';

  @override
  String get albumTrackDialogEditTitle => '編輯歌曲';

  @override
  String get albumTrackFieldTitle => '歌曲名稱';

  @override
  String get albumTitleRequiredMessage => '請輸入專輯名稱。';

  @override
  String get albumCoverLocalRequiredMessage => '請選擇本機封面圖片。';

  @override
  String albumDetailLanguage(String lang) {
    return '語言：$lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return '版本：$ver';
  }

  @override
  String get albumTrackImageLabel => '歌曲圖片（可選）';

  @override
  String get albumTrackClearImageTooltip => '清除圖片';

  @override
  String get albumTrackImageUseAlbumHint => '若未設定圖片，將會使用專輯封面顯示這首歌曲。';
}
