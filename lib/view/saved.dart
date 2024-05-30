// flutter
import 'package:flutter/material.dart';

// business logic
import '../model/post_content_model.dart';
import '../controller/local_controller.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  State<Saved> createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  ValueNotifier<List<PostContentModel>> posts = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    List<PostContentModel> data = await LocalController.getAllSavedPosts();

    setState(() {
      posts.value = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _displayFeed(),
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
      return const Center(child: Text('No hay publicaciones guardadas'));
    } else {
      return ListView.builder(
        itemCount: posts.value.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _displayPostHeader(posts.value[index]),
                  _displayPostContent(posts.value[index]),
                  //_displayImages(posts.value[index].post.images),
                  //_displaySaveButton(posts.value[index]),
                ],
              ),
            ),
            onTap: () {
              // mostrar modal para eliminar la publicación guardada
              _showConfirmDeleteDialog(posts.value[index]);
            },
          );
        },
      );
    }
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
              onPressed: () async {
                Navigator.pop(context);
                await LocalController.deleteOnePost(post.post.id).then(
                  (value) {
                    _fetchData();
                  },
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Widget _displayPostHeader(PostContentModel post) {
    return ListTile(
      title: Text(post.name),
      subtitle: Text(post.userName),
      leading: const CircleAvatar(child: Icon(Icons.person_outline)),
    );
  }

  Widget _displayPostContent(PostContentModel post) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
      ),
      child: Text(post.post.content),
    );
  }
}
