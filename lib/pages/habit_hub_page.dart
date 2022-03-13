import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/headers/subHeader.dart';

import '../widgets/navigation/nav_drawer_widget.dart';

List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];
List<double> _stopsCircle = [0.0, 0.7];

class HabitHubPage extends StatelessWidget {
  HabitHubPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(),
        body: Builder(
          builder: (context) => Container(
            //color: Color.fromARGB(255, 61, 58, 59),
            decoration: BoxDecoration(
              //border: Border.all(width: 3),
              color: Color.fromRGBO(58, 66, 86, 1.0),
              // gradient: LinearGradient(
              //   //begin: Alignment.topLeft,
              //   colors: _colors,
              //   stops: _stopsCircle,
              // ),
              //shape: BoxShape.circle,
              boxShadow: [
                //color: Colors.white, //background color of box

                BoxShadow(
                  color: Color(0xffffdaea),
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    -3.0, // Move to right 10  horizontally
                    -3.0, // Move to bottom 10 Vertically
                  ),
                ),
                BoxShadow(
                  color: Color(0xff84a6cd),
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    3.0, // Move to right 10  horizontally
                    3.0, // Move to bottom 10 Vertically
                  ),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  color: Colors.blueGrey,
                  padding: EdgeInsets.only(top: 15),
                  child: SafeArea(
                    child: Topbar(
                      title: this.title!,
                      onClicked: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                Container(
                  // color: Colors.amber,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      color: Colors.blueGrey),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        padding: EdgeInsets.only(
                            bottom: 10.0, left: 15.0, right: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ', //'$_totalNotifications',
                              style: GoogleFonts.barlowCondensed(
                                textStyle: TextStyle(
                                  letterSpacing: 0.8,
                                  fontSize: 34.0,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 173, 173, 173),
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
                              style: GoogleFonts.barlowCondensed(
                                textStyle: TextStyle(
                                  letterSpacing: 1.2,
                                  fontSize: 40.0,
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
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'You have 5 pending habits',
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
                ),
                SubHeader(title: "Today's Notifications"),
              ],
            ),
          ),
        ));
  }
}
