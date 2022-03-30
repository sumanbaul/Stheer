import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/model/notificationCategory.dart';

import '../../helper/NotificationsHelper.dart';
import '../../helper/notificationCatHelper.dart';
import '../../model/Notifications.dart';
import 'notification_card.dart';

class NotificationsListWidget extends StatefulWidget {
  NotificationsListWidget({Key? key}) : super(key: key);

  @override
  State<NotificationsListWidget> createState() =>
      _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
  List<Notifications>? notifications;
  List<NotificationCategory>? notificationsByCat;
  bool started = false;
  bool _loading = false;
  bool isToday = true;
  ReceivePort port = ReceivePort();

  //Theme
  List<Color> _colors = [Color.fromRGBO(94, 109, 145, 1.0), Colors.transparent];
  String? flagEntry; //this variable need to check later,
  //after notfications logic is cleaned
  @override
  void initState() {
    super.initState();

    initPlatformState();
    //notificationsOfTheDay = initializeData(isToday);
    notificationsOfTheDay =
        NotificationsHelper.initializeDbGetNotificationsToday(isToday ? 0 : 1);
    notificationsByCatFuture =
        NotificationCatHelper.getNotificationsByCategoryInit(isToday);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //appBar: Topbar.getTopbar(widget.title),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Container(
        height: 600,
        padding: EdgeInsets.zero,
        child: _buildContainer(context),
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
      _currentNotification = await NotificationsHelper.onData(message);
      // don't use the default receivePort
      // NotificationsListener.receivePort.listen((evt) => onData(evt));

      //started = isServiceRunning;
      if (_currentNotification != null &&
          _currentNotification?.appTitle != null) {
        setState(() {
          notificationsOfTheDay =
              appendElements(notificationsOfTheDay!, _currentNotification!);
          notificationsByCatFuture =
              NotificationCatHelper.getNotificationsByCategoryUpdate(
                  notificationsOfTheDay!, isToday);
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

  Future<List<Notifications>> appendElements(
      Future<List<Notifications>> listFuture,
      Notifications elementToAdd) async {
    final list = await listFuture;
    list.add(elementToAdd);
    // list
    //   ..sort(
    //       (a, b) => (b.createAt.toString()).compareTo(a.createAt.toString()));
    return list;
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

  // Future<List<Notifications>> initializeData(bool istoday) async {
  //   List<NotificationCategory> _ncList =
  //       await NotificationCatHelper.getNotificationsByCategory(istoday);
  //   notificationsOfTheDay = initializeNotifications(istoday);
  //   // final _ntList = await NotificationsHelper.initializeDbGetNotificationsToday(
  //   //     istoday ? 0 : 1);

  //   notifications = await notificationsOfTheDay;

  //   if (notifications!.length > 0) {
  //     notificationsByCatFuture = notificationsByCategory(notifications!);
  //   }
  //   return notifications!;
  // }

  Future<List<Notifications>> initializeNotifications(bool istoday) async {
    return await NotificationsHelper.initializeDbGetNotificationsToday(
        istoday ? 0 : 1);
  }

  // Future<List<NotificationCategory>> updateData(bool istoday) async {
  //   final _ntCat = await notificationsByCategory(
  //       NotificationsHelper.initializeDbGetNotificationsToday(istoday ? 0 : 1));
  //   return _ntCat;
  // }

  // Future<List<NotificationCategory>> notificationsByCategory(
  //     List<Notifications> notificationsFuture) async {
  //   return await NotificationsHelper.getCategoryListFuture(
  //       isToday ? 0 : 1, notificationsFuture);
  // }

  // Future<List<NotificationCategory>> initializeCatData() async {
  //   final _ntList = initializeData();
  //   notificationsOfTheDay = _ntList;
  //   return notificationsByCat = notificationsByCategory(_ntList);
  // }

  Widget _buildContainer(BuildContext context) {
    return Container(
      height: 700,
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
                  if (isToday == false) {
                    setState(() {
                      isToday = true;
                      //notificationsOfTheDay = initializeData(isToday);
                      notificationsByCatFuture =
                          NotificationCatHelper.getNotificationsByCategoryInit(
                              isToday);
                    });
                  }
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
                  if (isToday == true) {
                    setState(() {
                      isToday = false;
                      //notificationsOfTheDay = initializeData(isToday);
                      notificationsByCatFuture =
                          NotificationCatHelper.getNotificationsByCategoryInit(
                              isToday);
                    });
                  }
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
                future: notificationsByCatFuture,
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
                    print(
                        "Snapshot.length -> NotificationsWidget:$snapshot.data!.length");
                    return MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final entry = snapshot.data![index];
                          // final app = NotificationsHelper.getCurrentAppWithIcon(
                          //     entry.packageName!);
                          return NotificationsCard(
                            notificationsCategory: entry,
                            //index: index,
                            key: GlobalKey(),
                            // key: UniqueKey(), //widget.key,
                          );
                        },
                        //   ListTile(
                        //       trailing: Text(
                        //           entry.packageName.toString().split('.').last),
                        //       title: Container(
                        //         child: Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             // CircleAvatar(
                        //             //   child:  await NotificationsHelper.getCurrentAppWithIcon(event.packageName!)) ?? entry.packageName Image.memory(bytes),
                        //             // ),
                        //             Text(entry.title ?? "no title"),
                        //             Text(entry.text ?? "No message"),
                        //             // Text(entry.createAt
                        //             //     .toString()
                        //             //     .substring(0, 19)),
                        //           ],
                        //         ),
                        //       ));
                        // },
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