import 'package:stheer/src/helper/NotificationsHelper.dart';

import '../../src/model/Notifications.dart';
import '../../src/model/Notifications.dart';

class NotificationsFactory {
  static final NotificationsFactory _singleton =
      NotificationsFactory._internal();

  factory NotificationsFactory() {
    return _singleton;
  }

  NotificationsFactory._internal();

  initializeDatabase() async {
    return NotificationsHelper.initializeDbGetNotificationsToday;
  }
}

// abstract class NotificationsBase {
//   @protected
//   List<Future<Notifications>> initialNotification;
//   @protected
//   List<Future<Notifications>> notifications;

//   String get currentText => notifications;

//   void setStatess(){
//     notifications = 
//   }
// }
