import 'package:flutter/material.dart';

class NotificationCategory {
  final int? id;
  final String? appTitle;
  final Image? appIcon;
  final Image? tempIcon;
  final String? message;
  final String? packageName;
  final int? timestamp;
  final int? notificationCount;

  NotificationCategory(
      {this.id,
      this.appIcon,
      this.tempIcon,
      this.appTitle,
      this.message,
      this.packageName,
      this.timestamp,
      this.notificationCount
      //this.signature
      });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appTitle': appTitle,
      'appIcon': appIcon,
      'tempIcon': tempIcon,
      'message': message,
      'packageName': packageName,
      'timestamp': timestamp,
      'notificationCount': notificationCount
      //'signature': signature
    };
  }
}
