import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerWidget extends StatefulWidget {
  BannerWidget({Key key}) : super(key: key);

  @override
  _BannerState createState() => _BannerState();
}

List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];

List<double> _stops = [0.0, 0.7];

List<double> _startCircle = [-1.0, 0.7];
List<double> _stopsCircle = [0.0, 0.7];

class _BannerState extends State<BannerWidget> {
  Color gradientStart = Colors.transparent;
  Color gradientEnd = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(child: bannerSection(context));
  }

  Widget bannerSection(BuildContext context) {
    double _width = MediaQuery.of(context).size.width * 0.55;

    return Container(
      margin: EdgeInsets.only(bottom: 25.0),
      decoration: BoxDecoration(
          boxShadow: [
            //color: Colors.white, //background color of box
            BoxShadow(
              color: Colors.black38,
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 3.0, //extend the shadow
              offset: Offset(
                5.0, // Move to right 10  horizontally
                5.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          gradient: LinearGradient(
            colors: _colors,

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            //stops: _stops
          ),
          color: Colors.orange,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          )),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 15),
      height: 240,
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    height: 200,
                    width: _width,
                    color: Colors.transparent,
                    padding: EdgeInsets.only(bottom: 20),
                    child: _getReadNotifications,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: <Widget>[
                      _whatsAppNotifications,
                      _gmailNotifications,
                    ],
                  ),
                ),
                /*2*/
              ],
            ),
          ),
          /*3*/
        ],
      ),
    );
  }

  Widget _getReadNotifications = Container(
    margin: EdgeInsets.only(top: 15),
    padding: EdgeInsets.all(15),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      //border: Border.all(width: 3),
      color: Color.fromRGBO(58, 66, 86, 1.0),
      gradient: LinearGradient(
        //begin: Alignment.topLeft,
        colors: _colors,
        stops: _stopsCircle,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Color(0xffffdaea),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            -5.0, // Move to right 10  horizontally
            -5.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Color(0xff84a6cd),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            5.0, // Move to right 10  horizontally
            5.0, // Move to bottom 10 Vertically
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
            '1999',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                letterSpacing: 1.2,
                fontSize: 50.0,
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
            'Unread',
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Color.fromRGBO(58, 66, 86, 1.0),
                  letterSpacing: 1,
                  fontSize: 20.0),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _whatsAppNotifications = Container(
    padding: EdgeInsets.all(15),
    margin: EdgeInsets.only(bottom: 10, top: 10),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      color: Color.fromRGBO(58, 66, 86, 1.0),
      gradient: LinearGradient(
        //begin: Alignment.topLeft,
        colors: _colors,
        stops: _stopsCircle,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Color(0xffffdaea),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 2.0, //extend the shadow
          offset: Offset(
            -4.0, // Move to right 10  horizontally
            -4.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Color(0xff84a6cd),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            4.0, // Move to right 10  horizontally
            4.0, // Move to bottom 10 Vertically
          ),
        ),
      ],
    ),
    child: Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            //heightFactor: 2,
            child: Text(
              '500',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 28.0,
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
              'Msgs',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Color.fromRGBO(58, 66, 86, 1.0),
                    letterSpacing: 1,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    ),
  );

  Widget _gmailNotifications = Container(
    padding: EdgeInsets.all(15),
    margin: EdgeInsets.only(bottom: 10, top: 10),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      // border: Border.all(width: 3),
      color: Color.fromRGBO(58, 66, 86, 1.0),
      gradient: LinearGradient(
        //begin: Alignment.topLeft,
        colors: _colors,
        stops: _stopsCircle,
      ),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Color(0xffffdaea),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 2.0, //extend the shadow
          offset: Offset(
            -4.0, // Move to right 10  horizontally
            -4.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Color(0xff84a6cd),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 2.0, //extend the shadow
          offset: Offset(
            4.0, // Move to right 10  horizontally
            4.0, // Move to bottom 10 Vertically
          ),
        ),
      ],
    ),
    child: Container(
      margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            //heightFactor: 2,
            child: Text(
              '500',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 28.0,
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
              'Mails',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Color.fromRGBO(58, 66, 86, 1.0),
                    letterSpacing: 1,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
