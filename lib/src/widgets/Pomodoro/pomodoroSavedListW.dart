import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stheer/src/helper/DatabaseHelper.dart';
import 'package:stheer/src/model/pomodoro_timer.dart';

class PomodoroSavedListW extends StatefulWidget {
  PomodoroSavedListW({Key? key, this.screenheight}) : super(key: key);

  final screenheight;
  @override
  _PomodoroSavedListWState createState() => _PomodoroSavedListWState();
}

List<Color> _bgColor = [Color(0xffecccc0), Color(0xffe7c1ed)];
List<Color> _counterShadows = [
  Color(0xff762d89),
  Color(0xffc197c9),
];

List<Color> _CardColor = [
  Color(0xffeeaeca),
  Color(0xffc197c9),
];
// Widget buildCounterList() {
//   //return ListView()

//   return Expanded(
//     child: Container(
//       height: 500,
//       child: FutureBuilder<List<PomodoroTimer>>(
//           future: getCategoryList(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return new ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (context, index) => ListTile(
//                   leading: Icon(Icons.ac_unit_outlined),
//                   title: Text(snapshot.data[index].taskName),
//                   subtitle: Text(snapshot.data[index].duration),
//                   trailing: Text(snapshot.data[index].createdDate),
//                 ),
//                 physics: BouncingScrollPhysics(
//                   parent: AlwaysScrollableScrollPhysics(),
//                 ),
//               );
//             } else {
//               return Container();
//             }
//           }),
//     ),
//   );
// }

Future<List<PomodoroTimer>> getCategoryList() async {
  return await DatabaseHelper.instance.getPomodoroTimer();
}

// Widget buildPomodoroCard(BuildContext context, int index) {
//    return null;
// }

class _PomodoroSavedListWState extends State<PomodoroSavedListW> {
  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();
    super.initState();
  }

  var screenHeight = window.physicalSize.height;
  var savedListContainer =
      1 - ((window.physicalSize.height - 500) / window.physicalSize.height);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    print("saved container: $savedListContainer");
    //print("screenHeight: $screenHeight");

    var screenHeight = MediaQuery.of(context).size.height;
    var listContainerInPercentage = ((screenHeight - 540) / screenHeight);
    print("listContainerInPercentage : $listContainerInPercentage");
    return DraggableScrollableSheet(
      initialChildSize: listContainerInPercentage,
      // maxChildSize: 0.7,
      minChildSize: listContainerInPercentage,
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
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Card(
                      elevation: 0.0,
                      margin: EdgeInsets.only(top: 0.0),
                      color: Colors.transparent,
                      child: Stack(children: [
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          // mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              //  margin: EdgeInsets.only(bottom: 10),
                              height: 90,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8.0),
                              decoration: BoxDecoration(
                                  // border: Border.all(
                                  //     width: 1.0, color: _counterShadows[1]),
                                  color: _CardColor[0],
                                  // gradient: LinearGradient(
                                  //   colors: _bgColor,
                                  //   begin: Alignment.topLeft,
                                  //   end: Alignment.bottomRight,
                                  // ),
                                  //color: Color.fromRGBO(40, 48, 59, 1),
                                  // color: Color.fromRGBO(58, 66, 86, 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xffffe8e8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(-3, -3)),
                                    BoxShadow(
                                        color: _counterShadows[1],
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(3, 3)),
                                  ]),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 25.0,
                                              //backgroundImage: _nc[index].appIcon,
                                              child: Icon(
                                                Icons.ac_unit_outlined,
                                                color: Colors.white,
                                              ),
                                              // child: ClipRRect(
                                              //   child: _nc[index].appIcon,
                                              //   borderRadius: BorderRadius.circular(100.0),
                                              // ),
                                              backgroundColor: Colors.white10,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              snapshot.data![index].taskName!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0),
                                            ),
                                          ],
                                        ),
                                        Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            snapshot.data![index].taskName!,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            snapshot.data![index].createdDate!,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ),
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
}
