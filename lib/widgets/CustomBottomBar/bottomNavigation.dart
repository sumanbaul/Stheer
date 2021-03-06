import 'TabItem.dart';
import 'navigator.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({
    this.onSelectTab,
    this.tabs,
  });
  final ValueChanged<int>? onSelectTab;
  final List<TabItem>? tabs;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      selectedLabelStyle: TextStyle(
        color: Colors.white,
      ),

      unselectedLabelStyle: TextStyle(color: Colors.grey),
      backgroundColor:
          Color.fromARGB(235, 34, 32, 48), //Color.fromARGB(255, 33, 31, 46),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.white,

      items: tabs!
          .map(
            (e) => _buildItem(
              index: e.getIndex(),
              icon: e.icon,
              tabName: e.tabName,
            ),
          )
          .toList(),
      onTap: (index) => onSelectTab!(
        index,
      ),
    );
  }

  BottomNavigationBarItem _buildItem(
      {int? index, IconData? icon, String? tabName}) {
    return BottomNavigationBarItem(
        icon: Icon(
          icon,
          color: _tabColor(index: index),
        ),
        // ignore: deprecated_member_use
        label: tabName,
        backgroundColor: Colors.redAccent,
        tooltip: tabName);
  }

  Color _tabColor({int? index}) {
    return AppState.currentTab == index
        ? Color.fromARGB(255, 255, 255, 255)
        : Colors.grey;
  }
}
