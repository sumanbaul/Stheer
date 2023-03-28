import 'package:dio/dio.dart';
import 'package:stheer/src/helper/DatabaseHelper.dart';
import '../../model/tasks.dart';

class TasksApiProvider {
  Future<List<Tasks?>> getAllTasks() async {
    var url = "https://demo1513143.mockable.io/tasks";
    Response response = await Dio().get(url);

    return (response.data as List).map((tasks) {
      print('Inserting $tasks');
      DatabaseHelper.instance.createTask(Tasks.fromJson(tasks));
    }).toList();
  }
}
