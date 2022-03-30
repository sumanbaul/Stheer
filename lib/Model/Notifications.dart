import 'package:flutter/cupertino.dart';

class Notifications {
  final int? id;
  final String? appTitle;
  //final Icon? appIcon;
  final String? title;
  final String? text;
  final String? message;
  final String? packageName;
  final int? timestamp;
  final String? createAt;
  final String? eventJson;
  final String? summaryText;
  final List<String>? textLines;
  final String? createdDate;
  final int? isDeleted;
  //final String signature;

  static const String TABLENAME = "notifications";

  Notifications(
      {this.id,
      this.title,
      this.appTitle,
      // this.appIcon,
      this.text,
      this.message,
      this.packageName,
      this.timestamp,
      this.createAt,
      this.eventJson,
      this.summaryText,
      this.textLines,
      this.createdDate,
      this.isDeleted
      //this.signature
      });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'appTitle': appTitle,
      //'appIcon': appIcon,
      'text': text,
      'message': message,
      'packageName': packageName,
      'timestamp': timestamp,
      'createAt': createAt,
      'eventJson': eventJson,
      'createdDate': createdDate,
      'isDeleted': isDeleted
      //'signature': signature
    };
  }

  Map<String, dynamic> toMapDb() {
    return {
      'id': id,
      'title': title,
      'appTitle': appTitle,
      // 'appIcon': appIcon,
      'text': text,
      'message': message,
      'packageName': packageName,
      'timestamp': timestamp,
      'createAt': createAt,
      'eventJson': eventJson,
      'createdDate': createdDate,
      'isDeleted': isDeleted
      //'signature': signature
    };
  }
}
