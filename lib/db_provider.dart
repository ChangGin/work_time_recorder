import 'dart:io';
import 'package:work_time_recorder/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static final tableName = "Record";
  var _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // DBがなかったら作る
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "RecordDB.db");

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable(Database db, int version) async {
    return await db.execute(
        "CREATE TABLE Record("
            "id TEXT PRIMARY KEY,"
            "title TEXT,"
            "time_in TEXT,"
            "latitude_in TEXT,"
            "longitude_in TEXT,"
            "address_in TEXT,"
            "address_in_detail TEXT,"
            "time_out TEXT,"
            "latitude_out TEXT,"
            "longitude_out TEXT,"
            "address_out TEXT,"
            "address_out_detail TEXT,"
            "create_date TEXT,"
            "update_date TEXT"
            ")"
    );
  }

  createRecord(Record record) async {
    final db = await database;
    var res = await db.insert(tableName, record.toMap());
    print("create$res");
    return res;
  }
  getAllRecord() async {
    final db = await database;
    var res = await db.query(tableName);
    List<Record> list = res.isNotEmpty ? res.map((c) => Record.fromMap(c)).toList() : [];
    print("AllRecord:$res");
    return list;
  }
  getRecord(String id) async {
    final db = await database;
    var res = await db.query(
        tableName,
        where: "id = ?",
        whereArgs: [id]
    );
    List<Record> list = res.isNotEmpty ? res.map((c) => Record.fromMap(c)).toList() : [];
    print("getRecord:$list");
    return list[0];
  }
  updateRecord(Record record) async {
    final db = await database;
    var res = await db.update(
      tableName,
      record.toMap(),
      where: "id = ?",
      whereArgs: [record.id],
    );
    return res;
  }
  updateAllRecord(List<Record> recordList) async {
    final db = await database;
    var batch = db.batch();
    recordList.forEach((record) {
      batch.update(
        tableName,
        record.toMap(),
        where: "id = ?",
        whereArgs: [record.id],
      );
    });
    var res = await batch.commit();
    return res;
  }
  deleteRecord(String id) async {
    final db = await database;
    var res = await db.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id],
    );
    return res;
  }
}