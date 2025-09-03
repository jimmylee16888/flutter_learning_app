// lib/screens/explore/ad_config.dart
const bool kUseRemoteAd = false; // ← 未來要接後端時改成 true 即可

// 本地硬寫的廣告設定（使用者無法改）
const String kAdBannerAsset = 'assets/images/ad_banner.png'; // 卡片上顯示的橫幅
const String kAdClickUrl =
    'https://buymeacoffee.com/'; // 點擊後的連結（無 WebView 需求時用）

// 如果你要保留「用本地 HTML 開啟」的體驗，也可以把 HTML 寫死在這：
// （ExploreView 會在啟動時把它寫到 <app-docs>/ad_page.html 然後用 OpenFilex 開）
// 若不需要 HTML，就把 kAdHtml 設為空字串即可。
const String kAdHtml = '''
<!doctype html><html lang="zh-Hant"><head>
<meta charset="utf-8"/><meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>工程師需要你的拯救｜PCARD</title>
<style>body{font-family:sans-serif;padding:24px} .btn{display:inline-block;padding:12px 18px;background:#7c4dff;color:#fff;border-radius:999px;text-decoration:none}</style>
</head><body>
  <h1>工程師需要你的拯救</h1>
  <p>小額贊助我們，完成更好作品・你的支持是前進的動力</p>
  <p><a class="btn" href="https://buymeacoffee.com/" target="_blank" rel="noopener">☕ 立即贊助</a></p>
</body></html>
''';

// （可選）未來切後端：遠端 JSON API
// 例：GET https://api.example.com/app/ad
// 回傳格式（建議）：
/*
{
  "bannerUrl": "https://cdn.example.com/ad/banner-2025-09.png",
  "clickUrl": "https://example.com/promo",         // 或 null
  "htmlUrl": "https://cdn.example.com/ad/page.html"// 或 null; 兩者擇一
}
*/
// 你可以把端點留空，等有了再填。
const String kRemoteAdEndpoint = ""; // 例如 "https://api.example.com/app/ad"
