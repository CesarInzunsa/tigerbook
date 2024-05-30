import './post_content_model.dart';

class UserContentModel {
  String id;
  String name;
  String userName;
  String profilePicture;
  List<PostContentModel> posts;

  UserContentModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.profilePicture,
    required this.posts,
  });

  UserContentModel.empty()
      : id = '',
        name = '',
        userName = '',
        profilePicture = '',
        posts = [];
}
