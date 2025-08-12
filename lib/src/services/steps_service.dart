import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:notifoo/src/services/push_notification_service.dart';
import 'package:flutter/material.dart'; // Added for Offset

class StepsService extends ChangeNotifier {
  final StreamController<int> _stepsController = StreamController<int>.broadcast();
  final StreamController<int> _goalController = StreamController<int>.broadcast();
  static const MethodChannel _fitness = MethodChannel('com.mindflo.stheer/fitness');

  int _todaySteps = 0;
  int _dailyGoal = 8000;
  List<int> _weeklySteps = List<int>.filled(7, 0); // Mon..Sun
  double _strideMeters = 0.78; // default average walking stride

  // Simple daily history with mock route preview points (normalized 0..1 Offsets)
  final List<Map<String, dynamic>> _dailyHistory = [];

  Timer? _mockTimer;
  bool _useReal = false;
  bool _connected = false;
  bool _isConnecting = false;
  Timer? _refreshTimer; // Timer for periodic refresh of Google Fit data
  DateTime? _lastUpdated; // Timestamp of last data update

  // Device sensor tracking (using accelerometer data)
  bool _useDeviceSensors = false;
  int _deviceStepCount = 0;
  DateTime? _lastDeviceStepTime;
  DateTime? _lastMidnight;
  Timer? _sensorCheckTimer;
  
  // Real sensor tracking variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  List<double> _accelerometerBuffer = [];
  double _lastMagnitude = 0.0;
  double _stepThreshold = 3.0; // Lowered from 12.0 to 3.0 for better sensitivity
  DateTime? _lastStepTime;
  int _minStepIntervalMs = 300; // Minimum time between steps (ms)
  bool _isWalking = false;
  int _consecutiveSteps = 0;
  
  // Sensor performance tracking
  DateTime? _firstSensorEvent;
  int _totalSensorEvents = 0;
  DateTime? _lastSensorEvent;
  double _sensorEventFrequency = 0.0; // events per second

  int get todaySteps => _todaySteps;
  int get dailyGoal => _dailyGoal;
  List<int> get weeklySteps => List.unmodifiable(_weeklySteps);
  Stream<int> get stepsStream => _stepsController.stream;
  Stream<int> get goalStream => _goalController.stream;
  bool get usingRealData => _useReal && _connected;
  bool get usingDeviceSensors => _useDeviceSensors;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _connected;
  DateTime? get lastUpdated => _lastUpdated;
  String get dataSource {
    if (_useReal && _connected && _useDeviceSensors) {
      return 'Google Fit + Device Sensors (Hybrid)';
    } else if (_useReal && _connected) {
      return 'Google Fit';
    } else if (_useDeviceSensors) {
      return 'Device Sensors';
    }
    return 'Manual Entry';
  }

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

