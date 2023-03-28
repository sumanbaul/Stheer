import 'package:flutter/material.dart';
import 'package:stheer/src/helper/DatabaseHelper.dart';
import 'package:stheer/src/helper/provider/task_api_provider.dart';
import 'package:stheer/src/model/tasks.dart';
import 'package:stheer/src/pages/add_task.dart';

String _selectedValue = "";

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  //Controllers
  final _repeatitionController = TextEditingController();
  final _taskNameController = TextEditingController();

  // A field value to capture from the child widget
  String taskName = '';
  String taskType = '';
  int repeatitions = 0;

  var isLoading = false;
  Tasks fieldValues = Tasks();

  @override
  void initState() {
    super.initState();
    // Assign this state to the global variable
    //taskPageState = this;
  }

  @override
  void dispose() {
    super.dispose();
    // Clear the global variable when disposing this state
    //taskPageState = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Api to sqlite'),
        centerTitle: true,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.settings_input_antenna),
              onPressed: () async {
                await _loadFromApi();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _deleteData();
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _buildTasksListView(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(_createRouteToAddTask())
              .then((value) async {
            // use your valueFromTextField from the second page
            List<Tasks> taskData =
                value; //value.map((c) => Tasks.fromMap(c)).toList();
            setState(() {
              //fieldValues = taskData;
              isLoading = true;
            });

            await DatabaseHelper.instance.insertTask(taskData.first);

            setState(() {
              isLoading = false;
            });
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white70,
        ),
        splashColor: Colors.blueGrey,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  //When loading from API
  _loadFromApi() async {
    setState(() {
      isLoading = true;
    });

    var apiProvider = TasksApiProvider();
    await apiProvider.getAllTasks();

    // wait for 2 seconds to simulate loading of data
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  //Delete Data
  _deleteData() async {
    setState(() {
      isLoading = true;
    });

    await DatabaseHelper.instance.deleteAllTasks();

    // wait for 1 second to simulate loading of data
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    print('All employees deleted');
  }

  //To Add Task Page
  Route _createRouteToAddTask() {
    print("TaskName: " + taskName);
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddTask(
        repeatitionController: _repeatitionController,
        taskNameController: _taskNameController,
        onPressed: () => {},
        onChanged: (newValue) {
          setState(
            () {
              _selectedValue = newValue!;
              print("_selectedValue: " + _selectedValue);
            },
          );
        },
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  _buildTasksListView() {
    return FutureBuilder(
      future: DatabaseHelper.instance.getAllTasks(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black12,
            ),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              var colorString = "";
              int color = 0;
              if (snapshot.data[index].color.toString().contains("#") &&
                  snapshot.data[index].color.toString() != "") {
                colorString =
                    snapshot.data[index].color.toString().split("#").last;
                color = int.parse('0xFF$colorString');
              } else if (snapshot.data[index].color.toString().length > 6) {
                colorString = snapshot.data[index].color.toString();
                color = int.parse(colorString);
              } else {
                color = 0xFF39375b;
              }

              return ListTile(
                leading: Text(
                  "${index + 1}",
                  style: TextStyle(fontSize: 20.0),
                ),
                title: Text("${snapshot.data[index].title} "),
                subtitle: Text(
                    'Repeat: Type:${snapshot.data[index].taskType} | ${snapshot.data[index].createdDate} '),
                isThreeLine: true,
                trailing: Text('Repeat: ${snapshot.data[index].repeatitions}'),
                tileColor: Color(color),
              );
            },
          );
        }
      },
    );
  }
}
