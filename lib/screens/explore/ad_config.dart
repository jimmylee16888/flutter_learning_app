// lib/screens/explore/ad_config.dart

/// 是否啟用遠端設定（Explore 那邊會用到）
const bool kUseRemoteAd = true;

/// 共用目錄（你 GitHub Pages 的資料夾）
const String kAdBase = "https://jimmylee16888.github.io/popcard-ad/";

/// Explore / 其他頁面的遠端 JSON
const String kRemoteAdEndpoint = "${kAdBase}ad.json";

class AdFallback {
  final String bannerUrl;
  final String clickUrl;
  const AdFallback(this.bannerUrl, this.clickUrl);
}

/// Explore 通用備援
const List<AdFallback> kAdFallbacks = <AdFallback>[
  AdFallback(
    "${kAdBase}promo_banner_1200x600.png",
    "https://example.com/landing",
  ),
];

/// ✅ CardsView 專用：固定圖片 & 點擊連結
const String kCardViewAdBannerUrl = "${kAdBase}cardview_banner_1200x600.png";
const String kCardViewAdClickUrl = "https://example.com/cardview-landing";
