import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/Notifications.dart';

class DatabaseHelper {
  //Create a private constructor
  DatabaseHelper._();

  static const databaseName = 'notifoo_database.db';
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  initializeDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          // "CREATE TABLE notifications (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, infoText TEXT, summaryText TEXT, showWhen INTEGER, package_name TEXT, text TEXT,  subText TEXT, timestamp TEXT)");
          "CREATE TABLE notifications (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, appTitle TEXT, text TEXT, message TEXT, packageName TEXT, timestamp INTEGER, createAt TEXT, eventJson TEXT)");
    });
  }

  insertNotification(Notifications notifications) async {
    final db = await database;
    var res = await db.insert(Notifications.TABLENAME, notifications.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<List<Notifications>> getNotifications() async {
    final db = await database;

    var now = DateTime.now();
    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    //var today = new DateTime.now().millisecondsSinceEpoch;
    //print('Date from Db: $lastMidnight');

    String whereString = 'timestamp >= ?';
    List<dynamic> whereArguments = [lastMidnight];

    final List<Map<String, dynamic>> maps = await db.query(
        Notifications.TABLENAME,
        orderBy: 'createAt ASC',
        where: whereString,
        whereArgs: whereArguments);

    return List.generate(maps.length, (i) {
      return Notifications(
          //  id: maps[i]['id'],
          title: maps[i]['title'],
          text: maps[i]['text'],
          message: maps[i]['message'],
          packageName: maps[i]['packageName'],
          timestamp: maps[i]['timestamp'],
          createAt: maps[i]['createAt'],
          appTitle: maps[i]['appTitle']
          // eventJson: maps[i]['eventJson'],
          // signature: maps[i]['signature'],

          // infoText: maps[i]['infoText'],
          // summaryText: maps[i]['summaryText'],
          // showWhen: maps[i]['showWhen'],
          // package_name: maps[i]['package_name'],
          // text: maps[i]['text'],
          // subText: maps[i]['subText'],
          // timestamp: maps[i]['timestamp'],
          );
    });
  }

  // updateTodo(Notifications todo) async {
  //   final db = await database;

  //   await db.update(Notifications.TABLENAME, todo.toMap(),
  //       where: 'id = ?',
  //       whereArgs: [todo.id],
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }

  deleteTodo(int id) async {
    var db = await database;
    db.delete(Notifications.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }
}