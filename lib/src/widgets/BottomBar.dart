import 'package:flutter/material.dart';

class BottomBar {
  static getBottomBar(BuildContext context) {
    final makeBottom = Container(
      height: 60.0,
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,

        color: Colors
            .blueGrey, //Color(0xff0A0E21), //Color.fromRGBO(58, 66, 86, 1.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.notification_add, color: Colors.white),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/'
                    //NotificationsLog(title: "stheer"),
                    );
              },
            ),
            IconButton(
              icon: Icon(Icons.blur_on, color: Colors.white),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/pomodoro'
                    //   MaterialPageRoute(
                    //       builder: (context) => TestPage(title: "Test Page")),
                    );
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/profile');
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.account_box, color: Colors.white),
            //   onPressed: () {},
            // )
          ],
        ),
      ),
    );

    return makeBottom;
  }
}
