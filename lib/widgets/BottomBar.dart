import 'package:flutter/material.dart';

class BottomBar {
  static getBottomBar(BuildContext context) {
    final makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color: Color(0xff0A0E21), //Color.fromRGBO(58, 66, 86, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.notification_add, color: Colors.white),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/'
                    //NotificationsLog(title: "Notifoo"),
                    );
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.blur_on, color: Colors.white),
            //   onPressed: () {
            //     Navigator.popAndPushNamed(context, '/second'
            //         //   MaterialPageRoute(
            //         //       builder: (context) => TestPage(title: "Test Page")),
            //         );
            //   },
            // ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/profile');
              },
            ),
            IconButton(
              icon: Icon(Icons.account_box, color: Colors.white),
              onPressed: () {},
            )
          ],
        ),
      ),
    );

    return makeBottom;
  }
}
