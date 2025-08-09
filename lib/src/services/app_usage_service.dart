import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class AppUsageService {
  static const MethodChannel _channel = MethodChannel('com.mindflo.stheer/usage');

  Future<bool> hasPermission() async {
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

  Future<Map<String, dynamic>> getDailySummary() async {
    if (!Platform.isAndroid) return {'screenTimeMinutes': 0, 'pickups': 0};
    try {
      final res = await _channel.invokeMethod('getDailySummary');
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {'screenTimeMinutes': 0, 'pickups': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getMostUsedApps({int limit = 10}) async {
    if (!Platform.isAndroid) return [];
    try {
      final list = await _channel.invokeMethod('getMostUsedApps', {'limit': limit});
      return (list as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }
}


