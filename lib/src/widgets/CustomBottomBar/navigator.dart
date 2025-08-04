import 'package:flutter/material.dart';
import 'package:notifoo/src/pages/Homepage.dart';
import 'package:notifoo/src/pages/Pomodoro.dart';
import 'package:notifoo/src/pages/pomodoro_home.dart';
import 'package:notifoo/src/pages/SignIn.dart';
import 'package:notifoo/src/pages/habit_tracker.dart';
import 'package:notifoo/src/pages/habit_hub_page.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'package:notifoo/src/widgets/CustomBottomBar/BottomNavigation.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';

import '../../../src/model/Notifications.dart';
import '../../pages/Profile.dart';
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
  static int currentTab = 0;
  final GlobalKey<ScaffoldState> scaffoldKey;
  late final List<TabItem> tabs;

  AppState({required this.scaffoldKey}) {
    tabs = [
      TabItem(
        tabName: "Notifications",
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        page: Homepage(
          title: 'Notifoo',
          openNavigationDrawer: () => scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      TabItem(
        tabName: "Habits",
        icon: Icons.track_changes_outlined,
        activeIcon: Icons.track_changes,
        page: HabitHubPage(
          title: 'Habits',
          openNavigationDrawer: () => scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      TabItem(
        tabName: "Pomodoro",
        icon: Icons.timer_outlined,
        activeIcon: Icons.timer,
        page: PomodoroHome(
          title: 'Pomodoro',
          openNavigationDrawer: () => scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      TabItem(
        tabName: "Tasks",
        icon: Icons.task_outlined,
        activeIcon: Icons.task,
        page: TaskPage(
          openNavigationDrawer: () => scaffoldKey.currentState!.openDrawer(),
        ),
      ),
    ];

    tabs.asMap().forEach((index, details) {
      details.setIndex(index);
    });
  }

  void _selectTab(int index) {
    if (index == currentTab) {
      tabs[index].key.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() => currentTab = index);
    }
  }

  void openNavigationDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: NavigationDrawerWidget(),
      body: IndexedStack(
        index: currentTab,
        children: tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tabs.map((tab) {
                return _buildTabItem(tab);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(TabItem tab) {
    bool isSelected = currentTab == tab.index;
    
    return GestureDetector(
      onTap: () => _selectTab(tab.index!),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.activeIcon : tab.icon,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              tab.tabName!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
