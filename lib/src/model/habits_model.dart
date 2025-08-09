class HabitsModel {
  final int? id;
  final String? habitTitle;
  final int? isCompleted;
  final String? habitType;
  final String? color;
  final int? repetitionsPerDay; // new
  final String? category; // new
  final String? times; // comma-separated HH:MM list

  static const String TABLENAME = "tblhabits";

  HabitsModel({
    this.id,
    this.habitTitle,
    this.isCompleted,
    this.habitType,
    this.color,
    this.repetitionsPerDay,
    this.category,
    this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitTitle': habitTitle,
      'isCompleted': isCompleted,
      'habitType': habitType,
      'color': color,
      'repetitionsPerDay': repetitionsPerDay,
      'category': category,
      'times': times,
    };
  }

  factory HabitsModel.fromMap(Map<String, dynamic> map) {
    return HabitsModel(
      id: map['id'],
      habitTitle: map['habitTitle'],
      isCompleted: map['isCompleted'],
      habitType: map['habitType'],
      color: map['color'],
      repetitionsPerDay: map['repetitionsPerDay'],
      category: map['category'],
      times: map['times'],
    );
  }
}
