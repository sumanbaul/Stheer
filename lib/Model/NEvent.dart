class NEvent {
  DateTime createAt;
  int timestamp;
  String packageName;
  String title;
  String text;
  String message;

  // dynamic _data;

  NEvent({
    this.createAt,
    this.packageName,
    this.title,
    this.text,
    this.message,
    this.timestamp,
  });
}
