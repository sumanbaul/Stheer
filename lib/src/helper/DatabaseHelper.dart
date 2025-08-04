import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:notifoo/src/model/apps.dart';
import 'package:notifoo/src/model/habits_model.dart';
import 'package:notifoo/src/model/pomodoro_timer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../../src/model/Notifications.dart';
import '../model/tasks.dart';

class DatabaseHelper {
  static const databaseName = 'notifoo_database.db';
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  //Create a private constructor
  DatabaseHelper._();

  //Queries
  String _deviceAppsTable =
      '''CREATE TABLE deviceapps (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, appName TEXT, apkFilePath TEXT,packageName TEXT,versionName TEXT, versionCode TEXT,dataDir TEXT, systemApp INTEGER, installTimeMillis INTEGER,  category TEXT,  enabled INTEGER)''';
  String _pomodoroLogTable =
      '''CREATE TABLE tblpomodorolog (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, taskName TEXT, duration TEXT, isCompleted INTEGER, createdDate TEXT, isDeleted INTEGER)''';
  String _notificationsLogTable =
      '''CREATE TABLE notifications (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, appTitle TEXT, text TEXT, message TEXT, packageName TEXT, timestamp INTEGER, createAt TEXT, eventJson TEXT, createdDate TEXT, isDeleted INTEGER, UNIQUE(title , text))''';
  String _createTasksTable = '''CREATE TABLE Tasks(
            id INTEGER PRIMARY KEY,
            title TEXT,
            isCompleted INTEGER,
            taskType TEXT,
            color TEXT,
            createdDate TEXT,
            modifiedDate TEXT,
            repeatitions INTEGER
          )''';

  String _habitsTable = '''CREATE TABLE IF NOT EXISTS tblhabits (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
        habitTitle TEXT, 
        isCompleted INTEGER, 
        habitType TEXT, 
        color TEXT, 
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )''';

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
    // For web platform, return null and use mock data
    if (kIsWeb) {
      print('Running on web platform - using mock database');
      return null;
    }

