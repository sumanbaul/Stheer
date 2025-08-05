import 'package:flutter/material.dart';
import 'package:notifoo/src/pages/Pomodoro.dart';
import 'package:notifoo/src/pages/Profile.dart';
import 'package:notifoo/src/pages/habit_tracker.dart';
import 'package:notifoo/src/pages/habit_hub_page.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'package:notifoo/src/pages/insights_page.dart';
import 'package:notifoo/src/pages/pomodoro_home.dart';
import 'package:notifoo/src/pages/SplashScreen.dart';
import 'package:notifoo/src/pages/Homepage.dart';
import 'package:notifoo/src/widgets/CustomBottomBar/navigator.dart';

class Routes {
  late Map<String, Widget Function(BuildContext)> route;

  getRoute() {
    route = {
      '/': (context) => SplashScreen(),
      '/app': (context) => App(),
      '/home': (context) => HabitTracker(),
      '/signin': (context) => Profile(),
      '/profile': (context) => Profile(title: "Profile"),
      '/pomodoro': (context) => PomodoroHome(title: "Timer"),
      '/habits': (context) => HabitHubPage(title: "Habits"),
      '/tasks': (context) => TaskPage(),
      '/insights': (context) => InsightsPage(),
      '/alerts': (context) => Homepage(
        title: "Alerts",
        openNavigationDrawer: () {},
      ),
    };

    return route;
  }
}
