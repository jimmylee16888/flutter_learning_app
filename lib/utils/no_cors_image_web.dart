// lib/utils/no_cors_image_web.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui; // Web 專用：提供 platformViewRegistry
import 'package:flutter/widgets.dart';

class NoCorsImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width, height, borderRadius;

  const NoCorsImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  static final _registered = <String>{};

  @override
  Widget build(BuildContext context) {
    final viewType =
        'nocors-img-${url.hashCode}-${borderRadius ?? 0}-${fit.name}';

    if (!_registered.contains(viewType)) {
      ui.platformViewRegistry.registerViewFactory(viewType, (int _) {
        // 外層包一層，裁切圓角，並讓事件穿透
        final wrapper = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.overflow = 'hidden'
          ..style.borderRadius = '${borderRadius ?? 0}px'
          ..style.pointerEvents = 'none'; // 讓事件穿透到 Flutter

        final img = html.ImageElement()
          ..src = url
          ..draggable = false
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = _css(fit)
          ..style.pointerEvents = 'none'; // 同樣不要吃事件

        wrapper.children = [img];
        return wrapper;
      });
      _registered.add(viewType);
    }

    return SizedBox(
      width: width,
      height: height,
      // 不再使用 hitTestBehavior；全靠 CSS pointer-events: none
      child: HtmlElementView(viewType: viewType),
    );
  }

  String _css(BoxFit f) {
    switch (f) {
      case BoxFit.contain:
      case BoxFit.fitHeight:
      case BoxFit.fitWidth:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
      case BoxFit.cover:
      default:
        return 'cover';
    }
  }
}
