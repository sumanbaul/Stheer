import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:notifoo/src/model/notificationCategory.dart';

import '../../helper/NotificationsHelper.dart';
import '../../helper/notificationCatHelper.dart';
import '../../../src/model/Notifications.dart';
import 'notification_card.dart';
import 'dart:async';

class NotificationsListWidget extends StatefulWidget {
  final Function(Future<int>)? onCountChange;
  final VoidCallback? onCountAdded;
  
  NotificationsListWidget({
    Key? key, 
    this.onCountAdded, 
    this.onCountChange
  }) : super(key: key);

  @override
  State<NotificationsListWidget> createState() => _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget>
    with WidgetsBindingObserver {
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (AppLifecycleState.resumed == state) {
      // Handle app resume
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mockNotificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: 600,
        padding: EdgeInsets.zero,
        child: _buildContainer(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'notification_listener_button',
        onPressed: started ? stopListening : startListening,
        icon: _loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(started ? Icons.stop : Icons.play_arrow),
        label: Text(started ? 'Stop' : 'Start'),
        backgroundColor: started 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
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
    notificationsByCatFuture = NotificationCatHelper.getNotificationsByCat(notificationsOfTheDay!, isToday);
  }

  Future<void> startListening() async {
    setState(() {
      _loading = true;
    });

    try {
      // For sandbox, we'll simulate starting the service
      print("Starting sandbox notification listener");
      
      // Simulate service start delay
      await Future.delayed(Duration(seconds: 1));
      
      // Start mock notification timer
      _mockNotificationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        _addMockNotification();
      });

      setState(() {
        started = true;
        _loading = false;
      });

      // Add initial mock notifications
      _addMockNotification();
      
    } catch (e) {
      print("Error starting notification listener: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> stopListening() async {
    setState(() {
      _loading = true;
    });

    try {
      // For sandbox, we'll simulate stopping the service
      print("Stopping sandbox notification listener");
      
      _mockNotificationTimer?.cancel();
      
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        started = false;
        _loading = false;
      });
      
    } catch (e) {
      print("Error stopping notification listener: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  void _addMockNotification() {
    // Add mock notifications for testing
    final mockNotifications = [
      {
        'packageName': 'com.whatsapp',
        'title': 'WhatsApp',
        'text': 'New message from John',
        'message': 'You have 7 Unread notifications',
      },
      {
        'packageName': 'com.instagram.android',
        'title': 'Instagram',
        'text': 'New story from Sarah',
        'message': 'You have 3 Unread notifications',
      },
      {
        'packageName': 'com.google.android.gm',
        'title': 'Gmail',
        'text': 'New email received',
        'message': 'You have 2 Unread notifications',
      },
    ];

    final randomNotification = mockNotifications[DateTime.now().millisecond % mockNotifications.length];
    
    // Create mock notification event
    final mockEvent = NotificationEvent(
      title: randomNotification['title']!,
      text: randomNotification['text']!,
      packageName: randomNotification['packageName']!,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      createAt: DateTime.now(),
    );

    // Process the notification
    NotificationsHelper.onData(mockEvent).then((notification) {
      if (notification != null) {
        // Refresh the data
        setState(() {
          notificationsOfTheDay = NotificationsHelper.initializeDbGetNotificationsToday(0);
          notificationsByCatFuture = NotificationCatHelper.getNotificationsByCat(notificationsOfTheDay!, isToday);
        });
      }
    });
  }

  Widget _buildContainer(BuildContext context) {
    return FutureBuilder<List<NotificationCategory>>(
      future: notificationsByCatFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading notifications...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please try again',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        List<NotificationCategory>? notifications = snapshot.data;
        
        if (notifications == null || notifications.isEmpty) {
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
                  'No notifications yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start listening to capture notifications',
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return NotificationsCard(
              key: ValueKey('notification_${notifications[index].packageName}_$index'),
              index: index,
              notificationsCategory: notifications[index],
            );
          },
        );
      },
    );
  }
}
