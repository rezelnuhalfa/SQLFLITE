import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<Database> db() async {
    return openDatabase(
      join(await getDatabasesPath(), 'kindacode.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        await database.execute("""
          CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            imagePath TEXT,
            createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        """);
      },
    );
  }

  // *Membaca semua data*
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id DESC");
  }

  // *Membaca satu data berdasarkan id*
  static Future<Map<String, dynamic>?> getItem(int id) async {
    final db = await SQLHelper.db();
    final result =
        await db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // *Membuat data baru dengan gambar*
  static Future<int> createItem(
      String title, String? description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description, 'imagePath': imagePath};
    return db.insert('items', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // *Memperbarui data termasuk gambar*
  static Future<int> updateItem(
      int id, String title, String? description, String? imagePath) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'imagePath': imagePath,
      'createdAt': DateTime.now().toString()
    };
    return db.update('items', data, where: "id = ?", whereArgs: [id]);
  }

  // *Menghapus data*
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    await db.delete('items', where: "id = ?", whereArgs: [id]);
  }
}
