import 'package:flutter/material.dart';
import '../../pages/Pomodoro.dart';
import '../../pages/Profile.dart';
import '../../pages/habit_tracker.dart';
import '../../widgets/CustomBottomBar/navigator.dart';

class Routes {
  late Map<String, Widget Function(BuildContext)> route;

  getRoute() {
    route = {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => App(),
      // When navigating to the "/splash" route, build the SecondScreen widget. // currently this is not in use
      //'/splash': (context) => SplashScreen(),
      '/home': (context) => HabitTracker(),
      '/signin': (context) => Profile(),
      '/profile': (context) => Profile(title: "Profile"),
      //'/app': (context) => App(),
      '/pomodoro': (context) => Pomodoro(title: "Pomodoro"),
    };

    return route;
  }
}
