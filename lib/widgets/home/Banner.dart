import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  BannerWidget({Key key}) : super(key: key);

  @override
  _BannerState createState() => _BannerState();
}

List<Color> _colors = [
  Color.fromRGBO(58, 66, 86, 1.0),
  Color.fromRGBO(52, 60, 79, 1)
];

List<double> _stops = [0.0, 0.7];

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
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
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
    padding: EdgeInsets.all(10),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      //border: Border.all(width: 3),
      color: Color.fromRGBO(58, 66, 86, 1.0),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Colors.white10,
          blurRadius: 25.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            -5.0, // Move to right 10  horizontally
            -5.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Colors.black38,
          blurRadius: 25.0, // soften the shadow
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
            '1000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            'Unread',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    ),
  );

  Widget _whatsAppNotifications = Container(
    padding: EdgeInsets.all(20),
    margin: EdgeInsets.only(bottom: 20, top: 15),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      color: Color.fromRGBO(58, 66, 86, 1.0),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Colors.white10,
          blurRadius: 25.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            -5.0, // Move to right 10  horizontally
            -5.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Colors.black38,
          blurRadius: 25.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            5.0, // Move to right 10  horizontally
            5.0, // Move to bottom 10 Vertically
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
            child: Text(
              '500',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          Center(
            child: Text('Whatsapp'),
          )
        ],
      ),
    ),
  );

  Widget _gmailNotifications = Container(
    // margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(20),
    //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
    decoration: BoxDecoration(
      // border: Border.all(width: 3),
      color: Color.fromRGBO(58, 66, 86, 1.0),
      shape: BoxShape.circle,
      boxShadow: [
        //color: Colors.white, //background color of box

        BoxShadow(
          color: Colors.white10,
          blurRadius: 25.0, // soften the shadow
          spreadRadius: 3.0, //extend the shadow
          offset: Offset(
            -5.0, // Move to right 10  horizontally
            -5.0, // Move to bottom 10 Vertically
          ),
        ),
        BoxShadow(
          color: Colors.black38,
          blurRadius: 25.0, // soften the shadow
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
            '500',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        Center(
          child: Text('Emails'),
        )
      ],
    ),
  );
}
