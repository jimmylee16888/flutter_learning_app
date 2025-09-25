import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../models/mini_card_data.dart';
import '../../../../../utils/mini_card_io/mini_card_io.dart';
import '../../../../../utils/no_cors_image/no_cors_image.dart';

class MiniCardFront extends StatelessWidget {
  const MiniCardFront({super.key, required this.card});
  final MiniCardData card;

  @override
  Widget build(BuildContext context) {
    // 判斷是否有本地檔（Web 上若是 'url:' 開頭視為不是本地）
    final hasLocal =
        (card.localPath ?? '').isNotEmpty &&
        !(kIsWeb && (card.localPath?.startsWith('url:') ?? false));
    final hasRemote = (card.imageUrl ?? '').isNotEmpty;

    Widget image;
    if (kIsWeb && !hasLocal && hasRemote) {
      // Web + 無本地 + 有 URL → 用無 CORS 小工具顯示
      image = NoCorsImage(card.imageUrl!, fit: BoxFit.cover);
    } else if (hasLocal) {
      // 有本地檔（跨平台），直接用 local provider（Web 也支援 'url:' 替代案）
      image = Image(
        image: imageProviderForLocalPath(card.localPath!),
        fit: BoxFit.cover,
      );
    } else {
      // 其他情況交給通用 provider（Network / Asset / Memory …）
      image = Image(image: imageProviderOf(card), fit: BoxFit.cover);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: image,
    );
  }
}
