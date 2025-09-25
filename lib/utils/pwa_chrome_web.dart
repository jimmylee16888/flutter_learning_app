// Web 平台：動態更新 <meta name="theme-color"> 與 body 背景
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui';

String _toHexRGB(Color c) =>
    '#${c.red.toRadixString(16).padLeft(2, '0')}'
    '${c.green.toRadixString(16).padLeft(2, '0')}'
    '${c.blue.toRadixString(16).padLeft(2, '0')}';

void updatePwaChrome({required Color surface, required bool dark}) {
  final hex = _toHexRGB(surface);

  // 1) 更新/建立 <meta name="theme-color">
  final head = html.document.head;
  if (head != null) {
    final metas = head.querySelectorAll('meta[name="theme-color"]');
    if (metas.isEmpty) {
      final m = html.MetaElement()
        ..name = 'theme-color'
        ..content = hex;
      head.append(m);
    } else {
      for (final el in metas) {
        final m = el as html.MetaElement;
        m.content = hex;
        m.removeAttribute('media'); // 立即生效（移除媒體條件）
      }
    }
  }

  // 2) 更新 body 背景，讓 iOS black-translucent 狀態列吃到這個色
  html.document.body?.style.backgroundColor = hex;
}
