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

  // Factory constructor that creates an instance of Tasks from a map
  factory Tasks.fromMap(Map<String, dynamic> map) {
    return Tasks(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'],
      taskType: map['taskType'],
      color: map['color'],
      createdDate:
          map['createdDate'] != "" ? DateTime.parse(map['createdDate']) : null,
      modifiedDate: map['modifiedDate'] != ""
          ? DateTime.parse(map['modifiedDate'])
          : null,
      repeatitions: map['repeatitions'],
    );
  }

  factory Tasks.fromJson(Map<String, dynamic> json) => Tasks(
        id: json["id"],
        title: json["title"],
        isCompleted: json["isCompleted"],
        color: json["color"],
        createdDate:
            json["createdDate"].isEmpty || json["createdDate"] != "null"
                ? DateTime.parse(json["createdDate"])
                : null,
        modifiedDate:
            (json["modifiedDate"].isEmpty || json["modifiedDate"] != "null")
                ? DateTime.parse(json["modifiedDate"])
                : null,
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
