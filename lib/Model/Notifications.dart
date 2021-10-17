// class Notifications {
//   final int id;
//   final String title;
//   final String infoText;
//   //final List<String> textLines;
//   final String summaryText;
//   final int showWhen;
//   final String package_name;
//   final String text;

//   final String subText;
//   final String timestamp;
//   static const String TABLENAME = "notifications";

//   Notifications(
//       {this.id,
//       this.title,
//       this.infoText,
//       //this.textLines,
//       this.summaryText,
//       this.showWhen,
//       this.package_name,
//       this.text,
//       this.subText,
//       this.timestamp});

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'infoText': infoText,
//       //'textLines': textLines,
//       'summaryText': summaryText,
//       'showWhen': showWhen,
//       'package_name': package_name,
//       'text': text,

//       'subText': subText,
//       'timestamp': timestamp
//     };
//   }
// }

class Notifications {
  final int id;
  final String title;
  final String text;
  final String message;
  final String packageName;
  final int timestamp;
  final String createAt;
  final String eventJson;
  final String summaryText;
  final List<String> textLines;

  static const String TABLENAME = "notifications";

  Notifications(
      {this.id,
      this.title,
      this.text,
      this.message,
      this.packageName,
      this.timestamp,
      this.createAt,
      this.eventJson,
      this.summaryText,
      this.textLines});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'message': message,
      'packageName': packageName,
      'timestamp': timestamp,
      'createAt': createAt,
      'eventJson': eventJson
    };
  }
}
