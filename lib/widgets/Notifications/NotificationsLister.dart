import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/helper/NotificationsHelper.dart';
import 'package:notifoo/widgets/Notifications/notification_category.dart';
import 'package:notifoo/model/Notifications.dart';

//Initialize singleton
//final AppListHelper appsListHelper = new AppListHelper();

class NotificationsLister extends StatefulWidget {
  NotificationsLister({
    Key? key,
    required this.getNotificationsOfToday,
  }) : super(key: key);

  final List<Notifications> getNotificationsOfToday;

  @override
  _NotificationsListerState createState() => _NotificationsListerState();
}

class _NotificationsListerState extends State<NotificationsLister> {
  bool isToday = true;
  // List<NotificationCategory> notificationCategoryStream = [];
  //String? packageName = "";
  Future<List<Notifications>>? notificationsOfToday;

  bool appsLoaded = false;

  String?
      flagEntry; //this variable need to check later, after notfications logic is cleaned

  bool started = false;
  bool _loading = false;
  ReceivePort port = ReceivePort();

  @override
  void initState() {
    initPlatformState();

    NotificationsHelper.initPopulateData(this.widget.getNotificationsOfToday);
    //initPopulateData();
    //DatabaseHelper.instance.initializeDatabase();
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

  void callSetState() {
    setState(
        () {}); // it can be called without parameters. It will redraw based on changes done in _SecondWidgetState
  }

  // getCategoryList(int day) async {
  //   return await NotificationsHelper.getCategoryListFuture(
  //       day, this.widget.getNotificationsOfToday);

  //   // setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    // initializeNotificationsByCategory(this.isToday ? 0 : 1);
    return Scaffold(
      backgroundColor: Colors.transparent,
      //appBar: Topbar.getTopbar(widget.title),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Container(
        height: 800,
        padding: EdgeInsets.zero,
        child: NotificationsCategoryWidget(
          title: 'Stheer',
          isToday: isToday,
          getNotificationsOfToday: NotificationsHelper.initPopulateData(this
              .widget
              .getNotificationsOfToday), //this.widget.getNotificationsOfToday,
          //refresh: callSetState,
        ),
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
    Notifications? _currentNotification;
    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_notifoolistener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_notifoolistener_");
    //IsolateNameServer.registerPortWithName(port.sendPort, "insta");
    port.listen((message) async {
      _currentNotification =
          await NotificationsHelper.onData(message, flagEntry ?? "");

      //started = isServiceRunning;
      pushCurrentNotificationToContext(_currentNotification);
      // setState(() {

      // });
    }); //onData(message, flagEntry!));
    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));
    var isServiceRunning = await (NotificationsListener.isRunning);
    print("""Service is ${!isServiceRunning! ? "not " : ""}aleary running""");

    //for testing
    //var test = this.widget.getNotificationsOfToday;
    ///////

    // setState(() {
    //   started = isServiceRunning;
    //   // _currentNotification != null
    //   //     ? this.widget.getNotificationsOfToday.add(_currentNotification!)
    //   //     : _currentNotification;
    // });

    setState(() {
      started = isServiceRunning;
    });
  }

  void pushCurrentNotificationToContext(Notifications? _currentNotification) {
    if (_currentNotification != null && _currentNotification.appTitle != "") {
      this.widget.getNotificationsOfToday.add(_currentNotification);
    }
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
          title: "Stheer listening",
          description: "Let's scrape the notifactions...",
          subTitle: "Service",
          showWhen: true
          //foreground: AppButtonAction(),
          );
    }
    setState(() {
      started = true;
      _loading = false;
      //this.widget.getNotificationsOfToday;
    });
  }

  void stopListening() async {
    print("stop listening");
    await NotificationsListener.stopService();

    setState(() {
      started = false;
      _loading = false;
    });
  }

  // Future<Application?> getCurrentAppWithIcon(String packageName) async {
  //   _currentApp = await DeviceApps.getApp(packageName, true);
  //   return _currentApp;
  // }

