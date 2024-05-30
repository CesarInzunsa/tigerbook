// flutter
import 'dart:developer';

// plugins
import 'package:sqflite/sqflite.dart';

// business logic
import '../model/post_content_model.dart';
import 'db_controller.dart';

class LocalController {
  static Future<bool> deleteOnePost(String postId) async {
    try {
      final Database db = await DbController.openDB();
      await db.delete(
        'postContent',
        where: 'postId = ?',
        whereArgs: [postId],
      );
      return true;
    } catch (e) {
      log('Error: $e');
      return false;
    }
  }

  /// save post to local database for offline use
  static Future<bool> savePost(PostContentModel post) async {
    try {
      // save post to local database
      final Database db = await DbController.openDB();

      // if the post is already saved, then update the post information
      final List<Map<String, dynamic>> existPost = await db.query(
        'postContent',
        where: 'postId = ?',
        whereArgs: [post.post.id],
      );

      if (existPost.isNotEmpty) {
        log('si existe');
        await db.update(
          'postContent',
          PostContentModel(
            userId: post.userId,
            profilePicture: '',
            name: post.name,
            userName: post.userName,
            post: post.post,
          ).toSqFlite(),
          where: 'postId = ?',
          whereArgs: [post.post.id],
        );
        return true;
      } else {
        log('es nuevo');
        await db.insert(
          'postContent',
          PostContentModel(
            userId: post.userId,
            profilePicture: '',
            name: post.name,
            userName: post.userName,
            post: post.post,
          ).toSqFlite(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }

      // if everything goes well return true
      return true;
    } catch (e) {
      // if something goes wrong return false
      return false;
    }
  }

  /// get all saved posts from local database
  static Future<List<PostContentModel>> getAllSavedPosts() async {
    try {
      final Database db = await DbController.openDB();
      final List<Map<String, dynamic>> posts = await db.query('postContent');

      if (posts.isEmpty) {
        return [];
      }

      return List.generate(
        posts.length,
        (index) => PostContentModel.fromSqFlite(posts[index]),
      );
    } catch (e) {
      log('Error: $e');
      return [];
    }
  }
}
