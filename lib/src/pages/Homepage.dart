import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/src/components/notifications/notifications_banner.dart';
import 'package:notifoo/src/widgets/Notifications/notifications_list_widget.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';

import 'package:notifoo/src/widgets/headers/subHeader.dart';
import 'package:notifoo/src/widgets/home/home_banner_widget.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';
import '../components/notifications/notifications_list.dart';
import '../helper/NotificationsHelper.dart';
import '../helper/notificationCatHelper.dart';
import '../model/Notifications.dart';
import '../model/notificationCategory.dart';

class Homepage extends StatefulWidget {
  Homepage({
    Key? key,
    this.title,
    required this.openNavigationDrawer,
  }) : super(key: key);

  final VoidCallback? openNavigationDrawer;
  final String? title;
  //final Future<List<Notifications>>? notificationsFromDb;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //List<Notifications> _getNotificationsOfToday = [];
  //Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
  int _notificationsCount = 0;
  bool started = false;
  bool _loading = false;
  bool isToday = true;
  ReceivePort port = ReceivePort();

  //Theme
  List<Color> _colors = [Color.fromRGBO(94, 109, 145, 1.0), Colors.transparent];
  String? flagEntry; //this variable need to check later,

  @override
  void initState() {
    super.initState();

    initPlatformState();
    initData();
    //WidgetsBinding.instance.addObserver(this);
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
      _currentNotification = await NotificationsHelper.onData(message);
      // don't use the default receivePort
      // NotificationsListener.receivePort.listen((evt) => onData(evt));

      //started = isServiceRunning;
      if (_currentNotification != null &&
          _currentNotification?.appTitle != null) {
        final _notifications =
            appendElements(notificationsOfTheDay!, _currentNotification!);
        var _notificationsByCat = _notifications.then((value) =>
            NotificationCatHelper.getNotificationsByCat(value, isToday));
        setState(() {
          //notificationsOfTheDay = _notifications;
          notificationsByCatFuture = _notificationsByCat;
        });
      }
    }); //onData(message, flagEntry!));
    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));
    var isServiceRunning = await (NotificationsListener.isRunning);
    print("""Service is ${!isServiceRunning! ? "not " : ""}aleary running""");
    if (!isServiceRunning) {
      startListening();
    }

    setState(() {
      started = isServiceRunning;
    });
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
      //Eraser.clearAllAppNotifications();
    });
  }

  Future<List<Notifications>> appendElements(
      Future<List<Notifications>> listFuture,
      Notifications elementToAdd) async {
    final list = await listFuture;
    list.add(elementToAdd);

    return list;
  }

  Future<void> initData() async {
    final _notificationsOfTheDay =
        NotificationsHelper.initializeDbGetNotificationsToday(isToday ? 0 : 1);

    final _notificationsByCatFuture = _notificationsOfTheDay.then(
        (value) => NotificationCatHelper.getNotificationsByCat(value, isToday));
    final _onCountChange = _notificationsOfTheDay.then((value) => value.length);

    //this.widget.onCountChange!(_onCountChange);
    _onCountChange.then((value) {
      setState(() {
        _notificationsCount = value;
        notificationsOfTheDay = _notificationsOfTheDay;
        notificationsByCatFuture = _notificationsByCatFuture;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Notifications Count in Homepage => $_notificationsCount");
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        drawer: NavigationDrawerWidget(),
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
        body: Builder(
          builder: (context) => SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            bottom: false,
            child: Container(
              child: Column(
                children: [
                  NotificationsBanner(
                      notificationBannerTitle: "Stheer1",
                      notificationCount: _notificationsCount,
                      onClicked: () => Scaffold.of(context).openDrawer()),
                  // HomeBannerWidget(
                  //   key: UniqueKey(),
                  //   onClicked: () => Scaffold.of(context).openDrawer(),
                  //   notificationCount: _notificationsCount,
                  //   //notifications: notificationsOfTheDay!,
                  // ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      // child: NotificationsListWidget(
                      //   onCountChange: (count) async {
                      //     var _count = await count;
                      //     setState(() {
                      //       _notificationsCount = _count;
                      //     });
                      //   },
                      // ),

                      child: NotificationsList(
                        // notificationsOfTheDay: notificationsOfTheDay,
                        notificationsByCatFuture: notificationsByCatFuture,
                        notificationsCount: _notificationsCount,
                        refreshData: initData,
                        colors: _colors,
                      ),

                      //child: NotificationsListerTest(),

                      // child: NotificationsLister(
                      //   getNotificationsOfToday: _getNotificationsOfToday,
                      // ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
        // NotificationsLister(),
        );
  }
}
