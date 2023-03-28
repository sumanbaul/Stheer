import 'package:stheer/src/model/notificationCategory.dart';

import '../../src/model/Notifications.dart';
import 'NotificationsHelper.dart';

class NotificationCatHelper {
  List<Notifications> notifications;

  NotificationCatHelper(this.notifications);

  static Future<List<NotificationCategory>> getNotificationsByCategoryInit(
      bool istoday) async {
    List<Notifications> _notifications =
        await NotificationsHelper.initializeDbGetNotificationsToday(
            istoday ? 0 : 1);

    return await NotificationsHelper.getCategoryListFuture(_notifications);
  }

  static Future<List<NotificationCategory>> getNotificationsByCategoryUpdate(
      Future<List<Notifications>> updatedNotifications, bool istoday) async {
    List<Notifications> _notifications = await updatedNotifications;
    return await NotificationsHelper.getCategoryListFuture(_notifications);
  }

  static Future<List<NotificationCategory>> getNotificationsByCategory(
      Future<List<Notifications>> notifications, bool istoday) async {
    List<Notifications> _notifications = await notifications;
    return await NotificationsHelper.getCategoryListFuture(_notifications);
  }

  static Future<List<NotificationCategory>> getNotificationsByCat(
      List<Notifications> notifications, bool istoday) async {
    //List<Notifications> _notifications = await notifications;
    return await NotificationsHelper.getCategoryListFuture(notifications);
  }
}
