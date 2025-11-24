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
      '이 작은 사이드 프로젝트를 사용해줘서 고마워요💫 \n\n저는 LE SSERAFIM의 진심 팬, FEARNOT입니다! 친구들과 포토카드 수집의 즐거움을 나누고 싶었지만, 항상 한 뭉치 들고 다니는 게 번거로워서 이 앱을 만들었어요📱. 이제 6.5인치 휴대폰 하나로 쉽게 카드 전시와 교환이 가능해요!\n\n앞으로도 계속 업데이트하고 개선할 예정이에요. 이 프로젝트를 다운로드해 가족(이라고 부르고 싶어요🩷)의 일원이 되어줘서 정말 감사해요! 아이디어나 의견이 있다면 언제든지 편하게 알려주세요💪';

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
  String get userProfileTitle => '사용자';

  @override
  String get userProfileTile => '사용자';

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

  @override
  String get common_about => '정보';

  @override
  String get settings_menu_general => '일반 설정';

  @override
  String get settings_menu_user => '사용자 설정';

  @override
  String get settings_menu_about => '정보';

  @override
  String get settingsMenuGeneral => '일반 설정';

  @override
  String get commonAbout => '정보';

  @override
  String get navMore => '더보기';

  @override
  String get exploreReflow => '위젯 정렬';

  @override
  String get commonAdd => '추가';

  @override
  String get exploreNoPhoto => '사진이 선택되지 않았습니다';

  @override
  String get exploreTapToEditQuote => '탭하여 인용문 편집';

  @override
  String get exploreAdd => '추가';

  @override
  String get exploreAddPhoto => '사진 카드';

  @override
  String get exploreAddQuote => '인용 카드';

  @override
  String get exploreAddBirthday => '생일 카운트다운';

  @override
  String get exploreAddBall => '공 추가';

  @override
  String get exploreAdBuiltIn => '광고는 내장되어 있습니다';

  @override
  String get exploreEnterAQuote => '인용문을 입력하세요';

  @override
  String get commonCancel => '취소';

  @override
  String get commonOk => '확인';

  @override
  String get exploreCountdownTitleHint => '아이돌/이벤트 (예: 사쿠라 생일)';

  @override
  String get exploreAddBallDialogTitle => '공 추가';

  @override
  String get exploreBallEmojiHint => '이모지(비우면 사진 사용)';

  @override
  String get exploreSize => '크기';

  @override
  String get explorePickPhoto => '사진 선택…';

  @override
  String get explorePickedPhoto => '사진 선택됨';

  @override
  String get navDex => '도감';

  @override
  String get dex_title => '내 도감';

  @override
  String get dex_uncategorized => '미분류';

  @override
  String get dex_searchHint => '아이돌 또는 카드를 검색…';

  @override
  String dex_cardsCount(Object count) {
    return '$count 장';
  }

  @override
  String get dex_empty => '아직 수집한 카드가 없습니다';

  @override
  String get zoomIn => '확대';

  @override
  String get zoomOut => '축소';

  @override
  String get resetZoom => '확대/축소 초기화';

  @override
  String get billing_title => '구독 및 결제';

  @override
  String get plan_free => '프리';

  @override
  String get plan_basic => '베이직';

  @override
  String get plan_pro => '프로';

  @override
  String get plan_plus => '플러스';

  @override
  String billing_current_plan(String plan) {
    return '현재 플랜: $plan';
  }

  @override
  String get section_plan_notes => '플랜 안내';

  @override
  String get section_payment_invoice => '결제 및 영수증 (Google Play를 통해 제공)';

  @override
  String get section_terms => '약관(데모)';

  @override
  String get upgrade_card_title => '저장공간 업그레이드로 더 가볍게';

  @override
  String get upgrade_card_desc => '유료 플랜에서 로컬 업로드, 더 큰 용량, 다중 기기 동기화를 제공합니다.';

  @override
  String get badge_coming_soon => '곧 제공';

  @override
  String get feature_external_images => '클라우드 공간 5GB (멀티 디바이스 동기화)';

  @override
  String get feature_small_cloud_space => '카드 분류 기능, 카드 뒷면 정보, 미니카드 상세 정보';

  @override
  String get feature_ad_free => '광고 없는 몰입형 경험';

  @override
  String get feature_upload_local_images => '클라우드 공간 10GB (멀티 디바이스 동기화)';

  @override
  String get feature_priority_support => '카드 분류 기능, 카드 뒷면 정보, 미니카드 상세 정보';

  @override
  String get feature_large_storage => '클라우드 공간 50GB (멀티 디바이스 동기화)';

  @override
  String get feature_album_report => '카드 분류 기능, 카드 뒷면 정보, 미니카드 상세 정보';

  @override
  String get feature_roadmap_advance => '고급 기능 (예고)';

  @override
  String get plan_badge_recommended => '추천';

  @override
  String price_per_month(Object price) {
    return '$price/월';
  }

  @override
  String get upgrade_now => '지금 업그레이드';

  @override
  String get manage_plan => '플랜 관리';

  @override
  String get coming_soon_title => '아직 이용할 수 없어요';

  @override
  String get coming_soon_body =>
      '로컬 클라우드 저장공간은 출시 준비 중입니다. 현재는 자리 표시자 화면입니다. 정식 출시 시 로컬 업로드, 더 큰 용량, 다중 기기 동기화를 제공할 예정입니다.';

  @override
  String get coming_soon_ok => '확인';

  @override
  String get bullet_free_external => '무료 플랜: 외부 이미지(URL)만 사용 가능';

  @override
  String get bullet_paid_local_upload => '유료 플랜: 로컬 이미지 업로드 및 더 큰 용량 제공';

  @override
  String get bullet_future_tiers => '추후 더 다양한 용량 구간을 제공';

  @override
  String get bullet_pay_cards => '현재는 Google Play 결제 구독만 지원합니다';

  @override
  String get bullet_einvoice =>
      '영수증/세금계산서는 Google Play에서 발급되며, 사업자 등록번호 입력은 지원되지 않습니다';

  @override
  String get bullet_cancel_anytime => '언제든 해지 가능, 다음 달부터 청구 중단';

  @override
  String get bullet_terms => '서비스 약관, 개인정보 처리방침, 환불 정책(추후 링크 추가)';

  @override
  String get bullet_abuse => '불법/남용 업로드 시 이용이 제한될 수 있습니다';

  @override
  String get common_ok => '확인';

  @override
  String get common_okDescription => '일반 확인 버튼';

  @override
  String get common_cancel => '취소';

  @override
  String get common_cancelDescription => '일반 취소 버튼';

  @override
  String get tutorial_title => '사용 가이드';

  @override
  String get tutorial_tab_cards => '카드';

  @override
  String get tutorial_tab_social => '소셜';

  @override
  String get tutorial_tab_explore => '탐색';

  @override
  String get tutorial_tab_more => '더보기';

  @override
  String get tutorial_tab_faq => 'FAQ';

  @override
  String get tutorial_cards_tags_addArtist => '아티스트 카드 추가';

  @override
  String get tutorial_cards_tags_addMini => '미니 카드 추가';

  @override
  String get tutorial_cards_tags_editDelete => '편집 / 삭제';

  @override
  String get tutorial_cards_tags_info => '미니 카드 정보';

  @override
  String get tutorial_cards_addArtist_title => '“아티스트 카드” 추가';

  @override
  String get tutorial_cards_addArtist_s1 => '카드 화면 오른쪽 하단의 “＋”를 탭하세요.';

  @override
  String get tutorial_cards_addArtist_s2 => '로컬 이미지를 선택하거나 이미지 URL을 붙여넣기.';

  @override
  String get tutorial_cards_addArtist_s3 => '오른쪽 스와이프: 정보 편집, 왼쪽 스와이프: 카드 삭제.';

  @override
  String get tutorial_cards_addMini_title => '“미니 카드” 추가';

  @override
  String get tutorial_cards_addMini_s1 => '아무 “아티스트 카드”나 탭해 상세로 이동.';

  @override
  String get tutorial_cards_addMini_s2 => '하단 미니 카드 영역을 탭/위로 스와이프 → 뷰어 진입.';

  @override
  String get tutorial_cards_addMini_s3 => '맨 왼쪽/오른쪽 페이지에서 QR 스캔 또는 편집 열기.';

  @override
  String get tutorial_cards_addMini_s4 =>
      '편집 화면 오른쪽 하단 “＋”로 추가, 같은 화면에서 삭제 가능.';

  @override
  String get tutorial_cards_info_title => '“미니 카드 정보” 관리';

  @override
  String get tutorial_cards_info_s1 => '추가 후 뷰어에 표시, 탭하면 뒤집기.';

  @override
  String get tutorial_cards_info_s2 => '뒤면 오른쪽 상단 “정보”에서 이름/번호/앨범/종류/메모/태그 편집.';

  @override
  String get tutorial_cards_info_s3 => '태그로 빠른 필터링 및 더 정확한 검색 가능.';

  @override
  String get tutorial_cards_note_json => '팁: 오른쪽 상단에서 JSON 다운로드와 일괄 가져오기 지원.';

  @override
  String get tutorial_social_tags_primary => '친구 / 인기 / 팔로잉';

  @override
  String get tutorial_social_tags_postComment => '게시 & 댓글';

  @override
  String get tutorial_social_tags_lists => '리스트 관리';

  @override
  String get tutorial_social_browse_title => '게시물 보기';

  @override
  String get tutorial_social_browse_s1 => '상단 탭에서 “친구”, “인기”, “팔로잉” 전환.';

  @override
  String get tutorial_social_browse_s2 => '각 탭에서 보기/좋아요/댓글 가능.';

  @override
  String get tutorial_social_post_title => '게시 & 댓글';

  @override
  String get tutorial_social_post_s1 => '오른쪽 하단 “연필” 버튼으로 게시.';

  @override
  String get tutorial_social_post_s2 => '게시물은 “인기”와 “친구”에 표시(친구가 상호작용).';

  @override
  String get tutorial_social_list_title => '리스트 관리';

  @override
  String get tutorial_social_list_s1 => '오른쪽 상단 “#”: 친구 리스트 편집.';

  @override
  String get tutorial_social_list_s2 => '오른쪽 상단 “명함”: 팔로잉 리스트 편집.';

  @override
  String get tutorial_explore_wall_title => '아이돌 배경 자유 제작';

  @override
  String get tutorial_explore_wall_s1 => '사진/슬로건/스티커로 개성 있게 꾸미기.';

  @override
  String get tutorial_explore_wall_s2 => '“생일 디데이” 위젯 추가 가능.';

  @override
  String get tutorial_more_settings_title => '설정 & 사용자';

  @override
  String get tutorial_more_settings_s1 => '“설정”: 테마, 언어, 알림 등.';

  @override
  String get tutorial_more_settings_s2 => '“사용자 설정”: 닉네임, 아바타, 로그인 방식.';

  @override
  String get tutorial_more_stats_title => '통계';

  @override
  String get tutorial_more_stats_s1 => '아티스트 수, 미니 카드 수, 출처(로컬/온라인) 확인.';

  @override
  String get tutorial_more_stats_s2 => '랭크/업적을 통해 수집 여정을 기록.';

  @override
  String get tutorial_more_dex_title => '도감';

  @override
  String get tutorial_more_dex_s1 => '모든 카드를 한눈에, 검색/필터 지원.';

  @override
  String get tutorial_faq_q1 => '미니 카드를 빠르게 여러 장 추가하려면?';

  @override
  String get tutorial_faq_a1 =>
      '미니 카드 보기 페이지 오른쪽 상단에는 두 개의 버튼이 있습니다. 왼쪽 버튼은 JSON 파일의 일괄 추가를 지원하며, 오른쪽 버튼은 해당 아티스트의 카드 JSON 파일을 다운로드할 수 있습니다.';

  @override
  String get tutorial_faq_q2 => 'QR / JSON 가져오기는 어디에 있나요?';

  @override
  String get tutorial_faq_a2 => '뷰어의 맨 왼쪽/오른쪽, 또는 “더보기” 메뉴의 “가져오기”.';

  @override
  String get tutorial_faq_q3 => '태그는 무엇에 쓰나요?';

  @override
  String get tutorial_faq_a3 => '뷰어에서 빠른 필터, 더 정확한 검색에 도움.';

  @override
  String get tutorial_faq_q4 => '언어와 테마 변경은?';

  @override
  String get tutorial_faq_a4 => '“더보기 → 설정”에서 앱 언어와 라이트/다크 전환.';

  @override
  String get tutorial_faq_q5 => '소셜 게시물은 어디에 표시되나요?';

  @override
  String get tutorial_faq_a5 => '“인기”와 “친구”에 표시되며, 친구가 상호작용할 수 있습니다.';

  @override
  String get postHintShareSomething => '무엇을 공유하시겠어요?';

  @override
  String get postAlbum => '앨범';

  @override
  String get postPublish => '게시';

  @override
  String get postTags => '태그';

  @override
  String get postAddTagHint => '태그를 추가하고 Enter 키를 누르세요';

  @override
  String get postAdd => '추가';

  @override
  String postTagsCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String postTagLimit(int max) {
    return '태그는 최대 $max개';
  }

  @override
  String get currentPlan => '현재 플랜';

  @override
  String get filter => '필터';

  @override
  String get filterPanelTitle => '카드 필터';

  @override
  String get filterClear => '초기화';

  @override
  String get filterSearchHint => '이름·메모·시리얼 번호 검색…';

  @override
  String get extraInfoSectionTitle => '추가 정보';

  @override
  String get fieldStageNameLabel => '활동명 / 별명';

  @override
  String get fieldGroupLabel => '그룹 / 시리즈';

  @override
  String get fieldOriginLabel => '카드 출처';

  @override
  String get fieldNoteLabel => '메모';

  @override
  String get profileSectionTitle => '기본 정보';

  @override
  String get noQuotePlaceholder => '아직 문구가 없습니다';

  @override
  String cardNameAlreadyExists(Object name) {
    return '\"$name\" 이름의 카드가 이미 존재합니다. 다른 이름을 사용해주세요.';
  }

  @override
  String deleteCardAndMiniCardsMessage(Object name) {
    return '\"$name\"을(를) 삭제하시겠습니까? 이 인물에 속한 모든 미니 카드도 함께 삭제됩니다.';
  }

  @override
  String get socialProfileTitle => '프로필';

  @override
  String get userProfileLongPressHint => '길게 눌러 프로필을 편집하세요';

  @override
  String get scanFriendQrTitle => '명함 QR을 스캔해 친구 추가';

  @override
  String get scanFriendQrButtonLabel => '명함 스캔하여 추가';

  @override
  String get filterAlbumNone => '앨범 없음';

  @override
  String get albumCollectionTitle => '앨범 컬렉션';

  @override
  String get albumCollectionEmptyHint =>
      '아직 저장된 앨범이 없습니다. 먼저 가장 좋아하는 앨범부터 추가해 보세요.';

  @override
  String get albumSwipeEdit => '편집';

  @override
  String get albumSwipeDelete => '삭제';

  @override
  String get albumDialogAddTitle => '앨범 추가';

  @override
  String get albumDialogEditTitle => '앨범 편집';

  @override
  String get albumDialogFieldTitle => '앨범 이름';

  @override
  String get albumDialogFieldArtist => '아티스트 / 그룹';

  @override
  String get albumDialogFieldYear => '발매 연도 (선택)';

  @override
  String get albumDialogFieldCover => '커버 이미지 URL (선택)';

  @override
  String get albumDialogFieldYoutube => 'YouTube 링크 (선택)';

  @override
  String get albumDialogFieldYtmusic => 'YT Music 링크 (선택)';

  @override
  String get albumDialogFieldSpotify => 'Spotify 링크 (선택)';

  @override
  String get albumDialogAddConfirm => '추가';

  @override
  String get albumDialogEditConfirm => '저장';

  @override
  String get albumDeleteConfirmTitle => '앨범 삭제';

  @override
  String albumDeleteConfirmMessage(Object title) {
    return '\"$title\" 앨범을 삭제하시겠습니까?';
  }

  @override
  String albumDetailReleaseYear(Object year) {
    return '발매 연도: $year';
  }

  @override
  String get albumDetailNoStreaming => '아직 스트리밍 링크가 설정되지 않았어요.';

  @override
  String get albumDetailHint => '나중에 여기에서 트랙 리스트, 코멘트, 추천 이유 등을 적어 둘 수 있습니다.';

  @override
  String get albumTracksSectionTitle => '수록곡';

  @override
  String get albumNoTracksHint => '이 앨범에는 아직 곡이 추가되지 않았습니다.';

  @override
  String get albumFieldLanguage => '언어';

  @override
  String get albumFieldVersion => '버전';

  @override
  String get albumCoverFromUrlLabel => 'URL 사용';

  @override
  String get albumCoverFromLocalLabel => '로컬 이미지 사용';

  @override
  String get albumFieldArtistsLabel => '아티스트';

  @override
  String get albumFieldArtistsInputHint => '아티스트 이름을 입력하고 Enter 키로 추가…';

  @override
  String get albumArtistsSuggestionHint => '입력하면 추천 목록이 표시됩니다.';

  @override
  String get albumLinksSectionTitle => '스트리밍 링크';

  @override
  String get albumLinksCollapsedHint => 'YouTube / YT Music / Spotify…';

  @override
  String get albumAddTrackButtonLabel => '곡 추가';

  @override
  String get albumTrackDialogAddTitle => '곡 추가';

  @override
  String get albumTrackDialogEditTitle => '곡 편집';

  @override
  String get albumTrackFieldTitle => '곡 제목';

  @override
  String get albumTitleRequiredMessage => '앨범 제목을 입력해 주세요.';

  @override
  String get albumCoverLocalRequiredMessage => '로컬 커버 이미지를 선택해 주세요.';

  @override
  String albumDetailLanguage(String lang) {
    return '언어: $lang';
  }

  @override
  String albumDetailVersion(String ver) {
    return '버전: $ver';
  }

  @override
  String get albumTrackImageLabel => '트랙 이미지(선택 사항)';

  @override
  String get albumTrackClearImageTooltip => '이미지 지우기';

  @override
  String get albumTrackImageUseAlbumHint => '이미지를 설정하지 않으면 이 곡에는 앨범 커버가 사용됩니다.';
}
