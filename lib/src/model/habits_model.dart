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

  factory HabitsModel.fromMap(Map<String, dynamic> map) {
    return HabitsModel(
      id: map['id'],
      habitTitle: map['habitTitle'],
      isCompleted: map['isCompleted'],
      habitType: map['habitType'],
      color: map['color'],
    );
  }
}
