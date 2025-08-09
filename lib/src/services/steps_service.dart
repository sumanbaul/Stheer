import 'dart:async';
import 'dart:ui' show Offset; // for lightweight route previews
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notifoo/src/services/push_notification_service.dart';

class StepsService extends ChangeNotifier {
  final StreamController<int> _stepsController = StreamController<int>.broadcast();
  final StreamController<int> _goalController = StreamController<int>.broadcast();
  static const MethodChannel _fitness = MethodChannel('com.mindflo.stheer/fitness');

  int _todaySteps = 0;
  int _dailyGoal = 8000;
  List<int> _weeklySteps = List<int>.filled(7, 0); // Mon..Sun
  double _strideMeters = 0.78; // default average walking stride
  double _weightKg = 70; // used for rough calorie estimation

  // Simple daily history with mock route preview points (normalized 0..1 Offsets)
  final List<Map<String, dynamic>> _dailyHistory = [];

  Timer? _mockTimer;
  bool _useReal = false;
  bool _connected = false;

  int get todaySteps => _todaySteps;
  int get dailyGoal => _dailyGoal;
  List<int> get weeklySteps => List.unmodifiable(_weeklySteps);
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<int> get goalStream => _goalController.stream;
  bool get usingRealData => _useReal && _connected;

  // Gamified points and history accessors
  int get pointsToday {
    if (_todaySteps <= 0) return 0;
    final progress = _todaySteps / _dailyGoal;
    int pts = (progress * 100).round();
    if (progress >= 1.0) {
      pts += ((_todaySteps - _dailyGoal) / 1000).floor() * 10; // bonus beyond goal
    }
    return pts.clamp(0, 10000);
  }
  List<Map<String, dynamic>> get dailyHistory => List.unmodifiable(_dailyHistory);

  // Derived metrics
  double get distanceKm => (_todaySteps * _strideMeters) / 1000.0;
  int get activeMinutes => (_todaySteps / 100.0).round();
  int get caloriesKcal {
    // Rough heuristic: ~0.04 kcal per step for average adult walking
    return (_todaySteps * 0.04).round();
  }
  int get streakDays {
    // Count consecutive days from today backwards with non-zero steps
    int count = 0;
    for (int i = (DateTime.now().weekday - 1); i >= 0; i--) {
      if (_weeklySteps[i] > 0) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  void setStrideMeters(double meters) {
    _strideMeters = meters.clamp(0.3, 1.5);
    notifyListeners();
  }

  void setWeightKg(double kg) {
    _weightKg = kg.clamp(30, 200);
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_useReal) {
      try {
        _connected = await _fitness.invokeMethod('isConnected') == true;
        if (_connected) {
          await _loadRealToday();
          await _loadRealWeekly();
          _ensureHistoryToday();
          _updateHistoryToday();
          return;
        }
      } catch (_) {
        _connected = false;
      }
    }
    // Fallback: simulate steps for demo/testing.
    _ensureHistoryToday();
    _startMock();
  }

  void _startMock() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _todaySteps += 120;
      final int weekdayIndex = DateTime.now().weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
    });
  }

  Future<void> disposeService() async {
    await _stepsController.close();
    await _goalController.close();
    _mockTimer?.cancel();
  }

  void setGoal(int goal) {
    _dailyGoal = goal.clamp(1000, 50000);
    _goalController.add(_dailyGoal);
    notifyListeners();
    _checkGoalAndNotify();
  }

  void _checkGoalAndNotify() {
    if (_todaySteps >= _dailyGoal) {
      // Fire a local notification when target reached
      try {
        PushNotificationService().showLocalNotification(
          id: 9001,
          title: 'Daily Steps Goal Achieved',
          body: 'Great job! You reached ${_todaySteps} steps today.',
        );
      } catch (_) {}
    }
  }

  Future<bool> connectGoogleFit() async {
    try {
      final ok = await _fitness.invokeMethod('connect');
      _useReal = ok == true;
      _connected = _useReal;
      notifyListeners();
      if (_connected) {
        _mockTimer?.cancel();
        await _loadRealToday();
        await _loadRealWeekly();
        _ensureHistoryToday();
        _updateHistoryToday();
      }
      return _connected;
    } catch (_) {
      _useReal = false;
      _connected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshAfterPermission() async {
    try {
      final has = await _fitness.invokeMethod('hasPermissions');
      if (has == true) {
        _useReal = true;
        _connected = true;
        _mockTimer?.cancel();
        await _loadRealToday();
        await _loadRealWeekly();
        _ensureHistoryToday();
        _updateHistoryToday();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadRealToday() async {
    try {
      final steps = await _fitness.invokeMethod('getTodaySteps');
      _todaySteps = (steps as int? ?? 0);
      final weekdayIndex = DateTime.now().weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadRealWeekly() async {
    try {
      final list = await _fitness.invokeMethod('getWeeklySteps');
      final l = (list as List?)?.map((e) => e as int).toList() ?? [];
      if (l.length == 7) {
        _weeklySteps = l;
      }
      notifyListeners();
    } catch (_) {}
  }

  void _ensureHistoryToday() {
    final now = DateTime.now();
    final key = DateTime(now.year, now.month, now.day).toIso8601String();
    final exists = _dailyHistory.any((e) => e['key'] == key);
    if (!exists) {
      _dailyHistory.insert(0, {
        'key': key,
        'date': now,
        'steps': 0,
        'distanceKm': 0.0,
        'activeMinutes': 0,
        'points': 0,
        'route': const [
          Offset(0.06, 0.70),
          Offset(0.22, 0.42),
          Offset(0.38, 0.68),
          Offset(0.56, 0.36),
          Offset(0.78, 0.58),
          Offset(0.94, 0.32),
        ],
      });
    }
  }

  void _updateHistoryToday() {
    if (_dailyHistory.isEmpty) return;
    final entry = _dailyHistory.first;
    entry['steps'] = _todaySteps;
    entry['distanceKm'] = distanceKm;
    entry['activeMinutes'] = activeMinutes;
    entry['points'] = pointsToday;
  }

}
