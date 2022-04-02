import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

import '../model/Notifications.dart';
import '../model/notificationCategory.dart';
import 'DatabaseHelper.dart';
import 'datetime_ago.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  static Future<List<Notifications>> initializeDbGetNotificationsToday(
      int day) async {
    // DatabaseHelper.instance.initializeDatabase();
    return await DatabaseHelper.instance.getNotifications(day);
  }

  static Future<Application?> getCurrentAppWithIcon(String packageName) async {
    return await DeviceApps.getApp(packageName, true);
  }

  //critical function below
//This function is triggered on receiving of data from port
  //static Future<Notifications> onData(
  static Future<Notifications> onData(NotificationEvent event) async {
    final _event = event;
    final eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
    print(event); // this is needed for later
    final Notifications _notification;
    if (!eventAppWithIcon!.systemApp) {
      if (event.packageName!.contains("skydrive") ||
          (event.packageName!.contains("service")) ||
          // (event.packageName.contains("android")) ||
          (event.packageName!.contains("notifoo")) ||
          (event.packageName!.contains("screenshot")) ||
          // (event.title ??  event.title!.contains("WhatsApp")) ||  //needs to be checked
          (event.packageName!.contains("deskclock")) ||
          (event.packageName!.contains("wellbeing")) ||
          (event.packageName!.contains("weather2")) ||
          (event.packageName!.contains("gallery"))) {
        print(event.packageName);
      } else {
        final Map<String, dynamic> jsonresponse = json.decode(event.toString());
        final createatday = event.createAt!.day;
        final today = DateTime.now().day;
        print("Create AT Day: $createatday");

        if (!jsonresponse.containsKey('summaryText') &&
            event.createAt!.day >= today) {
          // if ((event.text != flagEntry) && event.text != null) {
          if (event.text != null) {
            final currentNotification = Notifications(
              title: _event.title,
              appTitle: eventAppWithIcon.appName,
              text: _event.text,
              message: _event.message,
              packageName: _event.packageName,
              timestamp: _event.timestamp,
              createAt: _event.createAt!.millisecondsSinceEpoch.toString(),
              eventJson: _event.toString(),
              createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
              isDeleted: 0,
            );

            _notification = currentNotification;

            await DatabaseHelper.instance
                .insertNotification(currentNotification);
            // flagEntry = event.text.toString();
            print("$_notification.appTitle");
            return currentNotification;
          } else {
            // # TODO: Change for cleaning notifications better

            // var titleLength = jsonresponse["textLines"].length;

            final currentNotification = Notifications(
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

            _notification = currentNotification;
            await DatabaseHelper.instance
                .insertNotification(currentNotification);
            return _notification;
          }
        }
      }
    }
    _notification = new Notifications();
    return _notification;
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
          final Application? _app =
              await (getCurrentAppWithIcon(value[0].packageName));
          //final _length = value.length;
          var dt =
              DateTime.fromMicrosecondsSinceEpoch(value[0].timestamp * 1000);
          NotificationCategory nc = NotificationCategory(
              packageName: _app?.packageName,
              appTitle: _app?.appName,
              appIcon:
                  _app is ApplicationWithIcon ? Image.memory(_app.icon) : null,
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
