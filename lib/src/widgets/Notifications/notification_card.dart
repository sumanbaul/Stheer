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

  IconData _getAppIcon(String? packageName) {
    if (packageName == null) return Icons.apps;
    
    if (packageName.contains("whatsapp")) {
      return Icons.chat;
    } else if (packageName.contains("gmail") || packageName.contains("google.android.gm")) {
      return Icons.mail;
    } else if (packageName.contains("instagram")) {
      return Icons.camera_alt;
    } else if (packageName.contains("facebook")) {
      return Icons.facebook;
    } else if (packageName.contains("twitter") || packageName.contains("x")) {
      return Icons.flutter_dash;
    } else if (packageName.contains("youtube")) {
      return Icons.play_circle;
    } else if (packageName.contains("telegram")) {
      return Icons.send;
    } else if (packageName.contains("discord")) {
      return Icons.games;
    } else if (packageName.contains("slack")) {
      return Icons.work;
    } else if (packageName.contains("linkedin")) {
      return Icons.business;
    } else if (packageName.contains("reddit")) {
      return Icons.forum;
    } else if (packageName.contains("spotify")) {
      return Icons.music_note;
    } else if (packageName.contains("netflix")) {
      return Icons.movie;
    } else if (packageName.contains("uber")) {
      return Icons.local_taxi;
    } else if (packageName.contains("doordash")) {
      return Icons.delivery_dining;
    } else if (packageName.contains("amazon")) {
      return Icons.shopping_cart;
    } else if (packageName.contains("ebay")) {
      return Icons.store;
    } else if (packageName.contains("paypal")) {
      return Icons.payment;
    } else if (packageName.contains("venmo")) {
      return Icons.account_balance_wallet;
    } else if (packageName.contains("bank") || packageName.contains("chase")) {
      return Icons.account_balance;
    } else if (packageName.contains("weather")) {
      return Icons.cloud;
    } else if (packageName.contains("calendar")) {
      return Icons.calendar_today;
    } else if (packageName.contains("clock") || packageName.contains("alarm")) {
      return Icons.access_time;
    } else if (packageName.contains("camera")) {
      return Icons.camera_alt;
    } else if (packageName.contains("gallery") || packageName.contains("photos")) {
      return Icons.photo_library;
    } else if (packageName.contains("maps") || packageName.contains("google.maps")) {
      return Icons.map;
    } else if (packageName.contains("drive") || packageName.contains("google.drive")) {
      return Icons.folder;
    } else if (packageName.contains("dropbox")) {
      return Icons.cloud_queue;
    } else if (packageName.contains("zoom")) {
      return Icons.video_call;
    } else if (packageName.contains("teams")) {
      return Icons.groups;
    } else if (packageName.contains("skype")) {
      return Icons.video_camera_front;
    } else if (packageName.contains("chrome") || packageName.contains("browser")) {
      return Icons.language;
    } else if (packageName.contains("settings")) {
      return Icons.settings;
    } else if (packageName.contains("phone") || packageName.contains("dialer")) {
      return Icons.phone;
    } else if (packageName.contains("messages") || packageName.contains("sms")) {
      return Icons.sms;
    } else if (packageName.contains("contacts")) {
      return Icons.contacts;
    } else if (packageName.contains("calculator")) {
      return Icons.calculate;
    } else if (packageName.contains("notes") || packageName.contains("memo")) {
      return Icons.note;
    } else if (packageName.contains("reminder") || packageName.contains("todo")) {
      return Icons.checklist;
    } else if (packageName.contains("health") || packageName.contains("fitness")) {
      return Icons.favorite;
    } else if (packageName.contains("game") || packageName.contains("play")) {
      return Icons.games;
    } else if (packageName.contains("news")) {
      return Icons.article;
    } else if (packageName.contains("shopping") || packageName.contains("store")) {
      return Icons.shopping_bag;
    } else if (packageName.contains("food") || packageName.contains("restaurant")) {
      return Icons.restaurant;
    } else if (packageName.contains("travel") || packageName.contains("booking")) {
      return Icons.flight;
    } else if (packageName.contains("education") || packageName.contains("learning")) {
      return Icons.school;
    } else if (packageName.contains("finance") || packageName.contains("money")) {
      return Icons.account_balance_wallet;
    } else if (packageName.contains("productivity") || packageName.contains("office")) {
      return Icons.work;
    } else if (packageName.contains("entertainment") || packageName.contains("media")) {
      return Icons.movie;
    } else if (packageName.contains("social") || packageName.contains("chat")) {
      return Icons.people;
    } else if (packageName.contains("utility") || packageName.contains("tool")) {
      return Icons.build;
    } else if (packageName.contains("lifestyle") || packageName.contains("wellness")) {
      return Icons.spa;
    } else if (packageName.contains("sports") || packageName.contains("fitness")) {
      return Icons.sports_soccer;
    } else if (packageName.contains("music") || packageName.contains("audio")) {
      return Icons.music_note;
    } else if (packageName.contains("video") || packageName.contains("streaming")) {
      return Icons.video_library;
    } else if (packageName.contains("photo") || packageName.contains("image")) {
      return Icons.photo;
    } else if (packageName.contains("document") || packageName.contains("file")) {
      return Icons.description;
    } else if (packageName.contains("security") || packageName.contains("vpn")) {
      return Icons.security;
    } else if (packageName.contains("backup") || packageName.contains("cloud")) {
      return Icons.backup;
    } else if (packageName.contains("system") || packageName.contains("android")) {
      return Icons.android;
    } else {
      return Icons.apps;
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          _getAppIcon(notificationsCategory!.packageName),
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
