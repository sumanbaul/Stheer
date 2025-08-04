class HabitsModel {
  final int? id;
  final String? habitTitle;
  final int? isCompleted;
  final String? habitType;
  final String? color;

  static const String TABLENAME = "tblhabits";

  HabitsModel({
    this.id,
    this.habitTitle,
    this.isCompleted,
    this.habitType,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitTitle': habitTitle,
      'isCompleted': isCompleted,
      'habitType': habitType,
      'color': color,
    };
  }
}
