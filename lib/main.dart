import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stheer/src/helper/provider/google_sign_in.dart';
import 'package:stheer/src/pages/Pomodoro.dart';
import 'package:stheer/src/pages/Profile.dart';
import 'package:stheer/src/pages/SignIn.dart';
import 'package:stheer/src/pages/habit_tracker.dart';
import 'package:stheer/src/widgets/CustomBottomBar/navigator.dart';
import 'src/helper/DatabaseHelper.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

Future main() async {
  //Init all required async components
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseHelper.instance.initializeDatabase();

  //Initialize Hive
  await Hive.initFlutter();
  //open a box
  await Hive.openBox("Habit_Database");

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
            statusBarColor: Colors.transparent, //i like transaparent :-)
            systemNavigationBarColor: Color.fromARGB(235, 34, 32,
                48), //Color.fromARGB(255, 33, 31, 46), // navigation bar color
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              // primaryColor:
              //     Color.fromARGB(115, 20, 20, 20), //Color(0xff0A0E21),
              scaffoldBackgroundColor: Color.fromARGB(
                  235, 63, 43, 194), // Color.fromARGB(235, 34, 32, 48),
              // brightness: Brightness.dark,
              textTheme: TextTheme(
                bodyText2: getBarlowFont(),
                bodyText1: getBarlowFont(),
                subtitle1: getBarlowFont(),
              ),
            ),
            //theme: ThemeData(primarySwatch: Colors.yellow),
            initialRoute: '/',
            routes: {
              // When navigating to the "/" route, build the FirstScreen widget.
              '/': (context) => App(),
              // When navigating to the "/splash" route, build the SecondScreen widget. // currently this is not in use
              //'/splash': (context) => SplashScreen(),
              '/home': (context) => HabitTracker(),
              '/signin': (context) => SignIn(),
              '/profile': (context) => Profile(title: "Profile"),
              //'/app': (context) => App(),
              '/pomodoro': (context) => Pomodoro(title: "Pomodoro"),
            },
          ),
        ),
      );
}
