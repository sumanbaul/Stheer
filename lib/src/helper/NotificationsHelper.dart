import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

import '../../src/model/Notifications.dart';
import '../../src/model/notificationCategory.dart';
import 'DatabaseHelper.dart';
import 'datetime_ago.dart';
import 'package:timeago/timeago.dart' as timeago;

// Mock Application class for sandbox
class MockApplication {
  final String appName;
  final String packageName;
  final String versionName;
  final int versionCode;
  final String dataDir;
  final bool systemApp;
  final String apkFilePath;
  final int size;
  final Image? icon;

  MockApplication({
    required this.appName,
    required this.packageName,
    required this.versionName,
    required this.versionCode,
    required this.dataDir,
    required this.systemApp,
    required this.apkFilePath,
    required this.size,
    this.icon,
  });
}

class NotificationsHelper {
  static bool started = false;
  static ReceivePort port = ReceivePort();
  static List<NotificationEvent?>? notificationEvent;

  static void _callback(NotificationEvent evt) {
    print("send evt to ui: $evt");
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  static Future<List<Notifications>> initializeDbGetNotificationsToday(
      int day) async {
    // For sandbox, return mock data
    return [
      Notifications(
        title: "Mock WhatsApp Message",
        appTitle: "WhatsApp",
        text: "Hello from sandbox! This is a test notification.",
        message: "New message received",
        packageName: "com.whatsapp",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        createAt: DateTime.now().toString(),
      ),
      Notifications(
        title: "Mock Email",
        appTitle: "Gmail",
        text: "You have a new email in your inbox.",
        message: "New email received",
        packageName: "com.google.android.gm",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        createAt: DateTime.now().toString(),
      ),
      Notifications(
        title: "Mock Instagram Like",
        appTitle: "Instagram",
        text: "Someone liked your post!",
        message: "New activity",
        packageName: "com.instagram.android",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        createAt: DateTime.now().toString(),
      ),
    ];
  }

  static Future<MockApplication?> getCurrentAppWithIcon(String packageName) async {
    // Mock app data for sandbox
    return MockApplication(
      appName: packageName.contains("whatsapp") ? "WhatsApp" : 
               packageName.contains("gmail") ? "Gmail" : 
               packageName.contains("instagram") ? "Instagram" : "Unknown App",
      packageName: packageName,
      versionName: "1.0.0",
      versionCode: 1,
      dataDir: "/mock/data",
      systemApp: false,
      apkFilePath: "/mock/app.apk",
      size: 1000000,
      icon: null, // Mock icon
    );
  }

  static Future<Notifications> onData(NotificationEvent event) async {
    final _event = event;
    final eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
    print(event);
    
    if (eventAppWithIcon != null) {
      if (!eventAppWithIcon.systemApp) {
        if (event.packageName!.contains("skydrive") ||
            (event.packageName!.contains("service")) ||
            (event.packageName!.contains("notifoo")) ||
            (event.packageName!.contains("screenshot")) ||
            (event.packageName!.contains("deskclock")) ||
            (event.packageName!.contains("wellbeing")) ||
            (event.packageName!.contains("weather2")) ||
            (event.packageName!.contains("gallery"))) {
          print(event.packageName);
        } else {
          final Map<String, dynamic> jsonresponse =
              json.decode(event.toString());
          final createatday = event.createAt!.day;
          final today = DateTime.now().day;
          print("Create AT Day: $createatday");

          if (!jsonresponse.containsKey('summaryText') &&
              event.createAt!.day >= today) {
            if (event.text != null) {
              final currentNotification = Notifications(
                title: _event.title,
                appTitle: eventAppWithIcon.appName,
                text: _event.text,
                message: _event.message,
                packageName: _event.packageName,
                timestamp: _event.timestamp,
                createAt: _event.createAt!.toString(),
              );

              // Save to database
              await DatabaseHelper.instance.insertNotification(currentNotification);
              return currentNotification;
            }
          }
        }
      }
    }

    // Return mock notification if no real data
    return Notifications(
      title: "Sandbox Notification",
      appTitle: "Sandbox App",
      text: "This is a sandbox notification for testing",
      message: "Test message",
      packageName: "com.sandbox.app",
      timestamp: DateTime.now().millisecondsSinceEpoch,
      createAt: DateTime.now().toString(),
    );
  }

  static Future<List<NotificationCategory>> getCategoryListFuture(
      List<Notifications> notifications) async {
    final listByPackageName;
    List<NotificationCategory> notificationsByCategory = [];
    final _notifications = notifications;
    if (_notifications.length > 0) {
      listByPackageName = groupBy(_notifications, (Notifications n) {
        return n.packageName.toString();
      });

      if (listByPackageName.length > 0) {
        listByPackageName.forEach((key, value) async {
          // print(value[value.length - 1].createdDate);
          // if (value != null) {
          final MockApplication? _app =
              await (getCurrentAppWithIcon(value[0].packageName));
          //final _length = value.length;
          var dt =
              DateTime.fromMicrosecondsSinceEpoch(value[0].timestamp * 1000);
          NotificationCategory nc = NotificationCategory(
              packageName: _app?.packageName,
              appTitle: _app?.appName,
              appIcon: null, // Remove icon for sandbox
              //tempIcon: Image.memory(_currentApp.icon),
              timestamp: timeago.format(dt),
              message: "You have " +
                  value.length.toString() +
                  " Unread notifications",
              notificationCount: value.length);

          //  NotificationCategory nc2 = NotificationCategory(
          // packageName: value[index].packageName,
          // appTitle: value.,
          // appIcon:
          //     _app is ApplicationWithIcon ? Image.memory(_app.icon) : null,
          // //tempIcon: Image.memory(_currentApp.icon),
          // timestamp: value[0].timestamp,
          // message: "You have " +
          //     value.length.toString() +
          //     " Unread notifications",
          // notificationCount: value.length);

          notificationsByCategory.add(nc);
          // }
        });
      }
      notificationsByCategory
          .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    }
    print(
        "NotificationsHelper -> NotificationsCategory${notificationsByCategory.length}");
    return notificationsByCategory; // as Future<List<NotificationCategory>>;
  }

  static Future<List<Notifications>> initPopulateData(
      List<Notifications> notificationsOfToday) async {
    return notificationsOfToday.isNotEmpty || notificationsOfToday.length > 0
        ? notificationsOfToday
        : await DatabaseHelper.instance.getNotifications(0);
  }

  static Future<bool> redundantNotificationCheck(
      NotificationEvent event) async {
    var getNotificationModel = await DatabaseHelper.instance
        .getNotificationsByPackageToday(event.packageName);

    Future<bool>? entryFlag;

    getNotificationModel.forEach((key) {
      if (key.packageName!.contains(event.packageName!)) {
        if (key.title!.contains(event.title!) &&
            key.text!.contains(event.text!)) {
          entryFlag = Future<bool>.value(true);
          //return Future<bool>.value(true);
        } else {
          entryFlag = Future<bool>.value(false);
        }
      }
    });

    return entryFlag!;
  }

  //this below method will be moved later to a different place
  static buildLoader() {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.white70,
        value: 18.0,
        strokeWidth: 4.0,
      ),
    );
  }

  static buildError(String error) {
    return Text('Error: ' + error);
  }

  static buildNoData() {
    return Text('No Data / default');
  }

  //will be used in future to clear notifications
  Future<void> initClearNotificationsState() async {
    //ClearAllNotifications.clear();
  }
}