//critical function below
//This function is triggered on receiving of data from port
  // void onData(NotificationEvent event, String flat) async {
  //   var eventAppWithIcon = await (getCurrentAppWithIcon(event.packageName!));
  //   print(event); // this is needed for later

  //   if (!eventAppWithIcon!.systemApp) {
  //     if (event.packageName!.contains("skydrive") ||
  //         (event.packageName!.contains("service")) ||
  //         // (event.packageName.contains("android")) ||
  //         (event.packageName!.contains("notifoo")) ||
  //         (event.packageName!.contains("screenshot")) ||
  //         (event.title!.contains("WhatsApp")) ||
  //         (event.packageName!.contains("deskclock")) ||
  //         (event.packageName!.contains("wellbeing")) ||
  //         (event.packageName!.contains("weather2")) ||
  //         (event.packageName!.contains("gallery"))) {
  //       print(event.packageName);
  //     } else {
  //       packageName = event.packageName;
  //       // print("Success Package Found: " + app.packageName);
  //       //var jsondata2 = json.decode(event.toString());
  //       Map<String, dynamic> jsonresponse = json.decode(event.toString());

  //       var createatday = event.createAt!.day;
  //       print("Create AT Day: $createatday");
  //       var today = new DateTime.now().day;
  //       print('today: $today');
  //       //var xx = jsonresponse.containsKey('summaryText');
  //       if (!jsonresponse.containsKey('summaryText') &&
  //           event.createAt!.day >= today) {
  //         //Redundancy check, currently not in use, need to use it to...
  //         //filter out redundant notifications

  //         // bool redundancy;
  //         //  NotificationsHelper.redundantNotificationCheck(event).then((bool value) {
  //         //    redundancy = value;
  //         //  });

  //         if ((event.text != flagEntry) && event.text != null) {
  //           var currentNotification = Notifications(
  //               title: event.title,
  //               appTitle: _currentApp!.appName,
  //               // appIcon: _currentApp is ApplicationWithIcon
  //               //     ? Image.memory(_currentApp.icon)
  //               //     : null,
  //               text: event.text,
  //               message: event.message,
  //               packageName: event.packageName,
  //               timestamp: event.timestamp,
  //               createAt: event.createAt!.millisecondsSinceEpoch.toString(),
  //               eventJson: event.toString(),
  //               createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
  //               isDeleted: 0
  //               // infoText: jsonData["text"],
  //               // showWhen: 1,
  //               // subText: jsonData["text"],
  //               // timestamp: event.timestamp.toString(),
  //               // packageName: jsonData["packageName"],
  //               // text: jsonData["text"],
  //               // summaryText: jsonData["summaryText"] ?? ""
  //               );

  //           //add current notification to this Global Variable(getNotificationsOfToday)
  //           //inside context

  //           await DatabaseHelper.instance
  //               .insertNotification(currentNotification);
  //           setState(() {
  //             this.widget.getNotificationsOfToday.add(currentNotification);
  //             print("Setstate getting hit: $currentNotification");
  //           });
  //           //initClearNotificationsState();
  //           flagEntry = event.text;
  //         } else {
  //           // # TODO fix here

  //           // var titleLength = jsonresponse["textLines"].length;

  //           var currentNotification = Notifications(
  //               title: jsonresponse["textLines"] ??
  //                   jsonresponse["textLines"] as String?,
  //               text: event.text,
  //               message: event.message,
  //               packageName: event.packageName,
  //               timestamp: event.timestamp,
  //               createAt: event.createAt!.millisecondsSinceEpoch.toString(),
  //               eventJson: event.toString(),
  //               createdDate: DateTime.now().millisecondsSinceEpoch.toString(),
  //               isDeleted: 0
  //               // infoText: jsonData["text"],
  //               // showWhen: 1,
  //               // subText: jsonData["text"],
  //               // timestamp: event.timestamp.toString(),
  //               // packageName: jsonData["packageName"],
  //               // text: jsonData["text"],
  //               // summaryText: jsonData["summaryText"] ?? ""
  //               );

  //           //initClearNotificationsState();
  //           this.setState(() {
  //             this.widget.getNotificationsOfToday.add(currentNotification);
  //             print("Setstate getting hit: $currentNotification");
  //           });
  //         }
  //       }
  //     }

  //     setState(() {});
  //     // if (!event.packageName.contains("example") ||
  //     //     !event.packageName.contains("skydrive") ||
  //     //     !event.packageName.contains("skydrive") ||
  //     //     !event.packageName.contains("xiaomi")) {
  //     //   // TODO: fix bug
  //     //   // NotificationsListener.promoteToForeground("");
  //     // }
  //     // print("Print Notification: $event");
  //   }
  // }

  //Notifications By Category

  // initializeNotificationsByCategory(int day) async {
  //   var notificationFromDatabase = this.widget.getNotificationsOfToday.isEmpty
  //       ? await DatabaseHelper.instance.getNotifications(day)
  //       : this.widget.getNotificationsOfToday;
  //   notificationCategoryStream =
  //       await getCategoryListFuture(day, notificationFromDatabase);
  //   setState(() {});
  // }

  // Future<List<NotificationCategory>> getCategoryListFuture(
  //     int selectedDay, List<Notifications>? notifications) async {
  //   var listByPackageName;

  //   if (notifications != null) {
  //     listByPackageName = groupBy(notifications, (Notifications n) {
  //       return n.packageName.toString();
  //     });
  //   }
  //   List<NotificationCategory> notificationsByCategory = [];

  //   if (listByPackageName.length > 0) {
  //     listByPackageName.forEach((key, value) async {
  //       // print(value[value.length - 1].createdDate);
  //       var _app = await (getCurrentAppWithIcon(value[0].packageName));

  //       var nc = NotificationCategory(
  //           packageName: _app?.packageName,
  //           appTitle: _app?.appName,
  //           appIcon: _app is ApplicationWithIcon
  //               ? Image.memory(
  //                   _app.icon,
  //                   //height: 30.0,
  //                   fit: BoxFit.cover,
  //                   gaplessPlayback: true,
  //                 )
  //               : null,
  //           //tempIcon: Image.memory(_currentApp.icon),
  //           timestamp: value[0].timestamp,
  //           message:
  //               "You have " + value.length.toString() + " Unread notifications",
  //           notificationCount: value.length);

  //       notificationsByCategory.add(nc);
  //     });

  //     setState(() {
  //       notificationsByCategory
  //           .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
  //       _nc = notificationsByCategory;
  //     });
  //   }

  //   return notificationsByCategory;
  // }

  // Future<List<Notifications>> initPopulateData() async {
  //   return this.widget.getNotificationsOfToday.isNotEmpty ||
  //           this.widget.getNotificationsOfToday.length > 0
  //       ? this.widget.getNotificationsOfToday
  //       : await DatabaseHelper.instance.getNotifications(0);
  // }
}
