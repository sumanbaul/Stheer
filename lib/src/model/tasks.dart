import 'dart:convert';

class Tasks {
  final int? id;
  final String? title;
  final int? isCompleted;
  final String? taskType;
  final String? color;
  final DateTime? createdDate;
  final DateTime? modifiedDate;
  final int? repeatitions;

  static const String TABLENAME = "tbltasks";

  List<Tasks> taskFromJson(String str) =>
      List<Tasks>.from(json.decode(str).map((x) => Tasks.fromJson(x)));

  String taskToJson(List<Tasks> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  Tasks(
      {this.id,
      this.title,
      this.isCompleted,
      this.color,
      this.createdDate,
      this.modifiedDate,
      this.repeatitions,
      this.taskType});

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks(
        id: json["id"],
        title: json["title"],
        isCompleted: json["isCompleted"],
        color: json["color"],
        createdDate: DateTime.parse(json["createdDate"]),
        modifiedDate: DateTime.parse(json["modifiedDate"]),
        repeatitions: json["repeatitions"],
        taskType: json["taskType"],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'taskType': taskType,
      'color': color,
      'createdDate': createdDate.toString(),
      'modifiedDate': modifiedDate.toString(),
      'repeatitions': repeatitions
    };
  }
}
