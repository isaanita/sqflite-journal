import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

// buat create table

class SQLHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)""");
  }

// add database name

  static Future<sql.Database> db() async {
    return sql.openDatabase('jurnal.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  // create

  static Future<int> createItem(String title, String? description) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'description': description};
    final id = await db.insert('items', data, // db.insert buat memasukkan data
        conflictAlgorithm: sql.ConflictAlgorithm
            .replace); // conflictAlgorithm fungsinya biar gd duplicate data
    return id;
  }

  // get item dari database

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db(); // koneksi database
    return db.query('items', orderBy: "id"); // db.query buat dapetin data
  }

  // get data tertentu atau update data

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // update data

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // delete item

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("something went wrong when deleting an item: $err");
    }
  }
}
