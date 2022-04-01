import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/Notifications/notifications_list_widget.dart';
import 'package:notifoo/widgets/navigation/nav_drawer_widget.dart';

import 'package:notifoo/widgets/headers/subHeader.dart';
import 'package:notifoo/widgets/home/home_banner_widget.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';
import '../model/Notifications.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key, this.title}) : super(key: key);

  final String? title;
  //final Future<List<Notifications>>? notificationsFromDb;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //List<Notifications> _getNotificationsOfToday = [];
  //Future<List<Notifications>>? notificationsOfTheDay;
  int _notificationsCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Notifications Count in Homepage => $_notificationsCount");
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        drawer: NavigationDrawerWidget(),
        body: Builder(
          builder: (context) => SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            bottom: false,
            child: Container(
              child: Column(
                children: [
                  HomeBannerWidget(
                    key: UniqueKey(),
                    onClicked: () => Scaffold.of(context).openDrawer(),
                    notificationCount: _notificationsCount,
                    //notifications: notificationsOfTheDay!,
                  ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      child: NotificationsListWidget(
                        onCountChange: (count) async {
                          var _count = await count;
                          setState(() {
                            _notificationsCount = _count;
                          });
                        },
                      ),

                      //child: NotificationsListerTest(),

                      // child: NotificationsLister(
                      //   getNotificationsOfToday: _getNotificationsOfToday,
                      // ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
        // NotificationsLister(),
        );
  }
}
