import 'package:flutter/material.dart';
import 'package:notifoo/pages/Profile.dart';
import 'package:notifoo/pages/SignIn.dart';
import 'package:notifoo/pages/SplashScreen.dart';
import 'package:notifoo/pages/TestPage.dart';
import 'package:notifoo/provider/google_sign_in.dart';
import 'pages/NotificationsLister.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xff0A0E21),
            scaffoldBackgroundColor: Color(0xFF0A0E21),
          ),
          initialRoute: '/splash',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => NotificationsLister(title: "Notifoo"),
            // When navigating to the "/splash" route, build the SecondScreen widget.
            '/second': (context) => TestPage(title: "Test"),
            '/splash': (context) => SplashScreen(),
            '/signin': (context) => SignIn(),
            '/profile': (context) => Profile(title: "Profile"),
          },
        ),

        // title: "Notifoo",
        // home: new NotificationsLog(title: "Notifoo"),
      );
}
