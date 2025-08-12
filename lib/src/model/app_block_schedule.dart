import 'dart:convert';

class AppBlockSchedule {
  final String id;
  final String name;
  final String description;
  final List<String> appPackageNames; // Apps to block
  final List<String> categories; // App categories to block
  final DateTime startTime;
  final DateTime endTime;
  final List<int> daysOfWeek; // 1=Monday, 7=Sunday
  final bool isActive;
  final bool isRecurring;
  final String? focusMode; // 'Deep Work', 'Study', 'Sleep', 'Custom'
  final Map<String, dynamic>? customSettings;
  final DateTime createdAt;
  final DateTime? lastExecuted;

  AppBlockSchedule({
    required this.id,
    required this.name,
    required this.description,
    required this.appPackageNames,
    required this.categories,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.isActive = true,
    this.isRecurring = true,
    this.focusMode,
    this.customSettings,
    required this.createdAt,
    this.lastExecuted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'appPackageNames': appPackageNames.join(','),
      'categories': categories.join(','),
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'daysOfWeek': daysOfWeek.join(','),
      'isActive': isActive ? 1 : 0,
      'isRecurring': isRecurring ? 1 : 0,
      'focusMode': focusMode,
      'customSettings': customSettings != null ? jsonEncode(customSettings) : null,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastExecuted': lastExecuted?.millisecondsSinceEpoch,
    };
  }

  factory AppBlockSchedule.fromMap(Map<String, dynamic> map) {
    return AppBlockSchedule(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      appPackageNames: map['appPackageNames']?.split(',') ?? [],
      categories: map['categories']?.split(',') ?? [],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      daysOfWeek: map['daysOfWeek']?.split(',').map((e) => int.parse(e)).toList() ?? [],
      isActive: map['isActive'] == 1,
      isRecurring: map['isRecurring'] == 1,
      focusMode: map['focusMode'],
      customSettings: map['customSettings'] != null 
          ? jsonDecode(map['customSettings']) 
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastExecuted: map['lastExecuted'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastExecuted']) 
          : null,
    );
  }

  AppBlockSchedule copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? appPackageNames,
    List<String>? categories,
    DateTime? startTime,
    DateTime? endTime,
    List<int>? daysOfWeek,
    bool? isActive,
    bool? isRecurring,
    String? focusMode,
    Map<String, dynamic>? customSettings,
    DateTime? createdAt,
    DateTime? lastExecuted,
  }) {
    return AppBlockSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      appPackageNames: appPackageNames ?? this.appPackageNames,
      categories: categories ?? this.categories,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      isRecurring: isRecurring ?? this.isRecurring,
      focusMode: focusMode ?? this.focusMode,
      customSettings: customSettings ?? this.customSettings,
      createdAt: createdAt ?? this.createdAt,
      lastExecuted: lastExecuted ?? this.lastExecuted,
    );
  }

  // Check if schedule should be active now
  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    // Check if today is in the schedule
    if (!daysOfWeek.contains(currentDay)) return false;
    
    // Check if current time is within the schedule
    final currentTime = CustomTimeOfDay.fromDateTime(now);
    final startTimeOfDay = CustomTimeOfDay.fromDateTime(startTime);
    final endTimeOfDay = CustomTimeOfDay.fromDateTime(endTime);
    
    return currentTime.isAfter(startTimeOfDay) && currentTime.isBefore(endTimeOfDay);
  }

  // Get duration in minutes
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Get next execution time
  DateTime? get nextExecutionTime {
    if (!isRecurring) return null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Find next day in schedule
    for (int i = 1; i <= 7; i++) {
      final checkDay = today.add(Duration(days: i));
      if (daysOfWeek.contains(checkDay.weekday)) {
        return DateTime(
          checkDay.year,
          checkDay.month,
          checkDay.day,
          startTime.hour,
          startTime.minute,
        );
      }
    }
    return null;
  }
}

// Helper class for CustomTimeOfDay operations (renamed to avoid conflicts)
class CustomTimeOfDay {
  final int hour;
  final int minute;

  CustomTimeOfDay({required this.hour, required this.minute});

  factory CustomTimeOfDay.fromDateTime(DateTime dateTime) {
    return CustomTimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  bool isAfter(CustomTimeOfDay other) {
    if (hour > other.hour) return true;
    if (hour < other.hour) return false;
    return minute > other.minute;
  }

  bool isBefore(CustomTimeOfDay other) {
    if (hour < other.hour) return true;
    if (hour > other.hour) return false;
    return minute < other.minute;
  }

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
