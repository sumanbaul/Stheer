import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/widgets/Topbar.dart';

class PomodoroBannerW extends StatefulWidget {
  PomodoroBannerW({Key key}) : super(key: key);

  @override
  _PomodoroBannerW createState() => _PomodoroBannerW();
}

//List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];
List<Color> _colors = [Color(0xffb2f4ff), Color(0xff160040)];
List<Color> _bannerColors = [Color(0xfff56aa2), Color(0xffF48CC5)];
List<Color> _counterColors2 = [
  Color(0xffF48CC5),
  Color(0xffF56AA2),
];
List<Color> _counterShadows = [Color(0xfffcb0da), Color(0xffe83582)];

List<double> _stopsCircle = [0.0, 0.7];

class _PomodoroBannerW extends State<PomodoroBannerW> {
  Color gradientStart = Colors.transparent;
  Color gradientEnd = Colors.black;
  String _totalNotifications;

  @override
  void initState() {
    // DatabaseHelper.instance.initializeDatabase();

    super.initState();

    // getTotalNotifications().then((String result) {
    //   setState(() {
    //     _totalNotifications = result;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: bannerSection(context));
  }

  Widget bannerSection(BuildContext context) {
    //double _width = MediaQuery.of(context).size.width * 0.55;
    double _height = 305; //MediaQuery.of(context).size.height * 0.40;

    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
      decoration: BoxDecoration(
          boxShadow: [
            //color: Colors.white, //background color of box
            BoxShadow(
              color: Color(0xffc197c9),
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 2.0, //extend the shadow
              offset: Offset(
                3.0, // Move to right 10  horizontally
                3.0, // Move to bottom 10 Vertically
              ),
            )
          ],
          gradient: LinearGradient(
            colors: _bannerColors,

            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            //stops: _stops
          ),
          color: Colors.orange,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30.0),
            bottomLeft: Radius.circular(30.0),
          )),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
      height: _height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(
                title: 'Pomodoro',
              ),
              Container(
                height: 148,
                color: Colors.transparent,
                // padding: EdgeInsets.only(
                //   left: 15,
                //   right: 15,
                //   bottom: 20,
                // ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(child: _getReadNotifications()),
                    Center(child: _whatsAppNotifications()),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.only(top: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _getbox1,
                    _getbox1,
                    _getbox1,
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getbox1 = Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.ac_unit,
          color: _colors[0],
        ),
        Text('amc'),
      ],
    ),
  );

  Widget _getReadNotifications() {
    return Container(
      // margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(35),
      width: MediaQuery.of(context).size.width * 0.35,
      //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      decoration: BoxDecoration(
        //border: Border.all(width: 3),
        color: Colors.grey,
        gradient: LinearGradient(
          begin: Alignment.center,
          colors: _counterColors2,
          stops: _stopsCircle,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          //color: Colors.white, //background color of box

          BoxShadow(
            color: _counterShadows[0],
            blurRadius: 15.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
            offset: Offset(
              -4.0, // Move to right 10  horizontally
              -4.0, // Move to bottom 10 Vertically
            ),
          ),
          BoxShadow(
            color: _counterShadows[1],
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
              '20', //'$_totalNotifications',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  letterSpacing: 1.2,
                  fontSize: 45.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 1.0,
                      color: Color(0xffacd5e0),
                      offset: Offset(-1.0, 1.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'Complete',
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

  Widget _whatsAppNotifications() {
    return Container(
      padding: EdgeInsets.all(35),
      //height: 170,
      width: MediaQuery.of(context).size.width * 0.35,
      // margin: EdgeInsets.only(
      //   bottom: 15,
      // ),
      //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      decoration: BoxDecoration(
        color: Color.fromRGBO(58, 66, 86, 1.0),
        gradient: LinearGradient(
          begin: Alignment.center,
          colors: _counterColors2,
          stops: _stopsCircle,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          //color: Colors.white, //background color of box

          BoxShadow(
            color: _counterShadows[0],
            blurRadius: 15.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
            offset: Offset(
              -3.0, // Move to right 10  horizontally
              -3.0, // Move to bottom 10 Vertically
            ),
          ),
          BoxShadow(
            color: _counterShadows[1],
            blurRadius: 15.0, // soften the shadow
            spreadRadius: 2.0, //extend the shadow
            offset: Offset(
              3.0, // Move to right 10  horizontally
              3.0, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
      child: Container(
        //margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              //heightFactor: 2,
              child: Text(
                '20',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    letterSpacing: 1.2,
                    fontSize: 45.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Color(0xffacd5e0),
                        offset: Offset(-1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'Failed',
                textAlign: TextAlign.center,
                style: GoogleFonts.barlowCondensed(
                  textStyle: TextStyle(
                    color: Color(0xffc62169), //Color.fromRGBO(58, 66, 86, 1.0),
                    letterSpacing: 1,
                    fontSize: 18.0,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gmailNotifications = Container(
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.only(
      bottom: 15,
    ),
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
          spreadRadius: 1.0, //extend the shadow
          offset: Offset(
            -3.0, // Move to right 10  horizontally
            -3.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Color(0xff84a6cd),
          blurRadius: 15.0, // soften the shadow
          spreadRadius: 1.0, //extend the shadow
          offset: Offset(
            3.0, // Move to right 10  horizontally
            3.0, // Move to bottom 10 Vertically
          ),
        ),
      ],
    ),
    child: Container(
      //margin: EdgeInsets.only(top: 15),
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

Future<String> getTotalNotifications() async {
  var getNotifications = await DatabaseHelper.instance.getNotifications();
  return getNotifications.length.toString();
}
