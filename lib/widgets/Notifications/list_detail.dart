import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/helper/datetime_ago.dart';
import 'package:notifoo/model/list_detail_model.dart';

class NotificationDetailList extends StatefulWidget {
  // In the constructor, require a Todo.
  NotificationDetailList({
    Key? key,
    this.packageName,
    this.title,
    this.appIcon,
    this.appTitle,
    this.notification,
  }) : super(key: key);
  //NotificationCatgoryList({Key key, this.title}) : super(key: key);
  //final AppListHelper appsListHelper = new AppListHelper();

  final String? title;
  final String? packageName;
  final Image? appIcon;
  final String? appTitle;
  final Notification? notification;

  @override
  _NotificationCatgoryListState createState() =>
      _NotificationCatgoryListState();
}

class _NotificationCatgoryListState extends State<NotificationDetailList> {
  ScrollController _controller = new ScrollController();
  final List<Color> _cardColors = [
    Color.fromRGBO(59, 66, 84, 1),
    Color.fromRGBO(41, 47, 61, 1)
  ];

  List<NotificationModel> _notificationsList = [];
  // final List<Application> _apps = AppListHelper().appListData;
  // ApplicationWithIcon _currentApp;

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();

    super.initState();

    getNotificationList();
  }

  // Application getCurrentApp(String packageName) {
  //   if (_currentApp == null) {}
  //   // getListOfApps().whenComplete(() => _apps);
  //   for (var app in _apps) {
  //     if (app.packageName == packageName) {
  //       _currentApp = app;
  //     }
  //   }
  //   return _currentApp;
  // }

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return Scaffold(
      //appBar: Topbar.getTopbar(widget.title),
      // backgroundColor: Colors.transparent,
      body: getNotificationListBody(),
    );
  }

  Future<List<NotificationModel>> getNotificationList() async {
    var getNotificationModel =
        await DatabaseHelper.instance.getNotifications(0);

    List<NotificationModel> notificationList = [];

    getNotificationModel.forEach((key) {
      if (key.packageName!.contains(widget.packageName!)) {
        // print(key.text);
        // print(key.title);
        var _notification = NotificationModel(
          title: key.title,
          text: key.text,
          packageName: key.packageName,
          appTitle: widget.appTitle,
          appIcon: widget.appIcon != null ? widget.appIcon : null,
          timestamp: key.timestamp,
          createAt: key.createAt,
          message: key.message,
          textLines: key.textLines,
          createdDate: key.createdDate,
          isDeleted: key.isDeleted,
        );
        notificationList.add(_notification);
      }

      //notificationsByCategory.add(nc);
    });

    // notificationList.sort(
    //     (a, b) => a.appTitle.toLowerCase().compareTo(b.appTitle.toLowerCase()));
    _notificationsList = notificationList;
    // setState(
    //     () {}); //this line is responsible for updating the view instantaneously

    return notificationList;
    //print(listByPackageName);
  }

  // getNotificationListBody() {
  //   return FutureBuilder<List<NotificationModel>>(
  //       future: DatabaseHelper.instance.getNotifications(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           return new ListView.builder(
  //               itemBuilder: buildNotificationCard,
  //               physics: BouncingScrollPhysics(
  //                 parent: AlwaysScrollableScrollPhysics(),
  //               ));
  //         }

  //         else {

  //         }
  //       });
  // }

  getNotificationListBody() {
    return FutureBuilder<List<NotificationModel>>(
        future: getNotificationList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
              itemCount: snapshot.data!.length,
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

  getTagButton() {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.blueAccent, //Color.fromRGBO(84, 98, 117, 0.9),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(84, 98, 117, 1),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(-3, -3)),
            BoxShadow(
                color: Color.fromRGBO(40, 48, 59, 1),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(3, 3)),
          ]),
      margin: EdgeInsets.fromLTRB(7, 10, 5, 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 5.0),
        child: Text('#social'),
      ),
    );
  }

  Widget buildNotificationCard(BuildContext context, int index) {
    var size = MediaQuery.of(context).size;
    final item = _notificationsList[index];

    return Dismissible(
// Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: ObjectKey(item),
      // Provide a function that tells the app
      // what to do after an item has been swiped away.
      onDismissed: (direction) {
        //#TODO
        // Remove the item from the data source.
        // setState(() {
        //   _notificationsList.removeAt(index);
        // });
      },
      // Show a red background as the item is swiped away.
      background: Container(color: Colors.red),

      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: <Widget>[
            Container(
              // height: 165,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            //radius: 25.0,
                            //backgroundImage: _nc[index].appIcon,
                            child: item.appIcon,
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
                              Container(
                                width: size.width - 130,
                                child: new Text(
                                  item.title ?? item.appTitle!,
                                  //overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              SizedBox(
                                height: 3.0,
                              ),
                              Container(
                                child: item.createdDate != null
                                    ? Text(
                                        readTimestamp(
                                          int.parse(item.createdDate!),
                                        ),
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                196, 196, 196, 1)),
                                      )
                                    : Text("null"), // TODO
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
                      Expanded(
                        flex: 1,
                        child: new SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          dragStartBehavior: DragStartBehavior.start,
                          child: Container(
                            padding: const EdgeInsets.only(top: 10.0),
                            width: size.width * 0.87,
                            //height: 45.0,
                            child: Text(item.text ?? "No text to display"),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 10.0),
                      //   child: Text(
                      //     '2 minutes ago',
                      //     style: TextStyle(
                      //       color: Color.fromRGBO(196, 196, 196, 1),
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Container(
                    color: Colors.transparent,
                    width: size.width,
                    height: 45,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(), // new
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      children: [
                        getTagButton(),
                        getTagButton(),
                        getTagButton(),
                        getTagButton(),
                        getTagButton(),
                        getTagButton(),
                        getTagButton(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
