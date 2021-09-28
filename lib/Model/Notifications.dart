class Notifications {
  final int id;
  final String infoText;
  final List<String> textLines;
  final String summaryText;
  final bool showWhen;
  final String package_name;
  final String text;
  final String title;
  final String subText;
  final int timestamp;
  static const String TABLENAME = "notifications";

  Notifications(
      {this.id,
      this.infoText,
      this.textLines,
      this.summaryText,
      this.showWhen,
      this.package_name,
      this.text,
      this.title,
      this.subText,
      this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'infoText': infoText,
      'textLines': textLines,
      'summaryText': summaryText,
      'showWhen': showWhen,
      'package_name': package_name,
      'text': text,
      'title': title,
      'subText': subText,
      'timestamp': timestamp
    };
  }
}
