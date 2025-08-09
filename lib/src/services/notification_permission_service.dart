import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';

class NotificationPermissionService {
  static final NotificationPermissionService _instance = NotificationPermissionService._internal();
  factory NotificationPermissionService() => _instance;
  NotificationPermissionService._internal();

  bool _hasPermission = false;
  bool _isChecking = false;
  
  // Stream controllers for permission status
  final StreamController<bool> _permissionStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _permissionMessageController = StreamController<String>.broadcast();

  // Getters
  Stream<bool> get permissionStatusStream => _permissionStatusController.stream;
  Stream<String> get permissionMessageStream => _permissionMessageController.stream;
  bool get hasPermission => _hasPermission;
  bool get isChecking => _isChecking;

  static const MethodChannel _methodChannel = MethodChannel('com.mindflo.stheer/notifications/methods');
  static const EventChannel _eventChannel = EventChannel('com.mindflo.stheer/notifications/events');
  static StreamSubscription? _eventSub;

  // Check if notification permission is granted
  Future<bool> checkPermission() async {
    if (_isChecking) return _hasPermission;
    
    _isChecking = true;
    _permissionMessageController.add('Checking notification permission...');
    
    try {
      // Use real plugin permission when available
      bool enabled = false;
      try {
        final res = await _methodChannel.invokeMethod('isNotificationAccessEnabled');
        enabled = res == true;
      } catch (e) {
        enabled = false;
      }
      _hasPermission = enabled;
      _permissionStatusController.add(_hasPermission);
      
      if (_hasPermission) {
        _permissionMessageController.add('Notification access granted');
      } else {
        _permissionMessageController.add('Notification access');
      }
      
      return _hasPermission;
    } catch (e) {
      _hasPermission = false;
      _permissionStatusController.add(false);
      _permissionMessageController.add('Error checking permission: $e');
      return false;
    } finally {
      _isChecking = false;
    }
  }

  // Request notification permission
  Future<bool> requestPermission(BuildContext context) async {
    if (_isChecking) return _hasPermission;
    
    _isChecking = true;
    _permissionMessageController.add('Requesting notification permission...');
    print('Starting permission request...');
    
    try {
      // First check current permission using plugin
      bool currentPermission = _hasPermission;
      print('Current permission status: $currentPermission');
      
      if (currentPermission == true) {
        _hasPermission = true;
        _permissionStatusController.add(true);
        _permissionMessageController.add('Permission already granted');
        return true;
      }
      
      // Show permission request dialog
      final shouldRequest = await _showPermissionDialog(context);
      print('User chose to request: $shouldRequest');
      
      if (shouldRequest) {
        // Try to open settings directly first
        bool settingsOpened = false;
        
        try {
          print('Trying to open notification access settings via method channel...');
          await _methodChannel.invokeMethod('openNotificationAccessSettings');
          settingsOpened = true;
          print('Notification access settings opened successfully');
        } catch (e) {
          print('Plugin openPermissionSettings failed: $e');
          try {
            await AppSettings.openAppSettings();
            settingsOpened = true;
          } catch (e2) {
            print('App settings fallback failed: $e2');
          }
        }
        
        // Show manual instructions if settings couldn't be opened
        if (!settingsOpened) {
          print('Showing manual instructions...');
          await _showManualInstructionsDialog(context);
        }
        
        // Wait a bit and check again
        await Future.delayed(Duration(seconds: 3));
        bool newPermission = false;
        try {
          final res = await _methodChannel.invokeMethod('isNotificationAccessEnabled');
          newPermission = res == true;
        } catch (_) { newPermission = false; }
        print('New permission status: $newPermission');
        
        _hasPermission = newPermission;
        _permissionStatusController.add(_hasPermission);
        
        if (_hasPermission) {
          _permissionMessageController.add('Permission granted successfully!');
        } else {
          _permissionMessageController.add('Permission denied. Please enable manually.');
        }
        
        return _hasPermission;
      } else {
        _permissionMessageController.add('Permission request cancelled');
        return false;
      }
    } catch (e) {
      print('Error in requestPermission: $e');
      _hasPermission = false;
      _permissionStatusController.add(false);
      _permissionMessageController.add('Error requesting permission: $e');
      return false;
    } finally {
      _isChecking = false;
    }
  }

  // Show permission request dialog
  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text('Notification Access'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To capture and manage your notifications, this app needs access to your notification history.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to enable:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                                             '1. Tap "Open Settings"\n'
                       '2. Scroll to "Special app access"\n'
                       '3. Tap "Notification access"\n'
                       '4. Find and enable "FocusFluke"\n'
                       '5. Return to the app\n\n'
                       '⚠️ Note: This is different from "App notifications" permission',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Show permission status widget
  Widget buildPermissionStatusWidget(BuildContext context) {
    return StreamBuilder<bool>(
      stream: permissionStatusStream,
      builder: (context, snapshot) {
        final hasPermission = snapshot.data ?? _hasPermission;
        
        if (hasPermission) {
          return Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Access Enabled',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Capturing notifications in the background',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Access',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'Enable to capture live notifications',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          print('Enable button pressed - requesting permission...');
                          await requestPermission(context);
                        } catch (e) {
                          print('Error in enable button: $e');
                          // Fallback: try to open settings directly
                          try {
                            await AppSettings.openAppSettings();
                          } catch (e2) {
                            print('Fallback also failed: $e2');
                          }
                        }
                      },
                      child: Text('Enable'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    SizedBox(width: 8),
                                         ElevatedButton(
                       onPressed: () async {
                         print('Test button pressed - opening settings directly...');
                         try {
                           // Try to open notification access settings directly
                           final Uri notificationSettingsUri = Uri.parse('android-app://com.android.settings/.notification.NotificationAccessSettings');
                           if (await canLaunchUrl(notificationSettingsUri)) {
                             await launchUrl(notificationSettingsUri);
                           } else {
                             // Fallback to app settings
                             await AppSettings.openAppSettings();
                           }
                         } catch (e) {
                           print('Test button failed: $e');
                           // Final fallback
                           try {
                             await AppSettings.openAppSettings();
                           } catch (e2) {
                             print('Final fallback also failed: $e2');
                           }
                         }
                       },
                       child: Text('Settings'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.blue,
                         foregroundColor: Colors.white,
                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                       ),
                     ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Show manual instructions dialog
  Future<void> _showManualInstructionsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text('Manual Setup Required'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please follow these steps to enable notification access:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step-by-step instructions:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                                             '1. Open Android Settings\n'
                       '2. Scroll down to "Apps"\n'
                       '3. Tap "Special app access"\n'
                       '4. Tap "Notification access"\n'
                       '5. Find "FocusFluke" in the list\n'
                       '6. Toggle the switch to ON\n'
                       '7. Return to this app\n\n'
                       '⚠️ IMPORTANT: This is NOT the same as "App notifications" permission. '
                       'You need "Notification access" which allows the app to read your notification history.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('I\'ve enabled it'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Try to open settings again
                AppSettings.openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Dispose resources
  void dispose() {
    _permissionStatusController.close();
    _permissionMessageController.close();
  }
} 
