import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  bool _isInitialized = false;

  // Notification channels
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _habitChannel = AndroidNotificationChannel(
    'habit_reminders',
    'Habit Reminders',
    description: 'Reminders for daily habits',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _taskChannel = AndroidNotificationChannel(
    'task_reminders',
    'Task Reminders',
    description: 'Reminders for tasks and deadlines',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _focusChannel = AndroidNotificationChannel(
    'focus_sessions',
    'Focus Sessions',
    description: 'Pomodoro timer notifications',
    importance: Importance.low,
  );

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      
      // Request permission for iOS
      if (Platform.isIOS) {
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        _saveTokenToFirestore(token);
      });

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check for initial notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      print('Push notification service initialized successfully');
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_habitChannel);
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_taskChannel);
    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_focusChannel);
  }

  Future<void> _saveTokenToFirestore(String token) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(message);
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    
    // Handle different notification types
    String? type = message.data['type'];
    String? targetId = message.data['targetId'];
    
    switch (type) {
      case 'habit_reminder':
        // Navigate to habits page
        break;
      case 'task_reminder':
        // Navigate to tasks page
        break;
      case 'focus_session':
        // Navigate to timer page
        break;
      case 'productivity_insight':
        // Navigate to analytics page
        break;
    }
  }

  Future<void> _onNotificationTapped(NotificationResponse response) async {
    print('Local notification tapped: ${response.payload}');
    
    // Handle local notification tap
    if (response.payload != null) {
      Map<String, dynamic> data = json.decode(response.payload!);
      String? type = data['type'];
      String? targetId = data['targetId'];
      
      // Handle navigation based on notification type
      switch (type) {
        case 'habit_reminder':
          // Navigate to habits page
          break;
        case 'task_reminder':
          // Navigate to tasks page
          break;
        case 'focus_session':
          // Navigate to timer page
          break;
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            color: Colors.blue,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: json.encode(message.data),
      );
    }
  }

  // Public helper: show a simple local notification immediately
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
    AndroidNotificationChannel? channel,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          (channel ?? _channel).id,
          (channel ?? _channel).name,
          channelDescription: (channel ?? _channel).description,
          icon: '@mipmap/ic_launcher',
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload != null ? json.encode(payload) : null,
    );
  }

  // Schedule local notifications
  Future<void> scheduleHabitReminder(String habitId, String habitName, int hour, int minute) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      habitId.hashCode,
      'Habit Reminder',
      'Time to complete: $habitName',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _habitChannel.id,
          _habitChannel.name,
          channelDescription: _habitChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'type': 'habit_reminder',
        'habitId': habitId,
        'habitName': habitName,
      }),
    );
  }

  Future<void> scheduleTaskReminder(String taskId, String taskName, DateTime deadline) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      taskId.hashCode,
      'Task Reminder',
      'Deadline approaching: $taskName',
      tz.TZDateTime.from(deadline.subtract(Duration(hours: 1)), tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannel.id,
          _taskChannel.name,
          channelDescription: _taskChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'type': 'task_reminder',
        'taskId': taskId,
        'taskName': taskName,
      }),
    );
  }

  Future<void> scheduleFocusSessionReminder(int sessionNumber, Duration duration) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      sessionNumber,
      'Focus Session Complete',
      'Great job! Take a ${duration.inMinutes}-minute break.',
      tz.TZDateTime.now(tz.local).add(duration),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusChannel.id,
          _focusChannel.name,
          channelDescription: _focusChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode({
        'type': 'focus_session',
        'sessionNumber': sessionNumber,
      }),
    );
  }

  // Send push notification to specific user
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String? fcmToken = userDoc.get('fcmToken');
      if (fcmToken == null) return;

      // Send notification via Firebase Cloud Functions
      // This would typically be done through a Cloud Function
      // For now, we'll just log it
      print('Sending push notification to user $userId');
      print('Title: $title');
      print('Body: $body');
      print('Type: $type');
      print('Data: $data');
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  // Cancel scheduled notifications
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get FCM token
  String? get fcmToken => _fcmToken;

  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  
  // Handle background message
  // You can perform background tasks here
}

// Helper function to get next instance of time
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }
  
  return scheduledDate;
} 
