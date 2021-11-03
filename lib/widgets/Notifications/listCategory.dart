import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/Notifications.dart';

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
  final List<Application> _apps = AppListHelper().appListData;
  ApplicationWithIcon _currentApp;

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();

    super.initState();
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

  getNotificationListBody() {
    return FutureBuilder<List<Notifications>>(
        future: DatabaseHelper.instance.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _notifications = snapshot.data;
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
    var currentApp = getCurrentApp(_notifications[index].packageName);

    // final entry =
    return new Container(
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: ClipRRect(
                            child: _currentApp is ApplicationWithIcon
                                ? Image.memory(_currentApp.icon)
                                : null,
                            borderRadius: BorderRadius.circular(200.0),
                          ),
                          backgroundColor: Colors.transparent,
                          radius: 30.0,
                        ),
                        // Text(_notifications[index].packageName),
                        Text(_notifications[index].appTitle ??
                            currentApp.appName),
                      ],
                    ),
                    Text(_notifications[index].text ?? "")
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
