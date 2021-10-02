class Notifications {
  final int id;
  final String title;
  final String infoText;
  //final List<String> textLines;
  final String summaryText;
  final int showWhen;
  final String package_name;
  final String text;

  final String subText;
  final String timestamp;
  static const String TABLENAME = "notifications";

  Notifications(
      {this.id,
      this.title,
      this.infoText,
      //this.textLines,
      this.summaryText,
      this.showWhen,
      this.package_name,
      this.text,
      this.subText,
      this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'infoText': infoText,
      //'textLines': textLines,
      'summaryText': summaryText,
      'showWhen': showWhen,
      'package_name': package_name,
      'text': text,

      'subText': subText,
      'timestamp': timestamp
    };
  }

  // Notifications.FromJson(Map json) {
  //   this.package_name = json["package_name"];
  // }
}
