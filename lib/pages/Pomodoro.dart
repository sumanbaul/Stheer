import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:notifoo/widgets/button_widget.dart';

class Pomodoro extends StatefulWidget {
  Pomodoro({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PomodoroState createState() => _PomodoroState();
}

class _PomodoroState extends State<Pomodoro> {
  Duration duration = Duration();
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer timer;

  void resetTimer() {
    setState(() => seconds = maxSeconds);
  }

  void stopTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }
    setState(() {
      timer.cancel();
    });
  }

  void startTimer({bool reset = true}) {
    if (reset) {
      resetTimer();
    }

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {
          seconds--;
        });
      } else {
        stopTimer(reset: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: Topbar.getTopbar(widget.title),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTimer(),
              buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtons() {
    final isRunning = timer == null ? false : timer.isActive;
    final isCompleted = seconds == maxSeconds || seconds == 0;

    return isRunning || !isCompleted
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ButtonWidget(
                  text: isRunning ? 'Pause' : 'Resume',
                  color: Colors.black,
                  backgroundColor: Colors.red,
                  onClicked: () {
                    if (isRunning) {
                      stopTimer(reset: false);
                    } else {
                      startTimer(reset: false);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: ButtonWidget(
                  text: 'Cancel',
                  color: Colors.black,
                  backgroundColor: Colors.red,
                  onClicked: () {
                    stopTimer();
                  },
                ),
              ),
            ],
          )
        : Flexible(
            child: ButtonWidget(
              text: 'Start Pomodoro',
              color: Colors.white,
              backgroundColor: Colors.pink,
              onClicked: () {
                startTimer();
              },
            ),
          );
  }

  Widget buildTimer() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 0),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1 - seconds / maxSeconds,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.red,
                strokeWidth: 12,
              ),
              Center(
                child: buildTime(),
              ),
            ],
          ),
        ),
      );

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    //final seconds = twoDigits(duration.inMinutes.remainder(60));
    return Text(
      '$seconds',
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white, fontSize: 120),
    );
  }
}
