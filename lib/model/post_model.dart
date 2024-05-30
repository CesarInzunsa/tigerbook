class PostModel {
  String id;
  String userId;
  String content;
  List<String> images;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.images,
  });

  PostModel.empty()
      : id = '',
        userId = '',
        content = '',
        images = [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'images': images,
    };
  }

  static PostModel fromMap(Map<String, dynamic> map, String id) {
    //log('Post.fromMap: ${map['images']}');
    return PostModel(
      id: id,
      userId: map['userId'],
      content: map['content'],
      images: List<String>.from(map['images']),
    );
  }
}
