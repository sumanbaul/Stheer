import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/home/Banner.dart';
import 'package:notifoo/widgets/navigation/nav_drawer.dart';
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
    //debugPaintSizeEnabled = true;
    // final padding = MediaQuery.of(context).viewPadding;
    // print(padding);
    return Scaffold(
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        // drawer: Drawer(
        //   child: ListView(
        //     // Important: Remove any padding from the ListView.
        //     padding: EdgeInsets.zero,
        //     children: [
        //       const DrawerHeader(
        //         decoration: BoxDecoration(
        //           color: Colors.blue,
        //         ),
        //         child: Text('Drawer Header'),
        //       ),
        //       ListTile(
        //         title: const Text('Item 1'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //       ListTile(
        //         title: const Text('Item 2'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //     ],
        //   ), // Populate the Drawer in the next step.
        // ), //NavDrawer(),
        //appBar: Topbar.getTopbar('ss'),
        body: SafeArea(
          maintainBottomViewPadding: true,
          top: false,
          child: Container(
            child: Column(
              children: [
                BannerWidget(),
                _buildHeader("Today's Notifications"),
                Container(
                  child: Expanded(
                    child: NotificationsLister(),
                  ),
                )
              ],
            ),
          ),
        )
        // NotificationsLister(),
        );
  }

  Container _buildHeader(String title) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(bottom: 15.0),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.barlowSemiCondensed(
            textStyle: TextStyle(
              letterSpacing: 1.5,
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
    );
  }

  // Widget homeWidget = Container(
  //   padding: const EdgeInsets.all(32),
  //   child: Column(
  //     children: [BannerWidget(), NotificationsLister()],
  //   ),
  // );
}
