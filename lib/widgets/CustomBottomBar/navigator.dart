import 'package:flutter/material.dart';
import 'package:notifoo/pages/Homepage.dart';
import 'package:notifoo/pages/Pomodoro.dart';
import 'package:notifoo/pages/Profile.dart';
import 'package:notifoo/pages/TestPage.dart';
import 'package:notifoo/pages/pomodoro_home.dart';
import 'package:notifoo/widgets/CustomBottomBar/BottomNavigation.dart';
import 'package:notifoo/widgets/navigation/nav_drawer.dart';

import 'TabItem.dart';

class App extends StatefulWidget {
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
        title: 'Notifoo',
      ),
    ),
    TabItem(
      tabName: "Pomodoro",
      icon: Icons.person,
      page: Pomodoro(
        title: 'Pomodoro',
      ),
    ),
    TabItem(
      tabName: "Settings",
      icon: Icons.settings,
      page: Profile(
        title: 'Profile',
      ),
    ),
    TabItem(
      tabName: "Pomodoro Home",
      icon: Icons.settings,
      page: PomodoroHome(
        title: 'Pomodoro Home',
      ),
    ),
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
      tabs[index].key.currentState.popUntil((route) => route.isFirst);
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
            !await tabs[currentTab].key.currentState.maybePop();
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
        //xtendBody: true,
        // indexed stack shows only one child
        // drawer: Drawer(
        //   child: ListView(
        //     // Important: Remove any padding from the ListView.
        //     padding: EdgeInsets.zero,
        //     children: [
        //       const DrawerHeader(
        //         decoration: BoxDecoration(
        //           color: Colors.blue,
        //         ),
        //         child: Text('Drawer Header'),
        //       ),
        //       ListTile(
        //         title: const Text('Item 1'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //       ListTile(
        //         title: const Text('Item 2 test'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //     ],
        //   ), // Populate the Drawer in the next step.
        // ), //NavDrawer(),
        //drawer: NavigationDrawerWidget(),
        body: IndexedStack(
          index: currentTab,
          children: tabs.map((e) => e.page).toList(),
        ),
        // Bottom navigation
        bottomNavigationBar: BottomNavigation(
          onSelectTab: _selectTab,
          tabs: tabs,
        ),
      ),
    );
  }
}
