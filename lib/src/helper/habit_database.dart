//reference our box
import 'package:hive_flutter/hive_flutter.dart';
import 'datetime/date_time.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];
  List todaysHabitListNew = [];
  Map<DateTime, int>? heatMapDataSet = {};

  //create initial default data
  void createDefaultData() {
    // data structure for today's list
    todaysHabitList = [
      ["Morning Run", false],
      ["Meditate", false],
    ];

    todaysHabitListNew = [
      ["Morning Run", false, 5],
      ["Meditate", false, 0],
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
    _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);
  }

  // load data if it already exists
  void loadData() {
    // check if its a new day, get habit list from database
    if ((_myBox.get(todaysDateFormatted())) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      // set all habit completed to false since is a new day
      for (var i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
    // if its not a new day, load today's list
    else {
      // _myBox.delete(todaysDateFormatted());
      //_myBox.put("START_DATE", "20230307");
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  void loadPreviousData(DateTime? date) {
    if ((_myBox.get(convertDateTimeToString(date!))) != null) {
      todaysHabitList = _myBox.get(convertDateTimeToString(date));
      // todaysHabitList;
    } else {
      //(if _mybox.get(date) doesnt have data)
      //check if date is a future date than today
      if (!date.isAfter(DateTime.now())) {
        todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
        // set all habit completed to false since is a new day
        for (var i = 0; i < todaysHabitList.length; i++) {
          todaysHabitList[i][1] = false;
        }
        _myBox.put(convertDateTimeToString(date), todaysHabitList);

        // return todaysHabitList;
      } else {
        todaysHabitList = [];
      }
    }
  }

  //update database
  void updateDatabase(DateTime selectedDate) {
    var startDate = _myBox.get("START_DATE");

    if (createDateTimeObject(startDate).isAfter(selectedDate)) {
      _myBox.put("START_DATE", convertDateTimeToString(selectedDate));
    }

    if (selectedDate == DateTime.now()) {
      // update todays entry
      _myBox.put(todaysDateFormatted(), todaysHabitList);
      //update universal habit list in case it changed (new habit, edit habit, delete habit)
      _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);
    } else {
      _myBox.put("${convertDateTimeToString(selectedDate)}", todaysHabitList);
      //update universal habit list in case it changed (new habit, edit habit, delete habit)
      _myBox.put("CURRENT_HABIT_LIST", todaysHabitList);
    }

    calculateHabitPercentages(selectedDate);
    loadHeatMap();
  }

  calculateHabitPercentages(DateTime selectedDate) {
    int countCompleted = 0;
    for (var i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        countCompleted++;
      }
    }

    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

    // key: "PERCENTAGE_SUMMARY_yyyymmdd"
    // value: string of 1dp number between 0.0-1.0 inclusive
    _myBox.put(
        "PERCENTAGE_SUMMARY_${convertDateTimeToString(selectedDate)}", percent);
    //print(_myBox.get("PERCENTAGE_SUMMARY_${todaysDateFormatted()}"));
    //print(_myBox.values);
  }

  getHabitPercentages(DateTime date) {
    //Get percentage of requested date!
    double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_${convertDateTimeToString(date)}") ??
            "0.0");
    return strengthAsPercent;
  }

  loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    // COUNT NUMBER OF DAYS TO LOAD
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to today and add each percentage to the dataset
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the db
    for (var i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strengthAsPercent = double.parse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      // split the datetime up like below so it doesnrt worry about hours/mins/secs etc

      //year
      int year = startDate.add(Duration(days: i)).year;

      // month
      int month = startDate.add(Duration(days: i)).month;

      // day
      int day = startDate.add(Duration(days: i)).day;

      final percentageForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      heatMapDataSet?.addEntries(percentageForEachDay.entries);
      //print(heatMapDataSet);
    }
  }
}
