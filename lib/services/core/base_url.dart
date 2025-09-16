// lib/services/core/base_url.dart

/// 預設：Android 模擬器連本機用 10.0.2.2；實機或雲端請用正式網域
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

/// 社群後端（如與主 API 分離）
const String kSocialBaseUrl = String.fromEnvironment(
  'SOCIAL_BASE_URL',
  defaultValue: 'https://socialdemo-backend.onrender.com',
  // defaultValue: 'http://10.0.2.2:8088',
);

/// 小工具：把相對路徑補成完整網址（/path → https://host/path）
String absUrl(String base, String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  if (url.startsWith('/')) return '$base$url';
  return '$base/$url';
}
