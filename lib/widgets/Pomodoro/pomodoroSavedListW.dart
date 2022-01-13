import 'package:flutter/material.dart';
import 'package:notifoo/helper/DatabaseHelper.dart';
import 'package:notifoo/model/pomodoro_timer.dart';

class PomodoroSavedListW extends StatefulWidget {
  PomodoroSavedListW({Key key}) : super(key: key);

  @override
  _PomodoroSavedListWState createState() => _PomodoroSavedListWState();
}

List<Color> _bgColor = [Color(0xffecccc0), Color(0xffe7c1ed)];
List<Color> _counterShadows = [
  Color(0xff762d89),
  Color(0xffc197c9),
];
Widget buildCounterList() {
  //return ListView()

  return Expanded(
    child: Container(
      height: 500,
      child: FutureBuilder<List<PomodoroTimer>>(
          future: getCategoryList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.ac_unit_outlined),
                  title: Text(snapshot.data[index].taskName),
                  subtitle: Text(snapshot.data[index].duration),
                  trailing: Text(snapshot.data[index].createdDate),
                ),
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              );
            } else {
              return Container();
            }
          }),
    ),
  );
}

Future<List<PomodoroTimer>> getCategoryList() async {
  return await DatabaseHelper.instance.getPomodoroTimer();
}

class _PomodoroSavedListWState extends State<PomodoroSavedListW> {
  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      // maxChildSize: 0.7,
      minChildSize: 0.36,
      builder: (context, controller) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _bgColor,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          //color: Colors.white30,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            //color: Colors.white, //background color of box

            BoxShadow(
              color: Color(0xffeeaeca),
              blurRadius: 25.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
              offset: Offset(
                -3.0, // Move to right 10  horizontally
                -3.0, // Move to bottom 10 Vertically
              ),
            ),
          ],
        ),
        child: FutureBuilder<List<PomodoroTimer>>(
            future: getCategoryList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView.builder(
                  controller: controller,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) => Container(
                      //padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Color(0xffeeaeca),
                        border:
                            Border.all(width: 1.0, color: _counterShadows[1]),
                        boxShadow: [
                          //color: Colors.white, //background color of box

                          BoxShadow(
                            color: Color(0xffffe8e8), //_bgColor[0],
                            blurRadius: 15.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                            offset: Offset(
                              -4.0, // Move to right 10  horizontally
                              -4.0, // Move to bottom 10 Vertically
                            ),
                          ),
                          BoxShadow(
                            color: _counterShadows[1],
                            blurRadius: 15.0, // soften the shadow
                            spreadRadius: 1.0, //extend the shadow
                            offset: Offset(
                              3.0, // Move to right 10  horizontally
                              3.0, // Move to bottom 10 Vertically
                            ),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.fromLTRB(30, 0, 30, 20),
                      child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            //width: MediaQuery.of(context).size.width * 0.1,
                            height: 70,
                            child: Icon(
                              Icons.ac_unit_outlined,
                              color: Colors.white,
                            ),
                          ),
                          Flex(
                            direction: Axis.vertical,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //  width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  snapshot.data[index].taskName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                //width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  snapshot.data[index].duration,
                                  style: TextStyle(
                                    color: Color(0xffa9abd6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(snapshot.data[index].createdDate),
                          )
                        ],
                      )),
                  physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                );
              } else {
                return Container();
              }
            }),
      ),
    );
  }
}
