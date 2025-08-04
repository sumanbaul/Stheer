import 'package:flutter/material.dart';
import '../../helper/NotificationsHelper.dart';
import '../../model/Notifications.dart';
import '../../model/notificationCategory.dart';
import '../../widgets/Notifications/notification_card.dart';

class NotificationsList extends StatelessWidget {
  //final Future<List<Notifications>>? notificationsOfTheDay;
  final Future<List<NotificationCategory>>? notificationsByCatFuture;
  final int notificationsCount;
  final List<Color> colors;
  final Function() refreshData;

  const NotificationsList({
    Key? key,
   // required this.notificationsOfTheDay,
    required this.notificationsByCatFuture,
    required this.notificationsCount,
    required this.colors,
    required this.refreshData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          colors: colors,
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
                    // onPrimary: isToday ? Colors.black87 : Colors.white24,
                    // primary: isToday ? Colors.grey[300] : Colors.grey[600],
                    //minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
                onPressed: () async {
                  //  await getCategoryList(0);
                  // if (isToday == false) {
                  //   isToday = true;
                  //   //notificationsOfTheDay = initializeData(isToday);
                  //   var _ntCat =
                  //       NotificationCatHelper.getNotificationsByCategoryInit(
                  //           isToday);
                  //   setState(() {
                  //     isToday = true;
                  //     notificationsByCatFuture = _ntCat;
                  //   });
                  // }
                },
                child: Text('Today'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    //onPrimary: isToday ? Colors.white24 : Colors.black87,
                    //primary: isToday ? Colors.grey[600] : Colors.grey[300],
                    //minimumSize: Size(88, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    )),
                onPressed: () async {
                  //  await getCategoryList(1);
                  // if (isToday == true) {
                  //   isToday = false;
                  //   var _ntCat =
                  //       NotificationCatHelper.getNotificationsByCategoryInit(
                  //           isToday);
                  //   setState(() {
                  //     isToday = false;
                  //     notificationsByCatFuture = _ntCat;
                  //     //notificationsOfTheDay = initializeData(isToday);
                  //   });
                  // }
                },
                child: Text('Yesterday'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white24,
                    backgroundColor: Colors.grey[600],
                    //minimumSize: Size(88, 36),
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
                            onRefresh: () => refreshData(),
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
