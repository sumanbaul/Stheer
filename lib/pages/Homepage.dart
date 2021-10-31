import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/home/Banner.dart';
import 'package:path/path.dart';

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
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        appBar: Topbar.getTopbar(widget.title),
        body: Container(
          child: Column(
            children: [
              BannerWidget(),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                decoration: BoxDecoration(
                  // color: Colors.amber,

                  //color: Colors.orange,
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Text(
                    'Notifications',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(child: Container(child: NotificationsLister()))
            ],
          ),
        )
        // NotificationsLister(),
        );
  }

  // Widget homeWidget = Container(
  //   padding: const EdgeInsets.all(32),
  //   child: Column(
  //     children: [BannerWidget(), NotificationsLister()],
  //   ),
  // );
}
