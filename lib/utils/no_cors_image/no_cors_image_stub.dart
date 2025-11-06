import 'package:flutter/widgets.dart';

class NoCorsImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width, height, borderRadius;

  const NoCorsImage(this.url, {super.key, this.fit = BoxFit.cover, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Image.network(url, width: width, height: height, fit: fit);
  }
}
