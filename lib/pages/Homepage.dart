import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/CustomBottomBar/navigationDrawerWidget.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/buttons/button_widget.dart';
import 'package:notifoo/widgets/headers/subHeader.dart';
import 'package:notifoo/widgets/home/Banner.dart';
//import 'package:notifoo/widgets/navigation/nav_drawer.dart';
import '../widgets/Notifications/NotificationsLister.dart';

class Homepage extends StatefulWidget {
  Homepage({Key? key, this.title}) : super(key: key);

  final String? title;
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //int _selectedTab = 0;

  // void _selectedIndex(int index) {
  //   setState(() {
  //     _selectedTab = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        drawer: NavigationDrawerWidget(),
        body: Builder(
          builder: (context) => SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            child: Container(
              child: Column(
                children: [
                  BannerWidget(
                    onClicked: () => Scaffold.of(context).openDrawer(),
                  ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      child: NotificationsLister(),
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
