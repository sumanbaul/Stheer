import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'User_Database';

  static const String kNotificationsEnabled = 'notifications_enabled';
  static const String kSoundEnabled = 'sound_enabled';
  static const String kVibrationEnabled = 'vibration_enabled';
  static const String kVoiceEnabled = 'voice_commands_enabled';
  static const String kCalendarEnabled = 'calendar_sync_enabled';
  static const String kWidgetsEnabled = 'widgets_enabled';
  static const String kLanguage = 'language';
  static const String kTheme = 'theme'; // 'System' | 'Light' | 'Dark'
  static const String kTimerDuration = 'timer_duration';
  static const String kBreakDuration = 'break_duration';

  Box get _box => Hive.box(_boxName);

  bool getBool(String key, {bool defaultValue = false}) => _box.get(key, defaultValue: defaultValue) as bool;
  String getString(String key, {String defaultValue = ''}) => _box.get(key, defaultValue: defaultValue) as String;
  double getDouble(String key, {double defaultValue = 0.0}) {
    final v = _box.get(key);
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return defaultValue;
  }

  Future<void> setBool(String key, bool value) async => _box.put(key, value);
  Future<void> setString(String key, String value) async => _box.put(key, value);
  Future<void> setDouble(String key, double value) async => _box.put(key, value);

  Future<void> saveAll({
    required bool notificationsEnabled,
    required bool soundEnabled,
    required bool vibrationEnabled,
    required bool voiceEnabled,
    required bool calendarEnabled,
    required bool widgetsEnabled,
    required String language,
    required String theme,
    required double timerDuration,
    required double breakDuration,
  }) async {
    await _box.putAll({
      kNotificationsEnabled: notificationsEnabled,
      kSoundEnabled: soundEnabled,
      kVibrationEnabled: vibrationEnabled,
      kVoiceEnabled: voiceEnabled,
      kCalendarEnabled: calendarEnabled,
      kWidgetsEnabled: widgetsEnabled,
      kLanguage: language,
      kTheme: theme,
      kTimerDuration: timerDuration,
      kBreakDuration: breakDuration,
    });
  }
}


