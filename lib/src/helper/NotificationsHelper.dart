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
    String appName = "Unknown App";
    IconData appIcon = Icons.apps;
    
    if (packageName.contains("whatsapp")) {
      appName = "WhatsApp";
      appIcon = Icons.chat;
    } else if (packageName.contains("gmail") || packageName.contains("google.android.gm")) {
      appName = "Gmail";
      appIcon = Icons.mail;
    } else if (packageName.contains("instagram")) {
      appName = "Instagram";
      appIcon = Icons.camera_alt;
    } else if (packageName.contains("facebook")) {
      appName = "Facebook";
      appIcon = Icons.facebook;
    } else if (packageName.contains("twitter") || packageName.contains("x")) {
      appName = "Twitter";
      appIcon = Icons.flutter_dash;
    } else if (packageName.contains("youtube")) {
      appName = "YouTube";
      appIcon = Icons.play_circle;
    } else if (packageName.contains("telegram")) {
      appName = "Telegram";
      appIcon = Icons.send;
    } else if (packageName.contains("discord")) {
      appName = "Discord";
      appIcon = Icons.games;
    } else if (packageName.contains("slack")) {
      appName = "Slack";
      appIcon = Icons.work;
    } else if (packageName.contains("linkedin")) {
      appName = "LinkedIn";
      appIcon = Icons.business;
    } else if (packageName.contains("reddit")) {
      appName = "Reddit";
      appIcon = Icons.forum;
    } else if (packageName.contains("spotify")) {
      appName = "Spotify";
      appIcon = Icons.music_note;
    } else if (packageName.contains("netflix")) {
      appName = "Netflix";
      appIcon = Icons.movie;
    } else if (packageName.contains("uber")) {
      appName = "Uber";
      appIcon = Icons.local_taxi;
    } else if (packageName.contains("doordash")) {
      appName = "DoorDash";
      appIcon = Icons.delivery_dining;
    } else if (packageName.contains("amazon")) {
      appName = "Amazon";
      appIcon = Icons.shopping_cart;
    } else if (packageName.contains("ebay")) {
      appName = "eBay";
      appIcon = Icons.store;
    } else if (packageName.contains("paypal")) {
      appName = "PayPal";
      appIcon = Icons.payment;
    } else if (packageName.contains("venmo")) {
      appName = "Venmo";
      appIcon = Icons.account_balance_wallet;
    } else if (packageName.contains("bank") || packageName.contains("chase")) {
      appName = "Bank App";
      appIcon = Icons.account_balance;
    } else if (packageName.contains("weather")) {
      appName = "Weather";
      appIcon = Icons.cloud;
    } else if (packageName.contains("calendar")) {
      appName = "Calendar";
      appIcon = Icons.calendar_today;
    } else if (packageName.contains("clock") || packageName.contains("alarm")) {
      appName = "Clock";
      appIcon = Icons.access_time;
    } else if (packageName.contains("camera")) {
      appName = "Camera";
      appIcon = Icons.camera_alt;
    } else if (packageName.contains("gallery") || packageName.contains("photos")) {
      appName = "Gallery";
      appIcon = Icons.photo_library;
    } else if (packageName.contains("maps") || packageName.contains("google.maps")) {
      appName = "Maps";
      appIcon = Icons.map;
    } else if (packageName.contains("drive") || packageName.contains("google.drive")) {
      appName = "Google Drive";
      appIcon = Icons.folder;
    } else if (packageName.contains("dropbox")) {
      appName = "Dropbox";
      appIcon = Icons.cloud_queue;
    } else if (packageName.contains("zoom")) {
      appName = "Zoom";
      appIcon = Icons.video_call;
    } else if (packageName.contains("teams")) {
      appName = "Microsoft Teams";
      appIcon = Icons.groups;
    } else if (packageName.contains("skype")) {
      appName = "Skype";
      appIcon = Icons.video_camera_front;
    } else if (packageName.contains("chrome") || packageName.contains("browser")) {
      appName = "Browser";
      appIcon = Icons.language;
    } else if (packageName.contains("settings")) {
      appName = "Settings";
      appIcon = Icons.settings;
    } else if (packageName.contains("phone") || packageName.contains("dialer")) {
      appName = "Phone";
      appIcon = Icons.phone;
    } else if (packageName.contains("messages") || packageName.contains("sms")) {
      appName = "Messages";
      appIcon = Icons.sms;
    } else if (packageName.contains("contacts")) {
      appName = "Contacts";
      appIcon = Icons.contacts;
    } else if (packageName.contains("calculator")) {
      appName = "Calculator";
      appIcon = Icons.calculate;
    } else if (packageName.contains("notes") || packageName.contains("memo")) {
      appName = "Notes";
      appIcon = Icons.note;
    } else if (packageName.contains("reminder") || packageName.contains("todo")) {
      appName = "Reminders";
      appIcon = Icons.checklist;
    } else if (packageName.contains("health") || packageName.contains("fitness")) {
      appName = "Health";
      appIcon = Icons.favorite;
    } else if (packageName.contains("game") || packageName.contains("play")) {
      appName = "Games";
      appIcon = Icons.games;
    } else if (packageName.contains("news")) {
      appName = "News";
      appIcon = Icons.article;
    } else if (packageName.contains("shopping") || packageName.contains("store")) {
      appName = "Shopping";
      appIcon = Icons.shopping_bag;
    } else if (packageName.contains("food") || packageName.contains("restaurant")) {
      appName = "Food";
      appIcon = Icons.restaurant;
    } else if (packageName.contains("travel") || packageName.contains("booking")) {
      appName = "Travel";
      appIcon = Icons.flight;
    } else if (packageName.contains("education") || packageName.contains("learning")) {
      appName = "Education";
      appIcon = Icons.school;
    } else if (packageName.contains("finance") || packageName.contains("money")) {
      appName = "Finance";
      appIcon = Icons.account_balance_wallet;
    } else if (packageName.contains("productivity") || packageName.contains("office")) {
      appName = "Productivity";
      appIcon = Icons.work;
    } else if (packageName.contains("entertainment") || packageName.contains("media")) {
      appName = "Entertainment";
      appIcon = Icons.movie;
    } else if (packageName.contains("social") || packageName.contains("chat")) {
      appName = "Social";
      appIcon = Icons.people;
    } else if (packageName.contains("utility") || packageName.contains("tool")) {
      appName = "Utility";
      appIcon = Icons.build;
    } else if (packageName.contains("lifestyle") || packageName.contains("wellness")) {
      appName = "Lifestyle";
      appIcon = Icons.spa;
    } else if (packageName.contains("sports") || packageName.contains("fitness")) {
      appName = "Sports";
      appIcon = Icons.sports_soccer;
    } else if (packageName.contains("music") || packageName.contains("audio")) {
      appName = "Music";
      appIcon = Icons.music_note;
    } else if (packageName.contains("video") || packageName.contains("streaming")) {
      appName = "Video";
      appIcon = Icons.video_library;
    } else if (packageName.contains("photo") || packageName.contains("image")) {
      appName = "Photos";
      appIcon = Icons.photo;
    } else if (packageName.contains("document") || packageName.contains("file")) {
      appName = "Documents";
      appIcon = Icons.description;
    } else if (packageName.contains("security") || packageName.contains("vpn")) {
      appName = "Security";
      appIcon = Icons.security;
    } else if (packageName.contains("backup") || packageName.contains("cloud")) {
      appName = "Backup";
      appIcon = Icons.backup;
    } else if (packageName.contains("system") || packageName.contains("android")) {
      appName = "System";
      appIcon = Icons.android;
    } else {
      // Try to derive app name from package name
      final parts = packageName.split('.');
      if (parts.length > 1) {
        appName = parts.last.split('_').map((part) => 
          part.substring(0, 1).toUpperCase() + part.substring(1)
        ).join(' ');
        appIcon = Icons.apps;
      }
    }
    
    return MockApplication(
      appName: appName, 
      packageName: packageName, 
      versionName: "1.0.0",
      versionCode: 1,
      dataDir: "/mock/data",
      systemApp: false,
      apkFilePath: "/mock/app.apk",
      size: 1000000,
      icon: null
    );
  }

  static Future<Notifications?> onData(NotificationEvent event) async {
    final _event = event;
    final eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
    
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
          // print(event.packageName); // Removed excessive logging
        } else {
          final createatday = event.createAt!.day;
          final today = DateTime.now().day;
          // print("Create AT Day: $createatday"); // Removed excessive logging

          if (event.createAt!.day >= today) {
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

    // Return null if no real notification was processed
    return null;
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
        for (var entry in listByPackageName.entries) {
          final key = entry.key;
          final value = entry.value;
          
          if (value.isNotEmpty) {
            final MockApplication? _app =
                await (getCurrentAppWithIcon(value[0].packageName));
            
            var dt =
                DateTime.fromMicrosecondsSinceEpoch(value[0].timestamp * 1000);
            
            NotificationCategory nc = NotificationCategory(
                packageName: _app?.packageName,
                appTitle: _app?.appName,
                appIcon: _app?.icon, // Use real app icon
                timestamp: timeago.format(dt),
                message: "You have " +
                    value.length.toString() +
                    " Unread notifications",
                notificationCount: value.length);

            notificationsByCategory.add(nc);
          }
        }
      }
      notificationsByCategory
          .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    }
    return notificationsByCategory;
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
