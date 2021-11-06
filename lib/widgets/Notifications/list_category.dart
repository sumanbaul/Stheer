import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
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
  List<Color> _colors = [Color(0xffff6198), Color(0xffffb861)];
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
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: getNotificationListBody(),
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
              ? Image.memory(
                  _currentApp.icon,
                  //height: 30.0,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                )
              : null,
          tempIcon: Image.memory(_currentApp.icon),
          message:
              "You have " + value.length.toString() + " Unread notifications",
          notificationCount: value.length);

      notificationsByCategory.add(nc);
    });

    notificationsByCategory.sort(
        (a, b) => a.appTitle.toLowerCase().compareTo(b.appTitle.toLowerCase()));
    _nc = notificationsByCategory;
    setState(
        () {}); //this line is responsible for updating the view instantaneously

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
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Stack(children: [
        Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
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
                        offset: Offset(-4, -4)),
                    BoxShadow(
                        color: Color.fromRGBO(40, 48, 59, 1),
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(4, 4)),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      color: Color.fromRGBO(196, 196, 196, 1)),
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
                            '2 minutes ago',
                            style: TextStyle(
                              color: Color.fromRGBO(196, 196, 196, 1),
                              fontWeight: FontWeight.bold,
                            ),
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
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
                child: new InkWell(
                  onTap: () => {
                    print('tapped'),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailList(
                          packageName: _nc[index].packageName,
                          title: _nc[index].appTitle,
                        ),
                      ),
                    ),
                  },
                )))
      ]),
    );
  }
}
