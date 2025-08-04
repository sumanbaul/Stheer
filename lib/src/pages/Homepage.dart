import 'dart:isolate';
import 'dart:ui';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/src/components/notifications/notifications_banner.dart';
import 'package:notifoo/src/widgets/Notifications/notifications_list_widget.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';
import 'package:notifoo/src/widgets/headers/subHeader.dart';
import 'package:notifoo/src/widgets/home/home_banner_widget.dart';
import '../components/notifications/notifications_list.dart';
import '../helper/NotificationsHelper.dart';
import '../helper/notificationCatHelper.dart';
import '../model/Notifications.dart';
import '../model/notificationCategory.dart';

class Homepage extends StatefulWidget {
  Homepage({
    Key? key,
    this.title,
    required this.openNavigationDrawer,
  }) : super(key: key);

  final VoidCallback? openNavigationDrawer;
  final String? title;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
  int _notificationsCount = 0;
  bool started = false;
  bool _loading = false;
  bool isToday = true;
  ReceivePort port = ReceivePort();
  Timer? _mockNotificationTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initData();
  }

  Future<void> initPlatformState() async {
    // For sandbox, we'll use mock notifications
    print("Initializing sandbox notification listener");
    
    var isServiceRunning = false; // Mock service state
    print("Service is ${!isServiceRunning ? "not " : ""}already running");
    if (!isServiceRunning) {
      startListening();
    }

    setState(() {
      started = isServiceRunning;
    });
  }

  static void _callback(NotificationEvent evt) {
    final SendPort? send = IsolateNameServer.lookupPortByName("_notifoolistener_");
    if (send == null) print("can't find the sender");
    send?.send(evt);
  }

  Future<List<Notifications>> appendElements(
      Future<List<Notifications>>? notifications, Notifications notification) async {
    List<Notifications> _notifications = await notifications!;
    _notifications.add(notification);
    return _notifications;
  }

  void initData() {
    notificationsOfTheDay = NotificationsHelper.initializeDbGetNotificationsToday(0);
    notificationsByCatFuture = notificationsOfTheDay!.then((value) =>
        NotificationCatHelper.getNotificationsByCat(value, isToday));
  }

  Future<void> startListening() async {
    setState(() {
      _loading = true;
    });

    try {
      // Mock service start for sandbox
      print("Starting sandbox notification listener");
      
      // Start mock notification timer
      _mockNotificationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (started) {
          _addMockNotification();
        }
      });
      
      setState(() {
        started = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error starting listener: $e');
    }
  }

  void _addMockNotification() {
    final mockNotifications = [
      Notifications(
        title: "Mock Message",
        appTitle: "WhatsApp",
        text: "New message received at ${DateTime.now().toString()}",
        message: "New message",
        packageName: "com.whatsapp",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        createAt: DateTime.now().toString(),
      ),
      Notifications(
        title: "Mock Email",
        appTitle: "Gmail",
        text: "New email in your inbox",
        message: "New email",
        packageName: "com.google.android.gm",
        timestamp: DateTime.now().millisecondsSinceEpoch,
        createAt: DateTime.now().toString(),
      ),
    ];

    final randomNotification = mockNotifications[DateTime.now().millisecond % mockNotifications.length];
    
    if (notificationsOfTheDay != null) {
      final _notifications = appendElements(notificationsOfTheDay!, randomNotification);
      var _notificationsByCat = _notifications.then((value) =>
          NotificationCatHelper.getNotificationsByCat(value, isToday));
      setState(() {
        notificationsByCatFuture = _notificationsByCat;
      });
    }
  }

  Future<void> stopListening() async {
    setState(() {
      _loading = true;
    });

    try {
      // Mock service stop for sandbox
      print("Stopping sandbox notification listener");
      _mockNotificationTimer?.cancel();
      
      setState(() {
        started = false;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error stopping listener: $e');
    }
  }

  @override
  void dispose() {
    _mockNotificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Notifoo'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(started ? Icons.stop : Icons.play_arrow),
            onPressed: started ? stopListening : startListening,
            tooltip: started ? 'Stop Listening' : 'Start Listening',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Manager',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Batch and read your notifications later',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        started ? Icons.notifications_active : Icons.notifications_off,
                        color: started 
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              started ? 'Listening for notifications' : 'Not listening',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: started 
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              started 
                                  ? 'Capturing notifications in the background'
                                  : 'Tap the play button to start',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: NotificationsListWidget(
              onCountChange: (count) {
                count.then((value) {
                  setState(() {
                    _notificationsCount = value;
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
