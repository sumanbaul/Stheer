import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/src/model/apps.dart';
import 'package:notifoo/src/model/app_block_schedule.dart';
import 'package:notifoo/src/model/usage_analytics.dart';

class AppUsageService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('com.mindflo.stheer/usage');
  static const MethodChannel _blockingChannel = MethodChannel('com.mindflo.stheer/app_blocking');

  // Current state
  bool _hasPermission = false;
  bool _isInitialized = false;
  List<Apps> _installedApps = [];
  List<AppBlockSchedule> _blockSchedules = [];
  UsageAnalytics? _todayAnalytics;
  WeeklyAnalytics? _weeklyAnalytics;
  MonthlyAnalytics? _monthlyAnalytics;
  
  // App categorization rules
  static const Map<String, String> _defaultAppCategories = {
    // Social Media
    'com.instagram.android': 'Social',
    'com.facebook.katana': 'Social',
    'com.twitter.android': 'Social',
    'com.whatsapp': 'Social',
    'com.tencent.mm': 'Social',
    'com.snapchat.android': 'Social',
    'com.linkedin.android': 'Social',
    'com.reddit.frontpage': 'Social',
    
    // Entertainment
    'com.google.android.youtube': 'Entertainment',
    'com.netflix.mediaclient': 'Entertainment',
    'com.spotify.music': 'Entertainment',
    'com.amazon.avod.thirdpartyclient': 'Entertainment',
    'com.discord': 'Entertainment',
    'com.zhiliaoapp.musically': 'Entertainment',
    
    // Gaming
    'com.activision.callofduty.shooter': 'Gaming',
    'com.epicgames.fortnite': 'Gaming',
    'com.roblox.client': 'Gaming',
    'com.mojang.minecraftpe': 'Gaming',
    'com.nianticlabs.pokemongo': 'Gaming',
    
    // Productivity
    'com.microsoft.office.word': 'Productivity',
    'com.microsoft.office.excel': 'Productivity',
    'com.microsoft.office.powerpoint': 'Productivity',
    'com.google.android.apps.docs.editors.docs': 'Productivity',
    'com.google.android.apps.docs.editors.sheets': 'Productivity',
    'com.google.android.apps.docs.editors.slides': 'Productivity',
    'com.dropbox.android': 'Productivity',
    'com.evernote': 'Productivity',
    
    // Work
    'com.slack': 'Work',
    'com.microsoft.teams': 'Work',
    'com.zoom.us': 'Work',
    'com.skype.raider': 'Work',
    'com.asana.app': 'Work',
    'com.trello': 'Work',
    
    // Education
    'org.khanacademy.android': 'Education',
    'com.duolingo': 'Education',
    'com.coursera.android': 'Education',
    'com.udacity.android': 'Education',
    
    // Health & Fitness
    'com.strava': 'Health',
    'com.fitbit.FitbitMobile': 'Health',
    'com.myfitnesspal.android': 'Health',
    'com.nike.ntc': 'Health',
    'com.underarmour.mapmyrun': 'Health',
  };

  // System app patterns to filter out
  static const List<String> _systemAppPatterns = [
    'com.android.',
    'com.google.android.apps.',
    'com.google.android.gms.',
    'com.google.android.packageinstaller',
    'com.google.android.setupwizard',
    'com.android.settings',
    'com.android.systemui',
    'com.android.phone',
    'com.android.contacts',
    'com.android.calendar',
    'com.android.camera',
    'com.android.gallery',
    'com.android.music',
    'com.android.vending',
    'com.android.providers.',
    'com.android.server.',
    'android',
    'system',
    'com.qualcomm.',
    'com.mediatek.',
    'com.samsung.',
    'com.huawei.',
    'com.xiaomi.',
    'com.oneplus.',
    'com.oppo.',
    'com.vivo.',
    'com.realme.',
    'com.iqoo.',
    'com.meizu.',
    'com.zte.',
    'com.lenovo.',
    'com.asus.',
    'com.htc.',
    'com.lg.',
    'com.sony.',
    'com.motorola.',
    'com.nokia.',
    'com.blackberry.',
    'com.bbm.',
    'com.rim.',
    'com.htc.',
    'com.acer.',
    'com.alcatel.',
    'com.bq.',
    'com.coolpad.',
    'com.gionee.',
    'com.honor.',
    'com.leeco.',
    'com.letv.',
    'com.meitu.',
    'com.nubia.',
    'com.oneplus.',
    'com.oppo.',
    'com.realme.',
    'com.vivo.',
    'com.xiaomi.',
    'com.zte.',
  ];

  // Getters
  bool get hasPermission => _hasPermission;
  bool get isInitialized => _isInitialized;
  List<Apps> get installedApps => List.unmodifiable(_installedApps);
  List<Apps> get userApps => _installedApps.where((app) => !_isSystemApp(app)).toList();
  List<AppBlockSchedule> get blockSchedules => List.unmodifiable(_blockSchedules);
  UsageAnalytics? get todayAnalytics => _todayAnalytics;
  WeeklyAnalytics? get weeklyAnalytics => _weeklyAnalytics;
  MonthlyAnalytics? get monthlyAnalytics => _monthlyAnalytics;

  // Helper method to check if an app is a system app
  bool _isSystemApp(Apps app) {
    if (app.packageName == null) return true;
    
    final packageName = app.packageName!.toLowerCase();
    
    // Check if it matches any system app pattern
    for (final pattern in _systemAppPatterns) {
      if (packageName.startsWith(pattern.toLowerCase())) {
        return true;
      }
    }
    
    // Check if it's marked as a system app
    if (app.isSystemApp == true) {
      return true;
    }
    
    // Check if it's a system app based on package name characteristics
    if (packageName.contains('system') || 
        packageName.contains('android') ||
        packageName.contains('google') ||
        packageName.contains('qualcomm') ||
        packageName.contains('mediatek') ||
        packageName.contains('samsung') ||
        packageName.contains('huawei') ||
        packageName.contains('xiaomi') ||
        packageName.contains('oneplus') ||
        packageName.contains('oppo') ||
        packageName.contains('vivo') ||
        packageName.contains('realme') ||
        packageName.contains('iqoo') ||
        packageName.contains('meizu') ||
        packageName.contains('zte') ||
        packageName.contains('lenovo') ||
        packageName.contains('asus') ||
        packageName.contains('htc') ||
        packageName.contains('lg') ||
        packageName.contains('sony') ||
        packageName.contains('motorola') ||
        packageName.contains('nokia') ||
        packageName.contains('blackberry') ||
        packageName.contains('bbm') ||
        packageName.contains('rim') ||
        packageName.contains('acer') ||
        packageName.contains('alcatel') ||
        packageName.contains('bq') ||
        packageName.contains('coolpad') ||
        packageName.contains('gionee') ||
        packageName.contains('honor') ||
        packageName.contains('leeco') ||
        packageName.contains('letv') ||
        packageName.contains('meitu') ||
        packageName.contains('nubia')) {
      return true;
    }
    
    return false;
  }

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    if (kDebugMode) {
      print('🚀 Initializing AppUsageService...');
    }
    
    try {
      // Check permissions
      _hasPermission = await hasUsagePermission();
      
      if (_hasPermission) {
        // Load installed apps
        await _loadInstalledApps();
        
        // Load block schedules
        await _loadBlockSchedules();
        
        // Load analytics
        await _loadAnalytics();
        
        // Start monitoring
        _startUsageMonitoring();
        
        _isInitialized = true;
        
        if (kDebugMode) {
          print('✅ AppUsageService initialized successfully');
          print('📱 Loaded ${_installedApps.length} apps');
          print('⏰ Loaded ${_blockSchedules.length} block schedules');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing AppUsageService: $e');
      }
    }
    
    notifyListeners();
  }

  // Permission management
  Future<bool> hasUsagePermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod('hasUsageAccess');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> openPermissionSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } catch (_) {}
  }

  // App management
  Future<void> _loadInstalledApps() async {
    try {
      final apps = await _channel.invokeMethod('getInstalledApps');
      _installedApps = (apps as List).map((e) => Apps.fromMap(e)).toList();
      
      // Categorize apps
      _categorizeApps();
      
      if (kDebugMode) {
        print('📱 Loaded ${_installedApps.length} installed apps');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading installed apps: $e');
      }
      _installedApps = [];
    }
  }

  void _categorizeApps() {
    for (final app in _installedApps) {
      if (app.packageName != null) {
        // Check default categories first
        if (_defaultAppCategories.containsKey(app.packageName)) {
          app.appType = _defaultAppCategories[app.packageName]!;
        } else {
          // Use AI-based categorization or default to Neutral
          app.appType = _categorizeAppByPackageName(app.packageName!);
        }
      }
    }
  }

  String _categorizeAppByPackageName(String packageName) {
    final lowerPackage = packageName.toLowerCase();
    
    // System apps
    if (lowerPackage.startsWith('com.android') || 
        lowerPackage.startsWith('android') ||
        lowerPackage.startsWith('com.google.android')) {
      return 'System';
    }
    
    // Social media patterns
    if (lowerPackage.contains('social') || 
        lowerPackage.contains('chat') ||
        lowerPackage.contains('messenger') ||
        lowerPackage.contains('dating')) {
      return 'Social';
    }
    
    // Entertainment patterns
    if (lowerPackage.contains('video') || 
        lowerPackage.contains('music') ||
        lowerPackage.contains('stream') ||
        lowerPackage.contains('tv') ||
        lowerPackage.contains('movie')) {
      return 'Entertainment';
    }
    
    // Gaming patterns
    if (lowerPackage.contains('game') || 
        lowerPackage.contains('play') ||
        lowerPackage.contains('fun')) {
      return 'Gaming';
    }
    
    // Productivity patterns
    if (lowerPackage.contains('work') || 
        lowerPackage.contains('business') ||
        lowerPackage.contains('office') ||
        lowerPackage.contains('task') ||
        lowerPackage.contains('project')) {
      return 'Productivity';
    }
    
    // Education patterns
    if (lowerPackage.contains('learn') || 
        lowerPackage.contains('study') ||
        lowerPackage.contains('course') ||
        lowerPackage.contains('school') ||
        lowerPackage.contains('university')) {
      return 'Education';
    }
    
    // Health patterns
    if (lowerPackage.contains('health') || 
        lowerPackage.contains('fitness') ||
        lowerPackage.contains('workout') ||
        lowerPackage.contains('diet') ||
        lowerPackage.contains('meditation')) {
      return 'Health';
    }
    
    return 'Neutral';
  }

  // Analytics methods
  Future<void> _loadAnalytics() async {
    try {
      // Load today's analytics
      _todayAnalytics = await _getTodayAnalytics();
      
      // Load weekly analytics
      _weeklyAnalytics = await _getWeeklyAnalytics();
      
      // Load monthly analytics
      _monthlyAnalytics = await _getMonthlyAnalytics();
      
      if (kDebugMode) {
        print('📊 Analytics loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading analytics: $e');
      }
    }
  }

  Future<UsageAnalytics> _getTodayAnalytics() async {
    try {
      final summary = await _channel.invokeMethod('getDailySummary');
      final apps = await _channel.invokeMethod('getMostUsedAppsDetailed', {'limit': 50});
      
      // Process app usage data
      final appUsageMinutes = <String, int>{};
      final categoryUsageMinutes = <String, int>{};
      final appLaunchEvents = <AppLaunchEvent>[];
      
      for (final app in apps) {
        final packageName = app['packageName'] as String;
        final minutes = app['minutes'] as int;
        
        appUsageMinutes[packageName] = minutes;
        
        // Get app category
        final appInfo = _installedApps.firstWhere(
          (a) => a.packageName == packageName,
          orElse: () => Apps(packageName: packageName, appType: 'Neutral'),
        );
        
        final category = appInfo.appType ?? 'Neutral';
        categoryUsageMinutes[category] = (categoryUsageMinutes[category] ?? 0) + minutes;
        
        // Create app launch event
        appLaunchEvents.add(AppLaunchEvent(
          packageName: packageName,
          timestamp: DateTime.now(),
          durationMinutes: minutes,
          category: category,
        ));
      }
      
      // Calculate focus score
      final focusScore = _calculateFocusScore(categoryUsageMinutes);
      
      return UsageAnalytics(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        totalScreenTimeMinutes: summary['screenTimeMinutes'] ?? 0,
        totalPickups: summary['pickups'] ?? 0,
        totalAppLaunches: appLaunchEvents.length,
        appUsageMinutes: appUsageMinutes,
        categoryUsageMinutes: categoryUsageMinutes,
        pickupEvents: [], // Will be populated by native code
        appLaunchEvents: appLaunchEvents,
        focusScore: focusScore,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting today analytics: $e');
      }
      
      // Return default analytics
      return UsageAnalytics(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        totalScreenTimeMinutes: 0,
        totalPickups: 0,
        totalAppLaunches: 0,
        appUsageMinutes: {},
        categoryUsageMinutes: {},
        pickupEvents: [],
        appLaunchEvents: [],
        focusScore: 0.5,
      );
    }
  }

  Future<WeeklyAnalytics> _getWeeklyAnalytics() async {
    try {
      final weeklyMinutes = await _channel.invokeMethod('getWeeklyMinutes');
      
      // Create weekly analytics from daily data
      final dailyAnalytics = <UsageAnalytics>[];
      int totalScreenTime = 0;
      int totalPickups = 0;
      double totalFocusScore = 0.0;
      
      for (int i = 0; i < weeklyMinutes.length; i++) {
        final date = DateTime.now().subtract(Duration(days: 6 - i));
        final minutes = (weeklyMinutes[i] as num).toInt();
        
        totalScreenTime += minutes;
        
        dailyAnalytics.add(UsageAnalytics(
          id: date.millisecondsSinceEpoch.toString(),
          date: date,
          totalScreenTimeMinutes: minutes,
          totalPickups: 0, // Will be populated by native code
          totalAppLaunches: 0,
          appUsageMinutes: {},
          categoryUsageMinutes: {},
          pickupEvents: [],
          appLaunchEvents: [],
          focusScore: 0.5,
        ));
        
        totalFocusScore += 0.5;
      }
      
      return WeeklyAnalytics(
        weekStart: DateTime.now().subtract(const Duration(days: 6)),
        dailyAnalytics: dailyAnalytics,
        totalScreenTimeMinutes: totalScreenTime,
        totalPickups: totalPickups,
        averageFocusScore: totalFocusScore / dailyAnalytics.length,
        totalAppUsageMinutes: {},
        totalCategoryUsageMinutes: {},
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting weekly analytics: $e');
      }
      
      return WeeklyAnalytics(
        weekStart: DateTime.now().subtract(const Duration(days: 6)),
        dailyAnalytics: [],
        totalScreenTimeMinutes: 0,
        totalPickups: 0,
        averageFocusScore: 0.5,
        totalAppUsageMinutes: {},
        totalCategoryUsageMinutes: {},
      );
    }
  }

  Future<MonthlyAnalytics> _getMonthlyAnalytics() async {
    // For now, return a basic monthly analytics
    // This will be enhanced with actual monthly data collection
    return MonthlyAnalytics(
      monthStart: DateTime(DateTime.now().year, DateTime.now().month, 1),
      weeklyAnalytics: [],
      totalScreenTimeMinutes: 0,
      totalPickups: 0,
      averageFocusScore: 0.5,
      totalAppUsageMinutes: {},
      totalCategoryUsageMinutes: {},
    );
  }

  double _calculateFocusScore(Map<String, int> categoryUsageMinutes) {
    final productiveCategories = ['Work', 'Education', 'Productivity', 'Health'];
    final distractingCategories = ['Social', 'Entertainment', 'Gaming'];
    
    int productiveMinutes = 0;
    int distractingMinutes = 0;
    
    for (final entry in categoryUsageMinutes.entries) {
      if (productiveCategories.contains(entry.key)) {
        productiveMinutes += entry.value;
      } else if (distractingCategories.contains(entry.key)) {
        distractingMinutes += entry.value;
      }
    }
    
    final totalMinutes = productiveMinutes + distractingMinutes;
    if (totalMinutes == 0) return 0.5;
    
    return productiveMinutes / totalMinutes;
  }

  // App blocking methods
  Future<void> _loadBlockSchedules() async {
    try {
      // Load from local storage or database
      // For now, create some default schedules
      _blockSchedules = _createDefaultSchedules();
      
      if (kDebugMode) {
        print('⏰ Loaded ${_blockSchedules.length} block schedules');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading block schedules: $e');
      }
      _blockSchedules = [];
    }
  }

  List<AppBlockSchedule> _createDefaultSchedules() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return [
      // Deep Work Schedule (9 AM - 12 PM, Mon-Fri)
      AppBlockSchedule(
        id: 'deep_work_morning',
        name: 'Deep Work Morning',
        description: 'Focus on important work without distractions',
        appPackageNames: [],
        categories: ['Social', 'Entertainment', 'Gaming'],
        startTime: DateTime(today.year, today.month, today.day, 9, 0),
        endTime: DateTime(today.year, today.month, today.day, 12, 0),
        daysOfWeek: [1, 2, 3, 4, 5], // Mon-Fri
        focusMode: 'Deep Work',
        createdAt: now,
      ),
      
      // Study Time (2 PM - 5 PM, Mon-Fri)
      AppBlockSchedule(
        id: 'study_time_afternoon',
        name: 'Study Time Afternoon',
        description: 'Dedicated time for learning and education',
        appPackageNames: [],
        categories: ['Social', 'Entertainment', 'Gaming'],
        startTime: DateTime(today.year, today.month, today.day, 14, 0),
        endTime: DateTime(today.year, today.month, today.day, 17, 0),
        daysOfWeek: [1, 2, 3, 4, 5], // Mon-Fri
        focusMode: 'Study',
        createdAt: now,
      ),
      
      // Sleep Mode (10 PM - 6 AM, Daily)
      AppBlockSchedule(
        id: 'sleep_mode',
        name: 'Sleep Mode',
        description: 'Reduce blue light and distractions before bed',
        appPackageNames: [],
        categories: ['Social', 'Entertainment', 'Gaming'],
        startTime: DateTime(today.year, today.month, today.day, 22, 0),
        endTime: DateTime(today.year, today.month, today.day, 6, 0),
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7], // Daily
        focusMode: 'Sleep',
        createdAt: now,
      ),
    ];
  }

  // Block apps immediately
  Future<bool> blockAppsNow({
    required List<String> appPackageNames,
    required List<String> categories,
    int durationMinutes = 60,
  }) async {
    try {
      if (kDebugMode) {
        print('🚫 Blocking apps: $appPackageNames, categories: $categories for $durationMinutes minutes');
      }
      
      // Get apps to block based on categories
      final appsToBlock = <String>[];
      if (categories.isNotEmpty) {
        for (final app in _installedApps) {
          if (app.appType != null && categories.contains(app.appType)) {
            if (app.packageName != null) {
              appsToBlock.add(app.packageName!);
            }
          }
        }
      }
      
      // Add specific package names
      appsToBlock.addAll(appPackageNames);
      
      if (kDebugMode) {
        print('📱 Apps to block: $appsToBlock');
      }
      
      if (appsToBlock.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No apps found to block');
        }
        return false;
      }
      
      // Create temporary block schedule
      final tempSchedule = AppBlockSchedule(
        id: 'temp_block_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Temporary Block',
        description: 'Apps blocked for focus time',
        appPackageNames: appsToBlock,
        categories: categories,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(minutes: durationMinutes)),
        daysOfWeek: [DateTime.now().weekday],
        isRecurring: false,
        focusMode: 'Custom',
        createdAt: DateTime.now(),
      );
      
      // Add to schedules
      _blockSchedules.add(tempSchedule);
      
      // Update app states immediately for UI feedback
      _updateAppBlockStates(appsToBlock, categories, true);
      notifyListeners();
      
      // Try to notify native code to block apps
      try {
        final result = await _blockingChannel.invokeMethod('blockApps', {
          'packageNames': appsToBlock,
          'categories': categories,
          'durationMinutes': durationMinutes,
        });
        
        if (result == true) {
          if (kDebugMode) {
            print('✅ Apps blocked successfully via native code');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Native blocking failed, but apps marked as blocked in UI');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Native blocking error: $e, but apps marked as blocked in UI');
        }
      }
      
      // Schedule unblocking
      Timer(Duration(minutes: durationMinutes), () {
        unblockApps(
          appPackageNames: appsToBlock,
          categories: categories,
        );
      });
      
      if (kDebugMode) {
        print('✅ Apps blocked successfully for $durationMinutes minutes');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error blocking apps: $e');
      }
      return false;
    }
  }

  // Unblock apps
  Future<bool> unblockApps({
    required List<String> appPackageNames,
    required List<String> categories,
  }) async {
    try {
      if (kDebugMode) {
        print('🔓 Unblocking apps: $appPackageNames, categories: $categories');
      }
      
      // Remove temporary blocks
      _blockSchedules.removeWhere((schedule) => 
        schedule.focusMode == 'Custom' && 
        schedule.isCurrentlyActive
      );
      
      // Notify native code to unblock apps
      final result = await _blockingChannel.invokeMethod('unblockApps', {
        'packageNames': appPackageNames,
        'categories': categories,
      });
      
      if (result == true) {
        if (kDebugMode) {
          print('✅ Apps unblocked successfully');
        }
        
        // Update app states
        _updateAppBlockStates(appPackageNames, categories, false);
        
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to block apps');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error unblocking apps: $e');
      }
      return false;
    }
  }

  void _updateAppBlockStates(List<String> packageNames, List<String> categories, bool blocked) {
    for (final app in _installedApps) {
      if (packageNames.contains(app.packageName) || 
          (app.appType != null && categories.contains(app.appType))) {
        app.isBlocked = blocked;
        app.lastBlockedTime = blocked ? DateTime.now() : null;
      }
    }
  }

  // Schedule management
  Future<void> addBlockSchedule(AppBlockSchedule schedule) async {
    _blockSchedules.add(schedule);
    notifyListeners();
    
    if (kDebugMode) {
      print('⏰ Added block schedule: ${schedule.name}');
    }
  }

  Future<void> updateBlockSchedule(AppBlockSchedule schedule) async {
    final index = _blockSchedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      _blockSchedules[index] = schedule;
      notifyListeners();
      
      if (kDebugMode) {
        print('⏰ Updated block schedule: ${schedule.name}');
      }
    }
  }

  Future<void> deleteBlockSchedule(String scheduleId) async {
    _blockSchedules.removeWhere((s) => s.id == scheduleId);
    notifyListeners();
    
    if (kDebugMode) {
      print('⏰ Deleted block schedule: $scheduleId');
    }
  }

  // Get currently blocked apps
  List<Apps> getCurrentlyBlockedApps() {
    return _installedApps.where((app) => app.isBlocked == true).toList();
  }

  // Get apps by category
  List<Apps> getAppsByCategory(String category) {
    return _installedApps.where((app) => app.appType == category).toList();
  }

  // Get all categories
  List<String> getAllCategories() {
    final categories = <String>{};
    for (final app in _installedApps) {
      if (app.appType != null) {
        categories.add(app.appType!);
      }
    }
    return categories.toList()..sort();
  }

  // Check if any blocking schedule is currently active
  bool get isAnyBlockingActive {
    return _blockSchedules.any((schedule) => schedule.isCurrentlyActive);
  }

  // Get active blocking schedule
  AppBlockSchedule? get activeBlockingSchedule {
    try {
      return _blockSchedules.firstWhere((schedule) => schedule.isCurrentlyActive);
    } catch (_) {
      return null;
    }
  }

  // Start usage monitoring
  void _startUsageMonitoring() {
    // Set up periodic analytics refresh
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_hasPermission && _isInitialized) {
        _refreshAnalytics();
      }
    });
    
    // Set up periodic app blocking check
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_hasPermission && _isInitialized) {
        _checkAndExecuteBlockSchedules();
      }
    });
  }

  Future<void> _refreshAnalytics() async {
    try {
      _todayAnalytics = await _getTodayAnalytics();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing analytics: $e');
      }
    }
  }

  Future<void> _checkAndExecuteBlockSchedules() async {
    for (final schedule in _blockSchedules) {
      if (schedule.isCurrentlyActive && schedule.isActive) {
        // Execute blocking
        await _executeBlockSchedule(schedule);
      }
    }
  }

  Future<void> _executeBlockSchedule(AppBlockSchedule schedule) async {
    try {
      if (kDebugMode) {
        print('⏰ Executing block schedule: ${schedule.name}');
      }
      
      // Get apps to block based on categories
      final appsToBlock = <String>[];
      for (final app in _installedApps) {
        if (schedule.categories.contains(app.appType)) {
          appsToBlock.add(app.packageName!);
        }
      }
      
      // Add specific apps
      appsToBlock.addAll(schedule.appPackageNames);
      
      if (appsToBlock.isNotEmpty) {
        await blockAppsNow(
          appPackageNames: appsToBlock,
          categories: schedule.categories,
          durationMinutes: schedule.durationMinutes,
        );
        
        // Note: We can't modify lastExecuted as it's final, so we'll create a new schedule
        final updatedSchedule = schedule.copyWith(
          lastExecuted: DateTime.now()
        );
        updateBlockSchedule(updatedSchedule);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error executing block schedule: $e');
      }
    }
  }

  // Legacy methods for backward compatibility
  Future<Map<String, dynamic>> getDailySummary() async {
    if (_todayAnalytics != null) {
      return {
        'screenTimeMinutes': _todayAnalytics!.totalScreenTimeMinutes,
        'pickups': _todayAnalytics!.totalPickups,
        'focusScore': _todayAnalytics!.focusScore,
        'productivityScore': _todayAnalytics!.getProductivityScore(),
      };
    }
    
    if (!Platform.isAndroid) return {'screenTimeMinutes': 0, 'pickups': 0};
    try {
      final res = await _channel.invokeMethod('getDailySummary');
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {'screenTimeMinutes': 0, 'pickups': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getMostUsedApps({int limit = 10}) async {
    if (_todayAnalytics != null) {
      final topApps = _todayAnalytics!.getTopAppsByUsage().take(limit).toList();
      return topApps.map((entry) {
        final app = _installedApps.firstWhere(
          (a) => a.packageName == entry.key,
          orElse: () => Apps(packageName: entry.key, appType: 'Neutral'),
        );
        
        return {
          'packageName': entry.key,
          'label': app.appName ?? entry.key,
          'minutes': entry.value,
          'type': app.appType ?? 'Neutral',
          'color': _getCategoryColor(app.appType ?? 'Neutral'),
          'iconBase64': app.iconBase64,
          'isBlocked': app.isBlocked ?? false,
        };
      }).toList();
    }
    
    if (!Platform.isAndroid) return [];
    try {
      final list = await _channel.invokeMethod('getMostUsedAppsDetailed', {'limit': limit});
      return (list as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<int>> getWeeklyMinutes() async {
    if (_weeklyAnalytics != null) {
      return _weeklyAnalytics!.getDailyBreakdown();
    }
    
    if (!Platform.isAndroid) return List<int>.filled(7, 0);
    try {
      final list = await _channel.invokeMethod('getWeeklyMinutes');
      return (list as List).map((e) => (e as int)).toList();
    } catch (_) {
      return List<int>.filled(7, 0);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Productive':
      case 'Work':
      case 'Education':
        return Colors.green;
      case 'Distracting':
      case 'Social':
      case 'Entertainment':
        return Colors.red;
      case 'Gaming':
        return Colors.orange;
      case 'Health':
        return Colors.blue;
      case 'System':
        return Colors.grey;
      default:
        return Colors.purple;
    }
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}


