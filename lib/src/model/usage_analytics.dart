import 'dart:convert';

class UsageAnalytics {
  final String id;
  final DateTime date;
  final int totalScreenTimeMinutes;
  final int totalPickups;
  final int totalAppLaunches;
  final Map<String, int> appUsageMinutes; // packageName -> minutes
  final Map<String, int> categoryUsageMinutes; // category -> minutes
  final List<PickupEvent> pickupEvents;
  final List<AppLaunchEvent> appLaunchEvents;
  final double focusScore;
  final Map<String, dynamic>? metadata;

  UsageAnalytics({
    required this.id,
    required this.date,
    required this.totalScreenTimeMinutes,
    required this.totalPickups,
    required this.totalAppLaunches,
    required this.appUsageMinutes,
    required this.categoryUsageMinutes,
    required this.pickupEvents,
    required this.appLaunchEvents,
    required this.focusScore,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'totalScreenTimeMinutes': totalScreenTimeMinutes,
      'totalPickups': totalPickups,
      'totalAppLaunches': totalAppLaunches,
      'appUsageMinutes': jsonEncode(appUsageMinutes),
      'categoryUsageMinutes': jsonEncode(categoryUsageMinutes),
      'pickupEvents': jsonEncode(pickupEvents.map((e) => e.toMap()).toList()),
      'appLaunchEvents': jsonEncode(appLaunchEvents.map((e) => e.toMap()).toList()),
      'focusScore': focusScore,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory UsageAnalytics.fromMap(Map<String, dynamic> map) {
    return UsageAnalytics(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      totalScreenTimeMinutes: map['totalScreenTimeMinutes'],
      totalPickups: map['totalPickups'],
      totalAppLaunches: map['totalAppLaunches'],
      appUsageMinutes: Map<String, int>.from(
        jsonDecode(map['appUsageMinutes']),
      ),
      categoryUsageMinutes: Map<String, int>.from(
        jsonDecode(map['categoryUsageMinutes']),
      ),
      pickupEvents: (jsonDecode(map['pickupEvents']) as List)
          .map((e) => PickupEvent.fromMap(e))
          .toList(),
      appLaunchEvents: (jsonDecode(map['appLaunchEvents']) as List)
          .map((e) => AppLaunchEvent.fromMap(e))
          .toList(),
      focusScore: map['focusScore']?.toDouble() ?? 0.0,
      metadata: map['metadata'] != null 
          ? jsonDecode(map['metadata']) 
          : null,
    );
  }

  // Get hourly breakdown for the day
  List<int> getHourlyBreakdown() {
    final hourly = List<int>.filled(24, 0);
    
    for (final event in appLaunchEvents) {
      final hour = event.timestamp.hour;
      hourly[hour] += event.durationMinutes;
    }
    
    return hourly;
  }

  // Get top apps by usage
  List<MapEntry<String, int>> getTopAppsByUsage() {
    final sorted = appUsageMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  // Get top categories by usage
  List<MapEntry<String, int>> getTopCategoriesByUsage() {
    final sorted = categoryUsageMinutes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  // Calculate productivity score based on app categories
  double getProductivityScore() {
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
}

class PickupEvent {
  final DateTime timestamp;
  final int durationMinutes;
  final String? triggerApp; // App that triggered the pickup

  PickupEvent({
    required this.timestamp,
    required this.durationMinutes,
    this.triggerApp,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'triggerApp': triggerApp,
    };
  }

  factory PickupEvent.fromMap(Map<String, dynamic> map) {
    return PickupEvent(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      durationMinutes: map['durationMinutes'],
      triggerApp: map['triggerApp'],
    );
  }
}

class AppLaunchEvent {
  final String packageName;
  final DateTime timestamp;
  final int durationMinutes;
  final String? category;
  final bool? wasBlocked;

  AppLaunchEvent({
    required this.packageName,
    required this.timestamp,
    required this.durationMinutes,
    this.category,
    this.wasBlocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'category': category,
      'wasBlocked': wasBlocked,
    };
  }

  factory AppLaunchEvent.fromMap(Map<String, dynamic> map) {
    return AppLaunchEvent(
      packageName: map['packageName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      durationMinutes: map['durationMinutes'],
      category: map['category'],
      wasBlocked: map['wasBlocked'],
    );
  }
}

// Weekly and Monthly Analytics
class WeeklyAnalytics {
  final DateTime weekStart;
  final List<UsageAnalytics> dailyAnalytics;
  final int totalScreenTimeMinutes;
  final int totalPickups;
  final double averageFocusScore;
  final Map<String, int> totalAppUsageMinutes;
  final Map<String, int> totalCategoryUsageMinutes;

  WeeklyAnalytics({
    required this.weekStart,
    required this.dailyAnalytics,
    required this.totalScreenTimeMinutes,
    required this.totalPickups,
    required this.averageFocusScore,
    required this.totalAppUsageMinutes,
    required this.totalCategoryUsageMinutes,
  });

  // Get daily breakdown for the week
  List<int> getDailyBreakdown() {
    final daily = List<int>.filled(7, 0);
    for (int i = 0; i < dailyAnalytics.length; i++) {
      daily[i] = dailyAnalytics[i].totalScreenTimeMinutes;
    }
    return daily;
  }

  // Get average daily screen time
  double getAverageDailyScreenTime() {
    if (dailyAnalytics.isEmpty) return 0.0;
    return totalScreenTimeMinutes / dailyAnalytics.length;
  }

  // Get total screen time for the week
  int getTotalScreenTime() {
    return totalScreenTimeMinutes;
  }

  // Get total pickups for the week
  int getTotalPickups() {
    return totalPickups;
  }
}

class MonthlyAnalytics {
  final DateTime monthStart;
  final List<WeeklyAnalytics> weeklyAnalytics;
  final int totalScreenTimeMinutes;
  final int totalPickups;
  final double averageFocusScore;
  final Map<String, int> totalAppUsageMinutes;
  final Map<String, int> totalCategoryUsageMinutes;

  MonthlyAnalytics({
    required this.monthStart,
    required this.weeklyAnalytics,
    required this.totalScreenTimeMinutes,
    required this.totalPickups,
    required this.averageFocusScore,
    required this.totalAppUsageMinutes,
    required this.totalCategoryUsageMinutes,
  });

  // Get weekly breakdown for the month
  List<int> getWeeklyBreakdown() {
    final weekly = <int>[];
    for (final week in weeklyAnalytics) {
      weekly.add(week.totalScreenTimeMinutes);
    }
    return weekly;
  }

  // Get average weekly screen time
  double getAverageWeeklyScreenTime() {
    if (weeklyAnalytics.isEmpty) return 0.0;
    return totalScreenTimeMinutes / weeklyAnalytics.length;
  }
}
