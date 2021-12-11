class PomodoroTimer {
  final int id;
  final String taskName;
  final String duration;
  final int isCompleted;
  final String createdDate;
  final int isDeleted;

  static const String TABLENAME = "tblpomodorolog";

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
