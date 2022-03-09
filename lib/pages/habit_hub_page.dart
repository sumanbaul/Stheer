import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/headers/subHeader.dart';

import '../widgets/navigation/nav_drawer_widget.dart';

class HabitHubPage extends StatelessWidget {
  const HabitHubPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(),
        body: Builder(
          builder: (context) => SafeArea(
            maintainBottomViewPadding: true,
            top: false,
            bottom: false,
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Topbar(
                      title: this.title!,
                      onClicked: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  SubHeader(title: "Today's Notifications"),
                  Container(
                    child: Expanded(
                      child: Text('Description'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
