import 'package:flutter/material.dart';

class TaskWidget extends StatefulWidget {
  TaskWidget({Key key}) : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

List<Color> _counterShadows = [
  Color(0xffeeaeca),
  Color(0xffc197c9),
];

List<Color> _widgetBgColor = [
  Color(0xffffffff),
  Color(0xfffae2ff),
];

List<Color> _buttonShadows = [
  Color(0xfffcedff),
  Color(0xffffe2d3),
];
Widget _calendarWidget() {
  return Container(
    height: 100,
    width: 180,
    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
    margin: EdgeInsets.only(right: 15.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        //color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          colors: _widgetBgColor,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          //color: Colors.white, //background color of box

          BoxShadow(
            color: _counterShadows[0],
            blurRadius: 15.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              -4.0, // Move to right 10  horizontally
              4.0, // Move to bottom 10 Vertically
            ),
          ),
        ]),
    //color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '10:10 AM',
                style: TextStyle(
                  color: Color(0xffa9abd6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Work on Notifoo App',
                textAlign: TextAlign.left,
                overflow: TextOverflow.clip,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff680038) //_counterShadows[1],
                    ),
              ),
            ],
          ),
        ),
        Container(
          child: Container(
            // margin: EdgeInsets.only(top: 0),
            padding: EdgeInsets.all(10),
            width: 60,
            height: 60,
            //decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            decoration: BoxDecoration(
              //border: Border.all(width: 3),
              color: _counterShadows[0],
              border: Border.all(width: 3.0, color: _counterShadows[1]),
              // gradient: LinearGradient(
              //   begin: Alignment.center,
              //   colors: _counterColors2,
              //   stops: _stopsCircle,
              //   end: Alignment.bottomRight,
              // ),
              shape: BoxShape.circle,
              boxShadow: [
                //color: Colors.white, //background color of box

                BoxShadow(
                  color: _buttonShadows[0],
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    -4.0, // Move to right 10  horizontally
                    -4.0, // Move to bottom 10 Vertically
                  ),
                ),
                BoxShadow(
                  color: _buttonShadows[1],
                  blurRadius: 15.0, // soften the shadow
                  spreadRadius: 2.0, //extend the shadow
                  offset: Offset(
                    3.0, // Move to right 10  horizontally
                    3.0, // Move to bottom 10 Vertically
                  ),
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_outlined,
              size: 30.0,
            ),
          ),
        ),
      ],
    ),
  );
}

class _TaskWidgetState extends State<TaskWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.fromLTRB(25, 10, 15, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _calendarWidget(),
                _calendarWidget(),
                _calendarWidget(),
                _calendarWidget(),
                _calendarWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
