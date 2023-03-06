import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifoo/src/components/monthly_summary.dart';
import 'package:notifoo/src/helper/habit_database.dart';

import '../components/floating_action_btn.dart';
import '../components/habit_tile.dart';
import '../components/my_alert_box.dart';

class HabitTracker extends StatefulWidget {
  const HabitTracker({Key? key}) : super(key: key);

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    // if there is no current habit list, then this is the first time opening the app
    //then create default data
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    }

    // there already exists data, this is not the first time
    else {
      db.loadData();
    }

    db.updateDatabase();
    super.initState();
  }

  //check box was tapped
  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value!;
    });

    db.updateDatabase();
  }

  //create a new habit
  final _newHabitController = TextEditingController();
  void createNewHabit() {
    //show alert dialog for the user to add a habit
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            habitTextController: _newHabitController,
            onSave: saveNewHabit,
            onCancel: cancelDialog,
            hintText: "Enter a new habit",
          );
        });
  }

  //save new habit
  void saveNewHabit() {
    //add new habit to todays list
    setState(() {
      db.todaysHabitList.add([_newHabitController.text, false]);
    });

    //clear text field
    _newHabitController.clear();

    //pop dialog box(use the below code to pop without popping root page)
    Navigator.of(context, rootNavigator: true).pop();
    db.updateDatabase();
  }

  //settings clicked
  void openHabitSettings(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return MyAlertBox(
            habitTextController: _newHabitController,
            onSave: () => saveExistingHabit(index),
            onCancel: cancelDialog,
            hintText: db.todaysHabitList[index][0],
          );
        });
  }

  void saveExistingHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newHabitController.text;
    });

    Navigator.of(context, rootNavigator: true).pop();
    db.updateDatabase();
  }

  //cancel new habit
  void cancelDialog() {
    //clear text field
    _newHabitController.clear();
    //pop dialog box(use the below code to pop without popping root page)
    Navigator.of(context, rootNavigator: true).pop();
  }

  //on delete
  void deleteHabit(int? index) {
    setState(() {
      db.todaysHabitList.removeAt(index!);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: FloatingActionBtn(
        onPressed: createNewHabit,
      ),
      body: ListView(
        children: [
          //monthly sumary heatmap
          MonthlySummaryHeatmap(datasets: db.heatMapDataSet, startDate: _myBox.get("START_DATE")),

          //List of habits
          ListView.builder(
            itemCount: db.todaysHabitList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return HabitTile(
                habitName: db.todaysHabitList[index][0],
                habitCompleted: db.todaysHabitList[index][1],
                onChanged: (value) => checkBoxTapped(value, index),
                settingsTapped: (context) => openHabitSettings(index),
                deleteTapped: (context) => deleteHabit(index),
              );
            }),
          ),
        ],
      ),
    );
  }
}
