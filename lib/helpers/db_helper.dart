import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    Database database = await openDatabase(
        path.join(dbPath, 'catalogue_maker.db'), onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE product(id TEXT PRIMARY KEY, properties TEXT, price TEXT, alterImages TEXT, mainImg TEXT)');
      await db.execute(
          'CREATE TABLE project(id TEXT PRIMARY KEY, products TEXT, properties TEXT, status TEXT, creationDate TEXT, logoImage TEXT, description TEXT)');
    }, version: 1);
    return database;
  }

  static Future<void> insert(
      String tableName, Map<String, String> values) async {
    final db = await DBHelper.database();
    db.insert(
      tableName,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(
      String tableName, Map<String, String> values, String id) async {
    final db = await DBHelper.database();
    db.update(
      tableName,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, String>>> getData(String tableName) async {
    final db = await DBHelper.database();
    final data = await db.query(tableName);
    final result = data.map((mapItem) {
      return mapItem.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
    print('$tableName: $result');
    // db.delete('product');
    // db.delete('project');
    return result;
  }

  static Future<void> delete(String tableName, String id) async {
    final db = await DBHelper.database();
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    if (tableName == 'product') {
      // await DBHelper.update('project',);
    }
  }
}
