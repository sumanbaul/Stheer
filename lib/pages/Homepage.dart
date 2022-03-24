import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/helper/NotificationsHelper.dart';
import 'package:notifoo/widgets/navigation/nav_drawer_widget.dart';

import 'package:notifoo/widgets/headers/subHeader.dart';
import 'package:notifoo/widgets/home/home_banner_widget.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';
import '../model/Notifications.dart';
import '../widgets/Notifications/NotificationsLister.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key, this.title, this.notificationsFromDb}) : super(key: key);

  final String? title;
  final List<Notifications>? notificationsFromDb;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Notifications> _getNotificationsOfToday = [];
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<List<Notifications>> initializeData() async {
    _getNotificationsOfToday =
        await NotificationsHelper.initializeDbGetNotificationsToday();
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
                  ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      child: NotificationsLister(
                        getNotificationsOfToday: _getNotificationsOfToday,
                      ),
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
