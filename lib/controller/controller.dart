// flutter
import 'dart:developer';
import 'dart:io';

// firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tigerbook/model/user_content_model.dart';

// models
import '../model/post_model.dart';
import '../model/post_content_model.dart';
import '../model/user_model.dart';
import 'login_controller.dart';

class Controller {
  static FirebaseFirestore baseRemota = FirebaseFirestore.instance;
  static var carpetaRemota = FirebaseStorage.instance;

  Future<bool> deletePost(PostContentModel post) async {
    try {
      // Eliminar las imagenes asociadas al post
      for (var img in post.post.images) {
        await carpetaRemota.refFromURL(img).delete();
      }

      // Eliminar el post de la base de datos
      await baseRemota.collection('posts').doc(post.post.id).delete();

      // Retornar true si se eliminó correctamente
      return true;
    } catch (err) {
      // Retonar false si hubo un error
      return false;
    }
  }

  Future<bool> editPost(PostModel post, List<File?> imgs) async {
    try {
      // Imprimir por consola todos los datos del post
      log('Post: ${post.id}');
      log('User: ${post.userId}');
      log('Content: ${post.content}');
      log('Images: ${post.images}');

      // Si el arreglo de imagenes no esta vacio
      if (imgs.isNotEmpty) {
        // Subir las imagenes a Firebase Storage
        List<String> imgUrls = [];

        // Crear una copia de la lista de imagenes pero guardarlo en un stream
        var imgsStream = Stream.fromIterable(imgs);

        // Obtener el id del usuario actual
        var userId = LoginController().getMyProfileId();

        // Eliminar las imagenes antiguas
        for (var img in post.images) {
          await carpetaRemota.refFromURL(img).delete();
        }

        // Subir cada imagen a Firebase Storage
        await for (var img in imgsStream) {
          var imgRef =
              carpetaRemota.ref('posts/$userId/${img!.path.split('/').last}');
          await imgRef.putFile(img);
          imgUrls.add(await imgRef.getDownloadURL());
        }

        // Reemplazar las imagenes del post con las urls de las nuevas imagenes
        post.images = imgUrls;
      }

      // Actualizar el post en la base de datos
      await baseRemota.collection('posts').doc(post.id).update({
        'content': post.content,
        'images': post.images,
      });

      // Retonar true si se actualizó correctamente
      return true;
    } catch (e) {
      // Retonar false si hubo un error
      log('Error: $e');
      return false;
    }
  }

  Future<UserContentModel> getUserProfile(String userId) async {
    UserModel user = await getUserById(userId);
    List<PostContentModel> posts = await getPostsById(userId);
    return UserContentModel(
      id: user.id,
      name: user.name,
      userName: user.userName,
      profilePicture: user.profilePicture,
      posts: posts,
    );
  }

  Future<UserModel> getUserById(String userId) async {
    var userResult = await baseRemota.collection('user').doc(userId).get();
    Map<String, dynamic>? data = userResult.data();
    return UserModel.fromMap(data!, userResult.id);
  }

  Future<List<PostContentModel>> getPostsById(String userId) async {
    List<PostModel> posts = [];
    List<PostContentModel> postContent = [];

    // Obtener toda la información de los posts desde firebase
    var postResult = await baseRemota
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in postResult.docs) {
      Map<String, dynamic> data = doc.data();
      posts.add(PostModel.fromMap(data, doc.id));
    }

    // Agregar la informacion de los usuarios a los posts y retonar la lista de post_content
    for (var post in posts) {
      // Obtener la información del usuario
      UserModel userResult =
          await baseRemota.collection('user').doc(post.userId).get().then(
        (value) {
          Map<String, dynamic>? data = value.data();
          return UserModel.fromMap(data!, value.id);
        },
      );
      // Crear un objeto PostContent
      postContent.add(
        PostContentModel(
          userId: post.userId,
          userName: userResult.userName,
          profilePicture: userResult.profilePicture,
          name: userResult.name,
          post: post,
        ),
      );
    }

