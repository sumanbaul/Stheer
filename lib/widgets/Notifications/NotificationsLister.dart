import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/apps.dart';
import 'package:notifoo/widgets/Notifications/list_category.dart';
import 'package:notifoo/widgets/Notifications/notification_category.dart';
import 'package:notifoo/widgets/buttons/appActionButton.dart';
import 'package:device_apps/device_apps.dart';
import 'package:notifoo/model/Notifications.dart';

//Initialize singleton
//#todo
//final AppListHelper appsListHelper = new AppListHelper();

class NotificationsLister extends StatefulWidget {
  NotificationsLister({Key? key}) : super(key: key);

  @override
  _NotificationsListerState createState() => _NotificationsListerState();
}

class _NotificationsListerState extends State<NotificationsLister> {
  List<NotificationEvent> _log = []; // check what this variable is doing??????

  //List<Apps> _apps = AppListHelper().appListData;

  Application? _currentApp;
  Image? _icon;

  bool appsLoaded = false;

  String?
      flagEntry; //this variable need to check later, after notfications logic is cleaned

  bool started = false;
  bool _loading = false;
  String? packageName = "";

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();
    DatabaseHelper.instance.initializeDatabase();

    super.initState();
  }

  // we must use static method, to handle in background
  static void _callback(NotificationEvent evt) {
    // print(
    //   "send evt to ui: $evt",
    // );
    final SendPort? send =
        IsolateNameServer.lookupPortByName("_notifoolistener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //appBar: Topbar.getTopbar(widget.title),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Container(
        height: 800,
        padding: EdgeInsets.zero,
        // child: NotificationCatgoryList(
        //   key: UniqueKey(),
        // ), //getNotificationListBody(),

        child: NotificationsCategoryWidget(title: 'Stheer'),
      ),
      floatingActionButton: FloatingActionButton(
        //backgroundColor: Color(0xffeeaeca),
        splashColor: Color(0xff94bbe9),
        hoverColor: Color(0xffeeaeca),
        focusColor: Color(0xff94bbe9),
        onPressed: started ? stopListening : startListening,
        tooltip: 'Start/Stop sensing',
        child: _loading
            ? Icon(Icons.hourglass_bottom_outlined)
            : (started ? Icon(Icons.close) : Icon(Icons.play_arrow)),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_notifoolistener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_notifoolistener_");
    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) => onData(message));

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isServiceRunning = await (NotificationsListener.isRunning);
    print("""Service is ${!isServiceRunning! ? "not " : ""}aleary running""");

    setState(() {
      started = isServiceRunning;
    });
  }

  Apps? getCurrentApp(String packageName) {
    //Apps app;
    Apps? app;
    if (packageName != "") {
      // getCurrentAppWithIcon(packageName);
      // app = await DeviceApps.getApp('com.frandroid.app');
      //_currentApp = await DeviceApps.getApp(packageName);
      _currentApp = (() async {
        await DeviceApps.getApp(packageName);
      })() as Application;

      // AppListHelper().appListData.forEach((element) async {
      //   if (element.packageName == packageName) {
      //     _currentApp = await DeviceApps.getApp(packageName);
      //     // _currentApp = app;
      //     //_icon = app.icon;
      //     //Application appxx = app;
      //   }
      // });
    }
    return app; // as Application;
  }

  Future<Application?> getCurrentAppWithIcon(String packageName) async {
    _currentApp = await DeviceApps.getApp(packageName);
    return _currentApp;
  }

