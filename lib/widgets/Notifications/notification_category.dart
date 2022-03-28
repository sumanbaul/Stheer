import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/NotificationsHelper.dart';
import 'package:notifoo/model/notificationCategory.dart';

import '../../model/Notifications.dart';
import 'notification_card.dart';

class NotificationsCategoryWidget extends StatefulWidget {
  NotificationsCategoryWidget({
    Key? key,
    this.title,
    required this.getNotificationsOfToday,
    required this.isToday,
    //this.refresh,
  }) : super(key: key);
  final String? title;
  final Future<List<Notifications>> getNotificationsOfToday;
  final bool isToday;
  // final Function? refresh;

  @override
  State<NotificationsCategoryWidget> createState() =>
      _NotificationsCategoryWidgetState();
}

class _NotificationsCategoryWidgetState
    extends State<NotificationsCategoryWidget> {
  bool isToday = true;
  bool hasData = false;
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
    super.initState();
    // NotificationsHelper.initializeDbGetNotificationsToday();
    initializeNotificationsByCategory(this.widget.isToday ? 0 : 1);
  }

  initializeNotificationsByCategory(int day) async {
    var _getNotificationsOfToday = await this.widget.getNotificationsOfToday;
    return _getNotificationsOfToday.length > 0
        ? await NotificationsHelper.getCategoryListFuture(
            day, this.widget.getNotificationsOfToday)
        : refreshData();

    // print(
    //     "initializeNotificationsByCategory - >getNotificationsOfToday: $_getNotificationsOfToday.lenth");
    // return await NotificationsHelper.getCategoryListFuture(
    //     day, getNotificationsOfToday);

    // setState(() {});
  }

  Future<List<Notifications>> refreshData() async {
    print("Refresh data triggered");
    return await NotificationsHelper.initializeDbGetNotificationsToday();
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
                future: NotificationsHelper.getCategoryListFuture(
                    0, this.widget.getNotificationsOfToday),
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
                          return new Container(
                            key: GlobalKey(),
                            // key: UniqueKey(), //widget.key,
                          );
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

  // _runFuture() {
  //   _future = Future.delayed(Duration(seconds: 2), this.widget.refresh);
  //   setState(() {});
  // }
}
