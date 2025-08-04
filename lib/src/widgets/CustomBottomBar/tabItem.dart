import 'package:flutter/material.dart';
import 'navigator.dart';

class TabItem {
  final String? tabName;
  final IconData? icon;
  final IconData? activeIcon;
  final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  int _index = 0;
  Widget? _page;
  
  TabItem({
    @required this.tabName,
    @required this.icon,
    this.activeIcon,
    @required Widget? page,
  }) {
    _page = page!;
  }

  void setIndex(int i) {
    _index = i;
  }

  int getIndex() => _index;
  
  int? get index => _index;

  Widget get page {
    return Visibility(
      visible: _index == AppState.currentTab,
      maintainState: true,
      child: Navigator(
        key: key,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (_) => _page!,
          );
        },
      ),
    );
  }
}
