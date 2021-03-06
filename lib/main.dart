import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:notifoo/helper/AppListHelper.dart';
import 'package:notifoo/helper/provider/google_sign_in.dart';
import 'package:notifoo/pages/Homepage.dart';
import 'package:notifoo/pages/Pomodoro.dart';
import 'package:notifoo/pages/Profile.dart';
import 'package:notifoo/pages/SignIn.dart';
// import 'package:notifoo/pages/SplashScreen.dart';
// import 'package:notifoo/pages/TestPage.dart';
// import 'package:notifoo/pages/habit_hub_page.dart';
import 'package:notifoo/widgets/CustomBottomBar/navigator.dart';
import 'helper/DatabaseHelper.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

Future main() async {
  //Init all required async components
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseHelper.instance.initializeDatabase();
  //await AppListHelper.getApps();
  debugPaintSizeEnabled = false;
  runApp(MyApp());
  Eraser.clearAllAppNotifications();
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
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            //statusBarColor: Colors.transparent, //i like transaparent :-)
            systemNavigationBarColor: Color.fromARGB(235, 34, 32,
                48), //Color.fromARGB(255, 33, 31, 46), // navigation bar color
            statusBarIconBrightness: Brightness.dark, // status bar icons' color
            systemNavigationBarIconBrightness:
                Brightness.dark, //navigation bar icons' color
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              primaryColor:
                  Color.fromARGB(255, 20, 20, 20), //Color(0xff0A0E21),
              scaffoldBackgroundColor: Color.fromARGB(
                  235, 34, 32, 48), // Color.fromARGB(235, 34, 32, 48),
              brightness: Brightness.dark,
              textTheme: TextTheme(
                bodyText2: getBarlowFont(),
                bodyText1: getBarlowFont(),
                subtitle1: getBarlowFont(),
              ),
            ),
            initialRoute: '/',
            routes: {
              // When navigating to the "/" route, build the FirstScreen widget.
              '/': (context) => App(),
              // When navigating to the "/splash" route, build the SecondScreen widget.

              //'/home': (context) => Homepage(title: "Home"),
              // '/second': (context) => TestPage(title: "Test"),
              //'/splash': (context) => SplashScreen(),
              // '/habits': (context) => HabitHubPage(),

              '/signin': (context) => SignIn(),
              '/profile': (context) => Profile(title: "Profile"),
              //'/app': (context) => App(),
              '/pomodoro': (context) => Pomodoro(title: "Pomodoro"),
            },
          ),
        ),
      );
}