    // Retornar la lista de posts
    return postContent.isNotEmpty ? postContent : [];
  }

  Future<bool> createPost(PostModel newPost, List<File?> imgs) async {
    try {
      // Subir las imagenes a Firebase Storage
      List<String> imgUrls = [];

      // Crear una copia de la lista de imagenes pero guardarlo en un stream
      var imgsStream = Stream.fromIterable(imgs);

      // Obtener el id del usuario actual
      var userId = LoginController().getMyProfileId();

      // Subir cada imagen a Firebase Storage
      await for (var img in imgsStream) {
        var imgRef =
            carpetaRemota.ref('posts/$userId/${img!.path.split('/').last}');
        await imgRef.putFile(img);
        imgUrls.add(await imgRef.getDownloadURL());
      }

      // Reemplazar las imagenes del nuevo post con las urls
      newPost.images = imgUrls;

      // Insertar el nuevo post en la base de datos
      await baseRemota.collection('posts').add({
        'userId': newPost.userId,
        'content': newPost.content,
        'images': newPost.images,
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (error) {
      //('Error: $error');
      return false;
    }
  }

  Future<List<PostContentModel>> getPosts() async {
    List<PostModel> posts = [];
    List<PostContentModel> postContent = [];
    //log('1');

    // Obtener toda la información de los usuarios desde firebase
    var postResult = await baseRemota.collection('posts').get();

    for (var doc in postResult.docs) {
      Map<String, dynamic> data = doc.data();
      posts.add(PostModel.fromMap(data, doc.id));
    }

    //log('2');

    // Agregar la informacion de los usuarios a los posts y retonar la lista de post_content
    for (var post in posts) {
      // Obtener la información del usuario
      UserModel userResult =
          await baseRemota.collection('user').doc(post.userId).get().then(
        (value) {
          Map<String, dynamic>? data = value.data();
          return UserModel.fromMap(data!, value.id);
        },
      );
      // Crear un objeto PostContent
      postContent.add(
        PostContentModel(
          userId: post.userId,
          userName: userResult.userName,
          profilePicture: userResult.profilePicture,
          name: userResult.name,
          post: post,
        ),
      );
    }

    //log('3');

    // Retornar la lista de posts
    return postContent.isNotEmpty ? postContent : [];
  }

  Future<bool> isEmailAlreadyInUse(String email) async {
    var consulta = await baseRemota
        .collection('user')
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    return consulta.docs.isNotEmpty;
  }

  Future<bool> isUserNameAlreadyInUse(String userName) async {
    var consulta = await baseRemota
        .collection('user')
        .where('userName', isEqualTo: userName.toLowerCase())
        .get();
    return consulta.docs.isNotEmpty;
  }

  Future<bool> insertOneUser(UserModel newUser, File imgProfile) async {
    try {
      // Subir la imagen a Firebase Storage
      var imgRef = carpetaRemota.ref('user/${newUser.id}/profile.jpg');
      await imgRef.putFile(imgProfile);
      // Reemplazar la imagen de perfil con la url
      newUser.profilePicture = await imgRef.getDownloadURL();

      // Insertar el nuevo usuario en la base de datos
      await baseRemota.collection('user').doc(newUser.id).set({
        'profilePicture': newUser.profilePicture,
        'userName': newUser.userName.toLowerCase(),
        'email': newUser.email.toLowerCase(),
        'name': newUser.name,
      });

      // Retornar true si se insertó correctamente
      return true;
    } catch (e) {
      // Retornar false si hubo un error
      return false;
    }
  }

  Future<bool> isUserVerified(String userId) async {
    try {
      // Buscar el documento del usuario con el id
      Map<String, dynamic> user = await baseRemota
          .collection('user')
          .doc(userId)
          .get()
          .then((doc) => doc.data()!);

      //log('Usuario: ${user['userName']}');

      // Verificar si el usuario tiene una clave llamada verified
      if (user['verified'] == null) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateOneUser(UserModel user, File imgProfile) async {
    try {
      // Comprobar que el nombre de usuario nuevo este disponible
      var consulta = await baseRemota
          .collection('user')
          .where('userName', isEqualTo: user.userName.trim().toLowerCase())
          .get();

      if (consulta.docs.isNotEmpty) {
        if (consulta.docs.first.id != user.id) {
          return false;
        }
      }

      // Si se cambió la imagen de perfil
      if (imgProfile.path.isNotEmpty) {
        // Subir la imagen a Firebase Storage
        var imgRef = carpetaRemota.ref('user/${user.id}/profile.jpg');
        await imgRef.putFile(imgProfile);
        // Reemplazar la imagen de perfil con la url
        user.profilePicture = await imgRef.getDownloadURL();
      }

      // Actualizar el documento del usuario con el id
      await baseRemota.collection('user').doc(user.id).update({
        'name': user.name.trim(),
        'userName': user.userName.trim().toLowerCase(),
        'profilePicture': user.profilePicture,
      });

      // Retornar true si se actualizó correctamente
      return true;
    } catch (error) {
      // Retornar false si hubo un error
      log('Error: $error');
      return false;
    }
  }
}
