import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // final padding = MediaQuery.of(context).viewPadding;
    // print(padding);
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        //appBar: Topbar.getTopbar(widget.title),
        body: SafeArea(
          maintainBottomViewPadding: true,
          top: false,
          child: Container(
            //padding: EdgeInsets.only(top: 20.0),
            child: Column(
              children: [
                BannerWidget(),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
                  decoration: BoxDecoration(
                    // color: Colors.amber,

                    //color: Colors.orange,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      'Todays Notifications',
                      style: GoogleFonts.barlowSemiCondensed(
                        textStyle: TextStyle(
                          letterSpacing: 1.2,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          // shadows: [
                          //   Shadow(
                          //     blurRadius: 1.0,
                          //     color: Color(0xffe2adc4),
                          //     offset: Offset(-1.0, 1.0),
                          //   ),
                          // ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        child: NotificationsLister()))
              ],
            ),
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
