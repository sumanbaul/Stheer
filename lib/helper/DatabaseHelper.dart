import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifoo/model/apps.dart';
import 'package:notifoo/model/habits_model.dart';
import 'package:notifoo/model/pomodoro_timer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/Notifications.dart';

class DatabaseHelper {
  //Create a private constructor
  DatabaseHelper._();

  static const databaseName = 'notifoo_database.db';
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  //Queries
  String _deviceAppsTable =
      "CREATE TABLE deviceapps (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, appName TEXT, apkFilePath TEXT,packageName TEXT,versionName TEXT, versionCode TEXT,dataDir TEXT, systemApp INTEGER, installTimeMillis INTEGER,  category TEXT,  enabled INTEGER)";
  String _pomodoroLogTable =
      "CREATE TABLE tblpomodorolog (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, taskName TEXT, duration TEXT, isCompleted INTEGER, createdDate TEXT, isDeleted INTEGER)";
  String _notificationsLogTable =
      '''CREATE TABLE notifications (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, appTitle TEXT, text TEXT, message TEXT, packageName TEXT, timestamp INTEGER, createAt TEXT, eventJson TEXT, createdDate TEXT, isDeleted INTEGER, UNIQUE(title , text))''';

  String _habitsTable = """Create table tblhabits (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        habitTitle TEXT, 
        isCompleted INTEGER, 
        habitType TEXT, 
        color TEXT, 
        createdAt TIMESTAMP NOT NULL DEFAYLT CURRENT_TIMESTAMP
        )""";

  //V3 Alter table
  String _deviceAppsAlterTableV3 =
      "ALTER TABLE deviceapps ADD COLUMN apkFilePath TEXT, packageName TEXT, versionCode TEXT";

  //String _deviceAppsAlterTableV4 = "";

  Future<Database?> get database async {
    if (_database == null) {
      return await initializeDatabase();
    }
    return _database;
  }

  initializeDatabase() async {
    //Directory appDocDir = await getApplicationDocumentsDirectory();

    //String appDocPath = appDocDir.path;
    // String path = join(await getDatabasesPath(), databaseName);
    // print("Path: $path");
    // final db = await database;
    //print("Version: $db.getVersion()");

    return await openDatabase(
      join(await getDatabasesPath(), databaseName),
      version: 5,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) => {
        //BELOW CODE IS CURRENTLY NOT IN USE
        if (oldVersion == 2)
          {
            // db.execute(_deviceAppsTable),
            db.execute(_deviceAppsAlterTableV3),
          }
        else if (oldVersion == 3)
          {db.execute(_deviceAppsAlterTableV3), db.close()}
      },
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(_pomodoroLogTable);

    await db.execute(_notificationsLogTable);

    await db.execute(_deviceAppsTable);

    await db.execute(_habitsTable);
  }

  Future close() async {
    final db = await (instance.database as Future<Database>);
    db.close();
  }

  insertNotification(Notifications notifications) async {
    final db = await (database);
    var res = await db?.insert(Notifications.TABLENAME, notifications.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<Notifications>> getNotifications(int selectedDay) async {
    final db = await (database);
    var yesterday = DateTime.now().subtract(Duration(days: 1));
    var now = selectedDay == 0 ? DateTime.now() : yesterday;

    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    //var today = new DateTime.now().millisecondsSinceEpoch;
    //print('Date from Db: $lastMidnight');

    String whereString = 'timestamp >= ?';
    List<dynamic> whereArguments = [lastMidnight];

    final List<Map<String, dynamic>> maps = await db!.query(
        Notifications.TABLENAME,
        orderBy: 'createdDate DESC',
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
        appTitle: maps[i]['appTitle'],
        createdDate: maps[i]['createdDate'],
        isDeleted: maps[i]['isDeleted'],
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

  Future<List<Notifications>> getNotificationsByPackageToday(
      String? package) async {
    final db = await (database);

    var now = DateTime.now();
    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    String whereString = 'timestamp >= ? and packageName = ?';
    List<dynamic> whereArguments = [lastMidnight, package];

    final List<Map<String, dynamic>> maps = await db!.query(
        Notifications.TABLENAME,
        orderBy: 'createAt DESC',
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
    var db = await (database as Future<Database>);
    db.delete(Notifications.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }

  //Pomodoro
  insertPomodoroTimer(PomodoroTimer pomodoroTimer) async {
    final db = await (database as Future<Database>);
    var res = await db.insert(PomodoroTimer.TABLENAME, pomodoroTimer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<PomodoroTimer>> getPomodoroTimer() async {
    final db = await (database);

    var now = DateTime.now();
    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    String whereString = 'createdDate >= ?';
    List<dynamic> whereArguments = [lastMidnight];

    final List<Map<String, dynamic>> maps = await db!.query(
        PomodoroTimer.TABLENAME,
        orderBy: 'createdDate DESC',
        where: whereString,
        whereArgs: whereArguments);

    return List.generate(maps.length, (i) {
      return PomodoroTimer(
        taskName: maps[i]['taskName'],
        duration: maps[i]['duration'],
        isCompleted: maps[i]['isCompleted'],
        createdDate: maps[i]['createdDate'],
        isDeleted: maps[i]['isDeleted'],
      );
    });
  }

// Device Apps
  insertDeviceApps(Apps application) async {
    final db = await (database);
    var res = await db!.insert(Apps.TABLENAME, application.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<Apps>> getInstalledApps() async {
    final db = await (database);

    final List<Map<String, dynamic>> maps = await db!.query(Apps.TABLENAME);

    return List.generate(maps.length, (i) {
      return Apps(
        appName: maps[i]['appName'],
        apkFilePath: maps[i]['apkFilePath'],
        packageName: maps[i]['packageName'],
        versionName: maps[i]['versionName'],
        versionCode: maps[i]['versionCode'],
        dataDir: maps[i]['dataDir'],
        systemApp: maps[i]['systemApp'],
        installTimeMillis: maps[i]['installTimeMillis'],
        category: maps[i]['category'],
        enabled: maps[i]['enabled'],
      );
    });
  }

  // Create new Habit
  Future<int> createHabit(HabitsModel habitsItem) async {
    final db = await (database);
    final id = await db?.insert(HabitsModel.TABLENAME, habitsItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return id!;
  }

  // Read all items (habits)
  Future<List<Map<String, dynamic>>> getHabits() async {
    final db = await (database);
    return db!.query('tblhabits', orderBy: "id");
  }

  // Read a single item by id
  // Currently this is not in use, but put here for referrence
  Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await (database);
    return db!.query('tblhabits', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id(need to update)
  Future<int> updateHabitItem(int id, String title, String? descrption) async {
    final db = await (database);

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db?.update('tblhabits', data, where: "id = ?", whereArgs: [id]);
    return result!;
  }

  // Delete(will need to update)
  Future<void> deleteHabitItem(int id) async {
    final db = await (database);
    try {
      await db?.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