//critical function below
//This function is triggered on receiving of data from port
  void onData(NotificationEvent event) async {
    var eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
    print(event); // this is needed for later

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
        //print(event.packageName);
      } else {
        //_currentApp = app as Application;
        packageName = event.packageName;
        // print("Success Package Found: " + app.packageName);
        //var jsondata2 = json.decode(event.toString());
        Map<String, dynamic> jsonresponse = json.decode(event.toString());

        _log.add(event);
        var createatday = event.createAt!.day;
        print("Create AT Day: $createatday");
        var today = new DateTime.now().day;
        print('today: $today');
        //var xx = jsonresponse.containsKey('summaryText');
        if (!jsonresponse.containsKey('summaryText') &&
            event.createAt!.day >= today) {
          //check
          bool redundancy;
          // redundantNotificationCheck(event)!.then((bool value) {
          //   redundancy = value;
          // });

          if ((event.text != flagEntry) && event.text != null) {
            DatabaseHelper.instance.insertNotification(
              Notifications(
                  title: event.title,
                  appTitle: _currentApp!.appName,
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
                  isDeleted: 0
                  // infoText: jsonData["text"],
                  // showWhen: 1,
                  // subText: jsonData["text"],
                  // timestamp: event.timestamp.toString(),
                  // packageName: jsonData["packageName"],
                  // text: jsonData["text"],
                  // summaryText: jsonData["summaryText"] ?? ""
                  ),
            );

            //initClearNotificationsState();
            flagEntry = event.text;
          } else {
            // # TODO fix here

            // var titleLength = jsonresponse["textLines"].length;

            DatabaseHelper.instance.insertNotification(
              Notifications(
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
                  ),
            );

            //initClearNotificationsState();
          }
        }
      }

      setState(() {});
      // if (!event.packageName.contains("example") ||
      //     !event.packageName.contains("skydrive") ||
      //     !event.packageName.contains("skydrive") ||
      //     !event.packageName.contains("xiaomi")) {
      //   // TODO: fix bug
      //   // NotificationsListener.promoteToForeground("");
      // }
      // print("Print Notification: $event");
    }
  }

  Future<bool>? redundantNotificationCheck(NotificationEvent event) async {
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

  void startListening() async {
    print("start listening");

    var hasPermission = await (NotificationsListener.hasPermission);
    if (!hasPermission!) {
      print("no permission, so open settings");
      NotificationsListener.openPermissionSettings();
      return;
    }

    var isR = await (NotificationsListener.isRunning);

    if (!isR!) {
      await NotificationsListener.startService(
        title: "Notifoo listening",
        description: "Let's scrape the notifactions...",
        subTitle: "Service",
        //foreground: AppButtonAction(),
      );
      setState(() {
        started = true;
        _loading = false;
      });
    }
  }

  void stopListening() async {
    print("stop listening");
    await NotificationsListener.stopService();

    setState(() {
      started = false;
      _loading = false;
    });
  }

  Future<void> initClearNotificationsState() async {
    //ClearAllNotifications.clear();
  }

  // getNotificationListBody() {
  //   return FutureBuilder<List<Notifications>>(
  //     future: DatabaseHelper.instance.getNotifications(0),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         //var packageName = (Notifications element) => element.packageName;
  //         // DateTime expiryAsDateTime = DateTime.parse(snapshot.data[]);
  //         // var snapshotelement = snapshot.data;
  //         // print("Snapshot data: $snapshot.data");
  //         return StickyGroupedListView<Notifications, String>(
  //           //padding: EdgeInsets.only(bottom: 80),
  //           //itemScrollController: x ,
  //           physics: BouncingScrollPhysics(
  //             parent: AlwaysScrollableScrollPhysics(),
  //           ),
  //           elements: snapshot.data,
  //           order: StickyGroupedListOrder.DESC,
  //           groupBy: (Notifications element) => element.packageName,
  //           groupComparator: (String value1, String value2) =>
  //               value2.compareTo(value1),
  //           itemComparator: (Notifications element1, Notifications element2) =>
  //               element1.packageName.compareTo(element2.packageName),
  //           floatingHeader: true,
  //           groupSeparatorBuilder: (Notifications element) => Container(
  //             height: 50,
  //             child: Align(
  //               alignment: Alignment.center,
  //               child: Container(
  //                 width: 120,
  //                 decoration: BoxDecoration(
  //                   color: Colors.black87,
  //                   border: Border.all(
  //                     color: Color(0xff94bbe9),
  //                   ),
  //                   borderRadius: BorderRadius.all(Radius.circular(20.0)),
  //                 ),
  //                 child: Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     //'${getCurrentApp(element.packageName).appName}',
  //                     '${element.appTitle}',
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           itemBuilder: (_, Notifications element) {
  //             if (element != null) {
  //               getCurrentApp(element.packageName);

  //               //print('Current App: ' +
  //               // getCurrentApp(element.packageName).appName);

  //               return Card(
  //                 // key: ObjectKey(snapshot
  //                 //     .data), // this is a new change, might break the app!!!!!
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(6.0),
  //                 ),
  //                 elevation: 8.0,
  //                 margin:
  //                     new EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
  //                 child: Container(
  //                   child: ListTile(
  //                     contentPadding:
  //                         EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),

  //                     leading: _currentApp is ApplicationWithIcon
  //                         ?
  //                         // Image.memory(
  //                         //     _currentApp.icon,
  //                         //     gaplessPlayback: true,
  //                         //     fit: BoxFit.cover,
  //                         //     scale: 2,
  //                         //   )
  //                         null
  //                         : null,
  //                     title: Container(
  //                       alignment: Alignment.topLeft,
  //                       //padding: EdgeInsets.a,
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Padding(
  //                             padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
  //                             child: Text(
  //                               element.title ?? packageName,
  //                               style: TextStyle(fontWeight: FontWeight.bold),
  //                             ),
  //                           ),
  //                           Padding(
  //                             padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
  //                             child: Text(element.text.toString()),
  //                           )
  //                         ],
  //                       ),
  //                     ),
  //                     subtitle: Padding(
  //                       padding: const EdgeInsets.fromLTRB(0, 7, 0, 0),
  //                       child: Text(
  //                         DateTime.fromMillisecondsSinceEpoch(
  //                                 (element.timestamp))
  //                             .toString()
  //                             .substring(0, 16),
  //                         style: TextStyle(color: Colors.white54, fontSize: 12),
  //                       ),
  //                     ),

  //                     isThreeLine: true,
  //                     //trailing: Text(element.text.toString()),
  //                     trailing:
  //                         //  Text(entry.packageName.toString().split('.').last),
  //                         Icon(Icons.keyboard_arrow_right),
  //                     // onTap: () => onAppClicked(
  //                     //     context, getCurrentApp(element.packageName),
  //                     //     ),
  //                   ),
  //                 ),
  //               );
  //             } else {
  //               return Center(child: Text('Nothing to Display!'));
  //             }
  //             // getCurrentApp(element.packageName);
  //           },
  //         );
  //       } else if (snapshot.hasError) {
  //         //return Center(child: Text("Oops!"));
  //         return Center(child: CircularProgressIndicator());
  //       }
  //       return Center(child: CircularProgressIndicator());
  //     },
  //   );
  // }

  onAppClicked(BuildContext context, Application app) {
    // final appName = SnackBar(content: Text(app.appName));
    // ScaffoldMessenger.of(context).showSnackBar(appName);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(app.appName),
            actions: <Widget>[
              AppButtonAction(
                label: 'Open app',
                onPressed: () => app.openApp(),
              ),
              AppButtonAction(
                label: 'Open app settings',
                onPressed: () => app.openSettingsScreen(),
              ),
            ],
          );
        });
  }
}
