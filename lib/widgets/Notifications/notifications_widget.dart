import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';

import '../../helper/NotificationsHelper.dart';
import '../../helper/datetime_ago.dart';
import '../../model/Notifications.dart';

class NotificationsListWidget extends StatefulWidget {
  NotificationsListWidget({Key? key}) : super(key: key);

  @override
  State<NotificationsListWidget> createState() =>
      _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  Future<List<Notifications>>? notificationsOfTheDay;
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
    initializeData();
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

  Future<void> initializeData() async {
    notificationsOfTheDay =
        NotificationsHelper.initializeDbGetNotificationsToday();
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
            child: FutureBuilder<List<Notifications>>(
                future: notificationsOfTheDay,
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
                          final entry = snapshot.data![index];
                          return ListTile(
                              trailing: Text(
                                  entry.packageName.toString().split('.').last),
                              title: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.title ?? "no title"),
                                    Text(entry.text ?? "No message"),
                                    // Text(entry.createAt
                                    //     .toString()
                                    //     .substring(0, 19)),
                                  ],
                                ),
                              ));
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

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({Key? key, this.index, this.notifications})
      : super(key: key);
  final int? index;
  final List<Notifications>? notifications;

  buildNotificationCard(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Card(
        elevation: 0.0,
        margin: EdgeInsets.only(top: 0.0),
        color: Colors.transparent,
        child: Stack(children: [
          Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //  margin: EdgeInsets.only(bottom: 10),
                height: 100,
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(59, 66, 84, 1),
                        Color.fromRGBO(41, 47, 61, 1)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    //color: Color.fromRGBO(40, 48, 59, 1),
                    // color: Color.fromRGBO(58, 66, 86, 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(84, 98, 117, 1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(-3, -3)),
                      BoxShadow(
                          color: Color.fromRGBO(40, 48, 59, 1),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(3, 3)),
                    ]),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // CircleAvatar(
                              //   radius: 25.0,
                              //   child:
                              //       notifications![index].appIcon,
                              //   // backgroundImage:
                              //   //     notificationsCategoryList[index]
                              //   //         .appIcon
                              //   //         .image,
                              //   //backgroundImage: _nc[index].appIcon,
                              //   //child: _nc[index].appIcon,
                              //   // child: ClipRRect(
                              //   //   child: _nc[index].appIcon,
                              //   //   borderRadius: BorderRadius.circular(100.0),
                              //   // ),
                              //   backgroundColor: Colors.black12,
                              // ),
                              // ClipOval(
                              //   child: Image(
                              //     image: _nc[index].appIcon.image,
                              //     fit: BoxFit.cover,
                              //     width: 50.0,
                              //     height: 50.0,
                              //     gaplessPlayback: true,
                              //     alignment: Alignment.center,
                              //   ),
                              // ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notifications![index].appTitle!,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    "$notifications![index].text", //'Tap to view details',
                                    style: TextStyle(
                                        color:
                                            Color.fromRGBO(196, 196, 196, 1)),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Icon(Icons.keyboard_arrow_right)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              notifications![index].message!,
                              style: TextStyle(
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              // readTimestamp(
                              //     notifications![index].createAt),
                              'sometyhing',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          new Positioned.fill(
              child: new Material(
                  type: MaterialType.transparency,
                  color: Colors.transparent,
                  child: new InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => {
                      // print('tapped'),
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => NotificationDetailList(
                      //       packageName:
                      //           notificationsCategoryList![index].packageName,
                      //       title: notificationsCategoryList![index].appTitle,
                      //       //appIcon: notificationsCategoryList![index].appIcon,
                      //       appTitle:
                      //           notificationsCategoryList![index].appTitle,
                      //     ),
                      //   ),
                      // ),
                    },
                  )))
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildNotificationCard(context, this.index!);
  }
}
