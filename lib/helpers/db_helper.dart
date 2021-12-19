import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();
    Database database = await openDatabase(
        path.join(dbPath, 'catalogue_maker.db'), onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE product(id TEXT PRIMARY KEY, properties TEXT, price REAL, alterImages TEXT, mainImg TEXT)');
      await db.execute(
          'CREATE TABLE project(id TEXT PRIMARY KEY, products TEXT, properties TEXT, status REAL, creationDate TEXT, logoImage TEXT, description TEXT)');
    }, version: 1);
    return database;
  }

  static Future<void> insert(
      String tableName, Map<String, dynamic> values) async {
    final db = await database();
    db.insert(
      tableName,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
