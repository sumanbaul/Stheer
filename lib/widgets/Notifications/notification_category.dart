import 'dart:async';

import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/notificationCategory.dart';

import '../../model/Notifications.dart';
import 'notification_card.dart';

class NotificationsCategoryWidget extends StatefulWidget {
  NotificationsCategoryWidget({
    Key? key,
    this.title,
    required this.todaysNotifications,
  }) : super(key: key);
  final String? title;
  final List<Notifications> todaysNotifications;
  @override
  State<NotificationsCategoryWidget> createState() =>
      _NotificationsCategoryWidgetState();
}

class _NotificationsCategoryWidgetState
    extends State<NotificationsCategoryWidget> {
  Future<List<NotificationCategory>>? notificationCategoryStream;

  bool isToday = true;
  List<NotificationCategory> _nc = [];

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
      child: getNotificationListBody(),
    );
  }

  @override
  void initState() {
    //DatabaseHelper.instance.initializeDatabase();
    super.initState();

    isToday ? initializeDatabase(0) : initializeDatabase(1);
  }

  initializeDatabase(int day) async {
    var notificationFromDatabase = this.widget.todaysNotifications.isEmpty
        ? await DatabaseHelper.instance.getNotifications(day)
        : this.widget.todaysNotifications;
    notificationCategoryStream =
        getCategoryListStream(day, notificationFromDatabase);
  }

  Future<Application?> getCurrentApp(String? packageName) async {
    Application? app;

    if (packageName != "") {
      app = await DeviceApps.getApp(packageName!, true);
      //_currentApp = app;
    }
    return app;
  }

  Future<List<NotificationCategory>> getCategoryListStream(
      int selectedDay, List<Notifications>? notifications) async {
    var listByPackageName;

    if (notifications != null) {
      listByPackageName = groupBy(notifications, (Notifications n) {
        return n.packageName.toString();
      });
    }
    List<NotificationCategory> notificationsByCategory = [];

    if (listByPackageName.length > 0) {
      listByPackageName.forEach((key, value) async {
        // print(value[value.length - 1].createdDate);
        var _app = await (getCurrentApp(value[0].packageName));

        var nc = NotificationCategory(
            packageName: _app?.packageName,
            appTitle: _app?.appName,
            appIcon: _app is ApplicationWithIcon
                ? Image.memory(
                    _app.icon,
                    //height: 30.0,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : null,
            //tempIcon: Image.memory(_currentApp.icon),
            timestamp: value[0].timestamp,
            message:
                "You have " + value.length.toString() + " Unread notifications",
            notificationCount: value.length);

        notificationsByCategory.add(nc);
      });

      setState(() {
        notificationsByCategory
            .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
        _nc = notificationsByCategory;
      });
    }

    return notificationsByCategory;
  }

  Widget getNotificationListBody() {
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
                future: notificationCategoryStream,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Text('none');
                    case ConnectionState.active:
                      return Text('active');
                    case ConnectionState.waiting:
                      return Center(
                          child: CircularProgressIndicator(
                        color: Colors.white70,
                      ));
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return NotificationsCard(
                                notificationsCategoryList: _nc,
                                index: index,
                                // key: UniqueKey(), //widget.key,
                              );
                            },
                            physics: BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                          ),
                        );
                      } else {
                        return Center(child: Text('Nothing to display'));
                      }
                    default:
                      return Text('default');
                  }
                }),
          ),
        ),
      ],
    );
  }
}
