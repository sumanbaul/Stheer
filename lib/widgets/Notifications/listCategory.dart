import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/Notifications.dart';
import 'package:notifoo/model/notificationCategory.dart';

class NotificationCatgoryList extends StatefulWidget {
  NotificationCatgoryList({Key key, this.title}) : super(key: key);
  final AppListHelper appsListHelper = new AppListHelper();

  final String title;
  @override
  _NotificationCatgoryListState createState() =>
      _NotificationCatgoryListState();
}

class _NotificationCatgoryListState extends State<NotificationCatgoryList> {
  List<Notifications> _notifications = [];
  List<NotificationCategory> _nc = [];
  final List<Application> _apps = AppListHelper().appListData;
  ApplicationWithIcon _currentApp;

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();

    super.initState();

    getCategoryList();
  }

  Application getCurrentApp(String packageName) {
    // getListOfApps().whenComplete(() => _apps);
    for (var app in _apps) {
      if (app.packageName == packageName) {
        _currentApp = app;
      }
    }
    return _currentApp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      //appBar: Topbar.getTopbar(widget.title),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Container(
        child: getNotificationListBody(),
      ),
    );
  }

  Future<List<NotificationCategory>> getCategoryList() async {
    var getNotifications = await DatabaseHelper.instance.getNotifications();
    final listByPackageName = groupBy(getNotifications, (Notifications n) {
      return n.packageName;
    });

    List<NotificationCategory> notificationsByCategory = [];

    listByPackageName.forEach((key, value) {
      var nc = NotificationCategory(
          packageName: key,
          appTitle: getCurrentApp(key).appName,
          appIcon: _currentApp is ApplicationWithIcon
              ? MemoryImage(_currentApp.icon)
              : null,
          tempIcon: Image.memory(_currentApp.icon),
          message:
              "You have " + value.length.toString() + " Unread notifications",
          notificationCount: value.length);

      notificationsByCategory.add(nc);
    });

    _nc = notificationsByCategory;
    setState(
        () {}); //this line is responsible for updating the view instantaneously

    return notificationsByCategory;
    //print(listByPackageName);
  }

  getNotificationListBody() {
    // debugPaintSizeEnabled = true;
    return FutureBuilder<List<NotificationCategory>>(
        future: getCategoryList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              child: new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: buildNotificationCard,
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildNotificationCard(BuildContext context, int index) {
    return new Container(
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              height: 80.0,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 30.0,
                              backgroundImage: _nc[index].appIcon,
                              // child: ClipRRect(
                              //   child: _nc[index].tempIcon,
                              //   borderRadius: BorderRadius.circular(200.0),
                              // ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          // Text(_notifications[index].packageName),
                          Text(_nc[index].appTitle),
                          Text(_nc[index].message),
                        ],
                      ),
                    ),
                    Text(_nc[index].notificationCount.toString())
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
