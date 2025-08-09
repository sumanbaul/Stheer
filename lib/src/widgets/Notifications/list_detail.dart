import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:device_apps/device_apps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/helper/datetime_ago.dart' show readTimestamp;
import 'package:notifoo/src/model/list_detail_model.dart';

class NotificationDetailList extends StatefulWidget {
  NotificationDetailList({
    Key? key,
    this.packageName,
    this.title,
    this.appIcon,
    this.appTitle,
    this.notification,
  }) : super(key: key);

  final String? title;
  final String? packageName;
  final Image? appIcon;
  final String? appTitle;
  final Notification? notification;

  @override
  _NotificationCatgoryListState createState() => _NotificationCatgoryListState();
}

class _NotificationCatgoryListState extends State<NotificationDetailList> {
  ScrollController _controller = new ScrollController();
  List<NotificationModel> _notificationsList = [];

  @override
  void initState() {
    DatabaseHelper.instance.initializeDatabase();
    super.initState();
    getNotificationList();
  }

  Future<void> _launchApp(String packageName) async {
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.appTitle ?? 'Notifications'),
        actions: [
          if (widget.packageName != null)
            IconButton(
              onPressed: () => _launchApp(widget.packageName!),
              icon: Icon(Icons.open_in_new),
              tooltip: 'Open App',
            ),
        ],
      ),
      body: _buildNotificationList(),
    );
  }

  Future<List<NotificationModel>> getNotificationList() async {
    var getNotificationModel = await DatabaseHelper.instance.getNotifications(0);
    List<NotificationModel> notificationList = [];

    getNotificationModel.forEach((key) {
      if (key.packageName!.contains(widget.packageName!)) {
        var _notification = NotificationModel(
          title: key.title,
          text: key.text,
          packageName: key.packageName,
          appTitle: widget.appTitle,
          appIcon: widget.appIcon != null ? widget.appIcon : null,
          timestamp: key.timestamp,
          createAt: key.createAt,
          message: key.message,
          textLines: key.textLines,
          createdDate: key.createdDate,
          isDeleted: key.isDeleted,
        );
        notificationList.add(_notification);
      }
    });

    setState(() {
      _notificationsList = notificationList;
    });

    return notificationList;
  }

  Widget _buildNotificationList() {
    if (_notificationsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'No notifications found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Notifications from this app will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _notificationsList.length,
      itemBuilder: (context, index) {
        final notification = _notificationsList[index];
        return _buildNotificationCard(notification, index);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _launchApp(notification.packageName!),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (notification.appIcon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: notification.appIcon,
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notification.title != null && notification.title!.isNotEmpty)
                            Text(
                              notification.title!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          SizedBox(height: 4),
                          Text(
                            readTimestamp(notification.timestamp!),
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
                if (notification.text != null && notification.text!.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Text(
                    notification.text!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchApp(notification.packageName!),
                        icon: Icon(Icons.open_in_new, size: 18),
                        label: Text('Open App'),
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
