import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/logic/notification_lister_logic.dart';

class NotificationListerModel extends ChangeNotifier {
  NotificationListerPageLogic logic;
  BuildContext context;
  bool started;
  String packageName;
  List<NotificationEvent> log = [];
}
