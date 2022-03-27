import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:path/path.dart';

import '../../helper/NotificationsHelper.dart';
import '../../model/Notifications.dart';
import '../../model/notificationCategory.dart';
import 'list_category.dart';

// ignore: must_be_immutable
class NotificationsListerWidget extends StatefulWidget {
  Future<List<Notifications>> notificationsOfTheDay;
  NotificationsListerWidget({Key? key, required this.notificationsOfTheDay})
      : super(key: key);

  @override
  State<NotificationsListerWidget> createState() =>
      _NotificationsListerWidgetState();
}

class _NotificationsListerWidgetState extends State<NotificationsListerWidget> {
  bool isToday = true;
  Future<List<Notifications>>? notificationsOfToday;
  Future<List<NotificationCategory>>? notificationsOfTodayByCat;
  bool started = false;
  bool _loading = false;
  ReceivePort port = ReceivePort();

  String? flagEntry; //this variable need to check later,
  //after notfications logic is cleaned
  @override
  void initState() {
    //initPlatformState();

    _getNotifications();
    super.initState();
    initPlatformState();
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
        child: new NotificationsCategoryWidget(
          title: 'Stheer',
          isToday: isToday,
          //getNotificationsOfToday: notificationsOfToday!,
          notificationsByCategory: notificationsOfTodayByCat!,
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

  Future<List<NotificationCategory>> _getNotifications() async {
    notificationsOfToday = this.widget.notificationsOfTheDay;
    //NotificationsHelper.initializeDbGetNotificationsToday();
    return notificationsOfTodayByCat =
        notificationsByCategory(notificationsOfToday!);
  }

  Future<List<NotificationCategory>> notificationsByCategory(
      Future<List<Notifications>> notificationsFuture) async {
    return NotificationsHelper.getCategoryListFuture(0, notificationsFuture);
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

      //started = isServiceRunning;
      if (_currentNotification != null &&
          _currentNotification?.appTitle != null) {
        setState(() {
          final _notifications = appendCurrentNotificationToList(
              _currentNotification, notificationsOfToday);
          this.widget.notificationsOfTheDay = _notifications;
          notificationsOfTodayByCat =
              NotificationsHelper.getCategoryListFuture(0, _notifications);
        });
      }
    }); //onData(message, flagEntry!));
    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));
    var isServiceRunning = await (NotificationsListener.isRunning);
    print("""Service is ${!isServiceRunning! ? "not " : ""}aleary running""");
    if (!isServiceRunning) {
      startListening();
      isServiceRunning = true;
    }

    setState(() {
      started = isServiceRunning!;
    });
  }

//Example of appending into list of type Future
  Future<List<Notifications>> appendCurrentNotificationToList(
      Notifications? _currentNotification,
      Future<List<Notifications>>? notifications) async {
    if (_currentNotification != null && _currentNotification.appTitle != "") {
      // final _notifications = await notifications;
      // _notifications!.add(_currentNotification);

      // return _notifications;
      final _notifications = await this.widget.notificationsOfTheDay;
      _notifications.add(_currentNotification);
      return _notifications;
    }
    return notifications!;
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
    });
  }
}

////////////////////////////////////////////////
class NotificationsCategoryWidget extends StatefulWidget {
  NotificationsCategoryWidget({
    Key? key,
    this.title,
    //required this.getNotificationsOfToday,
    required this.isToday,
    required this.notificationsByCategory,
    //this.refresh,
  }) : super(key: key);
  final String? title;
  //final Future<List<Notifications>> getNotificationsOfToday;
  final Future<List<NotificationCategory>> notificationsByCategory;
  final bool isToday;
  // final Function? refresh;

  @override
  State<NotificationsCategoryWidget> createState() =>
      _NotificationsCategoryWidgetState();
}

class _NotificationsCategoryWidgetState
    extends State<NotificationsCategoryWidget> {
  bool isToday = true;
  bool hasData = false;
  List<Color> _colors = [Color.fromRGBO(94, 109, 145, 1.0), Colors.transparent];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: EdgeInsets.only(top: 15.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        gradient: LinearGradient(
          colors: _colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          //stops: _stops
        ),
      ),
      child: getNotificationListBody(context),
    );
  }

  Widget getNotificationListBody(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          margin: EdgeInsets.only(bottom: 10.0),
          padding: EdgeInsets.symmetric(horizontal: 30.0),
          //color: Colors.blueAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    onPrimary: isToday ? Colors.black87 : Colors.white24,
                    primary: isToday ? Colors.grey[300] : Colors.grey[600],
                    minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
                onPressed: () async {
                  //  await getCategoryList(0);

                  setState(() {
                    isToday = true;
                  });
                  // notificationCategoryStream = isToday
                  //     ? getCategoryListStream(0)
                  //     : getCategoryListStream(1);
                },
                child: Text('Today'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    onPrimary: isToday ? Colors.white24 : Colors.black87,
                    primary: isToday ? Colors.grey[600] : Colors.grey[300],
                    minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
                onPressed: () async {
                  //  await getCategoryList(1);

                  setState(() {
                    isToday = false;
                  });
                  // notificationCategoryStream = isToday
                  //     ? getCategoryListStream(0)
                  //     : getCategoryListStream(1);
                },
                child: Text('Yesterday'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white24,
                    primary: Colors.grey[600],
                    minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
                onPressed: () {},
                child: Text('History'),
              )
            ],
          ),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Container(
            //height: 200,
            // decoration: BoxDecoration(color: Colors.brown),
            margin: EdgeInsets.only(top: 0.0),
            child: FutureBuilder<List<NotificationCategory>>(
                future: this.widget.notificationsByCategory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return NotificationsHelper.buildLoader();
                  }

                  if (snapshot.hasError) {
                    return NotificationsHelper.buildError(
                        snapshot.error.toString());
                    //setState(() {});
                  }
                  if (snapshot.hasData) {
                    print(snapshot.data!.length);
                    return MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return new NotificationsCard(
                            notificationsCategoryList: snapshot.data,
                            index: index,
                            key: GlobalKey(),
                            // key: UniqueKey(), //widget.key,
                          );
                        },
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                      ),
                    );
                  } else {
                    return NotificationsHelper.buildNoData();
                  }
                }),
          ),
        ),
      ],
    );
  }
}
