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
import '../../services/notification_permission_service.dart';

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
  List<NotificationCategory>? _cachedNotifications;

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
    
    // Clean up notification listener
    if (started) {
      // Note: The plugin doesn't have a stopListening method
      IsolateNameServer.removePortNameMapping("_notifoolistener_");
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Permission status widget
          NotificationPermissionService().buildPermissionStatusWidget(context),
          
          // Notifications list
          Expanded(
            child: Container(
              height: 600,
              padding: EdgeInsets.zero,
              child: _buildContainer(context),
            ),
          ),
        ],
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
    print("Initializing real notification listener");
    
    // Check permission status on init
    await NotificationPermissionService().checkPermission();
    
    // Check if service is already running
    var isServiceRunning = false;
    try {
      // For now, we'll assume service is not running
      isServiceRunning = false;
    } catch (e) {
      print("Error checking service status: $e");
    }
    
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
      // Check for notification permission first
      final permissionService = NotificationPermissionService();
      final hasPermission = await permissionService.checkPermission();
      
      if (!hasPermission) {
        // Request permission
        final granted = await permissionService.requestPermission(context);
        if (!granted) {
          setState(() {
            _loading = false;
          });
          return;
        }
      }
      
      // Start real notification listener
      print("Starting real notification listener");
      
      // Initialize the notification listener
      await NotificationsListener.initialize(
        callbackHandle: _callback,
      );
      
      // Start listening for notifications
      // The plugin automatically starts listening after initialization
      
      // Set up port for receiving notifications
      IsolateNameServer.registerPortWithName(port.sendPort, "_notifoolistener_");
      port.listen((dynamic message) {
        if (message is NotificationEvent) {
          _handleRealNotification(message);
        }
      });

      setState(() {
        started = true;
        _loading = false;
      });
      
      print("Real notification listener started successfully");
      
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
      // Stop real notification listener
      print("Stopping real notification listener");
      
      // Stop listening for notifications
      // Note: The plugin doesn't have a stopListening method
      // The service will continue running in the background
      
      // Unregister port
      IsolateNameServer.removePortNameMapping("_notifoolistener_");
      
      setState(() {
        started = false;
        _loading = false;
      });
      
      print("Real notification listener stopped successfully");
      
    } catch (e) {
      print("Error stopping notification listener: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  void _handleRealNotification(NotificationEvent event) {
    print("Received real notification: ${event.title} from ${event.packageName}");
    
    // Process the real notification
    NotificationsHelper.onData(event).then((notification) {
      if (notification != null) {
        // Refresh the data
        setState(() {
          notificationsOfTheDay = NotificationsHelper.initializeDbGetNotificationsToday(0);
          notificationsByCatFuture = notificationsOfTheDay!.then((value) =>
              NotificationCatHelper.getNotificationsByCat(value, isToday));
        });
        
        // Update notification count if callback is provided
        if (widget.onCountAdded != null) {
          widget.onCountAdded!();
        }
        
        print("Real notification processed and UI updated");
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
        
        // Cache the notifications to prevent flickering
        if (notifications != null && notifications.isNotEmpty) {
          _cachedNotifications = notifications;
        } else if (_cachedNotifications != null && notifications == null) {
          notifications = _cachedNotifications;
        }
        
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
          itemCount: notifications!.length,
          itemBuilder: (context, index) {
            final notification = notifications![index];
            return NotificationsCard(
              key: ValueKey('notification_${notification.packageName}_${notification.timestamp}_$index'),
              index: index,
              notificationsCategory: notification,
            );
          },
        );
      },
    );
  }
}
