class TipPrompt {
  final String id;
  final String title;
  final String body;
  final String imageUrl; // 絕對或相對網址

  TipPrompt({required this.id, required this.title, required this.body, required this.imageUrl});

  factory TipPrompt.fromJson(Map<String, dynamic> j) => TipPrompt(
    id: '${j['id'] ?? ''}',
    title: '${j['title'] ?? ''}',
    body: '${j['body'] ?? ''}',
    imageUrl: '${j['imageUrl'] ?? ''}',
  );
}
