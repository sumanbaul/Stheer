import 'package:flutter/material.dart';
import 'package:notifoo/src/pages/Homepage.dart';
import 'package:notifoo/src/pages/Pomodoro.dart';
import 'package:notifoo/src/pages/habit_tracker.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'package:notifoo/src/widgets/CustomBottomBar/BottomNavigation.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';

import '../../../src/model/Notifications.dart';
import 'TabItem.dart';

class App extends StatefulWidget {
  App({
    Key? key,
    this.notificationsFromDb,
  });
  final List<Notifications>? notificationsFromDb;

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;

  // list tabs here
  final List<TabItem> tabs = [
    TabItem(
      tabName: "Home",
      icon: Icons.home,
      page: Homepage(
        title: 'Stheer',
      ),
    ),
    TabItem(
      tabName: "Pomodoro",
      icon: Icons.person,
      page: Pomodoro(
        title: 'Pomodoro',
      ),
    ),
    // TabItem(
    //   tabName: "Tasks",
    //   icon: Icons.add_task_rounded,
    //   page: TaskPage(),
    //   // page: HabitHubPage(
    //   //   title: 'Profile',
    //   // ),
    // ),
    TabItem(
      tabName: "Habit Tracker",
      icon: Icons.add_task_rounded,
      page: HabitTracker(
          //title: 'Pomodoro Home',
          ),
    ),
    // TabItem(
    //   tabName: "Pomodoro Home",
    //   icon: Icons.settings,
    //   page: PomodoroHome(
    //     title: 'Pomodoro Home',
    //   ),
    // ),
  ];

  AppState() {
    // indexing is necessary for proper funcationality
    // of determining which tab is active
    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  // sets current tab index
  // and update state
  void _selectTab(int index) {
    if (index == currentTab) {
      // pop to first route
      // if the user taps on the active tab
      tabs[index].key.currentState!.popUntil((route) => route.isFirst);
    } else {
      // update the state
      // in order to repaint
      setState(() => currentTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope handle android back btn
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await tabs[currentTab].key.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (currentTab != 0) {
            // select 'main' tab
            _selectTab(0);
            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      // this is the base scaffold
      // don't put appbar in here otherwise you might end up
      // with multiple appbars on one screen
      // eventually breaking the app
      child: Scaffold(
          drawer: NavigationDrawerWidget(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          extendBody: false,
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Color.fromRGBO(233, 99, 150, 1),
            child: Icon(Icons.abc),
          ),
          //drawer: NavigationDrawerWidget(),
          body: IndexedStack(
            index: currentTab,
            children: tabs.map((e) => e.page).toList(),
          ),
          // Bottom navigation
          bottomNavigationBar: BottomAppBar(
            child: BottomNavigation(
              onSelectTab: _selectTab,
              tabs: tabs,
            ),
            // notchMargin: 4.0,
            notchMargin: 10.0,
            shape: const CircularNotchedRectangle(),
            color: Color.fromARGB(235, 34, 32, 48),
            elevation: 0,
          )),
    );
  }
}
