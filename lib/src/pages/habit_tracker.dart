import 'package:flutter/material.dart';

import '../components/habit_tile.dart';

class HabitTracker extends StatefulWidget {
  const HabitTracker({Key? key}) : super(key: key);

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  // data structure for today's list
  List todaysHabitList = [
    ["Morning Run", false],
    ["Meditate", false],
    ["Morning Read", false],
  ];

  //check box was tapped
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      todaysHabitList[index][1] = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        itemCount: todaysHabitList.length,
        itemBuilder: ((context, index) {
          return HabitTile(
            habitName: todaysHabitList[index][0],
            habitCompleted: todaysHabitList[index][1],
            onChanged: (value) => checkBoxTapped(value, index),
          );
        }),
      ),
    );
  }
}
