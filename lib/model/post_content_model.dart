//plugins
import 'package:uuid/uuid.dart';

// business logic
import '../model/post_model.dart';

class PostContentModel {
  String userId;
  String profilePicture;
  String name;
  String userName;
  PostModel post;

  PostContentModel.empty()
      : userId = '',
        profilePicture = '',
        name = '',
        userName = '',
        post = PostModel.empty();

  PostContentModel({
    required this.userId,
    required this.profilePicture,
    required this.name,
    required this.userName,
    required this.post,
  });

  Map<String, dynamic> toSqFlite() {
    return {
      'id': const Uuid().v4().replaceAll('-', ''),
      'postId': post.id,
      'userId': userId,
      'name': name,
      'userName': userName,
      'postContent': post.content,
    };
  }

  static PostContentModel fromSqFlite(Map<String, dynamic> map) {
    return PostContentModel(
      userId: map['userId'],
      profilePicture: '',
      name: map['name'],
      userName: map['userName'],
      post: PostModel(
        content: map['postContent'],
        id: map['postId'],
        userId: map['userId'],
        images: [],
      ),
    );
  }
}
