// lib/screens/social/post_composer.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_learning_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

// ✅ 使用 gen-l10n 產生的 AppLocalizations

class PostComposerResult {
  final String text;
  final List<String> tags;
  final XFile? image;
  const PostComposerResult({
    required this.text,
    required this.tags,
    this.image,
  });
}

Future<PostComposerResult?> showPostComposer(
  BuildContext context, {
  int maxTags = 5,
  String initialText = '',
  List<String> initialTags = const <String>[],
}) async {
  final cs = Theme.of(context).colorScheme;
  final textCtrl = TextEditingController(text: initialText);
  final tagCtrl = TextEditingController();
  final Set<String> tags = {...initialTags.map((e) => e.toLowerCase())};

  XFile? pickedImage;
  Uint8List? pickedPreviewBytes;

  return showModalBottomSheet<PostComposerResult?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (ctx, setSB) {
          // ⬇️ 這裡改用 AppLocalizations
          final t = AppLocalizations.of(ctx)!;

          void addTag(String raw) {
            final tv = raw.trim().toLowerCase();
            if (tv.isEmpty) return;
            if (tags.length >= maxTags) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.postTagLimit(maxTags))));
              return;
            }
            tags.add(tv);
            tagCtrl.clear();
            setSB(() {});
          }

          Future<void> pickFromGallery() async {
            final x = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 85,
            );
            if (x != null) {
              pickedImage = x;
              pickedPreviewBytes = await x.readAsBytes();
              setSB(() {});
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textCtrl,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: t.postHintShareSomething,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (pickedPreviewBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        pickedPreviewBytes!,
                        fit: BoxFit.cover,
                      ),
                    ),

                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: pickFromGallery,
                        icon: const Icon(Icons.photo),
                        label: Text(t.postAlbum),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          final txt = textCtrl.text.trim();
                          if (txt.isEmpty && pickedImage == null) {
                            Navigator.pop(context, null);
                            return;
                          }
                          Navigator.pop(
                            context,
                            PostComposerResult(
                              text: txt,
                              tags: tags.toList(),
                              image: pickedImage,
                            ),
                          );
                        },
                        child: Text(t.postPublish),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(t.postTags),
                      const SizedBox(width: 8),
                      Text(
                        t.postTagsCount(tags.length, maxTags),
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: t.postAddTagHint,
                          ),
                          onSubmitted: addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => addTag(tagCtrl.text),
                        child: Text(t.postAdd),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: [
                        for (final tg in tags)
                          InputChip(
                            label: Text('#$tg'),
                            onDeleted: () {
                              tags.remove(tg);
                              setSB(() {});
                            },
                          ),
                      ],
                    ),
                  ),

                  const SafeArea(
                    top: false,
                    minimum: EdgeInsets.only(bottom: 6),
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
