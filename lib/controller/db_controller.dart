// plugins
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbController {
  static Future<void> script(Database db) async {
    await _createTaskTable(db);
  }

  static Future<Database> openDB() async {
    return openDatabase(join(getDatabasesPath().toString(), 'tigerbook.db'),
        onCreate: (db, version) {
      return script(db);
    }, version: 1);
  }

  static Future<void> _createTaskTable(Database db) async {
    await db.execute('CREATE TABLE postContent ('
        'id TEXT PRIMARY KEY,'
        'postId TEXT NOT NULL,'
        'userId TEXT NOT NULL,'
        'name TEXT NOT NULL,'
        'userName TEXT NOT NULL,'
        'postContent TEXT NOT NULL,'
        'createdAt TEXT NOT NULL)');
  }
}
