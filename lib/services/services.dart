// lib/services/services.dart

/*
services/ 檔案職責（改動指引）

core/
- base_url.dart
  功能：集中定義後端 baseUrl（支援 --dart-define）。
  改這裡當：要換環境、改 API 網域/埠/預設逾時。

auth/
- auth_api.dart
  功能：呼叫認證後端（/healthz /v1/auth/login /v1/auth/register）。
  改這裡當：登入/註冊 API 路徑、參數、回傳格式要調整。
- auth_controller.dart
  功能：App 登入狀態（Firebase + 離線模式），提供 UI 監聽。
  改這裡當：登入流程、離線沿用帳號、登出或 token 取得方式要改。

explore/
- explore_local.dart
  功能：ExploreItem 清單的本機檔案存取（JSON in Documents）。
  改這裡當：Explore 的儲存檔名/格式、載入/儲存策略要改。

mini_cards/
- mini_card_store.dart
  功能：小卡資料的分組與狀態（依「擁有者/藝人」），提供給 UI。
  改這裡當：小卡載入來源、分組邏輯、通知 UI 的時機要改。

prefs/
- friend_prefs.dart
  功能：已追蹤好友 ID 的本機快取（SharedPreferences）。
  改這裡當：追蹤好友集合的本機儲存/同步策略要改。
- image_prefs.dart
  功能：postId → image 檔案路徑的對應表（SharedPreferences, JSON）。
  改這裡當：貼文圖片的本機映射/清理策略要改。
- profile_cache.dart
  功能：個人檔案相關本機快取（追蹤標籤/好友/相簿）。
  改這裡當：UI 離線顯示的快取欄位或格式要改。

social/
- social_api.dart
  功能：社群後端 API（/me、追蹤、貼文CRUD、留言、上傳檔）。
  改這裡當：任何社群相關 API 路徑/參數/Authorization/回傳要改。
- tag_follow_controller.dart
  功能：追蹤標籤的 UI 狀態管理（載入、新增/刪除、離線 fallback）。
  改這裡當：標籤上限/正規化策略/與後端同步流程要改。

stats/
- stats_service.dart
  功能：小卡統計的純計算（不含 IO）。
  改這裡當：統計欄位、分組規則、摘要內容要改或新增。

utils/qr/
- qr_codec.dart
  功能：QR 內容編解碼（gz: JSON、id: 短碼、通用 decode）。
  改這裡當：QR 承載格式、版本相容策略要改。
- qr_image_builder.dart
  功能：把字串資料畫成 QR PNG（可設定尺寸/邊界）。
  改這裡當：QR 影像輸出尺寸、邊距、繪製樣式要改。

barrel：
- services.dart
  功能：給 UI/Feature 層統一匯入；services 內部彼此請用精準匯入避免循環。
*/

// core
export 'core/base_url.dart';

// auth
export 'auth/auth_api.dart';
export 'auth/auth_controller.dart';

// social
export 'social/social_api.dart';
export 'social/tag_follow_controller.dart';
export 'social/friend_follow_controller.dart';

// prefs
export 'prefs/friend_prefs.dart';
export 'prefs/image_prefs.dart';
export 'prefs/profile_cache.dart';

// explore
// export 'explore/explore_local.dart';
export 'explore/explore_store.dart';

// mini cards
export 'mini_cards/mini_card_store.dart';

// stats
export 'stats/stats_service.dart';

// utils
export 'utils/qr/qr_codec.dart';
export 'utils/qr/qr_image_builder.dart';

// tips
export 'tips/tip_service.dart';