    // For mobile platforms, use SQLite
    try {
      return await openDatabase(
        join(await getDatabasesPath(), databaseName),
        version: 8,
        onCreate: _onCreate,
        onUpgrade: (db, oldVersion, newVersion) => {
          //BELOW CODE IS CURRENTLY NOT IN USE
          if (oldVersion == 2)
            {
              // db.execute(_deviceAppsTable),
              db.execute(_deviceAppsAlterTableV3),
            }
          else if (oldVersion == 3)
            {
              db.execute(_deviceAppsAlterTableV3),
              db.close(),
            }
          else if (oldVersion == 7)
            {
              db.execute(_deviceAppsAlterTableV3),
              db.execute(_createTasksTable),
              db.close(),
            }
        },
      );
    } catch (e) {
      print('Database initialization failed: $e');
      return null;
    }
  }

  Future _onCreate(Database db, int version) async {
    print("_onCreate() method executing");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    //final path = join(documentsDirectory.path, 'tasks.db');

    await db.execute(_pomodoroLogTable);

    await db.execute(_notificationsLogTable);

    await db.execute(_deviceAppsTable);

    await db.execute(_habitsTable);

    await db.execute(_createTasksTable);
    print(await db.query("tblhabits"));
  }

  Future close() async {
    final db = await (instance.database as Future<Database?>);
    if (db != null) {
      db.close();
    }
  }

  insertNotification(Notifications notifications) async {
    final db = await (database);
    if (db == null) {
      // For web platform, just print the notification
      print('Web platform: Would insert notification: ${notifications.title}');
      return 1;
    }
    var res = await db.insert(Notifications.TABLENAME, notifications.toMapDb(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<Notifications>> getNotifications(int selectedDay) async {
    final db = await (database);
    
    // For web platform, return mock data
    if (db == null) {
      return [
        Notifications(
          title: "Mock WhatsApp Message",
          appTitle: "WhatsApp",
          text: "Hello from sandbox! This is a test notification.",
          message: "New message received",
          packageName: "com.whatsapp",
          timestamp: DateTime.now().millisecondsSinceEpoch,
          createAt: DateTime.now().toString(),
          createdDate: DateTime.now().toString(),
          isDeleted: 0,
        ),
        Notifications(
          title: "Mock Email",
          appTitle: "Gmail",
          text: "You have a new email in your inbox.",
          message: "New email received",
          packageName: "com.google.android.gm",
          timestamp: DateTime.now().millisecondsSinceEpoch,
          createAt: DateTime.now().toString(),
          createdDate: DateTime.now().toString(),
          isDeleted: 0,
        ),
        Notifications(
          title: "Mock Instagram Like",
          appTitle: "Instagram",
          text: "Someone liked your post!",
          message: "New activity",
          packageName: "com.instagram.android",
          timestamp: DateTime.now().millisecondsSinceEpoch,
          createAt: DateTime.now().toString(),
          createdDate: DateTime.now().toString(),
          isDeleted: 0,
        ),
      ];
    }

    var yesterday = DateTime.now().subtract(Duration(days: 1));
    var now = selectedDay == 0 ? DateTime.now() : yesterday;

    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    print("Now in DB:${now.day}");

    String whereString = 'timestamp >= ?';
    List<dynamic> whereArguments = [lastMidnight];

    final List<Map<String, dynamic>> maps = await db.query(
        Notifications.TABLENAME,
        orderBy: 'createdDate DESC',
        where: whereString,
        whereArgs: whereArguments);

    return List.generate(maps.length, (i) {
      return Notifications(
        title: maps[i]['title'],
        text: maps[i]['text'],
        message: maps[i]['message'],
        packageName: maps[i]['packageName'],
        timestamp: maps[i]['timestamp'],
        createAt: maps[i]['createAt'],
        appTitle: maps[i]['appTitle'],
        createdDate: maps[i]['createdDate'],
        isDeleted: maps[i]['isDeleted'],
      );
    });
  }

  Future<List<Notifications>> getNotificationsByPackageToday(
      String? package) async {
    final db = await (database);

    // For web platform, return mock data
    if (db == null) {
      return [
        Notifications(
          title: "Mock ${package?.contains('whatsapp') == true ? 'WhatsApp' : 'App'} Message",
          appTitle: package?.contains('whatsapp') == true ? "WhatsApp" : "Unknown App",
          text: "Mock notification for $package",
          message: "Mock message",
          packageName: package,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          createAt: DateTime.now().toString(),
          createdDate: DateTime.now().toString(),
          isDeleted: 0,
        ),
      ];
    }

    var now = DateTime.now();
    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    String whereString = 'timestamp >= ? and packageName = ?';
    List<dynamic> whereArguments = [lastMidnight, package];

    final List<Map<String, dynamic>> maps = await db.query(
        Notifications.TABLENAME,
        orderBy: 'createAt DESC',
        where: whereString,
        whereArgs: whereArguments);

    return List.generate(maps.length, (i) {
      return Notifications(
          title: maps[i]['title'],
          text: maps[i]['text'],
          message: maps[i]['message'],
          packageName: maps[i]['packageName'],
          timestamp: maps[i]['timestamp'],
          createAt: maps[i]['createAt'],
          appTitle: maps[i]['appTitle'],
          createdDate: maps[i]['createdDate'],
          isDeleted: maps[i]['isDeleted'],
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
    final db = await (database);
    if (db == null) {
      print('Web platform: Would delete notification with id: $id');
      return;
    }
    db.delete(Notifications.TABLENAME, where: 'id = ?', whereArgs: [id]);
  }

  //Pomodoro
  insertPomodoroTimer(PomodoroTimer pomodoroTimer) async {
    final db = await (database);
    if (db == null) {
      print('Web platform: Would insert pomodoro timer: ${pomodoroTimer.taskName}');
      return 1;
    }
    var res = await db.insert(PomodoroTimer.TABLENAME, pomodoroTimer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<PomodoroTimer>> getPomodoroTimer() async {
    final db = await (database);

    // For web platform, return mock data
    if (db == null) {
      return [
        PomodoroTimer(
          taskName: "Mock Pomodoro Task",
          duration: "25:00",
          isCompleted: 1,
          createdDate: DateTime.now().toString(),
          isDeleted: 0,
        ),
      ];
    }

    var now = DateTime.now();
    var lastMidnight =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    String whereString = 'createdDate >= ?';
    List<dynamic> whereArguments = [lastMidnight];

    final List<Map<String, dynamic>> maps = await db.query(
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
    if (db == null) {
      print('Web platform: Would insert device app: ${application.appName}');
      return 1;
    }
    var res = await db.insert(Apps.TABLENAME, application.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return res;
  }

  Future<List<Apps>> getInstalledApps() async {
    final db = await (database);

    // For web platform, return mock data
    if (db == null) {
      return [
        Apps(
          appName: "Mock App 1",
          apkFilePath: "/mock/path/app1.apk",
          packageName: "com.mock.app1",
          versionName: "1.0.0",
          versionCode: "1",
          dataDir: "/mock/data/app1",
          systemApp: 0,
          installTimeMillis: DateTime.now().millisecondsSinceEpoch,
          category: "productivity",
          enabled: 1,
        ),
        Apps(
          appName: "Mock App 2",
          apkFilePath: "/mock/path/app2.apk",
          packageName: "com.mock.app2",
          versionName: "2.0.0",
          versionCode: "2",
          dataDir: "/mock/data/app2",
          systemApp: 0,
          installTimeMillis: DateTime.now().millisecondsSinceEpoch,
          category: "social",
          enabled: 1,
        ),
      ];
    }

    final List<Map<String, dynamic>> maps = await db.query(Apps.TABLENAME);

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
    if (db == null) {
      print('Web platform: Would create habit: ${habitsItem.habitTitle}');
      return 1;
    }
    final id = await db.insert(HabitsModel.TABLENAME, habitsItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return id;
  }

  // Read all items (habits)
  Future<List<HabitsModel>> getHabits() async {
    final db = await (database);
    
    // For web platform, return mock data
    if (db == null) {
      return [
        HabitsModel(
          id: 1,
          habitTitle: "Mock Habit 1",
          color: "#FF6B6B",
          habitType: "daily",
          isCompleted: 0,
        ),
        HabitsModel(
          id: 2,
          habitTitle: "Mock Habit 2",
          color: "#4ECDC4",
          habitType: "weekly",
          isCompleted: 1,
        ),
      ];
    }
    
    final List<Map<String, dynamic>> maps =
        await db.query(HabitsModel.TABLENAME, orderBy: "id");

    return List.generate(maps.length, (i) {
      return HabitsModel(
        id: maps[i]['id'],
        habitTitle: maps[i]['habitTitle'],
        color: maps[i]['color'],
        habitType: maps[i]['habitType'],
        isCompleted: maps[i]['isCompleted'],
      );
    });
  }

  // Read a single item by id
  // Currently this is not in use, but put here for referrence
  Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await (database);
    if (db == null) {
      print('Web platform: Would get item with id: $id');
      return [];
    }
    return db.query('tblhabits', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id(need to update)
  Future<int> updateHabitItem(int id, String title, String? descrption) async {
    final db = await (database);
    if (db == null) {
      print('Web platform: Would update habit item with id: $id');
      return 1;
    }

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('tblhabits', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete(will need to update)
  Future<void> deleteHabitItem(int id) async {
    final db = await (database);
    if (db == null) {
      print('Web platform: Would delete habit item with id: $id');
      return;
    }
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // Insert tasks on database
  createTask(Tasks newTask) async {
    //await deleteAllTasks();
    final db = await database;
    if (db == null) {
      print('Web platform: Would create task: ${newTask.title}');
      return 1;
    }
    final res = await db.insert('Tasks', newTask.toJson());
    return res;
  }

  insertTask(Tasks newTask) async {
    final db = await database;
    if (db == null) {
      print('Web platform: Would insert task: ${newTask.title}');
      return 1;
    }
    final res = await db.insert('Tasks', newTask.toJson());
    return res;
  }

  // Delete all employees
  Future<int> deleteAllTasks() async {
    final db = await database;
    if (db == null) {
      print('Web platform: Would delete all tasks');
      return 0;
    }
    final res = await db.rawDelete('DELETE FROM Tasks');
    return res;
  }

  Future<List<Tasks>> getAllTasks() async {
    final db = await database;
    
    // For web platform, return mock data
    if (db == null) {
      return [
        Tasks(
          id: 1,
          title: "Mock Task 1",
          isCompleted: 0,
          taskType: "personal",
          color: "#FF6B6B",
          createdDate: DateTime.now(),
          modifiedDate: DateTime.now(),
          repeatitions: 1,
        ),
        Tasks(
          id: 2,
          title: "Mock Task 2",
          isCompleted: 1,
          taskType: "work",
          color: "#4ECDC4",
          createdDate: DateTime.now(),
          modifiedDate: DateTime.now(),
          repeatitions: 2,
        ),
      ];
    }
    
    final res = await db.rawQuery("SELECT * FROM Tasks");

    List<Tasks> list =
        res.isNotEmpty ? res.map((c) => Tasks.fromJson(c)).toList() : [];

    return list;
  }
}
