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
  String get appTitle => 'MyApp 範例';

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
  String get addCard => '新增卡片';

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
  String get newCardTitle => '新增卡片';

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
  String get appTitle => 'MyApp 範例';

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
  String get addCard => '新增卡片';

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
  String get newCardTitle => '新增卡片';

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
}
