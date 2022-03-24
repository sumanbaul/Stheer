import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

import '../model/Notifications.dart';
import '../model/notificationCategory.dart';
import 'DatabaseHelper.dart';

class NotificationsHelper {
  static bool started = false;
  static ReceivePort port = ReceivePort();
  static List<NotificationEvent?>? notificationEvent;

  // static Future<void> initPlatformState() async {
  //   NotificationsListener.initialize(callbackHandle: _callback);

  //   // this can fix restart<debug> can't handle error
  //   IsolateNameServer.removePortNameMapping("_listener_");
  //   IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
  //   //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
  //   port.listen((message) => onData(message));

  //   // don't use the default receivePort
  //   // NotificationsListener.receivePort.listen((evt) => onData(evt));

  //   var isR = await (NotificationsListener.isRunning as Future<bool>);
  //   print("""Service is ${!isR ? "not " : ""}aleary running""");
  // }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    print(
      "send evt to ui: $evt",
    );
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  // static List<NotificationEvent?>? onData(NotificationEvent? event) {
  //   print("Print Notification: $event");
  //   notificationEvent!.add(event);
  //   return notificationEvent;
  // }

  static Future<List<Notifications>> initializeDbGetNotificationsToday() async {
    DatabaseHelper.instance.initializeDatabase();
    return await DatabaseHelper.instance.getNotifications(0);
  }

  static Future<Application?> getCurrentAppWithIcon(String packageName) async {
    return await DeviceApps.getApp(packageName, true);
  }

  //critical function below
//This function is triggered on receiving of data from port
  static Future<Notifications> onData(
      NotificationEvent event, String flagEntry) async {
    var eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
    print(event); // this is needed for later
    Notifications? _notification;
    if (!eventAppWithIcon!.systemApp) {
      if (event.packageName!.contains("skydrive") ||
          (event.packageName!.contains("service")) ||
          // (event.packageName.contains("android")) ||
          (event.packageName!.contains("notifoo")) ||
          (event.packageName!.contains("screenshot")) ||
          (event.title!.contains("WhatsApp")) ||
          (event.packageName!.contains("deskclock")) ||
          (event.packageName!.contains("wellbeing")) ||
          (event.packageName!.contains("weather2")) ||
          (event.packageName!.contains("gallery"))) {
        print(event.packageName);
      } else {
        // print("Success Package Found: " + app.packageName);
        //var jsondata2 = json.decode(event.toString());
        Map<String, dynamic> jsonresponse = json.decode(event.toString());

        var createatday = event.createAt!.day;
        print("Create AT Day: $createatday");
        var today = new DateTime.now().day;
        print('today: $today');
        //var xx = jsonresponse.containsKey('summaryText');
        if (!jsonresponse.containsKey('summaryText') &&
            event.createAt!.day >= today) {
          if ((event.text != flagEntry) && event.text != null) {
            var currentNotification = Notifications(
                title: event.title,
                appTitle: eventAppWithIcon.appName,
                // appIcon: _currentApp is ApplicationWithIcon
                //     ? Image.memory(_currentApp.icon)
                //     : null,
                text: event.text,
                message: event.message,
                packageName: event.packageName,
                timestamp: event.timestamp,
                createAt: event.createAt!.millisecondsSinceEpoch.toString(),
                eventJson: event.toString(),
                createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
                isDeleted: 0);

            //add current notification to this Global Variable(getNotificationsOfToday)
            //inside context

            await DatabaseHelper.instance
                .insertNotification(currentNotification);

            //initClearNotificationsState();
            flagEntry = event.text.toString();
            _notification = currentNotification;
          } else {
            // # TODO fix here

            // var titleLength = jsonresponse["textLines"].length;

            var currentNotification = Notifications(
                title: jsonresponse["textLines"] ??
                    jsonresponse["textLines"] as String?,
                text: event.text,
                message: event.message,
                packageName: event.packageName,
                timestamp: event.timestamp,
                createAt: event.createAt!.millisecondsSinceEpoch.toString(),
                eventJson: event.toString(),
                createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
                isDeleted: 0
                // infoText: jsonData["text"],
                // showWhen: 1,
                // subText: jsonData["text"],
                // timestamp: event.timestamp.toString(),
                // packageName: jsonData["packageName"],
                // text: jsonData["text"],
                // summaryText: jsonData["summaryText"] ?? ""
                );

            //initClearNotificationsState();

            //print("Setstate getting hit: $currentNotification");
            _notification = currentNotification;
            await DatabaseHelper.instance
                .insertNotification(currentNotification);
          }
        }
      }
    }
    return _notification!;
  }

  static Future<List<NotificationCategory>> getCategoryListFuture(
      int selectedDay, Future<List<Notifications>> notifications) async {
    var listByPackageName;
    var _notifications = await notifications;
    if (_notifications.length > 0) {
      listByPackageName = groupBy(_notifications, (Notifications n) {
        return n.packageName.toString();
      });
    }
    List<NotificationCategory> notificationsByCategory = [];

    if (listByPackageName.length > 0) {
      listByPackageName.forEach((key, value) async {
        // print(value[value.length - 1].createdDate);
        var _app = await (getCurrentAppWithIcon(value[0].packageName));

        var nc = NotificationCategory(
            packageName: _app?.packageName,
            appTitle: _app?.appName,
            appIcon:
                _app is ApplicationWithIcon ? Image.memory(_app.icon) : null,
            //tempIcon: Image.memory(_currentApp.icon),
            timestamp: value[0].timestamp,
            message:
                "You have " + value.length.toString() + " Unread notifications",
            notificationCount: value.length);

        notificationsByCategory.add(nc);
      });
    }
    notificationsByCategory
        .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    //_nc = notificationsByCategory;
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
      ),
    );
  }

  static buildError() {
    return Text('Error');
  }

  static buildNoData() {
    return Text('No Data / default');
  }
}
