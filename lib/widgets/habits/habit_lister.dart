import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class HabitListerWidget extends StatefulWidget {
  HabitListerWidget({Key? key}) : super(key: key);

  @override
  State<HabitListerWidget> createState() => _HabitListerWidgetState();
}

class _HabitListerWidgetState extends State<HabitListerWidget> {
  final List<Color> _cardColors = [
    Color.fromARGB(255, 255, 255, 255),
    Color.fromARGB(255, 233, 233, 233)
  ];

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
          // height: 600,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
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
              color: Color(0xFFEFEEEE)),
          child: ListView.builder(
            itemBuilder: _buildHabitItem,
            itemCount: 20,
            physics: BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          )),
    );
  }

  Widget _buildHabitItem(BuildContext context, int index) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: Offset(-6.0, -6.0),
                  blurRadius: 16.0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(6.0, 6.0),
                  blurRadius: 16.0,
                ),
              ],
              color: Color(0xFFEFEEEE),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // CircleAvatar(
                        //   //radius: 25.0,
                        //   //backgroundImage: _nc[index].appIcon,
                        //   child: item.appIcon,
                        //   // child: ClipRRect(
                        //   //   child: _nc[index].appIcon,
                        //   //   borderRadius: BorderRadius.circular(100.0),
                        //   // ),
                        //   backgroundColor: Colors.white10,
                        // ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: new Text(
                                "Habit 1",
                                //overflow: TextOverflow.clip,
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  overflow: TextOverflow.ellipsis,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 3.0,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.black45,
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        dragStartBehavior: DragStartBehavior.start,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10.0),
                          width: MediaQuery.of(context).size.width * 0.87,
                          //height: 45.0,
                          child: Text(
                            "No text to display",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
