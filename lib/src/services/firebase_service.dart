import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sync status tracking
  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _syncTimer;
  
  // Stream controllers for real-time updates
  final StreamController<bool> _syncStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _syncMessageController = StreamController<String>.broadcast();

  // Getters
  Stream<bool> get syncStatusStream => _syncStatusController.stream;
  Stream<String> get syncMessageStream => _syncMessageController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  // Initialize Firebase service
  Future<void> initialize() async {
    try {
      // Check network connectivity
      await _checkConnectivity();
      
      // Start periodic sync if user is authenticated
      if (_auth.currentUser != null) {
        _startPeriodicSync();
      }
      
      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _startPeriodicSync();
        } else {
          _stopPeriodicSync();
        }
      });
      
    } catch (e) {
      print('FirebaseService initialization error: $e');
    }
  }

  // Check if device is online
  Future<void> _checkConnectivity() async {
    try {
      // Try to access Firestore to check connectivity
      await _firestore.collection('test').doc('test').get();
      _isOnline = true;
      _syncStatusController.add(true);
      print('FirebaseService: Online status confirmed');
    } catch (e) {
      _isOnline = false;
      _syncStatusController.add(false);
      print('FirebaseService: Offline - $e');
    }
  }

  // Start periodic sync (every 30 seconds)
  void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isOnline && _auth.currentUser != null) {
        syncData();
      }
    });
  }

  // Stop periodic sync
  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Main sync function
  Future<void> syncData() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    _syncStatusController.add(true);
    
    try {
      await _checkConnectivity();
      
      if (!_isOnline) {
        _syncMessageController.add('Offline mode - data saved locally');
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        _syncMessageController.add('User not authenticated');
        return;
      }

      _syncMessageController.add('Starting sync...');
      
      // Sync tasks
      await _syncTasks(user.uid);
      
      // Sync habits
      await _syncHabits(user.uid);
      
      _syncMessageController.add('Sync completed successfully');
      
    } catch (e) {
      _syncMessageController.add('Sync error: $e');
      print('FirebaseService sync error: $e');
    } finally {
      _isSyncing = false;
      _syncStatusController.add(false);
    }
  }

  // Sync tasks between local and cloud
  Future<void> _syncTasks(String userId) async {
    try {
      // Get local tasks
      final localTasks = await DatabaseHelper.instance.getAllTasks();
      
      // Get cloud tasks
      final cloudSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .get();
      
      final cloudTasks = cloudSnapshot.docs.map((doc) {
        final data = doc.data();
        return Tasks(
          id: int.tryParse(doc.id),
          title: data['title'],
          isCompleted: data['isCompleted'] ?? 0,
          taskType: data['taskType'],
          color: data['color'],
          createdDate: data['createdDate'] != null 
              ? DateTime.parse(data['createdDate']) 
              : null,
          modifiedDate: data['modifiedDate'] != null 
              ? DateTime.parse(data['modifiedDate']) 
              : null,
          repeatitions: data['repeatitions'] ?? 0,
        );
      }).toList();

      // Find conflicts and resolve them
      final conflicts = _findTaskConflicts(localTasks, cloudTasks);
      
      // Resolve conflicts (local wins for now, but could be more sophisticated)
      for (final conflict in conflicts) {
        await _resolveTaskConflict(conflict, userId);
      }

      // Upload local changes to cloud
      for (final task in localTasks) {
        await _uploadTaskToCloud(task, userId);
      }

      // Download cloud changes to local
      for (final task in cloudTasks) {
        await _downloadTaskToLocal(task);
      }

    } catch (e) {
      print('Task sync error: $e');
      throw e;
    }
  }

  // Sync habits between local and cloud
  Future<void> _syncHabits(String userId) async {
    try {
      // Get local habits
      final localHabits = await DatabaseHelper.instance.getHabits();
      
      // Get cloud habits
      final cloudSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      
      final cloudHabits = cloudSnapshot.docs.map((doc) {
        final data = doc.data();
        return HabitsModel(
          id: int.tryParse(doc.id),
          habitTitle: data['habitTitle'],
          habitType: data['habitType'],
          isCompleted: data['isCompleted'] ?? 0,
          color: data['color'],
        );
      }).toList();

      // Find conflicts and resolve them
      final conflicts = _findHabitConflicts(localHabits, cloudHabits);
      
      // Resolve conflicts
      for (final conflict in conflicts) {
        await _resolveHabitConflict(conflict, userId);
      }

      // Upload local changes to cloud
      for (final habit in localHabits) {
        await _uploadHabitToCloud(habit, userId);
      }

      // Download cloud changes to local
      for (final habit in cloudHabits) {
        await _downloadHabitToLocal(habit);
      }

    } catch (e) {
      print('Habit sync error: $e');
      throw e;
    }
  }

  // Upload task to cloud
  Future<void> _uploadTaskToCloud(Tasks task, String userId) async {
    try {
      final taskData = {
        'title': task.title,
        'isCompleted': task.isCompleted,
        'taskType': task.taskType,
        'color': task.color,
        'createdDate': task.createdDate?.toIso8601String(),
        'modifiedDate': task.modifiedDate?.toIso8601String(),
        'repeatitions': task.repeatitions,
        'lastSync': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id.toString())
          .set(taskData, SetOptions(merge: true));
          
    } catch (e) {
      print('Upload task error: $e');
      throw e;
    }
  }

  // Upload habit to cloud
  Future<void> _uploadHabitToCloud(HabitsModel habit, String userId) async {
    try {
      final habitData = {
        'habitTitle': habit.habitTitle,
        'habitType': habit.habitType,
        'isCompleted': habit.isCompleted,
        'color': habit.color,
        'lastSync': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id.toString())
          .set(habitData, SetOptions(merge: true));
          
    } catch (e) {
      print('Upload habit error: $e');
      throw e;
    }
  }

  // Download task to local
  Future<void> _downloadTaskToLocal(Tasks task) async {
    try {
      // Check if task exists locally
      final existingTask = await DatabaseHelper.instance.getTaskById(task.id);
      
      if (existingTask == null) {
        // Insert new task
        await DatabaseHelper.instance.insertTask(task);
      } else {
        // Update existing task if cloud version is newer
        await DatabaseHelper.instance.insertTask(task);
      }
    } catch (e) {
      print('Download task error: $e');
      throw e;
    }
  }

  // Download habit to local
  Future<void> _downloadHabitToLocal(HabitsModel habit) async {
    try {
      // Check if habit exists locally
      final existingHabit = await DatabaseHelper.instance.getHabitById(habit.id);
      
      if (existingHabit == null) {
        // Insert new habit
        await DatabaseHelper.instance.createHabit(habit);
      } else {
        // Update existing habit if cloud version is newer
        await DatabaseHelper.instance.updateHabitItem(
          habit.id!,
          habit.habitTitle!,
          habit.habitType!,
        );
      }
    } catch (e) {
      print('Download habit error: $e');
      throw e;
    }
  }

  // Find task conflicts between local and cloud
  List<TaskConflict> _findTaskConflicts(List<Tasks> localTasks, List<Tasks> cloudTasks) {
    final conflicts = <TaskConflict>[];
    
    for (final localTask in localTasks) {
      final cloudTask = cloudTasks.firstWhere(
        (task) => task.id == localTask.id,
        orElse: () => Tasks(),
      );
      
      if (cloudTask.id != null && _hasTaskConflict(localTask, cloudTask)) {
        conflicts.add(TaskConflict(local: localTask, cloud: cloudTask));
      }
    }
    
    return conflicts;
  }

  // Find habit conflicts between local and cloud
  List<HabitConflict> _findHabitConflicts(List<HabitsModel> localHabits, List<HabitsModel> cloudHabits) {
    final conflicts = <HabitConflict>[];
    
    for (final localHabit in localHabits) {
      final cloudHabit = cloudHabits.firstWhere(
        (habit) => habit.id == localHabit.id,
        orElse: () => HabitsModel(),
      );
      
      if (cloudHabit.id != null && _hasHabitConflict(localHabit, cloudHabit)) {
        conflicts.add(HabitConflict(local: localHabit, cloud: cloudHabit));
      }
    }
    
    return conflicts;
  }

  // Check if tasks have conflicts
  bool _hasTaskConflict(Tasks local, Tasks cloud) {
    return local.modifiedDate != cloud.modifiedDate ||
           local.isCompleted != cloud.isCompleted ||
           local.title != cloud.title;
  }

  // Check if habits have conflicts
  bool _hasHabitConflict(HabitsModel local, HabitsModel cloud) {
    return local.isCompleted != cloud.isCompleted ||
           local.habitTitle != cloud.habitTitle ||
           local.habitType != cloud.habitType;
  }

  // Resolve task conflict (local wins for now)
  Future<void> _resolveTaskConflict(TaskConflict conflict, String userId) async {
    // For now, local version wins
    // In a more sophisticated system, you might want to merge changes
    await _uploadTaskToCloud(conflict.local, userId);
  }

  // Resolve habit conflict (local wins for now)
  Future<void> _resolveHabitConflict(HabitConflict conflict, String userId) async {
    // For now, local version wins
    await _uploadHabitToCloud(conflict.local, userId);
  }

  // Manual sync trigger
  Future<void> manualSync() async {
    await syncData();
  }

  // Get sync status
  bool getSyncStatus() {
    return _isOnline && !_isSyncing;
  }

  // Dispose resources
  void dispose() {
    _stopPeriodicSync();
    _syncStatusController.close();
    _syncMessageController.close();
  }
}

// Conflict resolution classes
class TaskConflict {
  final Tasks local;
  final Tasks cloud;
  
  TaskConflict({required this.local, required this.cloud});
}

class HabitConflict {
  final HabitsModel local;
  final HabitsModel cloud;
  
  HabitConflict({required this.local, required this.cloud});
} 
