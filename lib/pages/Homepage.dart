import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/helper/NotificationsHelper.dart';
import 'package:notifoo/util/notifications_factory.dart';
import 'package:notifoo/widgets/Notifications/notifications_widget.dart';
import 'package:notifoo/widgets/navigation/nav_drawer_widget.dart';

import 'package:notifoo/widgets/headers/subHeader.dart';
import 'package:notifoo/widgets/home/home_banner_widget.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';
import '../model/Notifications.dart';
import '../widgets/Notifications/NotificationsLister.dart';
import '../widgets/Notifications/notification_list_test_2.dart';
import '../widgets/Notifications/notifications_lister_test.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key, this.title, this.notificationsFromDb}) : super(key: key);

  final String? title;
  final Future<List<Notifications>>? notificationsFromDb;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Notifications> _getNotificationsOfToday = [];
  Future<List<Notifications>>? notificationsOfTheDay;
  int _notificationsCount = 0;

  @override
  void initState() {
    super.initState();
    //notificationsOfTheDay = NotificationsFactory().initializeDatabase();
    // notificationsOfTheDay = initializeData();
    //initializeData();
  }

  Future<List<Notifications>> initializeData() async {
    _getNotificationsOfToday =
        await NotificationsHelper.initializeDbGetNotificationsToday();
    _notificationsCount = _getNotificationsOfToday.length;
    return _getNotificationsOfToday;
  }

  @override
  Widget build(BuildContext context) {
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
                    //notifications: notificationsOfTheDay!,
                  ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      // child: NotificationsListWidget(),

                      child: NotificationsListerTest(),

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

  void appendCurrentNotificationToList(Notifications? _currentNotification,
      Future<List<Notifications>>? notifications) async {
    if (_currentNotification != null && _currentNotification.appTitle != "") {
      // final _notifications = await notifications;
      // _notifications!.add(_currentNotification);

      // return _notifications;
      final _notifications = await notifications;
      setState(() {
        //_notifications = [..._notifications!, _currentNotification];
        _notifications!.add(_currentNotification);
        debugPrint("list is appended? $_notifications[0].appTitle");
      });
    }
  }
}
