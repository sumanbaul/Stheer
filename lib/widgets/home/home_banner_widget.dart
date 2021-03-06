import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/widgets/Topbar.dart';

class HomeBannerWidget extends StatefulWidget {
  final String? title;
  final VoidCallback? onClicked;
  final int? notificationCount;
  //final Future<List<Notifications>> notifications;

  HomeBannerWidget({
    Key? key,
    this.title,
    this.onClicked,
    this.notificationCount,
    // required this.notifications,
  }) : super(key: key);

  @override
  _BannerState createState() => _BannerState();
}

List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];

//List<double> _stops = [0.0, 0.7];

//List<double> _startCircle = [-1.0, 0.7];
List<double> _stopsCircle = [0.0, 0.7];

class _BannerState extends State<HomeBannerWidget> {
  Color? gradientStart = Colors.transparent;
  Color? gradientEnd = Colors.black;

  int totalNotifications = 0;

  Stream<String>? totalNotificationsStream;

  @override
  void initState() {
    super.initState();
    totalNotifications = this.widget.notificationCount!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: bannerSection(context));
  }

  Widget bannerSection(BuildContext context) {
    double _height = 320; //MediaQuery.of(context).size.height * 0.40;
    return buildBanner(_height, totalNotifications);
  }

  Widget buildBanner(double height, int nCount) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.0),
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
      height: height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Topbar(
                title: "Stheer",
                onClicked: widget.onClicked,
              ),
              Container(
                height: 148,
                color: Colors.transparent,
                // padding: EdgeInsets.only(
                //   left: 15,
                //   right: 15,
                //   bottom: 20,
                // ),
                child: Center(
                  child: _getReadNotifications(nCount),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.only(top: 20.0),
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

  Widget _getReadNotifications(int notificationCount) {
    return Container(
      // margin: EdgeInsets.only(top: 0),
      padding: EdgeInsets.all(20),
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

  Widget _whatsAppNotifications = Container(
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.only(
      bottom: 15,
    ),
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
    child: Container(
      //margin: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            //heightFactor: 2,
            child: Text(
              '501',
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
