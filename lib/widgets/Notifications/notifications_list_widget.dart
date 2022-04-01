import 'dart:ffi';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/model/notificationCategory.dart';
// import 'package:notifoo/pages/Homepage.dart';
// import 'package:notifoo/widgets/home/home_banner_widget.dart';

import '../../helper/NotificationsHelper.dart';
import '../../helper/notificationCatHelper.dart';
import '../../model/Notifications.dart';
import 'notification_card.dart';

// Callback
//typedef void DetailsCallback(HomeBannerWidget val);

class NotificationsListWidget extends StatefulWidget {
  final Function(Future<int>)? onCountChange;
  final VoidCallback? onCountAdded;
  NotificationsListWidget({Key? key, this.onCountAdded, this.onCountChange})
      : super(key: key);

  @override
  State<NotificationsListWidget> createState() =>
      _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
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
    initData();
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
        final _notifications =
            appendElements(notificationsOfTheDay!, _currentNotification!);
        var _notificationsByCat = _notifications.then((value) =>
            NotificationCatHelper.getNotificationsByCat(value, isToday));
        setState(() {
          notificationsByCatFuture = _notificationsByCat;
          notificationsOfTheDay = _notifications;
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

  Future<void> initData() async {
    final _notificationsOfTheDay =
        NotificationsHelper.initializeDbGetNotificationsToday(isToday ? 0 : 1);

    final _notificationsByCatFuture = _notificationsOfTheDay.then(
        (value) => NotificationCatHelper.getNotificationsByCat(value, isToday));
    final _onCountChange = _notificationsOfTheDay.then((value) => value.length);
    setState(() {
      notificationsOfTheDay = _notificationsOfTheDay;
      notificationsByCatFuture = _notificationsByCatFuture;
      this.widget.onCountChange!(_onCountChange);
    });
  }

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
                    isToday = true;
                    //notificationsOfTheDay = initializeData(isToday);
                    var _ntCat =
                        NotificationCatHelper.getNotificationsByCategoryInit(
                            isToday);
                    setState(() {
                      isToday = true;
                      notificationsByCatFuture = _ntCat;
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
                    isToday = false;
                    var _ntCat =
                        NotificationCatHelper.getNotificationsByCategoryInit(
                            isToday);
                    setState(() {
                      isToday = false;
                      notificationsByCatFuture = _ntCat;
                      //notificationsOfTheDay = initializeData(isToday);
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
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return NotificationsHelper.buildLoader();
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return NotificationsHelper.buildError(
                            snapshot.error.toString());
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        print(
                            "Snapshot.length -> NotificationsWidget:${snapshot.data!.length}");
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: RefreshIndicator(
                            onRefresh: () => initData(),
                            child: ListView.builder(
                              itemCount: data!.length,
                              itemBuilder: (context, index) {
                                if (data.length > 0) {
                                  return NotificationsCard(
                                    notificationsCategory: data[index],
                                    //index: index,
                                    key: GlobalKey(),
                                    // key: UniqueKey(), //widget.key,
                                  );
                                } else {
                                  return Text(
                                      "You don't have any notifications today.");
                                }
                              },
                              physics: BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return NotificationsHelper.buildNoData();
                      }
                  }
                }),
          ),
        ),
      ],
    );
  }
}
