import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsBannerCounter extends StatelessWidget {
  final int notificationCount;
  final List<Color> gradient;
  final List<double> colorStops;
  const NotificationsBannerCounter({
    Key? key,
    required this.notificationCount,
    required this.gradient,
    required this.colorStops,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(20),
      //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      decoration: BoxDecoration(
        //border: Border.all(width: 3),
        color: Color.fromRGBO(58, 66, 86, 1.0),
        gradient: LinearGradient(
          //begin: Alignment.topLeft,
          colors: gradient,
          stops: colorStops,
        ),
        shape: BoxShape.circle,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              notificationCount.toString(), //'$_totalNotifications',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 45.0,
                  fontWeight: FontWeight.bold,
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
          ),
          Center(
            child: Text(
              'Unread alerts',
              textAlign: TextAlign.center,
              style: GoogleFonts.barlowCondensed(
                textStyle: TextStyle(
                  color: Color.fromRGBO(58, 66, 86, 1.0),
                  letterSpacing: 1,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
