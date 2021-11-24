import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/helper/provider/google_sign_in.dart';
import 'package:notifoo/pages/Homepage.dart';
import 'package:notifoo/pages/Profile.dart';
import 'package:notifoo/pages/SignIn.dart';
import 'package:notifoo/pages/SplashScreen.dart';
import 'package:notifoo/pages/TestPage.dart';
import 'package:notifoo/widgets/CustomBottomBar/navigator.dart';
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

  TextStyle getBarlowFont() {
    return GoogleFonts.barlowSemiCondensed(
      textStyle: TextStyle(
        letterSpacing: 1.2,
        //fontSize: 20.0,
        // fontWeight: FontWeight.bold,
        //color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            primaryColor: Color(0xff0A0E21),
            scaffoldBackgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
            brightness: Brightness.dark,
            textTheme: TextTheme(
              bodyText2: getBarlowFont(),
              bodyText1: getBarlowFont(),
              subtitle1: getBarlowFont(),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => NotificationsLister(title: "Notifoo"),
            // When navigating to the "/splash" route, build the SecondScreen widget.
            '/home': (context) => Homepage(title: "Home"),
            '/second': (context) => TestPage(title: "Test"),
            '/splash': (context) => SplashScreen(),
            '/signin': (context) => SignIn(),
            '/profile': (context) => Profile(title: "Profile"),
            '/app': (context) => App(),
            '/pomodoro': (context) => Profile(title: "Pomodoro"),
          },
        ),

        // title: "Notifoo",
        // home: new NotificationsLog(title: "Notifoo"),
      );
}
