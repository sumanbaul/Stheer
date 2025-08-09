import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const String _widgetName = 'FocusFlukeWidget';
  static const String _taskWidgetName = 'TaskWidget';
  static const String _habitWidgetName = 'HabitWidget';
  static const String _focusWidgetName = 'FocusWidget';

  /// Initialize widget service
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.focusfluke.widgets');
      print('Widget service initialized successfully');
    } catch (e) {
      print('Failed to initialize widget service: $e');
    }
  }

  /// Update all widgets with latest data
  Future<void> updateAllWidgets() async {
    try {
      await Future.wait([
        updateTaskWidget(),
        updateHabitWidget(),
        updateFocusWidget(),
      ]);
      
      // Trigger widget update
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
        iOSName: _widgetName,
      );
      
      print('All widgets updated successfully');
    } catch (e) {
      print('Failed to update widgets: $e');
    }
  }

  /// Update task widget with latest task data
  Future<void> updateTaskWidget() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final pendingTasks = tasks.where((task) => task.isCompleted == 0).toList();
      final completedToday = tasks.where((task) => 
        task.isCompleted == 1 && 
        task.modifiedDate != null &&
        _isToday(task.modifiedDate!)
      ).length;
      
      final taskData = {
        'total_tasks': tasks.length,
        'pending_tasks': pendingTasks.length,
        'completed_today': completedToday,
        'next_tasks': pendingTasks.take(3).map((task) => {
          'id': task.id,
          'title': task.title,
          'type': task.taskType,
          'color': task.color,
        }).toList(),
      };
      
      await HomeWidget.saveWidgetData('task_data', json.encode(taskData));
      await HomeWidget.updateWidget(name: _taskWidgetName);
    } catch (e) {
      print('Failed to update task widget: $e');
    }
  }

  /// Update habit widget with latest habit data
  Future<void> updateHabitWidget() async {
    try {
      final habits = await DatabaseHelper.instance.getHabits();
      final completedToday = habits.where((habit) => habit.isCompleted == 1).length;
      
      final habitData = {
        'total_habits': habits.length,
        'completed_today': completedToday,
        'completion_rate': habits.isNotEmpty ? (completedToday / habits.length * 100).round() : 0,
        'habits': habits.take(5).map((habit) => {
          'id': habit.id,
          'title': habit.habitTitle,
          'type': habit.habitType,
          'completed': habit.isCompleted == 1,
          'color': habit.color,
        }).toList(),
      };
      
      await HomeWidget.saveWidgetData('habit_data', json.encode(habitData));
      await HomeWidget.updateWidget(name: _habitWidgetName);
    } catch (e) {
      print('Failed to update habit widget: $e');
    }
  }

  /// Update focus widget with timer information
  Future<void> updateFocusWidget() async {
    try {
      final pomodoros = await DatabaseHelper.instance.getAllPomodoroTimers();
      final completedToday = pomodoros.where((p) => 
        p.isCompleted == 1 && 
        p.createdDate != null &&
        _isToday(DateTime.parse(p.createdDate!))
      ).length;
      
      final totalFocusTime = completedToday * 25; // Assuming 25 minutes per pomodoro
      
      final focusData = {
        'pomodoros_today': completedToday,
        'focus_time_minutes': totalFocusTime,
        'focus_time_hours': (totalFocusTime / 60).toStringAsFixed(1),
        'is_active': false, // This would be true if timer is running
        'next_break': _getNextBreakTime(),
      };
      
      await HomeWidget.saveWidgetData('focus_data', json.encode(focusData));
      await HomeWidget.updateWidget(name: _focusWidgetName);
    } catch (e) {
      print('Failed to update focus widget: $e');
    }
  }

  /// Quick add task from widget
  Future<void> quickAddTask(String title, String type) async {
    try {
      final task = Tasks(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        isCompleted: 0,
        taskType: type,
        color: '#6366F1',
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        repeatitions: 1,
      );
      
      await DatabaseHelper.instance.insertTask(task);
      await updateTaskWidget();
      
      print('Task added from widget: $title');
    } catch (e) {
      print('Failed to add task from widget: $e');
    }
  }

  /// Toggle habit completion from widget
  Future<void> toggleHabitFromWidget(int habitId) async {
    try {
      final habits = await DatabaseHelper.instance.getHabits();
      final habit = habits.firstWhere((h) => h.id == habitId);
      
      final newCompletionStatus = habit.isCompleted == 1 ? 0 : 1;
      
      await DatabaseHelper.instance.updateHabitItem(
        habitId,
        habit.habitTitle!,
        habit.habitType!,
      );
      
      await updateHabitWidget();
      
      print('Habit toggled from widget: ${habit.habitTitle}');
    } catch (e) {
      print('Failed to toggle habit from widget: $e');
    }
  }

  /// Start focus session from widget
  Future<void> startFocusFromWidget() async {
    try {
      // This would integrate with your Pomodoro timer
      // For now, we'll just update the widget to show active state
      final focusData = {
        'is_active': true,
        'session_start': DateTime.now().toIso8601String(),
        'session_duration': 25,
      };
      
      await HomeWidget.saveWidgetData('active_focus', json.encode(focusData));
      await updateFocusWidget();
      
      print('Focus session started from widget');
    } catch (e) {
      print('Failed to start focus from widget: $e');
    }
  }

  /// Handle widget interactions
  static Future<void> handleWidgetClick(String action, [String? data]) async {
    switch (action) {
      case 'quick_add_task':
        if (data != null) {
          final taskData = json.decode(data);
          await WidgetService().quickAddTask(
            taskData['title'] ?? 'Quick Task',
            taskData['type'] ?? 'personal',
          );
        }
        break;
      case 'toggle_habit':
        if (data != null) {
          final habitId = int.parse(data);
          await WidgetService().toggleHabitFromWidget(habitId);
        }
        break;
      case 'start_focus':
        await WidgetService().startFocusFromWidget();
        break;
      case 'open_app':
        // This would open the main app
        break;
    }
  }

  /// Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Get next break time (simplified)
  String _getNextBreakTime() {
    final now = DateTime.now();
    final nextBreak = DateTime(now.year, now.month, now.day, now.hour + 1);
    return '${nextBreak.hour.toString().padLeft(2, '0')}:${nextBreak.minute.toString().padLeft(2, '0')}';
  }

  /// Get widget summary for settings
  Future<Map<String, dynamic>> getWidgetSummary() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final habits = await DatabaseHelper.instance.getHabits();
      final pomodoros = await DatabaseHelper.instance.getAllPomodoroTimers();
      
      return {
        'widgets_available': ['Tasks', 'Habits', 'Focus Timer'],
        'last_update': DateTime.now().toIso8601String(),
        'data_summary': {
          'tasks': tasks.length,
          'habits': habits.length,
          'pomodoros_today': pomodoros.where((p) => 
            p.createdDate != null &&
            _isToday(DateTime.parse(p.createdDate!))
          ).length,
        }
      };
    } catch (e) {
      return {
        'widgets_available': ['Tasks', 'Habits', 'Focus Timer'],
        'last_update': 'Error loading data',
        'error': e.toString(),
      };
    }
  }
}