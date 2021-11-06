import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/list_detail_model.dart';
import 'package:notifoo/widgets/Topbar.dart';

class NotificationDetailList extends StatefulWidget {
  // In the constructor, require a Todo.
  NotificationDetailList({Key key, this.packageName, this.title})
      : super(key: key);
  //NotificationCatgoryList({Key key, this.title}) : super(key: key);
  final AppListHelper appsListHelper = new AppListHelper();

  final String title;
  final String packageName;

  @override
  _NotificationCatgoryListState createState() =>
      _NotificationCatgoryListState();
}

class _NotificationCatgoryListState extends State<NotificationDetailList> {
  final List<Color> _cardColors = [
    Color.fromRGBO(59, 66, 84, 1),
    Color.fromRGBO(41, 47, 61, 1)
  ];

  List<NotificationModel> _notificationsList = [];
  final List<Application> _apps = AppListHelper().appListData;
  ApplicationWithIcon _currentApp;

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();

    super.initState();

    getNotificationList();
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
      appBar: Topbar.getTopbar(widget.title),
      // backgroundColor: Colors.transparent,
      body: getNotificationListBody(),
    );
  }

  Future<List<NotificationModel>> getNotificationList() async {
    var getNotificationModel = await DatabaseHelper.instance.getNotifications();

    List<NotificationModel> notificationList = [];

    getNotificationModel.forEach((key) {
      if (key.packageName.contains(widget.packageName)) {
        print(key.text);
        print(key.title);
        var _notification = NotificationModel(
            title: key.title,
            text: key.message,
            packageName: key.packageName,
            appTitle: getCurrentApp(key.packageName).appName,
            appIcon: _currentApp is ApplicationWithIcon
                ? Image.memory(
                    _currentApp.icon,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : null,
            timestamp: key.timestamp,
            createAt: key.createAt,
            message: key.message,
            textLines: key.textLines);
        notificationList.add(_notification);
      }

      //notificationsByCategory.add(nc);
    });

    // notificationList.sort(
    //     (a, b) => a.appTitle.toLowerCase().compareTo(b.appTitle.toLowerCase()));
    _notificationsList = notificationList;
    setState(
        () {}); //this line is responsible for updating the view instantaneously

    return notificationList;
    //print(listByPackageName);
  }

  getNotificationListBody() {
    return FutureBuilder<List<NotificationModel>>(
        future: getNotificationList(),
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
      child: Column(
        children: <Widget>[
          Container(
            height: 130,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _cardColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
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
                          child: _notificationsList[index].appIcon,
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
                              _notificationsList[index].title ??
                                  _notificationsList[index].appTitle,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                            Text(
                              _notificationsList[index].text ?? "null",
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
                      child: Text(_notificationsList[index].text ?? "nnn"),
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
        ],
      ),
    );
  }
}
