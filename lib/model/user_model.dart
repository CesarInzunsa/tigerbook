class UserModel {
  String id;
  String profilePicture;
  String name;
  String userName;
  String email;

  UserModel.empty()
      : id = '',
        profilePicture = '',
        name = '',
        userName = '',
        email = '';

  UserModel({
    required this.id,
    required this.profilePicture,
    required this.name,
    required this.userName,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePicture': profilePicture,
      'name': name,
      'userName': userName,
      'email': email,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      profilePicture: map['profilePicture'],
      name: map['name'],
      userName: map['userName'],
      email: map['email'],
    );
  }
}
