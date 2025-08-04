import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../src/model/notificationCategory.dart';
import 'list_detail.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({
    Key? key,
    this.index,
    required this.notificationsCategory,
    this.notification,
  }) : super(key: key);
  
  final int? index;
  final NotificationCategory? notificationsCategory;
  final Notification? notification;

  Future<void> _launchApp(BuildContext context, String packageName) async {
    try {
      // For sandbox, just show a dialog
      print('Sandbox: Would launch app $packageName');
      
      // In a real app, this would launch the actual app
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sandbox: Would launch $packageName'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      print('Error launching app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12, top: 4),
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailList(
                  packageName: notificationsCategory!.packageName,
                  title: notificationsCategory!.appTitle,
                  appIcon: notificationsCategory!.appIcon,
                  appTitle: notificationsCategory!.appTitle,
                  notification: notification,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: notificationsCategory!.appIcon,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notificationsCategory!.appTitle!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            notificationsCategory!.timestamp.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ],
                ),
                if (notificationsCategory!.message != null) ...[
                  SizedBox(height: 12),
                  Text(
                    notificationsCategory!.message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotificationDetailList(
                                packageName: notificationsCategory!.packageName,
                                title: notificationsCategory!.appTitle,
                                appIcon: notificationsCategory!.appIcon,
                                appTitle: notificationsCategory!.appTitle,
                                notification: notification,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.list_alt, size: 18),
                        label: Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchApp(context, notificationsCategory!.packageName!),
                        icon: Icon(Icons.open_in_new, size: 18),
                        label: Text('Open App'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
