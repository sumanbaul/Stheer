import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Pomodoro/BannerPomodoro.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/home/Banner.dart';

class PomodoroHome extends StatefulWidget {
  PomodoroHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      body: SafeArea(
        maintainBottomViewPadding: true,
        top: false,
        child: Container(
          child: Column(
            children: [
              PomodoroBannerW(),
            ],
          ),
        ),
      ),
    );
  }
}
