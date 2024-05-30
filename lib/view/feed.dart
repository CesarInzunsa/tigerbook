// flutter
import 'package:flutter/material.dart';

// plugins
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:intl/intl.dart';

// business logic
import '../controller/controller.dart';
import '../controller/local_controller.dart';
import '../controller/login_controller.dart';
import '../model/post_content_model.dart';
import 'tool.dart';
import 'edit_post.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  ValueNotifier<List<PostContentModel>> posts =
      ValueNotifier<List<PostContentModel>>([]);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<PostContentModel> temp = await Controller().getPosts();

    // Check if this widget is still in the widget tree before calling setState
    if (mounted) {
      setState(() {
        posts.value = temp;
      });
    }

    // setState(() {
    //   posts.value = temp;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayFeed(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreatePost,
        label: const Text('Crear Post'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _displayFeed() {
    return ValueListenableBuilder(
      valueListenable: posts,
      builder: (context, users, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await _fetchData();
          },
          child: _displayPosts(),
        );
      },
    );
  }

  Widget _displayPosts() {
    if (posts.value.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80.0),
        itemCount: posts.value.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _displayPostHeader(posts.value[index]),
                  _displayPostContent(posts.value[index]),
                  _displayImages(posts.value[index].post.images),
                  _displaySaveButton(posts.value[index]),
                ],
              ),
            ),
            onTap: () {
              // Si es una publicacion del usuario actual, abrir dialogo
              if (posts.value[index].userId ==
                  LoginController().getMyProfileId()) {
                _showPostOptionsDialog(posts.value[index]);
              }
            },
          );
        },
      );
    }
  }

  Widget _displayPostHeader(PostContentModel post) {
    // Crear un formato de fecha
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
    return ListTile(
      title: Text(
        post.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '@${post.userName}',
        style: const TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      trailing: Text(format.format(post.post.createdAt)),
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

  Widget _displaySaveButton(PostContentModel post) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          onPressed: () async {
            // Guardar el post de forma local para su consulta sin internet
            _displayLoadingSavedPostDialog(post);
          },
        ),
      ],
    );
  }

  void _displayLoadingSavedPostDialog(PostContentModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureProgressDialog(
          LocalController.savePost(post),
          message: const Text('Guardando post'),
        );
      },
    ).then((value) {
      if (value) {
        Tool.showMessage('Post guardado', context);
      } else {
        Tool.showMessage('Error al guardar el post', context);
      }
    });
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

  void _handleCreatePost() {
    Navigator.pushNamed(context, '/create-post').then((value) => _fetchData());
  }

  void _showPostOptionsDialog(PostContentModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Opciones del post'),
          content: const Text('¿Qué deseas hacer con este post?'),
          actions: [
            _displayEditButton(post),
            _displayDeleteButton(post),
          ],
        );
      },
    );
  }

  Widget _displayEditButton(PostContentModel post) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return EditPost(post: post.post);
            },
          ),
        ).then((value) {
          Navigator.pop(context);
          // Actualizar la lista de posts
          _fetchData();
        });
      },
      child: const Text('Editar'),
    );
  }

  Widget _displayDeleteButton(PostContentModel post) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        // show confirm dialog
        _showConfirmDeleteDialog(post);
      },
      child: const Text('Eliminar'),
    );
  }

  void _showConfirmDeleteDialog(PostContentModel post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Estás seguro de que deseas eliminar este post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                //Controller().deletePost(post);
                _showDialogOfPostDeleted(post);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogOfPostDeleted(PostContentModel post) {
    showDialog(
        context: context,
        builder: (context) {
          return FutureProgressDialog(
            Controller().deletePost(post),
            message: const Text('Eliminando post'),
          );
        }).then((value) {
      if (value) {
        Tool.showMessage('Post guardado', context);
        // Actualizar la lista de posts
        _fetchData();
      } else {
        Tool.showMessage('Error al guardar el post', context);
      }
    });
  }
}
