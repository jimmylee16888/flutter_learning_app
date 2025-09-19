// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get authSignInWithGoogle => 'Google로 로그인';

  @override
  String get continueAsGuest => '게스트로 계속';

  @override
  String get noNetworkGuestTip => '현재 오프라인입니다. 게스트로 이용할 수 있습니다.';

  @override
  String get appTitle => 'Pop Card';

  @override
  String get navCards => '카드';

  @override
  String get navExplore => '탐색';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get theme => '테마';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get language => '언어';

  @override
  String get languageSystem => '시스템';

  @override
  String get languageZhTW => '번체 중국어';

  @override
  String get languageEn => '영어';

  @override
  String get languageJa => '일본어';

  @override
  String get languageKo => '한국어';

  @override
  String get languageDe => '독일어';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutDeveloper => '개발자 소개';

  @override
  String get developerRole => '개발자';

  @override
  String get emailLabel => '이메일';

  @override
  String get versionLabel => '버전';

  @override
  String get birthday => '생일';

  @override
  String get quoteTitle => '팬에게 한마디';

  @override
  String get fanMiniCards => '팬 미니 카드';

  @override
  String get noMiniCardsHint => '아직 미니 카드가 없습니다. ‘편집’을 눌러 추가하세요.';

  @override
  String get add => '추가';

  @override
  String get editMiniCards => '미니 카드 편집';

  @override
  String get save => '저장';

  @override
  String get edit => '편집';

  @override
  String get delete => '삭제';

  @override
  String get cancel => '취소';

  @override
  String get previewFailed => '미리보기에 실패했습니다';

  @override
  String get favorite => '즐겨찾기';

  @override
  String get favorited => '즐겨찾기에 추가됨';

  @override
  String get accountStatusGuest => '게스트 모드';

  @override
  String get accountStatusSignedIn => '로그인됨';

  @override
  String get accountStatusSignedOut => '로그인되지 않음';

  @override
  String get accountGuestSubtitle => '현재 게스트로 사용 중입니다. 데이터는 이 기기에만 저장됩니다.';

  @override
  String get accountNoInfo => '(계정 정보 없음)';

  @override
  String get accountBackToLogin => '로그인 화면으로';

  @override
  String get signOut => '로그아웃';

  @override
  String get helloDeveloperTitle => '안녕하세요! 개발자입니다';

  @override
  String get helloDeveloperBody =>
      '이 작은 사이드 프로젝트를 사용해 주셔서 감사합니다. 저는 LE SSERAFIM을 정말 좋아하는 FEARNOT이고, 친구들과 기쁨을 나눌 때마다 두꺼운 포토카드를 들고 다니고 싶지는 않았습니다. 그래서 이 앱을 만들었습니다. 6.5인치 화면에서 바로 카드를 보여주고 교환할 수 있도록요. 앞으로도 계속 유지보수하고, 코드는 GitHub에서 오픈으로 유지하겠습니다. 다운로드해 주시고 이 프로젝트(말하자면 작은 가족)의 일원이 되어 주셔서 다시 한 번 감사합니다. 개선 아이디어나 질문이 있으면 언제든 연락해 주세요. — Jimmy Lee';

  @override
  String get stats_title => '통계';

  @override
  String get stats_overview => '컬렉션 개요';

  @override
  String get stats_artist_count => '아티스트 수';

  @override
  String get stats_card_total => '미니 카드 총합';

  @override
  String get stats_front_source => '앞면 이미지 출처';

  @override
  String stats_cards_per_artist_topN(int n) {
    return '아티스트별 미니 카드 수 (상위 $n)';
  }

  @override
  String get stats_nav_subtitle => '총합, 출처, 상위 아티스트 등 통계를 확인하세요';

  @override
  String get welcomeTitle => 'Mini Cards에 오신 것을 환영합니다';

  @override
  String get welcomeSubtitle => '설정과 데이터를 동기화하려면 로그인하거나 계정을 만드세요';

  @override
  String get authSignIn => '로그인';

  @override
  String get authRegister => '등록';

  @override
  String get authContinueAsGuest => '게스트로 계속';

  @override
  String get authAccount => '계정 (이메일/임의 문자열)';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authCreateAndSignIn => '계정 만들기 및 로그인';

  @override
  String get authName => '이름';

  @override
  String get authGender => '성별';

  @override
  String get genderMale => '남성';

  @override
  String get genderFemale => '여성';

  @override
  String get genderOther => '기타/비공개';

  @override
  String get birthdayPick => '날짜 선택';

  @override
  String get birthdayNotChosen => '—';

  @override
  String get errorLoginFailed => '로그인 실패';

  @override
  String get errorRegisterFailed => '등록 실패';

  @override
  String get errorPickBirthday => '생일을 선택하세요';

  @override
  String get common_local => '로컬';

  @override
  String get common_url => 'URL';

  @override
  String get common_unnamed => '(이름 없음)';

  @override
  String get common_unit_cards => '장';

  @override
  String nameWithPinyin(Object name, Object pinyin) {
    return '$name ($pinyin)';
  }

  @override
  String get filterAll => '전체';

  @override
  String get deleteCategoryTitle => '카테고리 삭제';

  @override
  String deleteCategoryMessage(Object name) {
    return '“$name”을(를) 삭제하시겠습니까? 모든 카드에서 제거됩니다.';
  }

  @override
  String deletedCategoryToast(Object name) {
    return '카테고리 삭제됨: $name';
  }

  @override
  String get searchHint => '이름/카드 내용 검색';

  @override
  String get clear => '지우기';

  @override
  String get noCards => '카드가 없습니다';

  @override
  String get addCard => '카드 추가';

  @override
  String get deleteCardTitle => '카드 삭제';

  @override
  String deleteCardMessage(Object title) {
    return '“$title”을(를) 삭제하시겠습니까?';
  }

  @override
  String deletedCardToast(Object title) {
    return '삭제됨: $title';
  }

  @override
  String get editCard => '카드 편집';

  @override
  String get categoryAssignOrAdd => '카테고리 지정/추가';

  @override
  String get newCardTitle => '새 카드';

  @override
  String get editCardTitle => '카드 편집';

  @override
  String get nameRequiredLabel => '이름(필수)';

  @override
  String get imageByUrl => 'URL로';

  @override
  String get imageByLocal => '로컬 사진';

  @override
  String get imageUrl => '이미지 URL';

  @override
  String get pickFromGallery => '갤러리에서 선택';

  @override
  String get quoteOptionalLabel => '인용문(선택)';

  @override
  String get pickBirthdayOptional => '생일 선택(선택)';

  @override
  String get inputImageUrl => '이미지 URL을 입력하세요';

  @override
  String get downloadFailed => '다운로드 실패';

  @override
  String get pickLocalPhoto => '로컬 사진을 선택하세요';

  @override
  String get updatedCardToast => '카드가 업데이트되었습니다';

  @override
  String get manageCategoriesTitle => '카테고리 관리';

  @override
  String get newCategoryNameHint => '새 카테고리 이름';

  @override
  String get addCategory => '카테고리 추가';

  @override
  String get deleteCategoryTooltip => '카테고리 삭제';

  @override
  String get assignCategoryTitle => '카테고리 지정';

  @override
  String get confirm => '확인';

  @override
  String confirmDeleteCategoryMessage(Object name) {
    return '“$name”을(를) 삭제하시겠습니까? 모든 카드에서 제거됩니다.';
  }

  @override
  String addedCategoryToast(Object name) {
    return '카테고리 추가됨: $name';
  }

  @override
  String get noMiniCardsPreviewHint =>
      '아직 미니 카드가 없습니다. 여기를 클릭하거나 위로 스와이프하여 추가하세요.';

  @override
  String get detailSwipeHint => '위로 스와이프하여 미니 카드 페이지로 이동하세요 (스캔/QR 공유 포함).';

  @override
  String get noMiniCardsEmptyList => '현재 미니 카드가 없습니다. 오른쪽 하단의 +를 눌러 추가하세요.';

  @override
  String get miniLocalImageBadge => '로컬 이미지';

  @override
  String get miniHasBackBadge => '뒷면 이미지 포함';

  @override
  String get tagsLabel => '태그';

  @override
  String tagsCount(int n) {
    return '태그 $n';
  }

  @override
  String get nameLabel => '이름';

  @override
  String get serialNumber => '일련번호';

  @override
  String get album => '앨범';

  @override
  String get addAlbum => '앨범 추가';

  @override
  String get enterAlbumName => '앨범 이름 입력';

  @override
  String get cardType => '카드 종류';

  @override
  String get addCardType => '카드 종류 추가';

  @override
  String get enterCardTypeName => '카드 종류 이름 입력';

  @override
  String get noteLabel => '비고';

  @override
  String get newTagHint => '새 태그 추가…';

  @override
  String get frontSide => '앞면';

  @override
  String get backSide => '뒷면';

  @override
  String get frontImageTitle => '앞면 이미지';

  @override
  String get backImageTitleOptional => '뒷면 이미지 (선택 사항)';

  @override
  String get frontImageUrlLabel => '앞면 이미지 URL';

  @override
  String get backImageUrlLabel => '뒷면 이미지 URL';

  @override
  String get clearUrl => 'URL 지우기';

  @override
  String get clearLocal => '로컬 지우기';

  @override
  String get clearBackImage => '뒷면 이미지 지우기';

  @override
  String get localPickedLabel => '선택됨: 로컬';

  @override
  String get miniCardEditTitle => '미니 카드 편집';

  @override
  String get miniCardNewTitle => '새 미니 카드';

  @override
  String get errorFrontImageUrlRequired => '앞면 이미지 URL을 입력하거나 로컬로 전환하세요.';

  @override
  String get errorFrontLocalRequired => '앞면 로컬 사진을 선택하거나 URL로 다시 전환하세요.';

  @override
  String get userProfileTitle => '사용자 설정';

  @override
  String get userProfileTile => '사용자 설정';

  @override
  String get nicknameLabel => '닉네임';

  @override
  String get nicknameRequired => '닉네임은 필수입니다';

  @override
  String get notSet => '미설정';

  @override
  String get clearBirthday => '생일 지우기';

  @override
  String get userProfileSaved => '사용자 설정이 저장되었습니다';

  @override
  String get ready => '완료';

  @override
  String get fillNicknameAndBirthday => '닉네임과 생일을 입력해 주세요';

  @override
  String get navSocial => '소셜';

  @override
  String get timeJustNow => '방금 전';

  @override
  String timeMinutesAgo(int n) {
    return '$n분 전';
  }

  @override
  String timeHoursAgo(int n) {
    return '$n시간 전';
  }

  @override
  String timeDaysAgo(int n) {
    return '$n일 전';
  }

  @override
  String get socialFriends => '친구';

  @override
  String get socialHot => '인기';

  @override
  String get socialFollowing => '팔로잉';

  @override
  String get publish => '게시';

  @override
  String get socialShareHint => '무슨 생각을 하고 있나요?';

  @override
  String get leaveACommentHint => '댓글을 남겨보세요…';

  @override
  String get commentsTitle => '댓글';

  @override
  String commentsCount(int n) {
    return '댓글 $n개';
  }

  @override
  String get addTagHint => '태그 추가…';

  @override
  String followedTag(Object tag) {
    return '#$tag 팔로우함';
  }

  @override
  String unfollowedTag(Object tag) {
    return '#$tag 팔로우 해제';
  }

  @override
  String get friendCardsTitle => '친구 명함';

  @override
  String get addFriendCard => '명함 추가';

  @override
  String get editFriendCard => '명함 편집';

  @override
  String get scanQr => 'QR 코드 스캔';

  @override
  String get tapToFlip => '탭하여 뒤집기';

  @override
  String get deleteFriendCardTitle => '명함 삭제';

  @override
  String deleteFriendCardMessage(Object name) {
    return '“$name”을(를) 삭제하시겠습니까?';
  }

  @override
  String get followArtistsLabel => '팔로우하는 아티스트';

  @override
  String limitReached(String text) {
    return '최대 한도에 도달했습니다 ($text)';
  }

  @override
  String get retry => '다시 시도';

  @override
  String get offlineBanner => '오프라인: 일부 기능을 사용할 수 없습니다';

  @override
  String get manageFollowedTags => '팔로우한 태그';

  @override
  String get noFriendsYet => '추가된 친구가 없습니다';

  @override
  String get friendAddAction => '친구 추가';

  @override
  String get friendRemoveAction => '친구 해제';

  @override
  String get friendAddedStatus => '추가됨';

  @override
  String get remove => '제거';

  @override
  String get changeAvatar => '아바타 변경';

  @override
  String get socialLinksTitle => '소셜 링크';

  @override
  String get showInstagramOnProfile => '프로필에 Instagram 표시';

  @override
  String get showFacebookOnProfile => '프로필에 Facebook 표시';

  @override
  String get showLineOnProfile => '프로필에 LINE 표시';

  @override
  String followedTagsCount(int n) {
    return '팔로우한 태그 ($n)';
  }

  @override
  String get addFollowedTag => '팔로우할 태그 추가';

  @override
  String get addFollowedTagHint => '태그 이름을 입력한 뒤 Enter 키를 누르세요';

  @override
  String get manageCards => '명함 관리';

  @override
  String get phoneLabel => '전화';

  @override
  String get lineLabel => 'LINE';

  @override
  String get facebookLabel => 'Facebook';

  @override
  String get instagramLabel => 'Instagram';

  @override
  String get searchFriendsOrArtistsHint => '친구 또는 아티스트 검색';

  @override
  String get followedTagsTitle => '팔로우한 태그';

  @override
  String get noFollowedTagsYet => '팔로우한 태그가 없습니다';

  @override
  String get addedFollowedTagToast => '태그를 팔로우했습니다';

  @override
  String addFollowedTagFailed(Object error) {
    return '추가 실패: $error';
  }

  @override
  String get removedFollowedTagToast => '태그 팔로우를 해제했습니다';

  @override
  String removeFollowedTagFailed(Object error) {
    return '삭제 실패: $error';
  }

  @override
  String loadFailed(Object error) {
    return '불러오기에 실패했습니다: $error';
  }

  @override
  String miniCardsOf(Object title) {
    return '$title의 미니 카드';
  }

  @override
  String get importFromJsonTooltip => 'JSON에서 가져오기';

  @override
  String get exportJsonMultiTooltip => 'JSON 내보내기(여러 개)';

  @override
  String get scan => '스캔';

  @override
  String get share => '공유';

  @override
  String get shareThisCard => '이 카드를 공유';

  @override
  String importedMiniCardsToast(int n) {
    return '미니 카드 $n장을 가져왔습니다';
  }

  @override
  String get shareMultipleCards => '여러 카드 공유(다중 선택)';

  @override
  String get shareMultipleCardsSubtitle => '카드를 선택한 뒤, 사진 공유 또는 JSON 내보내기';

  @override
  String get shareOneCard => '한 장 선택하여 공유…';

  @override
  String get selectCardsForJsonTitle => '공유할 카드 선택(JSON)';

  @override
  String get selectCardsForShareOrExportTitle => '공유/내보낼 카드 선택';

  @override
  String get blockedLocalImageNote => '로컬 이미지를 포함하여 JSON으로 내보낼 수 없습니다';

  @override
  String shareMultiplePhotos(int n) {
    return '사진 $n장 공유';
  }

  @override
  String get exportJson => 'JSON 내보내기';

  @override
  String get exportJsonSkipLocalHint => '로컬 이미지 전용 카드는 건너뜁니다';

  @override
  String triedShareSummary(int total, int ok, int fail) {
    return '$total개 공유 시도, 성공 $ok / 실패 $fail';
  }

  @override
  String get shareQrCode => 'QR 코드 공유';

  @override
  String get shareQrAutoBackendHint => '데이터가 큰 경우 자동으로 백엔드 모드로 전환됩니다';

  @override
  String get cannotShareByQr => 'QR로 공유할 수 없습니다';

  @override
  String get noImageUrl => '이미지 URL이 없음';

  @override
  String get noImageUrlPhotoOnly => '이미지 URL이 없어 사진 직접 공유만 가능합니다';

  @override
  String get shareThisPhoto => '이 사진 공유';

  @override
  String shareFailed(Object error) {
    return '공유 실패: $error';
  }

  @override
  String get transportBackendHint => '백엔드 모드(API 사용)';

  @override
  String get transportEmbeddedHint => '임베디드(로컬)';

  @override
  String get qrIdOnlyNotice =>
      '이 QR에는 카드 ID만 포함되어 있습니다. 수신 측에서 백엔드에서 전체 내용을 가져옵니다.';

  @override
  String get qrGenerationFailed => 'QR 이미지 생성 실패';

  @override
  String get pasteJsonTitle => 'JSON 텍스트 붙여넣기';

  @override
  String get pasteJsonHint => 'mini_card_bundle_v2/v1 또는 mini_card_v2/v1 지원';

  @override
  String get import => '가져오기';

  @override
  String importedFromJsonToast(int n) {
    return 'JSON에서 미니 카드 $n장을 가져왔습니다';
  }

  @override
  String importFailed(Object error) {
    return '가져오기 실패: $error';
  }

  @override
  String get cannotExportJsonAllLocal =>
      '선택한 카드가 모두 로컬 이미지 전용이어서 JSON으로 내보낼 수 없습니다';

  @override
  String skippedLocalImagesCount(int n) {
    return '로컬 이미지 전용 카드 $n장을 건너뜀';
  }

  @override
  String get close => '닫기';

  @override
  String get copy => '복사';

  @override
  String get copiedJsonToast => 'JSON을 복사했습니다';

  @override
  String get copyJson => 'JSON 복사';

  @override
  String get none => '없음';

  @override
  String get selectCardsToShareTitle => '공유할 카드 선택';

  @override
  String get hasImageUrlJsonOk => '이미지 URL 있음: JSON으로 전송 가능';

  @override
  String get exportJsonOnlyUrlHint =>
      '팁: 내보낸 JSON에는 이미지 URL이 있는 카드만 포함됩니다. 로컬 전용 이미지는 건너뜁니다.';

  @override
  String get sharePhotos => '사진 공유';

  @override
  String get containsLocalImages => '로컬 이미지 포함';

  @override
  String containsLocalImagesDetail(int blocked, int allowed) {
    return '$blocked장은 JSON으로 내보낼 수 없습니다. 사용 가능한 $allowed장만 내보낼까요?';
  }

  @override
  String get onlyExportUsable => '사용 가능한 것만 내보내기';

  @override
  String get shareMiniCardTitle => '미니 카드 공유';

  @override
  String get qrCodeTab => 'QR 코드';

  @override
  String get qrTooLargeUseJsonHint =>
      'QR 코드가 표시되지 않으면 데이터가 너무 클 수 있습니다. JSON 사용을 고려하세요.';

  @override
  String get scanMiniCardQrTitle => '미니 카드 QR 스캔';

  @override
  String get scanFromGallery => '갤러리에서 스캔';

  @override
  String get noQrFoundInImage => '이미지에서 QR을 찾지 못했습니다';

  @override
  String get qrFormatInvalid => 'QR 형식이 올바르지 않습니다';

  @override
  String get qrTypeUnsupported => '지원되지 않는 QR 유형입니다';

  @override
  String fetchFromBackendFailed(Object error) {
    return '백엔드에서 가져오기 실패: $error';
  }

  @override
  String get addFollowedTagFailedOffline => '오프라인입니다. 태그가 로컬에 추가되었습니다.';

  @override
  String get removeFollowedTagFailedOffline => '오프라인입니다. 태그가 로컬에서 제거되었습니다.';

  @override
  String get loading => '불러오는 중…';

  @override
  String get networkRequiredTitle => '네트워크 연결이 필요합니다';

  @override
  String get networkRequiredBody => '로그인하려면 인터넷 연결이 필요합니다. 연결 후 다시 시도해 주세요.';

  @override
  String get ok => '확인';

  @override
  String get willSaveAs => '다음 이름으로 저장합니다';

  @override
  String get alreadyExists => '이미 존재합니다';
}
