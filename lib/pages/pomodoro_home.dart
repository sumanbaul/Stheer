import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Pomodoro/BannerPomodoro.dart';
import 'package:notifoo/widgets/Pomodoro/PomodoroTaskWidget.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/home/Banner.dart';

class PomodoroHome extends StatefulWidget {
  PomodoroHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

List<Color> _pagePomodoroColor = [Color(0xffecccc0), Color(0xffe7c1ed)];

class _PomodoroHomeState extends State<PomodoroHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE7C1ED), // Color(
      // 0xff3F2F40), //Color.fromRGBO(139, 67, 152, 1.0), //Color.fromRGBO(58, 66, 86, 1.0),
      body: SafeArea(
        maintainBottomViewPadding: true,
        top: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _pagePomodoroColor,

              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              //stops: _stops
            ),
          ),
          child: Column(
            children: [
              PomodoroBannerW(),
              TaskWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
