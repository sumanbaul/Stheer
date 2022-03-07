import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/widgets/Topbar.dart';

class BannerWidget extends StatefulWidget {
  BannerWidget({Key key, this.title, this.onClicked}) : super(key: key);
  final String title;
  final VoidCallback onClicked;
  @override
  _BannerState createState() => _BannerState();
}

List<Color> _colors = [Color(0xffeeaeca), Color(0xff94bbe9)];

//List<double> _stops = [0.0, 0.7];

//List<double> _startCircle = [-1.0, 0.7];
List<double> _stopsCircle = [0.0, 0.7];

class _BannerState extends State<BannerWidget> {
  Color gradientStart = Colors.transparent;
  Color gradientEnd = Colors.black;
  String _totalNotifications;

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();

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

  @override
  void didUpdateWidget(BannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bannerSection(BuildContext context) {
    //double _width = MediaQuery.of(context).size.width * 0.55;
    double _height = 320; //MediaQuery.of(context).size.height * 0.40;

    return StreamBuilder<String>(
        initialData: "0",
        stream: getTotalNotifications.asBroadcastStream(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error'));
            } else if (snapshot.hasData) {
              _totalNotifications = snapshot.data.toString();
              return Builder(builder: (context) {
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
                            title: "Notifoo",
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
                              child: _getReadNotifications(
                                  snapshot.data.toString()),
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
              });
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        });
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

  Widget _getReadNotifications(String notificationCount) {
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
              notificationCount, //'$_totalNotifications',
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

// Future<String> getTotalNotifications() async {
//   var getNotifications = await DatabaseHelper.instance.getNotifications();
//   return getNotifications.length.toString();
// }

Stream<String> getTotalNotifications = (() async* {
  var getNotifications = await DatabaseHelper.instance.getNotifications(0);
  yield getNotifications.length.toString();
})();
