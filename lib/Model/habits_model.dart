class HabitsModel {
  final String? habitTitle;
  final int? isCompleted;
  final String? habitType;
  final String? color;

  static const String TABLENAME = "tblhabitslog";

  HabitsModel({
    this.habitTitle,
    this.isCompleted,
    this.habitType,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitTitle': habitTitle,
      'isCompleted': isCompleted,
      'habitType': habitType,
      'color': color,
    };
  }
}
