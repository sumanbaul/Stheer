import 'package:notifoo/model/notificationCategory.dart';

import '../model/Notifications.dart';
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
}
