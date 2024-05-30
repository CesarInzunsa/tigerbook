class PostModel {
  String id;
  String userId;
  String content;
  List<String> images;
  DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
    required this.createdAt,
  });

  PostModel.empty()
      : id = '',
        userId = '',
        content = '',
        images = [],
        createdAt = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'images': images,
      'createdAt': createdAt,
    };
  }

  static PostModel fromMap(Map<String, dynamic> map, String id) {
    DateTime utcTime = DateTime.fromMillisecondsSinceEpoch(map['createdAt'].seconds * 1000);
    DateTime localTime = utcTime.toLocal();
    //log('Post.fromMap: ${map['images']}');
    return PostModel(
      id: id,
      userId: map['userId'],
      content: map['content'],
      images: List<String>.from(map['images']),
      createdAt: localTime,
    );
  }
}
