// lib/screens/social/post_composer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostComposerResult {
  final String text;
  final List<String> tags;
  final File? image; // 交給 SocialApi 上傳
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
  File? pickedImage;

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
          void addTag(String raw) {
            final t = raw.trim().toLowerCase();
            if (t.isEmpty) return;
            if (tags.length >= maxTags) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Tag limit $maxTags')));
              return;
            }
            tags.add(t);
            tagCtrl.clear();
            setSB(() {});
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
                    decoration: const InputDecoration(hintText: '分享點什麼…'),
                  ),
                  const SizedBox(height: 8),
                  if (pickedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(pickedImage!, fit: BoxFit.cover),
                    ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final x = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (x != null) {
                            pickedImage = File(x.path);
                            setSB(() {});
                          }
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text('相簿'),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          final t = textCtrl.text.trim();
                          if (t.isEmpty && pickedImage == null) {
                            Navigator.pop(context, null);
                            return;
                          }
                          Navigator.pop(
                            context,
                            PostComposerResult(
                              text: t,
                              tags: tags.toList(),
                              image: pickedImage,
                            ),
                          );
                        },
                        child: const Text('發佈'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('標籤'),
                      const SizedBox(width: 8),
                      Text(
                        '${tags.length}/$maxTags',
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
                          decoration: const InputDecoration(
                            hintText: '新增標籤，按 Enter',
                          ),
                          onSubmitted: addTag,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: () => addTag(tagCtrl.text),
                        child: const Text('加入'),
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
                        for (final t in tags)
                          InputChip(
                            label: Text('#$t'),
                            onDeleted: () {
                              tags.remove(t);
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
