import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';
import 'package:notifoo/src/model/pomodoro_timer.dart';

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  /// Export all app data to JSON format
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      // Get all data from local database
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final habits = await DatabaseHelper.instance.getHabits();
      final pomodoros = await DatabaseHelper.instance.getAllPomodoroTimers();
      
      // Create export data structure
      final exportData = {
        'export_info': {
          'app_name': 'FocusFluke',
          'version': '2.0.0',
          'export_date': DateTime.now().toIso8601String(),
          'data_count': {
            'tasks': tasks.length,
            'habits': habits.length,
            'pomodoros': pomodoros.length,
          }
        },
        'tasks': tasks.map((task) => task.toMap()).toList(),
        'habits': habits.map((habit) => habit.toMap()).toList(),
        'pomodoros': pomodoros.map((pomodoro) => pomodoro.toMap()).toList(),
      };
      
      return exportData;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  /// Export data to JSON file and share
  Future<void> exportToFile({String format = 'json'}) async {
    try {
      final exportData = await exportAllData();
      
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      String fileName;
      String fileContent;
      
      switch (format.toLowerCase()) {
        case 'json':
          fileName = 'focusfluke_backup_$timestamp.json';
          fileContent = const JsonEncoder.withIndent('  ').convert(exportData);
          break;
        case 'csv':
          fileName = 'focusfluke_backup_$timestamp.csv';
          fileContent = _convertToCSV(exportData);
          break;
        default:
          throw Exception('Unsupported format: $format');
      }
      
      // Create file
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(fileContent);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'FocusFluke Data Backup - ${DateTime.now().toString().split(' ')[0]}',
        subject: 'FocusFluke Data Export',
      );
      
    } catch (e) {
      throw Exception('Failed to export to file: $e');
    }
  }

  /// Convert data to CSV format
  String _convertToCSV(Map<String, dynamic> data) {
    final buffer = StringBuffer();
    
    // Export info
    buffer.writeln('EXPORT INFORMATION');
    buffer.writeln('App Name,Version,Export Date');
    final exportInfo = data['export_info'];
    buffer.writeln('${exportInfo['app_name']},${exportInfo['version']},${exportInfo['export_date']}');
    buffer.writeln();
    
    // Tasks
    buffer.writeln('TASKS');
    buffer.writeln('ID,Title,Completed,Type,Color,Created Date,Modified Date,Repetitions');
    final tasks = data['tasks'] as List;
    for (final task in tasks) {
      buffer.writeln('${task['id']},${_escapeCSV(task['title'])},${task['isCompleted']},${_escapeCSV(task['taskType'])},${task['color']},${task['createdDate']},${task['modifiedDate']},${task['repeatitions']}');
    }
    buffer.writeln();
    
    // Habits
    buffer.writeln('HABITS');
    buffer.writeln('ID,Title,Type,Completed,Color,Created Date');
    final habits = data['habits'] as List;
    for (final habit in habits) {
      buffer.writeln('${habit['id']},${_escapeCSV(habit['habitTitle'])},${_escapeCSV(habit['habitType'])},${habit['isCompleted']},${habit['color']},${habit['createdAt']}');
    }
    buffer.writeln();
    
    // Pomodoros
    buffer.writeln('POMODORO SESSIONS');
    buffer.writeln('ID,Task Name,Duration,Completed,Deleted,Created Date');
    final pomodoros = data['pomodoros'] as List;
    for (final pomodoro in pomodoros) {
      buffer.writeln('${pomodoro['id']},${_escapeCSV(pomodoro['taskName'])},${pomodoro['duration']},${pomodoro['isCompleted']},${pomodoro['isDeleted']},${pomodoro['createdDate']}');
    }
    
    return buffer.toString();
  }

  /// Escape CSV values
  String _escapeCSV(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Import data from JSON file
  Future<bool> importFromFile() async {
    try {
      // Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        // Parse JSON
        final Map<String, dynamic> importData = json.decode(content);
        
        // Validate data structure
        if (!_validateImportData(importData)) {
          throw Exception('Invalid data format');
        }
        
        // Import data
        await _importData(importData);
        return true;
      }
      
      return false;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Validate import data structure
  bool _validateImportData(Map<String, dynamic> data) {
    return data.containsKey('export_info') &&
           data.containsKey('tasks') &&
           data.containsKey('habits') &&
           data.containsKey('pomodoros');
  }

  /// Import data to local database
  Future<void> _importData(Map<String, dynamic> data) async {
    final dbHelper = DatabaseHelper.instance;
    
    try {
      // Import tasks
      final tasks = data['tasks'] as List;
      for (final taskMap in tasks) {
        final task = Tasks.fromMap(Map<String, dynamic>.from(taskMap));
        await dbHelper.insertTask(task);
      }
      
      // Import habits
      final habits = data['habits'] as List;
      for (final habitMap in habits) {
        final habit = HabitsModel.fromMap(Map<String, dynamic>.from(habitMap));
        await dbHelper.createHabit(habit);
      }
      
      // Import pomodoros
      final pomodoros = data['pomodoros'] as List;
      for (final pomodoroMap in pomodoros) {
        final pomodoro = PomodoroTimer.fromMap(Map<String, dynamic>.from(pomodoroMap));
        await dbHelper.insertPomodoroTimer(pomodoro);
      }
      
    } catch (e) {
      throw Exception('Failed to import data to database: $e');
    }
  }

  /// Generate data summary for preview
  Future<Map<String, dynamic>> getDataSummary() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final habits = await DatabaseHelper.instance.getHabits();
      final pomodoros = await DatabaseHelper.instance.getAllPomodoroTimers();
      
      final completedTasks = tasks.where((t) => t.isCompleted == 1).length;
      final completedHabits = habits.where((h) => h.isCompleted == 1).length;
      final completedPomodoros = pomodoros.where((p) => p.isCompleted == 1).length;
      
      return {
        'total_items': tasks.length + habits.length + pomodoros.length,
        'tasks': {
          'total': tasks.length,
          'completed': completedTasks,
          'pending': tasks.length - completedTasks,
        },
        'habits': {
          'total': habits.length,
          'completed': completedHabits,
          'pending': habits.length - completedHabits,
        },
        'pomodoros': {
          'total': pomodoros.length,
          'completed': completedPomodoros,
          'pending': pomodoros.length - completedPomodoros,
        },
        'last_export': await _getLastExportDate(),
      };
    } catch (e) {
      throw Exception('Failed to get data summary: $e');
    }
  }

  /// Get last export date from preferences
  Future<String?> _getLastExportDate() async {
    // This would typically come from SharedPreferences
    // For now, return null
    return null;
  }

  /// Save last export date
  Future<void> _saveLastExportDate() async {
    // This would typically save to SharedPreferences
    // Implementation depends on your preference storage
  }
}