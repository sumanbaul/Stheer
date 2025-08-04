import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/src/logic/notification_lister_logic.dart';

class NotificationListerModel extends ChangeNotifier {
  late NotificationListerPageLogic logic;
  BuildContext? context;

  bool? started;
  bool? loading;
  String? packageName;
  List<NotificationEvent> log = [];
  Application? app;

  NotificationListerModel() {
    logic = NotificationListerPageLogic(this);
  }

  void setContext(BuildContext context) {
    if (this.context == null) {
      this.context = context;
      Future.wait([
        logic.initPlatformState(),
      ]).then((value) => refresh());
    }
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("Notification Lister Model");
  }

  void refresh() {
    notifyListeners();
  }
}
