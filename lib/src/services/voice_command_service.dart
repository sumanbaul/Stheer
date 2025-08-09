import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastCommand = '';
  
  // Voice command callbacks
  Function(String)? onCommandRecognized;
  Function(String)? onListeningStateChanged;
  Function(String)? onError;

  /// Initialize voice command service
  Future<bool> initialize() async {
    try {
      _speech = stt.SpeechToText();
      _isAvailable = await _speech.initialize(
        onStatus: (status) => _onSpeechStatus(status),
        onError: (error) => _onSpeechError(error),
      );
      
      if (_isAvailable) {
        print('Voice command service initialized successfully');
        return true;
      } else {
        print('Speech recognition not available');
        return false;
      }
    } catch (e) {
      print('Failed to initialize voice commands: $e');
      onError?.call('Failed to initialize voice commands: $e');
      return false;
    }
  }

  /// Start listening for voice commands
  Future<void> startListening() async {
    if (!_isAvailable || _isListening) return;

    try {
      await _speech.listen(
        onResult: (result) => _processVoiceCommand(result.recognizedWords),
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 3),
        partialResults: true,
        localeId: 'en_US',
        onSoundLevelChange: (level) {
          // Handle sound level changes for UI feedback
        },
      );
    } catch (e) {
      print('Error starting voice recognition: $e');
      onError?.call('Error starting voice recognition: $e');
    }
  }

  /// Stop listening for voice commands
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
    }
  }

  /// Process recognized voice command
  Future<void> _processVoiceCommand(String command) async {
    _lastCommand = command.toLowerCase();
    onCommandRecognized?.call(command);
    
    try {
      if (_lastCommand.contains('add task') || _lastCommand.contains('create task')) {
        await _handleAddTaskCommand(_lastCommand);
      } else if (_lastCommand.contains('add habit') || _lastCommand.contains('create habit')) {
        await _handleAddHabitCommand(_lastCommand);
      } else if (_lastCommand.contains('start timer') || _lastCommand.contains('start pomodoro')) {
        await _handleStartTimerCommand();
      } else if (_lastCommand.contains('complete task') || _lastCommand.contains('finish task')) {
        await _handleCompleteTaskCommand(_lastCommand);
      } else if (_lastCommand.contains('complete habit') || _lastCommand.contains('finish habit')) {
        await _handleCompleteHabitCommand(_lastCommand);
      } else if (_lastCommand.contains('show tasks') || _lastCommand.contains('list tasks')) {
        await _handleShowTasksCommand();
      } else if (_lastCommand.contains('show habits') || _lastCommand.contains('list habits')) {
        await _handleShowHabitsCommand();
      } else if (_lastCommand.contains('help') || _lastCommand.contains('commands')) {
        _handleHelpCommand();
      } else {
        onError?.call('Command not recognized. Say "help" for available commands.');
      }
    } catch (e) {
      print('Error processing voice command: $e');
      onError?.call('Error processing command: $e');
    }
  }

  /// Handle "add task" voice command
  Future<void> _handleAddTaskCommand(String command) async {
    try {
      // Extract task name from command
      String taskName = _extractTaskName(command);
      String taskType = _extractTaskType(command);
      
      if (taskName.isEmpty) {
        onError?.call('Please specify a task name. For example: "Add task buy groceries"');
        return;
      }

      final task = Tasks(
        id: DateTime.now().millisecondsSinceEpoch,
        title: taskName,
        isCompleted: 0,
        taskType: taskType,
        color: '#6366F1',
        createdDate: DateTime.now(),
        modifiedDate: DateTime.now(),
        repeatitions: 1,
      );

      await DatabaseHelper.instance.insertTask(task);
      onCommandRecognized?.call('Task "$taskName" added successfully');
    } catch (e) {
      onError?.call('Failed to add task: $e');
    }
  }

  /// Handle "add habit" voice command
  Future<void> _handleAddHabitCommand(String command) async {
    try {
      String habitName = _extractHabitName(command);
      String habitType = _extractHabitType(command);
      
      if (habitName.isEmpty) {
        onError?.call('Please specify a habit name. For example: "Add habit drink water"');
        return;
      }

      final habit = HabitsModel(
        habitTitle: habitName,
        habitType: habitType,
        isCompleted: 0,
        color: '#8B5CF6',
      );

      await DatabaseHelper.instance.createHabit(habit);
      onCommandRecognized?.call('Habit "$habitName" added successfully');
    } catch (e) {
      onError?.call('Failed to add habit: $e');
    }
  }

  /// Handle "start timer" voice command
  Future<void> _handleStartTimerCommand() async {
    try {
      // This would integrate with your Pomodoro timer
      onCommandRecognized?.call('Starting 25-minute focus timer');
      // Add actual timer start logic here
    } catch (e) {
      onError?.call('Failed to start timer: $e');
    }
  }

  /// Handle "complete task" voice command
  Future<void> _handleCompleteTaskCommand(String command) async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final pendingTasks = tasks.where((task) => task.isCompleted == 0).toList();
      
      if (pendingTasks.isEmpty) {
        onCommandRecognized?.call('No pending tasks to complete');
        return;
      }

      // For simplicity, complete the first pending task
      // In a real implementation, you might want to match by task name
      final task = pendingTasks.first;
      final updatedTask = Tasks(
        id: task.id,
        title: task.title,
        isCompleted: 1,
        taskType: task.taskType,
        color: task.color,
        createdDate: task.createdDate,
        modifiedDate: DateTime.now(),
        repeatitions: task.repeatitions,
      );

      await DatabaseHelper.instance.insertTask(updatedTask);
      onCommandRecognized?.call('Task "${task.title}" marked as complete');
    } catch (e) {
      onError?.call('Failed to complete task: $e');
    }
  }

  /// Handle "complete habit" voice command
  Future<void> _handleCompleteHabitCommand(String command) async {
    try {
      final habits = await DatabaseHelper.instance.getHabits();
      final pendingHabits = habits.where((habit) => habit.isCompleted == 0).toList();
      
      if (pendingHabits.isEmpty) {
        onCommandRecognized?.call('No pending habits to complete');
        return;
      }

      // Complete the first pending habit
      final habit = pendingHabits.first;
      await DatabaseHelper.instance.updateHabitItem(
        habit.id!,
        habit.habitTitle!,
        habit.habitType!,
      );
      
      onCommandRecognized?.call('Habit "${habit.habitTitle}" marked as complete');
    } catch (e) {
      onError?.call('Failed to complete habit: $e');
    }
  }

  /// Handle "show tasks" voice command
  Future<void> _handleShowTasksCommand() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final pendingTasks = tasks.where((task) => task.isCompleted == 0).toList();
      
      if (pendingTasks.isEmpty) {
        onCommandRecognized?.call('You have no pending tasks');
      } else {
        final taskNames = pendingTasks.take(3).map((task) => task.title).join(', ');
        onCommandRecognized?.call('Your pending tasks: $taskNames');
      }
    } catch (e) {
      onError?.call('Failed to show tasks: $e');
    }
  }

  /// Handle "show habits" voice command
  Future<void> _handleShowHabitsCommand() async {
    try {
      final habits = await DatabaseHelper.instance.getHabits();
      final pendingHabits = habits.where((habit) => habit.isCompleted == 0).toList();
      
      if (pendingHabits.isEmpty) {
        onCommandRecognized?.call('You have no pending habits');
      } else {
        final habitNames = pendingHabits.take(3).map((habit) => habit.habitTitle).join(', ');
        onCommandRecognized?.call('Your pending habits: $habitNames');
      }
    } catch (e) {
      onError?.call('Failed to show habits: $e');
    }
  }

  /// Handle "help" voice command
  void _handleHelpCommand() {
    final helpText = '''
Available voice commands:
• "Add task [task name]" - Create a new task
• "Add habit [habit name]" - Create a new habit
• "Start timer" - Start a Pomodoro session
• "Complete task" - Mark first task as done
• "Complete habit" - Mark first habit as done
• "Show tasks" - List pending tasks
• "Show habits" - List pending habits
• "Help" - Show this help message
    ''';
    
    onCommandRecognized?.call(helpText);
  }

  /// Extract task name from voice command
  String _extractTaskName(String command) {
    final patterns = [
      RegExp(r'add task (.+)', caseSensitive: false),
      RegExp(r'create task (.+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim() ?? '';
      }
    }
    
    return '';
  }

  /// Extract task type from voice command
  String _extractTaskType(String command) {
    if (command.contains('work')) return 'work';
    if (command.contains('personal')) return 'personal';
    if (command.contains('health')) return 'health';
    if (command.contains('shopping')) return 'shopping';
    return 'personal'; // default
  }

  /// Extract habit name from voice command
  String _extractHabitName(String command) {
    final patterns = [
      RegExp(r'add habit (.+)', caseSensitive: false),
      RegExp(r'create habit (.+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(command);
      if (match != null && match.groupCount > 0) {
        return match.group(1)?.trim() ?? '';
      }
    }
    
    return '';
  }

  /// Extract habit type from voice command
  String _extractHabitType(String command) {
    if (command.contains('daily')) return 'daily';
    if (command.contains('weekly')) return 'weekly';
    if (command.contains('health')) return 'health';
    if (command.contains('exercise')) return 'exercise';
    return 'daily'; // default
  }

  /// Handle speech status changes
  void _onSpeechStatus(String status) {
    _isListening = status == 'listening';
    onListeningStateChanged?.call(status);
    
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }

  /// Handle speech errors
  void _onSpeechError(dynamic error) {
    print('Speech error: $error');
    _isListening = false;
    onError?.call('Speech recognition error: $error');
  }

  /// Get available voice commands
  List<String> getAvailableCommands() {
    return [
      'Add task [task name]',
      'Add habit [habit name]',
      'Start timer',
      'Complete task',
      'Complete habit',
      'Show tasks',
      'Show habits',
      'Help',
    ];
  }

  /// Check if voice commands are available
  bool get isAvailable => _isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get last recognized command
  String get lastCommand => _lastCommand;
}