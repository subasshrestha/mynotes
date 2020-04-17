import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite_demo/models/note.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableName = 'notes';
  final String columnId = 'id';
  final String columnTitle = 'title';
  final String columnBody = 'body';
  final String columnUpdatedAt = 'updatedAt';

  static Database _db;

  DatabaseHelper.internal();

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();

    return _db;
  }

  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'notes.db');

//    await deleteDatabase(path); // just for testing

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY, $columnTitle TEXT, $columnBody TEXT, $columnUpdatedAt TEXT)');
  }

  Future<int> saveNote(Note note) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableName, note.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableName ($columnTitle, $columnBody) VALUES (\'${note.title}\', \'${note.description}\')');

    return result;
  }

  Future<List> getAllNotes() async {
    var dbClient = await db;
    var result = await dbClient.query(
      tableName,
      columns: [columnId, columnTitle, columnBody, columnUpdatedAt],
      orderBy: columnUpdatedAt + " DESC",
    );
//    var result = await dbClient.rawQuery('SELECT * FROM $tableName ORDER BY $columnUpdatedAt DESC');
    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }

  Future<Note> getNote(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableName,
        columns: [columnId, columnTitle, columnBody, columnUpdatedAt],
        where: '$columnId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableName WHERE $columnId = $id');

    if (result.length > 0) {
      return new Note.fromMap(result.first);
    }

    return null;
  }

  Future<int> deleteNote(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(tableName, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableName WHERE $columnId = $id');
  }

  Future<int> deleteMultipleNote(List<int> ids) async {
    var dbClient = await db;
    ids.forEach((id) async {
      await dbClient.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
    });
    return Future.value(1);
//    return await dbClient.rawDelete('DELETE FROM $tableName WHERE $columnId = $id');
  }

  Future<int> deleteAllNote() async {
    var dbClient = await db;
    return await dbClient.delete(tableName);
//    return await dbClient.rawDelete('DELETE FROM $tableName WHERE $columnId = $id');
  }

  Future<int> updateNote(Note note) async {
    var dbClient = await db;
    return await dbClient.update(tableName, note.toMap(),
        where: "$columnId = ?", whereArgs: [note.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableName SET $columnTitle = \'${note.title}\', $columnBody = \'${note.description}\' WHERE $columnId = ${note.id}');
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
