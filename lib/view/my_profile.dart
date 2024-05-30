// flutter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// business logic
import '../controller/controller.dart';
import '../controller/login_controller.dart';
import '../model/post_content_model.dart';
import '../model/user_content_model.dart';
import 'edit_profile.dart';
import 'tool.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ValueNotifier<UserContentModel> userContent = ValueNotifier(UserContentModel.empty());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    String myUserId = LoginController().getMyProfileId();
    UserContentModel userContent = await Controller().getUserProfile(myUserId);

    setState(() {
      this.userContent.value = userContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _displayMyProfile();
  }

  Widget _displayMyProfile() {
    return ValueListenableBuilder(
      valueListenable: userContent,
      builder: (context, users, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await _fetchData();
            },
            child: Column(
              children: [
                _displayUserInfo(),
                Expanded(
                  child: _displayUserPosts(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _displayUserInfo() {
    if (userContent.value.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _displayProfilePicture(),
                _displayProfileOptions(),
              ],
            ),
            _displayProfileInfo(),
          ],
        ),
      );
    }
  }

  Widget _displayProfileOptions() {
    return OutlinedButton(
      onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return EditProfile(userContent: userContent.value);
            },
          ),
        ).then((value) {
          _fetchData();
        });
      },
      style: Tool.getButtonStyle('secondary'),
      child: const Text('Editar perfil'),
    );
  }

  Widget _displayProfileInfo() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _displayBadgeOrName(),
          Text(
            '@${userContent.value.userName}',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayBadgeOrName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${userContent.value.name} ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        FutureBuilder(
          future: Controller().isUserVerified(userContent.value.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.data!) {
                return const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: Colors.blue,
                  size: 20,
                );
              } else {
                return const SizedBox();
              }
            }
          },
        ),
      ],
    );
  }

  Widget _displayProfilePicture() {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: userContent.value.profilePicture.trim().isEmpty
          ? CircleAvatar(
              radius: 40,
              backgroundImage: Image.network(
                Tool.getDefaultProfileImage(),
                fit: BoxFit.scaleDown,
              ).image)
          : CircleAvatar(
              radius: 40,
              backgroundImage: Image.network(
                userContent.value.profilePicture,
                fit: BoxFit.scaleDown,
              ).image),
    );
  }

  Widget _displayUserPosts() {
    if (userContent.value.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: userContent.value.posts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _displayPostHeader(userContent.value.posts[index]),
                  _displayPostContent(userContent.value.posts[index]),
                  _displayImages(userContent.value.posts[index].post.images),
                  _displaySaveButton(userContent.value.posts[index]),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _displayPostHeader(PostContentModel post) {
    return ListTile(
      title: Text(post.name),
      subtitle: Text(post.userName),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          post.profilePicture,
        ),
      ),
    );
  }

  Widget _displayPostContent(PostContentModel post) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Text(post.post.content),
    );
  }

  Widget _displayImages(List<String> images) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20.0),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var image in images)
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  image,
                  width: 200.0,
                  height: 200.0,
                  loadingBuilder: _displayLoadingImageBuilder,
                  errorBuilder: _displayErrorImageBuilder,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _displayLoadingImageBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return SizedBox(
      height: 200,
      width: 200,
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _displayErrorImageBuilder(
    BuildContext context,
    Object exception,
    StackTrace? stackTrace,
  ) {
    return Container(
      height: 200,
      width: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.error_outline),
    );
  }

  Widget _displaySaveButton(PostContentModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          onPressed: () {
            // Guardar el post de forma local para su consulta sin internet
            //Controller().savePost(post);
          },
        ),
      ],
    );
  }
}