  Future<void> initialize() async {
    if (kDebugMode) {
      print('=== INITIALIZING STEPS SERVICE ===');
    }
    
    // Check if we already have a connection
    try {
      final connected = await _fitness.invokeMethod('isConnected') == true;
      if (kDebugMode) {
        print('🔍 Google Fit connection check: $connected');
      }
      
      if (connected) {
        // Check permission before loading data
        if (kDebugMode) {
          print('🔐 Checking ACTIVITY_RECOGNITION permission...');
        }
        final hasPermission = await _checkAndRequestActivityRecognitionPermission();
        if (kDebugMode) {
          print('🔐 ACTIVITY_RECOGNITION permission result: $hasPermission');
        }
        
        if (!hasPermission) {
          if (kDebugMode) {
            print('❌ ACTIVITY_RECOGNITION permission not granted during initialization');
          }
          _connected = false;
          _useReal = false;
        } else {
          if (kDebugMode) {
            print('✅ ACTIVITY_RECOGNITION permission granted, loading Google Fit data...');
          }
          _useReal = true;
          _connected = true;
          await _loadRealToday();
          await _loadRealWeekly();
          _ensureHistoryToday();
          _updateHistoryToday();
          notifyListeners();
          
          // Even when Google Fit is connected, initialize device sensors as backup
          if (kDebugMode) {
            print('📱 Google Fit connected, but also initializing device sensors as backup...');
          }
          await _initializeDeviceSensors();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking connection status: $e');
      }
      _connected = false;
    }

    // If not connected to Google Fit, try device sensors
    if (!_connected) {
      if (kDebugMode) {
        print('📱 Google Fit not connected, trying device sensors...');
      }
      await _initializeDeviceSensors();
    }

    // If not connected, initialize with mock data but don't start auto-increment
    _ensureHistoryToday();
    _updateHistoryToday();
    notifyListeners();
    
    if (kDebugMode) {
      print('📊 Steps service initialized:');
      print('   - Google Fit: $_useReal (connected: $_connected)');
      print('   - Device Sensors: $_useDeviceSensors');
      print('   - Today Steps: $_todaySteps');
    }
  }

  // Initialize device sensor tracking
  Future<void> _initializeDeviceSensors() async {
    try {
      if (kDebugMode) {
        print('🔧 Initializing real device sensor tracking...');
      }

      // Check activity recognition permission
      if (kDebugMode) {
        print('🔐 Checking ACTIVITY_RECOGNITION permission for device sensors...');
      }
      final hasPermission = await _checkAndRequestActivityRecognitionPermission();
      if (kDebugMode) {
        print('🔐 ACTIVITY_RECOGNITION permission for device sensors: $hasPermission');
      }
      
      if (!hasPermission) {
        if (kDebugMode) {
          print('❌ ACTIVITY_RECOGNITION permission not granted for device sensors');
        }
        return;
      }

      // Initialize real step counting using accelerometer
      await _startRealDeviceStepCounting();
      
      if (kDebugMode) {
        print('✅ Real device sensor tracking initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing device sensors: $e');
      }
    }
  }

  // Start real device step counting using accelerometer
  Future<void> _startRealDeviceStepCounting() async {
    try {
      if (kDebugMode) {
        print('=== STARTING REAL DEVICE STEP COUNTING ===');
      }
      
      // Cancel existing timer and subscription
      _sensorCheckTimer?.cancel();
      _accelerometerSubscription?.cancel();

      // Initialize accelerometer buffer
      _accelerometerBuffer.clear();
      _lastMagnitude = 0.0;
      _lastStepTime = null;
      _isWalking = false;
      _consecutiveSteps = 0;

      if (kDebugMode) {
        print('Accelerometer buffer initialized, subscribing to events...');
      }

      // Check if accelerometer is available
      try {
        // Test if we can get accelerometer events
        final testSubscription = accelerometerEvents.listen(
          (event) {
            if (kDebugMode) {
              print('✅ Accelerometer test event received: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}');
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print('❌ Accelerometer test error: $error');
            }
          },
        );
        
        // Cancel test subscription after a short delay
        Timer(const Duration(milliseconds: 500), () {
          testSubscription.cancel();
        });
        
        if (kDebugMode) {
          print('✅ Accelerometer is available and working');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Accelerometer not available: $e');
        }
        throw Exception('Accelerometer not available: $e');
      }

      // Subscribe to accelerometer events
      _accelerometerSubscription = accelerometerEvents.listen(
        _onAccelerometerEvent,
        onError: (error) {
          if (kDebugMode) {
            print('❌ Accelerometer error: $error');
          }
        },
        onDone: () {
          if (kDebugMode) {
            print('⚠️ Accelerometer stream closed');
          }
        },
      );

      if (kDebugMode) {
        print('✅ Accelerometer subscription created successfully');
      }

      // Set up a timer to check for new day and update UI
      _sensorCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _checkNewDay();
        _updateWalkingState();
        notifyListeners();
        if (kDebugMode) {
          print('🔄 Sensor check timer: Steps=$_deviceStepCount, Walking=$_isWalking, Consecutive=$_consecutiveSteps');
        }
      });

      _useDeviceSensors = true;
      _lastMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      
      if (kDebugMode) {
        print('✅ Real device step counting started using accelerometer');
        print('📱 Device sensors enabled: $_useDeviceSensors');
        print('🕐 Last midnight: $_lastMidnight');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error starting real device step counting: $e');
      }
      _useDeviceSensors = false;
      rethrow;
    }
  }

  // Handle accelerometer events for step detection
  void _onAccelerometerEvent(AccelerometerEvent event) {
    try {
      // Track sensor performance
      _totalSensorEvents++;
      if (_firstSensorEvent == null) {
        _firstSensorEvent = DateTime.now();
      }
      _lastSensorEvent = DateTime.now();
      
      // Calculate event frequency
      if (_firstSensorEvent != null && _totalSensorEvents > 1) {
        final duration = _lastSensorEvent!.difference(_firstSensorEvent!).inMilliseconds / 1000.0;
        _sensorEventFrequency = _totalSensorEvents / duration;
      }
      
      // Calculate magnitude of acceleration
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // Add to buffer (keep last 10 readings for smoothing)
      _accelerometerBuffer.add(magnitude);
      if (_accelerometerBuffer.length > 10) {
        _accelerometerBuffer.removeAt(0);
      }
      
      // Calculate average magnitude for smoothing
      final avgMagnitude = _accelerometerBuffer.reduce((a, b) => a + b) / _accelerometerBuffer.length;
      
      // Debug logging for first few events
      if (_deviceStepCount < 5 && _accelerometerBuffer.length >= 5) {
        if (kDebugMode) {
          print('📊 Accelerometer: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}');
          print('📊 Magnitude: ${magnitude.toStringAsFixed(2)}, Avg: ${avgMagnitude.toStringAsFixed(2)}');
          print('📊 Threshold: $_stepThreshold, Change: ${(avgMagnitude - _lastMagnitude).abs().toStringAsFixed(2)}');
          print('📊 Event #$_totalSensorEvents, Frequency: ${_sensorEventFrequency.toStringAsFixed(1)} Hz');
        }
      }
      
      // Step detection algorithm
      if (_detectStep(avgMagnitude)) {
        _incrementStep();
      }
      
      _lastMagnitude = avgMagnitude;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing accelerometer event: $e');
      }
    }
  }

  // Step detection algorithm
  bool _detectStep(double magnitude) {
    final now = DateTime.now();
    
    // Check minimum time interval between steps
    if (_lastStepTime != null && 
        now.difference(_lastStepTime!).inMilliseconds < _minStepIntervalMs) {
      return false;
    }
    
    // For initial detection, we can start with fewer buffer entries
    int minBufferSize = _consecutiveSteps > 0 ? 3 : 2;
    if (_accelerometerBuffer.length < minBufferSize) {
      return false;
    }
    
    // Check if magnitude change exceeds threshold (indicating a step)
    final magnitudeChange = (magnitude - _lastMagnitude).abs();
    
    // Dynamic threshold based on walking state
    double currentThreshold = _stepThreshold;
    if (_isWalking && _consecutiveSteps > 3) {
      currentThreshold *= 0.7; // Lower threshold when walking consistently
    }
    
    // For the first few steps, be more lenient
    if (_consecutiveSteps < 3) {
      currentThreshold *= 0.8;
    }
    
    // Check if magnitude change exceeds threshold
    bool hasSignificantChange = magnitudeChange > currentThreshold;
    
    // Also check if the current magnitude is significantly different from the average
    if (_accelerometerBuffer.length >= 3) {
      final avgMagnitude = _accelerometerBuffer.reduce((a, b) => a + b) / _accelerometerBuffer.length;
      final deviationFromAverage = (magnitude - avgMagnitude).abs();
      
      // If magnitude deviates significantly from average, it might be a step
      if (deviationFromAverage > currentThreshold * 0.6) {
        hasSignificantChange = true;
      }
    }
    
    // Additional check: look for acceleration patterns that indicate walking
    if (!hasSignificantChange && _accelerometerBuffer.length >= 5) {
      // Check if we have a pattern of increasing then decreasing magnitude (step pattern)
      final recentMagnitudes = _accelerometerBuffer.skip(_accelerometerBuffer.length - 5).toList();
      bool hasStepPattern = false;
      
      // Look for a peak in the middle (step impact)
      for (int i = 1; i < recentMagnitudes.length - 1; i++) {
        if (recentMagnitudes[i] > recentMagnitudes[i-1] && 
            recentMagnitudes[i] > recentMagnitudes[i+1] &&
            recentMagnitudes[i] > magnitude + currentThreshold * 0.5) {
          hasStepPattern = true;
          break;
        }
      }
      
      if (hasStepPattern) {
        hasSignificantChange = true;
      }
    }
    
    if (hasSignificantChange) {
      if (kDebugMode) {
        print('🚶 Step detected! Magnitude change: ${magnitudeChange.toStringAsFixed(2)} > $currentThreshold');
        print('📊 Current magnitude: ${magnitude.toStringAsFixed(2)}, Last: ${_lastMagnitude.toStringAsFixed(2)}');
        print('📊 Consecutive steps: $_consecutiveSteps, Walking: $_isWalking');
      }
      _lastStepTime = now;
      return true;
    }
    
    return false;
  }

  // Increment step count
  void _incrementStep() {
    try {
      final now = DateTime.now();
      
      // Check if it's a new day
      if (_lastMidnight == null || 
          now.isAfter(_lastMidnight!.add(const Duration(days: 1)))) {
        _lastMidnight = DateTime(now.year, now.month, now.day);
        _deviceStepCount = 0;
        _consecutiveSteps = 0;
        if (kDebugMode) {
          print('New day detected, resetting device step count');
        }
      }

      // Increment step count
      _deviceStepCount++;
      _consecutiveSteps++;
      _todaySteps = _deviceStepCount;
      _lastDeviceStepTime = now;
      _lastUpdated = now;
      
      // Update weekly data
      final weekdayIndex = now.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      
      // Update history and notify
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      
      // Adjust step threshold based on walking pattern
      _adjustStepThreshold();
      
      if (kDebugMode) {
        print('Step detected! Total: $_todaySteps, Consecutive: $_consecutiveSteps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error incrementing step: $e');
      }
    }
  }

  // Check if it's a new day
  void _checkNewDay() {
    final now = DateTime.now();
    if (_lastMidnight == null || 
        now.isAfter(_lastMidnight!.add(const Duration(days: 1)))) {
      _lastMidnight = DateTime(now.year, now.month, now.day);
      _deviceStepCount = 0;
      _consecutiveSteps = 0;
      if (kDebugMode) {
        print('New day detected, resetting device step count');
      }
    }
  }

  // Update walking state based on step pattern
  void _updateWalkingState() {
    // More responsive walking detection
    if (_consecutiveSteps >= 2) {
      _isWalking = true;
    } else if (_consecutiveSteps == 0) {
      _isWalking = false;
    }
    
    // If we haven't had a step in 10 seconds, reset walking state
    if (_lastStepTime != null) {
      final timeSinceLastStep = DateTime.now().difference(_lastStepTime!).inSeconds;
      if (timeSinceLastStep > 10) {
        _consecutiveSteps = 0;
        _isWalking = false;
        if (kDebugMode) {
          print('⏰ No steps for 10+ seconds, resetting walking state');
        }
      }
    }
  }

  // Stop device step counting
  void _stopDeviceStepCounting() {
    _sensorCheckTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _useDeviceSensors = false;
    if (kDebugMode) {
      print('Device step counting stopped');
    }
  }

  // Get current step count from device sensors
  int get currentDeviceStepCount => _deviceStepCount;
  
  // Get walking state
  bool get isWalking => _isWalking;
  
  // Get consecutive steps
  int get consecutiveSteps => _consecutiveSteps;
  
  // Get step threshold (for debugging/adjustment)
  double get stepThreshold => _stepThreshold;
  
  // Set step threshold (for calibration)
  void setStepThreshold(double threshold) {
    _stepThreshold = threshold.clamp(5.0, 20.0);
    notifyListeners();
  }

  // Reset step threshold to default
  void resetStepThreshold() {
    _stepThreshold = 3.0; // Updated default value for better sensitivity
    if (kDebugMode) {
      print('🔧 Step threshold reset to default: $_stepThreshold');
    }
    notifyListeners();
  }

  // Dynamically adjust step threshold based on walking pattern
  void _adjustStepThreshold() {
    if (_consecutiveSteps < 5) return; // Need more data
    
    // Calculate average magnitude change from recent steps
    if (_accelerometerBuffer.length >= 10) {
      final recentMagnitudes = _accelerometerBuffer.skip(_accelerometerBuffer.length - 10).toList();
      double totalChange = 0.0;
      int changeCount = 0;
      
      for (int i = 1; i < recentMagnitudes.length; i++) {
        final change = (recentMagnitudes[i] - recentMagnitudes[i - 1]).abs();
        if (change > 0) {
          totalChange += change;
          changeCount++;
        }
      }
      
      if (changeCount > 0) {
        final avgChange = totalChange / changeCount;
        
        // Adjust threshold based on average change, but keep it within reasonable bounds
        if (avgChange > _stepThreshold * 2.0) {
          // User has strong movements, increase threshold slightly
          final newThreshold = (_stepThreshold + avgChange * 0.2).clamp(2.0, 8.0);
          if (newThreshold != _stepThreshold) {
            if (kDebugMode) {
              print('🔧 Adjusting step threshold: $_stepThreshold -> ${newThreshold.toStringAsFixed(1)} (strong movements detected)');
            }
            _stepThreshold = newThreshold;
          }
        } else if (avgChange < _stepThreshold * 0.8) {
          // User has subtle movements, decrease threshold slightly
          final newThreshold = (_stepThreshold * 0.9).clamp(2.0, 8.0);
          if (newThreshold != _stepThreshold) {
            if (kDebugMode) {
              print('🔧 Adjusting step threshold: $_stepThreshold -> ${newThreshold.toStringAsFixed(1)} (subtle movements detected)');
            }
            _stepThreshold = newThreshold;
          }
        }
      }
    }
  }
  
  // Get sensor accuracy information
  String get sensorAccuracyInfo {
    if (_useDeviceSensors) {
      if (_isWalking && _consecutiveSteps > 5) {
        return 'High accuracy - Walking pattern detected';
      } else if (_consecutiveSteps > 0) {
        return 'Medium accuracy - Some movement detected';
      } else {
        return 'Low accuracy - No movement detected';
      }
    }
    return 'Sensors not active';
  }

  Future<bool> _checkAndRequestActivityRecognitionPermission() async {
    try {
      if (kDebugMode) {
        print('🔐 Checking ACTIVITY_RECOGNITION permission...');
      }
      
      // Check if permission is granted
      PermissionStatus status = await Permission.activityRecognition.status;
      if (kDebugMode) {
        print('🔐 Current ACTIVITY_RECOGNITION permission status: $status');
      }
      
      if (status.isGranted) {
        if (kDebugMode) {
          print('✅ ACTIVITY_RECOGNITION permission already granted');
        }
        return true;
      }
      
      if (kDebugMode) {
        print('📝 Requesting ACTIVITY_RECOGNITION permission...');
      }
      
      // Request permission
      status = await Permission.activityRecognition.request();
      
      if (kDebugMode) {
        print('🔐 ACTIVITY_RECOGNITION permission result: $status');
      }
      
      if (status.isGranted) {
        if (kDebugMode) {
          print('✅ ACTIVITY_RECOGNITION permission granted successfully');
        }
      } else {
        if (kDebugMode) {
          print('❌ ACTIVITY_RECOGNITION permission denied: $status');
        }
      }
      
      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking/requesting ACTIVITY_RECOGNITION permission: $e');
      }
      return false;
    }
  }

  Future<bool> isActivityRecognitionPermissionPermanentlyDenied() async {
    try {
      final status = await Permission.activityRecognition.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if permission is permanently denied: $e');
      }
      return false;
    }
  }

  Future<void> openAppSettingsForPermission() async {
    try {
      await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
    }
  }

  Future<void> disposeService() async {
    await _stepsController.close();
    await _goalController.close();
    _mockTimer?.cancel();
    _refreshTimer?.cancel(); // Clean up refresh timer
    _stopDeviceStepCounting(); // Stop device sensor tracking on dispose
  }

  void setGoal(int goal) {
    _dailyGoal = goal.clamp(1000, 50000);
    _goalController.add(_dailyGoal);
    notifyListeners();
    _checkGoalAndNotify();
  }

  // Add manual steps (for when user manually enters steps)
  void addManualSteps(int steps) {
    if (steps <= 0) return;
    
    try {
      final now = DateTime.now();
      
      // Check if it's a new day
      if (_lastMidnight == null || 
          now.isAfter(_lastMidnight!.add(const Duration(days: 1)))) {
        _lastMidnight = DateTime(now.year, now.month, now.day);
        _todaySteps = 0;
        if (kDebugMode) {
          print('New day detected, resetting manual step count');
        }
      }
      
      // Add the manual steps
      _todaySteps += steps;
      _lastUpdated = now;
      
      // Update weekly data
      final weekdayIndex = now.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      
      // Update history and notify
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
      
      if (kDebugMode) {
        print('Manual steps added: $steps, total today: $_todaySteps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding manual steps: $e');
      }
    }
  }

  // Set manual steps (overwrite current count)
  void setManualSteps(int steps) {
    if (steps < 0) return;
    
    try {
      final now = DateTime.now();
      
      // Check if it's a new day
      if (_lastMidnight == null || 
          now.isAfter(_lastMidnight!.add(const Duration(days: 1)))) {
        _lastMidnight = DateTime(now.year, now.month, now.day);
        if (kDebugMode) {
          print('New day detected, setting manual step count');
        }
      }
      
      // Set the manual steps
      _todaySteps = steps;
      _lastUpdated = now;
      
      // Update weekly data
      final weekdayIndex = now.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      
      // Update history and notify
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
      
      if (kDebugMode) {
        print('Manual steps set: $steps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting manual steps: $e');
      }
    }
  }

  // Get step count from the best available source
  int getCurrentStepCount() {
    if (_useReal && _connected) {
      // If Google Fit is connected, use its data but also consider device sensors
      int googleFitSteps = _todaySteps;
      int deviceSensorSteps = _deviceStepCount;
      
      // Use the higher count between Google Fit and device sensors
      if (deviceSensorSteps > googleFitSteps) {
        if (kDebugMode) {
          print('📊 Device sensors show more steps ($deviceSensorSteps) than Google Fit ($googleFitSteps), using device data');
        }
        return deviceSensorSteps;
      }
      return googleFitSteps;
    } else if (_useDeviceSensors) {
      return _deviceStepCount; // Device sensor data
    } else {
      return _todaySteps; // Manual entry data
    }
  }

  // Check if we have any step data available
  bool get hasStepData {
    return _todaySteps > 0 || _deviceStepCount > 0;
  }

  // Get the most recent step count timestamp
  DateTime? get lastStepUpdateTime {
    if (_lastUpdated != null) return _lastUpdated;
    if (_lastDeviceStepTime != null) return _lastDeviceStepTime;
    return null;
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
    if (_isConnecting) return false;
    
    _isConnecting = true;
    notifyListeners();
    
    try {
      if (kDebugMode) {
        print('Attempting to connect to Google Fit...');
      }
      
      // First check and request ACTIVITY_RECOGNITION permission
      final hasActivityPermission = await _checkAndRequestActivityRecognitionPermission();
      if (!hasActivityPermission) {
        if (kDebugMode) {
          print('ACTIVITY_RECOGNITION permission denied');
        }
        _isConnecting = false;
        notifyListeners();
        return false;
      }
      
      // Then check if we already have Google Fit permissions
      final hasPermissions = await _fitness.invokeMethod('hasPermissions');
      
      if (hasPermissions == true) {
        if (kDebugMode) {
          print('Google Fit permissions already granted, loading data...');
        }
        // We have permissions, try to get data
        _useReal = true;
        _connected = true;
        
        // Don't stop device sensor tracking when connecting to Google Fit
        // Keep both active for better reliability
        if (kDebugMode) {
          print('📱 Keeping device sensors active alongside Google Fit');
        }
        
        await _loadRealToday();
        await _loadRealWeekly();
        _ensureHistoryToday();
        _updateHistoryToday();
        _startPeriodicRefresh(); // Start periodic refresh
        
        // Reset connecting flag on success
        _isConnecting = false;
        notifyListeners();
        return true;
      }
      
      // Request permissions
      final result = await _fitness.invokeMethod('requestPermissions');
      
      if (result == true) {
        if (kDebugMode) {
          print('Google Fit permissions granted, connecting...');
        }
        
        // Don't stop device sensor tracking when connecting to Google Fit
        // Keep both active for better reliability
        if (kDebugMode) {
          print('📱 Keeping device sensors active alongside Google Fit');
        }
        
        _useReal = true;
        _connected = true;
        await _loadRealToday();
        await _loadRealWeekly();
        _ensureHistoryToday();
        _updateHistoryToday();
        _startPeriodicRefresh(); // Start periodic refresh
        
        // Reset connecting flag on success
        _isConnecting = false;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('Google Fit permissions denied');
        }
        _isConnecting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to Google Fit: $e');
      }
      _isConnecting = false;
      notifyListeners();
      return false;
    }
  }

  // Sync device sensor steps with Google Fit when it becomes available
  Future<void> syncStepsWithGoogleFit() async {
    if (!_connected || !_useReal) {
      if (kDebugMode) {
        print('Google Fit not connected, cannot sync steps');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('Syncing device sensor steps with Google Fit...');
      }

      // Get the current device sensor steps if available
      int deviceSteps = 0;
      if (_useDeviceSensors && _lastDeviceStepTime != null) {
        // Check if device sensor data is from today
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastStepDate = DateTime(_lastDeviceStepTime!.year, _lastDeviceStepTime!.month, _lastDeviceStepTime!.day);
        
        if (today.isAtSameMomentAs(lastStepDate)) {
          deviceSteps = _deviceStepCount;
          if (kDebugMode) {
            print('Device sensor steps from today: $deviceSteps');
          }
        }
      }

      // If we have device sensor data and it's higher than Google Fit data,
      // we could potentially write it to Google Fit (requires write permissions)
      if (deviceSteps > _todaySteps) {
        if (kDebugMode) {
          print('Device sensor steps ($deviceSteps) are higher than Google Fit steps ($_todaySteps)');
          print('Note: Writing to Google Fit requires additional permissions');
        }
        // TODO: Implement writing to Google Fit if write permissions are granted
      }

      if (kDebugMode) {
        print('Step synchronization completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing steps with Google Fit: $e');
      }
    }
  }

  // Check if device sensors are available and working
  Future<bool> checkDeviceSensorsAvailability() async {
    try {
      // This is a simulated check, so it will always return true
      // In a real app, you would check if a pedometer package is available
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking device sensors availability: $e');
      }
      return false;
    }
  }

  // Get tracking method description
  String getTrackingMethod() {
    if (_useReal && _connected && _useDeviceSensors) {
      return 'Google Fit + Device Sensors (Hybrid)';
    } else if (_useReal && _connected) {
      return 'Google Fit';
    } else if (_useDeviceSensors) {
      return 'Device Sensors (Real-time)';
    }
    return 'Manual Entry';
  }

  // Get tracking status description
  String getTrackingStatusDescription() {
    if (_useReal && _connected && _useDeviceSensors) {
      return 'Hybrid tracking - Google Fit for cloud sync + Device sensors for real-time updates';
    } else if (_useReal && _connected) {
      return 'Connected to Google Fit - Syncing with cloud data';
    }
    if (_useDeviceSensors) {
      if (_isWalking) {
        return 'Using device sensors - Walking detected (${_consecutiveSteps} consecutive steps)';
      } else {
        return 'Using device sensors - Waiting for movement';
      }
    }
    return 'Manual entry mode - Enter steps manually';
  }

  // Get step tracking recommendations
  List<String> getStepTrackingRecommendations() {
    final recommendations = <String>[];
    
    if (_useReal && _connected) {
      recommendations.add('✅ Google Fit is connected and syncing');
      recommendations.add('📱 Steps are automatically synced across devices');
      recommendations.add('🌐 Data is backed up to Google cloud');
    } else if (_useDeviceSensors) {
      recommendations.add('📱 Using device sensors for real-time tracking');
      if (_isWalking) {
        recommendations.add('🚶 Walking pattern detected - High accuracy');
      } else {
        recommendations.add('⏳ Waiting for movement to start tracking');
      }
      recommendations.add('💡 Connect to Google Fit for cloud sync');
    } else {
      recommendations.add('✋ Manual entry mode active');
      recommendations.add('📱 Enable device sensors for automatic tracking');
      recommendations.add('🌐 Connect to Google Fit for best experience');
    }
    
    if (!_connected && !_useDeviceSensors) {
      recommendations.add('🔧 Try enabling device sensors first');
      recommendations.add('📱 Check if Google Fit is installed');
    }
    
    return recommendations;
  }

  Future<void> refreshAfterPermission() async {
    try {
      // Check both permissions
      final hasActivityPermission = await _checkAndRequestActivityRecognitionPermission();
      if (!hasActivityPermission) {
        if (kDebugMode) {
          print('ACTIVITY_RECOGNITION permission not granted');
        }
        return;
      }
      
      final has = await _fitness.invokeMethod('hasPermissions');
      if (has == true) {
        _useReal = true;
        _connected = true;
        await _loadRealToday();
        await _loadRealWeekly();
        _ensureHistoryToday();
        _updateHistoryToday();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing after permission: $e');
      }
    }
  }

  Future<void> _loadRealToday() async {
    try {
      if (kDebugMode) {
        print('Loading today steps from Google Fit...');
      }
      
      // Check permission before making the call
      final hasPermission = await _checkAndRequestActivityRecognitionPermission();
      if (!hasPermission) {
        if (kDebugMode) {
          print('ACTIVITY_RECOGNITION permission not granted for loading today steps');
        }
        return;
      }
      
      final steps = await _fitness.invokeMethod('getTodaySteps');
      if (steps is int) {
        _todaySteps = steps;
        if (kDebugMode) {
          print('Received steps from Google Fit: $_todaySteps');
        }
      } else {
        if (kDebugMode) {
          print('Invalid steps data received: $steps');
        }
        _todaySteps = 0;
      }
      
      final weekdayIndex = DateTime.now().weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      _lastUpdated = DateTime.now(); // Update timestamp
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading today steps: $e');
      }
      _todaySteps = 0;
      // Try to fall back to cached data if available
      if (_dailyHistory.isNotEmpty) {
        final todayEntry = _dailyHistory.first;
        _todaySteps = (todayEntry['steps'] as int?) ?? 0;
      }
      // Re-throw to let UI handle the error
      rethrow;
    }
  }

  Future<void> _loadRealWeekly() async {
    try {
      if (kDebugMode) {
        print('Loading weekly steps from Google Fit...');
      }
      
      // Check permission before making the call
      final hasPermission = await _checkAndRequestActivityRecognitionPermission();
      if (!hasPermission) {
        if (kDebugMode) {
          print('ACTIVITY_RECOGNITION permission not granted for loading weekly steps');
        }
        return;
      }
      
      final list = await _fitness.invokeMethod('getWeeklySteps');
      if (list is List) {
        final l = list.map((e) => e as int).toList();
        if (kDebugMode) {
          print('Received weekly steps from Google Fit: $l');
        }
        
        if (l.length == 7) {
          _weeklySteps = l;
        } else {
          if (kDebugMode) {
            print('Invalid weekly data length: ${l.length}, expected 7');
          }
        }
      } else {
        if (kDebugMode) {
          print('Invalid weekly data received: $list');
        }
      }
      _lastUpdated = DateTime.now(); // Update timestamp
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading weekly steps: $e');
      }
      // Keep existing weekly data on error
      // Re-throw to let UI handle the error
      rethrow;
    }
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

  // Add a method to refresh data manually
  Future<void> refreshData() async {
    try {
      if (_useReal && _connected) {
        if (kDebugMode) {
          print('Refreshing Google Fit data...');
        }
        
        // Check permission before refreshing
        final hasPermission = await _checkAndRequestActivityRecognitionPermission();
        if (!hasPermission) {
          if (kDebugMode) {
            print('ACTIVITY_RECOGNITION permission not granted for refreshing data');
          }
          return;
        }
        
        await _loadRealToday();
        await _loadRealWeekly();
        if (kDebugMode) {
          print('Google Fit data refresh completed');
        }
      } else {
        if (kDebugMode) {
          print('Not connected to Google Fit, skipping refresh');
        }
      }
      _ensureHistoryToday();
      _updateHistoryToday();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
      // Even if refresh fails, ensure we have today's data structure
      _ensureHistoryToday();
      _updateHistoryToday();
      notifyListeners();
      // Re-throw to let UI handle the error
      rethrow;
    }
  }

  // Add a method to disconnect from Google Fit
  Future<void> disconnectFromGoogleFit() async {
    try {
      await _fitness.invokeMethod('disconnect');
      _useReal = false;
      _connected = false;
      _mockTimer?.cancel();
      _stopPeriodicRefresh(); // Stop periodic refresh
      _stopDeviceStepCounting(); // Stop device sensor tracking
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from Google Fit: $e');
      }
    }
  }

  // Add a method to check connection status
  Future<bool> checkConnectionStatus() async {
    try {
      if (kDebugMode) {
        print('Checking Google Fit connection status...');
      }
      
      final connected = await _fitness.invokeMethod('isConnected') == true;
      _connected = connected;
      
      if (connected) {
        // Check permission before loading data
        final hasPermission = await _checkAndRequestActivityRecognitionPermission();
        if (!hasPermission) {
          if (kDebugMode) {
            print('ACTIVITY_RECOGNITION permission not granted during connection check');
          }
          _connected = false;
          _useReal = false;
          _stopPeriodicRefresh();
          notifyListeners();
          return false;
        }
        
        if (kDebugMode) {
          print('Google Fit is connected, loading data...');
        }
        _useReal = true;
        await _loadRealToday();
        await _loadRealWeekly();
        _startPeriodicRefresh(); // Start periodic refresh when connected
      } else {
        if (kDebugMode) {
          print('Google Fit is not connected');
        }
        _stopPeriodicRefresh(); // Stop periodic refresh when disconnected
      }
      
      notifyListeners();
      return connected;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connection status: $e');
      }
      _connected = false;
      _useReal = false;
      _stopPeriodicRefresh(); // Stop periodic refresh when disconnected
      notifyListeners();
      return false;
    }
  }

  // Start periodic refresh of Google Fit data
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    if (_useReal && _connected) {
      _refreshTimer = Timer.periodic(const Duration(minutes: 15), (_) async {
        if (_useReal && _connected) {
          // Check permission before periodic refresh
          try {
            final hasPermission = await _checkAndRequestActivityRecognitionPermission();
            if (hasPermission) {
              await _loadRealToday();
              await _loadRealWeekly();
              notifyListeners();
            } else {
              if (kDebugMode) {
                print('ACTIVITY_RECOGNITION permission not granted during periodic refresh');
              }
              _stopPeriodicRefresh();
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error during periodic refresh: $e');
            }
            _stopPeriodicRefresh();
          }
        }
      });
      if (kDebugMode) {
        print('Started periodic refresh of Google Fit data');
      }
    }
  }

  // Stop periodic refresh
  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (kDebugMode) {
      print('Stopped periodic refresh of Google Fit data');
    }
  }

  // Check if Google Fit is installed on the device
  Future<bool> isGoogleFitInstalled() async {
    try {
      // This is a simple check - in a real app you might want to use package_info_plus
      // or check if the Google Fit app is available through the package manager
      final result = await _fitness.invokeMethod('isGoogleFitInstalled');
      return result == true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Google Fit installation: $e');
      }
      return false;
    }
  }

  // Get the best available step count for display
  int getDisplayStepCount() {
    if (_useReal && _connected) {
      // If Google Fit is connected, use its data but also consider device sensors
      int googleFitSteps = _todaySteps;
      int deviceSensorSteps = _deviceStepCount;
      
      // Use the higher count between Google Fit and device sensors
      if (deviceSensorSteps > googleFitSteps) {
        return deviceSensorSteps;
      }
      return googleFitSteps;
    } else if (_useDeviceSensors) {
      return _deviceStepCount; // Device sensor data (real-time)
    } else {
      return _todaySteps; // Manual entry data
    }
  }

  // Check if we should show a recommendation to install Google Fit
  bool get shouldRecommendGoogleFit {
    return !_connected && !_useDeviceSensors;
  }

  // Get the current tracking accuracy level
  String getTrackingAccuracy() {
    if (_useReal && _connected && _useDeviceSensors) {
      return 'Very High (Google Fit + Device Sensors)';
    } else if (_useReal && _connected) {
      return 'High (Google Fit)';
    } else if (_useDeviceSensors) {
      return 'Medium (Device Sensors)';
    } else {
      return 'Low (Manual Entry)';
    }
  }

  // Debug method to test sensor functionality
  Future<void> testSensorFunctionality() async {
    if (kDebugMode) {
      print('🧪 Testing sensor functionality...');
    }
    
    try {
      // Check if device sensors are enabled
      if (!_useDeviceSensors) {
        if (kDebugMode) {
          print('❌ Device sensors not enabled, trying to initialize...');
        }
        await _initializeDeviceSensors();
      }
      
      if (_useDeviceSensors) {
        if (kDebugMode) {
          print('✅ Device sensors are enabled');
          print('📊 Current sensor status:');
          print('   - Accelerometer subscription: ${_accelerometerSubscription != null}');
          print('   - Sensor check timer: ${_sensorCheckTimer != null}');
          print('   - Buffer size: ${_accelerometerBuffer.length}');
          print('   - Last magnitude: ${_lastMagnitude.toStringAsFixed(2)}');
          print('   - Step threshold: $_stepThreshold');
        }
        
        // Force a step increment for testing
        if (kDebugMode) {
          print('🧪 Forcing a test step increment...');
        }
        _incrementStep();
        
        if (kDebugMode) {
          print('✅ Test step added. New total: $_todaySteps');
        }
      } else {
        if (kDebugMode) {
          print('❌ Failed to enable device sensors');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error testing sensor functionality: $e');
      }
    }
  }

  // Method to check if sensors are actually receiving data
  bool get isReceivingSensorData {
    if (!_useDeviceSensors) return false;
    if (_accelerometerBuffer.isEmpty) return false;
    
    // Check if we've received data in the last 5 seconds
    final now = DateTime.now();
    if (_lastStepTime != null && now.difference(_lastStepTime!).inSeconds < 5) {
      return true;
    }
    
    // Check if buffer has recent data (indicating sensor is working)
    return _accelerometerBuffer.length >= 5;
  }

  // Get sensor health information
  Map<String, dynamic> getSensorHealthInfo() {
    return {
      'deviceSensorsEnabled': _useDeviceSensors,
      'accelerometerSubscription': _accelerometerSubscription != null,
      'sensorCheckTimer': _sensorCheckTimer != null,
      'bufferSize': _accelerometerBuffer.length,
      'lastMagnitude': _lastMagnitude,
      'stepThreshold': _stepThreshold,
      'isReceivingData': isReceivingSensorData,
      'lastStepTime': _lastStepTime?.toIso8601String(),
      'consecutiveSteps': _consecutiveSteps,
      'isWalking': _isWalking,
      'totalSensorEvents': _totalSensorEvents,
      'sensorEventFrequency': _sensorEventFrequency,
      'firstSensorEvent': _firstSensorEvent?.toIso8601String(),
      'lastSensorEvent': _lastSensorEvent?.toIso8601String(),
    };
  }

  // Method to manually reinitialize sensors
  Future<void> reinitializeSensors() async {
    if (kDebugMode) {
      print('🔄 Manually reinitializing sensors...');
    }
    
    try {
      // Stop current sensors
      _stopDeviceStepCounting();
      
      // Wait a moment
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Try to initialize again
      await _initializeDeviceSensors();
      
      if (kDebugMode) {
        print('✅ Sensor reinitialization completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reinitializing sensors: $e');
      }
      rethrow;
    }
  }

  // Method to simulate walking for testing
  void simulateWalking() {
    if (kDebugMode) {
      print('🚶 Simulating walking pattern...');
    }
    
    try {
      // Instead of creating fake events, we'll simulate the step detection logic
      // by temporarily adjusting the threshold and processing existing sensor data
      
      // Store original threshold
      final originalThreshold = _stepThreshold;
      
      // Temporarily lower threshold for testing
      _stepThreshold = 1.0;
      
      if (kDebugMode) {
        print('📊 Temporarily lowered threshold to $_stepThreshold for testing');
        print('📊 Current buffer size: ${_accelerometerBuffer.length}');
        print('📊 Last magnitude: ${_lastMagnitude.toStringAsFixed(2)}');
      }
      
      // If we have sensor data, try to detect steps from it
      if (_accelerometerBuffer.isNotEmpty) {
        // Process the last few buffer entries to look for steps
        for (int i = 0; i < _accelerometerBuffer.length; i++) {
          final magnitude = _accelerometerBuffer[i];
          if (_detectStep(magnitude)) {
            if (kDebugMode) {
              print('🚶 Test step detected from buffer entry $i!');
            }
          }
        }
      }
      
      // Restore original threshold after a delay
      Timer(const Duration(seconds: 3), () {
        _stepThreshold = originalThreshold;
        if (kDebugMode) {
          print('🔧 Restored threshold to $_stepThreshold');
        }
      });
      
      if (kDebugMode) {
        print('✅ Walking simulation test completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error simulating walking: $e');
      }
    }
  }

  // Simple test method to verify step detection
  void testStepDetection() {
    if (kDebugMode) {
      print('🧪 Testing step detection with current sensor data...');
    }
    
    try {
      if (kDebugMode) {
        print('📊 Current threshold: $_stepThreshold');
        print('📊 Buffer size: ${_accelerometerBuffer.length}');
        print('📊 Last magnitude: ${_lastMagnitude.toStringAsFixed(2)}');
        print('📊 Consecutive steps: $_consecutiveSteps');
        print('📊 Walking state: $_isWalking');
      }
      
      // Test if step detection logic works with current data
      if (_accelerometerBuffer.isNotEmpty) {
        // Try to detect a step from the last buffer entry
        final lastMagnitude = _accelerometerBuffer.last;
        final wouldDetectStep = _detectStep(lastMagnitude);
        
        if (kDebugMode) {
          print('📊 Last buffer magnitude: ${lastMagnitude.toStringAsFixed(2)}');
          print('📊 Would detect step: $wouldDetectStep');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ No sensor data available for testing');
        }
      }
      
      if (kDebugMode) {
        print('✅ Step detection test completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error testing step detection: $e');
      }
    }
  }

  // Method to clear sensor performance data
  void clearSensorPerformanceData() {
    _totalSensorEvents = 0;
    _sensorEventFrequency = 0.0;
    _firstSensorEvent = null;
    _lastSensorEvent = null;
    
    if (kDebugMode) {
      print('🧹 Sensor performance data cleared');
    }
    notifyListeners();
  }

  // Method to check if accelerometer is working
  Future<bool> checkAccelerometerWorking() async {
    if (kDebugMode) {
      print('🔍 Checking if accelerometer is working...');
    }
    
    try {
      bool receivedEvent = false;
      bool hasError = false;
      
      // Create a temporary subscription to test
      final testSubscription = accelerometerEvents.listen(
        (event) {
          receivedEvent = true;
          if (kDebugMode) {
            print('✅ Accelerometer test event received: x=${event.x.toStringAsFixed(2)}, y=${event.y.toStringAsFixed(2)}, z=${event.z.toStringAsFixed(2)}');
          }
        },
        onError: (error) {
          hasError = true;
          if (kDebugMode) {
            print('❌ Accelerometer test error: $error');
          }
        },
      );
      
      // Wait for events or timeout
      int attempts = 0;
      while (!receivedEvent && !hasError && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      
      // Cancel test subscription
      testSubscription.cancel();
      
      if (kDebugMode) {
        if (receivedEvent) {
          print('✅ Accelerometer is working and receiving events');
        } else if (hasError) {
          print('❌ Accelerometer has errors');
        } else {
          print('⚠️ Accelerometer not receiving events (timeout)');
        }
      }
      
      return receivedEvent && !hasError;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking accelerometer: $e');
      }
      return false;
    }
  }

  // Method to manually add a test step for debugging
  void addTestStep() {
    if (kDebugMode) {
      print('🧪 Manually adding a test step...');
    }
    
    try {
      // Manually increment step count for testing
      _deviceStepCount++;
      _consecutiveSteps++;
      _todaySteps = _deviceStepCount;
      _lastDeviceStepTime = DateTime.now();
      _lastUpdated = DateTime.now();
      _isWalking = true;
      
      // Update weekly data
      final now = DateTime.now();
      final weekdayIndex = now.weekday - 1;
      if (weekdayIndex >= 0 && weekdayIndex < _weeklySteps.length) {
        _weeklySteps[weekdayIndex] = _todaySteps;
      }
      
      // Update history and notify
      _ensureHistoryToday();
      _updateHistoryToday();
      _stepsController.add(_todaySteps);
      _checkGoalAndNotify();
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ Test step added! Total: $_todaySteps, Consecutive: $_consecutiveSteps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding test step: $e');
      }
    }
  }

  // Method to manually reset connecting state for debugging
  void resetConnectingState() {
    if (kDebugMode) {
      print('🔄 Manually resetting connecting state...');
    }
    
    _isConnecting = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('✅ Connecting state reset to: $_isConnecting');
    }
  }
}


