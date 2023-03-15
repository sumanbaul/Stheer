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
  State<StatefulWidget> createState() =>
      AppState(scaffoldKey: GlobalKey<ScaffoldState>());
}

class AppState extends State<App> {
  // this is static property so other widget throughout the app
  // can access it simply by AppState.currentTab
  static int currentTab = 0;

  // declare a key for scaffold
  final GlobalKey<ScaffoldState> scaffoldKey;

  // list tabs here
  late final List<TabItem> tabs;

  AppState({required this.scaffoldKey}) {
    tabs = [
      TabItem(
        tabName: "Home",
        icon: Icons.notifications_active_outlined,
        page: Homepage(
          title: 'Stheer',
          openNavigationDrawer: () => scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      TabItem(
        tabName: "Pomodoro",
        icon: Icons.timer_sharp,
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
        tabName: "Habits",
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

  void openNavigationDrawer() {
    Scaffold.of(context).openDrawer();
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
          key: scaffoldKey,
          drawer: NavigationDrawerWidget(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          extendBody: false,
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {},
          //   backgroundColor: Color.fromRGBO(233, 99, 150, 1),
          //   child: Icon(Icons.abc),
          // ),
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
            // notchMargin: 10.0,
            //shape: const CircularNotchedRectangle(),
            //color: Color.fromARGB(255, 254, 254, 255),
            elevation: 0,
          )),
    );
  }
}
