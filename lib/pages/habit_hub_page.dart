import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/habits/habit_lister.dart';
import 'package:notifoo/widgets/headers/subHeader.dart';

import '../widgets/navigation/nav_drawer_widget.dart';

List<double> _stopsCircle = [0.0, 0.7];

class HabitHubPage extends StatelessWidget {
  HabitHubPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    List<Color> _colors = [
      // Color(0xffD8E0BB),
      Color(0xff7268A6),
      Color(0xff86A3C3),
      //Color(0xffB6CEC7),
    ];

    List<Color> _pageColors = [
      // Color(0xffD8E0BB),
      Color.fromARGB(255, 236, 236, 236),
      Color.fromARGB(255, 235, 235, 235),
      //Color(0xffB6CEC7),
    ];

    return Scaffold(
        drawer: NavigationDrawerWidget(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(
            Icons.add,
            color: Colors.white70,
          ),
          splashColor: Colors.blueGrey,
          backgroundColor: Colors.blueAccent,
        ),
        body: Builder(
          builder: (context) => Container(
            //color: Color.fromARGB(255, 61, 58, 59),
            decoration: BoxDecoration(
              //border: Border.all(width: 3),
              color: Color(0xFFEFEEEE),
              // image: DecorationImage(
              //     image: AssetImage("assets/images/welcome-one.png"),
              //     fit: BoxFit.cover,
              //     alignment: Alignment.bottomCenter),
              // gradient: LinearGradient(
              //   //begin: Alignment.topLeft,
              //   colors: _pageColors,
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   //stops: _stopsCircle,
              // ),
              //shape: BoxShape.circle,
            ),
            child: Column(
              children: [
                Container(
                  //header

                  padding: EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    gradient: LinearGradient(
                      colors: _colors,

                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      //stops: _stops
                    ),
                    boxShadow: [
                      //color: Colors.white, //background color of box
                      BoxShadow(
                        color: Color.fromARGB(255, 190, 190, 190),
                        blurRadius: 25.0, // soften the shadow
                        spreadRadius: 3.0, //extend the shadow
                        offset: Offset(
                          5.0, // Move to right 10  horizontally
                          5.0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Topbar(
                        //   title: this.title!,
                        //   onClicked: () => Scaffold.of(context).openDrawer(),
                        // ),
                        bottomHeader(context),
                      ],
                    ),
                    // bottom: false,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                SubHeader(title: "Today's Notifications"),
                HabitListerWidget(),
              ],
            ),
          ),
        ));
  }

  Widget bottomHeader(BuildContext context) {
    return Container(
      // color: Colors.amber,

      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70.0,
            padding: EdgeInsets.only(
                bottom: 10.0, left: 15.0, right: 15.0, top: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Hi, ', //'$_totalNotifications',
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 32.0,
                      wordSpacing: 8.0,
                      fontWeight: FontWeight.w200,
                      color: Color.fromRGBO(223, 223, 223, 1),
                      shadows: [
                        Shadow(
                          blurRadius: 1.0,
                          color: Color(0xffe2adc4),
                          offset: Offset(-1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'Suman',
                  style: GoogleFonts.comfortaa(
                    textStyle: TextStyle(
                      letterSpacing: 0.5,
                      fontSize: 32.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 1.0,
                          color: Color(0xffe2adc4),
                          offset: Offset(-1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'You have 5 pending habits 👇',
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        //letterSpacing: 1.2,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 1.0,
                            color: Color(0xffe2adc4),
                            offset: Offset(-1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
