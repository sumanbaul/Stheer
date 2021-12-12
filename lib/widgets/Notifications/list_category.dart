import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/helper/datetime_ago.dart';
import 'package:notifoo/model/Notifications.dart';
import 'package:notifoo/model/notificationCategory.dart';
import 'package:notifoo/widgets/Notifications/list_detail.dart';

class NotificationCatgoryList extends StatefulWidget {
  NotificationCatgoryList({Key key, this.title}) : super(key: key);
  final AppListHelper appsListHelper = new AppListHelper();

  final String title;
  @override
  _NotificationCatgoryListState createState() =>
      _NotificationCatgoryListState();
}

class _NotificationCatgoryListState extends State<NotificationCatgoryList> {
  //List<Notifications> _notifications = [];
  List<Color> _colors = [Color.fromRGBO(94, 109, 145, 1.0), Colors.transparent];
  //List<Color> _colors = [Color(0xff635eff), Color(0xffffb861)];
  //List<Color> _colors = [Color(0xff635eff), Color(0xff5fd5ff)];

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
    if (_currentApp == null) {}
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
    setState(() {
      //this line is responsible for updating the view instantaneously
    });

    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: new Container(
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
      // print(value[value.length - 1].createdDate);
      var nc = NotificationCategory(
          packageName: value[0].packageName,
          appTitle: getCurrentApp(value[0].packageName).appName,
          appIcon: _currentApp is ApplicationWithIcon
              ? Image.memory(
                  _currentApp.icon,
                  //height: 30.0,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
              : null,
          tempIcon: Image.memory(_currentApp.icon),
          timestamp: value[0].timestamp,
          message:
              "You have " + value.length.toString() + " Unread notifications",
          notificationCount: value.length);

      notificationsByCategory.add(nc);
    });

    notificationsByCategory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _nc = notificationsByCategory;

    return notificationsByCategory;
    //print(listByPackageName);
  }

  getNotificationListBody() {
    //debugPaintSizeEnabled = true;
    return FutureBuilder<List<NotificationCategory>>(
        future: getCategoryList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: buildNotificationCard,
              physics: BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildNotificationCard(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Card(
        elevation: 0.0,
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
                              CircleAvatar(
                                radius: 25.0,
                                //backgroundImage: _nc[index].appIcon,
                                child: _nc[index].appIcon,
                                // child: ClipRRect(
                                //   child: _nc[index].appIcon,
                                //   borderRadius: BorderRadius.circular(100.0),
                                // ),
                                backgroundColor: Colors.white10,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nc[index].appTitle,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0),
                                  ),
                                  SizedBox(
                                    height: 3.0,
                                  ),
                                  Text(
                                    'Tap to view details',
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
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(_nc[index].message),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              readTimestamp((_nc[index].timestamp)),
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12),
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
                      print('tapped'),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationDetailList(
                            packageName: _nc[index].packageName,
                            title: _nc[index].appTitle,
                            appIcon: _nc[index].appIcon,
                            appTitle: _nc[index].appTitle,
                          ),
                        ),
                      ),
                    },
                  )))
        ]),
      ),
    );
  }
}
