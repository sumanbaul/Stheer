class PomodoroTimer {
  final int id;
  final String taskName;
  final String duration;
  final int isCompleted;
  final DateTime createdDate;
  final int isDeleted;

  static const String TABLENAME = "tbl_pomodoro_log";

  PomodoroTimer({
    this.id,
    this.taskName,
    this.duration,
    this.isCompleted,
    this.createdDate,
    this.isDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'duration': duration,
      'isCompleted': isCompleted,
      'createdDate': createdDate,
      'isDeleted': isDeleted
    };
  }
}
