import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/pages/SplashScreen.dart';
import 'pages/TestPage.dart';
import 'widgets/NotificationsLog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //getListOfApps();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Color(0xff0A0E21),
        scaffoldBackgroundColor: Color(0xFF0A0E21),
      ),
      initialRoute: '/splash',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => NotificationsLog(title: "Notifoo"),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/second': (context) => TestPage(title: "Test Page"),
        '/splash': (context) => SplashScreen(),
      },
      // title: "Notifoo",
      // home: new NotificationsLog(title: "Notifoo"),
    );
  }
}
