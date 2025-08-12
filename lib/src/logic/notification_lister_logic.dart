import 'dart:async';
// import 'dart:convert';
// import 'dart:isolate';
// import 'dart:ui';

// Removed device_apps import - using native implementation instead
import 'package:flutter/services.dart';
// import 'package:notifoo/src/helper/AppListHelper.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/Notifications.dart';
// import 'package:notifoo/src/model/apps.dart';
import 'package:notifoo/src/model/notification_lister_model.dart';

class NotificationListerPageLogic {
  final NotificationListerModel _model;
  NotificationListerPageLogic(this._model);

  String? flagEntry;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    const EventChannel _eventChannel = EventChannel('com.mindflo.stheer/notifications/events');
    _eventChannel.receiveBroadcastStream().listen((evt) => onData(evt));
    _model.started = true;
  }

  // we must use static method, to handle in background
  // Legacy callback removed

  void onData(dynamic event) async {
    //await getCurrentAppWithIcon(event.packageName);
    print(event);

    //packageName = event.packageName.toString().split('.').last.capitalizeFirstofEach;
    final String? packageName = event['packageName'] as String?;
    final String? title = event['title'] as String?;
    final String? text = event['text'] as String?;
    final int? timestamp = event['timestamp'] as int?;
    final int? createAtMillis = event['createAt'] as int?;

    if ((packageName ?? '').contains("skydrive") ||
        ((packageName ?? '').contains("service")) ||
        // (event.packageName.contains("android")) ||
        (event.packageName!.contains("stheer")) ||
        (event.packageName!.contains("screenshot")) ||
        (event.title!.contains("WhatsApp")) ||
        (event.packageName!.contains("deskclock")) ||
        (event.packageName!.contains("wellbeing")) ||
        (event.packageName!.contains("weather2")) ||
        (event.packageName!.contains("gallery"))) {
      //print(event.packageName);
    } else {
      // var xyz = currentApp as Application;
      //_currentApp = app.then((value) => value) as Application;

      //_currentApp = app as Application;
      _model.packageName = packageName;
      // print("Success Package Found: " + app.packageName);
      //var jsondata2 = json.decode(event.toString());
      // Map<String, dynamic> jsonresponse = json.decode(event.toString());

      //var jsonData = json.decoder.convert(event.toString());
      _model.log.add(event);
      var createatday = DateTime.fromMillisecondsSinceEpoch((createAtMillis ?? timestamp ?? DateTime.now().millisecondsSinceEpoch)).day;
      print("Create AT Day: $createatday");
      var today = new DateTime.now().day;
      print('today: $today');
      //var xx = jsonresponse.containsKey('summaryText');
      if (createatday >= today) {
        //check
        bool redundancy;
        // redundantNotificationCheck(event).then((bool value) {
        //   redundancy = value;
        // });

        if ((text != flagEntry) && text != null) {
          DatabaseHelper.instance.insertNotification(
            Notifications(
              title: title,
              //appTitle: _currentApp.appName,
              // appIcon: _currentApp is ApplicationWithIcon
              //     ? Image.memory(_currentApp.icon)
              //     : null,
              text: text,
              message: null,
              packageName: packageName,
              timestamp: (timestamp ?? DateTime.now().millisecondsSinceEpoch),
              createAt: (createAtMillis ?? DateTime.now().millisecondsSinceEpoch).toString(),
              eventJson: "{}",
              createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
              isDeleted: 0,
            ),
          );
        }
        flagEntry = text;
      } else {
        // # TODO fix here

        // var titleLength = jsonresponse["textLines"].length;

        DatabaseHelper.instance.insertNotification(
          Notifications(
              title: null,
              text: text,
              message: null,
              packageName: packageName,
              timestamp: (timestamp ?? DateTime.now().millisecondsSinceEpoch),
              createAt: (createAtMillis ?? DateTime.now().millisecondsSinceEpoch).toString(),
              eventJson: "{}"),
        );
      }
    }

    // print("Print Notification: $event");
  }

  Future<bool>? redundantNotificationCheck(dynamic event) async {
    var getNotificationModel = await DatabaseHelper.instance
        .getNotificationsByPackageToday(event['packageName']);

    Future<bool>? entryFlag;

    getNotificationModel.forEach((key) {
      if (key.packageName!.contains(event['packageName'] ?? '')) {
        if (key.title!.contains(event['title'] ?? '') &&
            key.text!.contains(event['text'] ?? '')) {
          entryFlag = Future<bool>.value(true);
          //return Future<bool>.value(true);
        } else {
          entryFlag = Future<bool>.value(false);
        }
      }
    });

    return entryFlag!;
  }

  // Apps getCurrentApp(String packageName) {
  //   //Apps app;
  //   Apps app;
  //   if (packageName != "") {
  //     // getCurrentAppWithIcon(packageName);
  //     // app = await DeviceApps.getApp('com.frandroid.app');
  //     AppListHelper().appListData.forEach((element) async {
  //       if (element.packageName == packageName) {
  //         _model.app = await DeviceApps.getApp(packageName);
  //         // _currentApp = app;
  //         //_icon = app.icon;
  //         //Application appxx = app;
  //       }
  //     });
  //   }
  //   return app; // as Application;
  // }

  void startListening() async {
    print("start listening");
    // TODO: Implement native notification listening
    // For now, using the EventChannel approach in initPlatformState
    print("Using EventChannel for notification listening");
  }

  void stopListening() async {
    print("stop listening");
    // TODO: Implement native notification listening stop
    print("Stopping EventChannel notification listening");
  }
}
