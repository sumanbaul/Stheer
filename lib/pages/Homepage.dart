import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Topbar.dart';

import 'NotificationsLister.dart';

class Homepage extends StatefulWidget {
  Homepage({Key key, this.title}) : super(key: key);

  final String title;
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
      appBar: Topbar.getTopbar(widget.title),
      body: NotificationsLister(),
      // bottomNavigationBar: CustomButtomBar(
      //   onTabSelected: _selectedIndex,
      //   items: [
      //     CustomBottomBarItem(icon: Icons.notifications),
      //     CustomBottomBarItem(icon: Icons.food_bank),
      //     CustomBottomBarItem(icon: Icons.person),
      //   ],
      // ),
    );
  }
}
