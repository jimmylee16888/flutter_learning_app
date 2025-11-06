// lib/screens/explore/ad_config.dart

/// 是否啟用遠端設定（建議 true）
/// 會去抓 [kRemoteAdEndpoint]：{"bannerUrl":"...","clickUrl":"..."}
const bool kUseRemoteAd = true;

/// 你的 GitHub Pages JSON 端點
const String kRemoteAdEndpoint = "https://jimmylee16888.github.io/popcard-ad/ad.json";

/// 備援：當遠端抓失敗就用這裡（支援多個；取第一個）
class AdFallback {
  final String bannerUrl;
  final String clickUrl;
  const AdFallback(this.bannerUrl, this.clickUrl);
}

const List<AdFallback> kAdFallbacks = <AdFallback>[
  // 你可以換成自己的圖與連結
  AdFallback("https://jimmylee16888.github.io/popcard-ad/promo_banner_1200x600.png", "https://example.com/landing"),
  // 可再加更多：
  // AdFallback("https://your.cdn.com/banner2.png", "https://your.site/promo2"),
];
