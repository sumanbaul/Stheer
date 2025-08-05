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
import 'package:notifoo/src/widgets/BottomBar.dart';
import '../components/notifications/notifications_list.dart';
import '../helper/NotificationsHelper.dart';
import '../helper/notificationCatHelper.dart';
import '../model/Notifications.dart';
import '../model/notificationCategory.dart';
import '../pages/habit_hub_page.dart';
import '../pages/task_page.dart';
import '../pages/insights_page.dart';
import '../pages/pomodoro_home.dart';

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
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initData();
  }

  @override
  void dispose() {
    _mockNotificationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    print("Initializing notification listener");
    
    var isServiceRunning = false;
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
      print("Starting notification listener");
      
      // For now, we'll use mock notifications since real notification access requires special permissions
      // In a production app, you would use:
      // await FlutterNotificationListener.initialize(
      //   callback: _callback,
      //   sendPort: port.sendPort,
      // );
      
      // Start mock notification timer for testing
      _mockNotificationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
        if (started) {
          _addMockNotification();
        }
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
      print("Stopping notification listener");
      
      _mockNotificationTimer?.cancel();
      
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
      {
        'packageName': 'com.twitter.android',
        'title': 'Twitter',
        'text': 'New tweet from TechNews',
        'message': 'You have 5 Unread notifications',
      },
      {
        'packageName': 'com.facebook.katana',
        'title': 'Facebook',
        'text': 'New post from your friend',
        'message': 'You have 1 Unread notification',
      },
    ];

    final randomNotification = mockNotifications[DateTime.now().millisecond % mockNotifications.length];
    
    final mockEvent = NotificationEvent(
      title: randomNotification['title']!,
      text: randomNotification['text']!,
      packageName: randomNotification['packageName']!,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      createAt: DateTime.now(),
    );

    NotificationsHelper.onData(mockEvent).then((notification) {
      if (notification != null) {
        setState(() {
          notificationsOfTheDay = NotificationsHelper.initializeDbGetNotificationsToday(0);
          notificationsByCatFuture = notificationsOfTheDay!.then((value) =>
              NotificationCatHelper.getNotificationsByCat(value, isToday));
        });
      }
    });
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0: // Alerts
        return _buildAlertsPage();
      case 1: // Habits
        return _buildHabitsPage();
      case 2: // Timer
        return _buildTimerPage();
      case 3: // Tasks
        return _buildTasksPage();
      case 4: // Stats
        return _buildStatsPage();
      default:
        return _buildAlertsPage();
    }
  }

  Widget _buildAlertsPage() {
    return Column(
      children: [
        // Header Section
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alert Manager',
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
    );
  }

  Widget _buildHabitsPage() {
    return HabitHubPage(
      title: 'Habits',
      openNavigationDrawer: () {
        _scaffoldKey.currentState?.openDrawer();
      },
      showAppBar: false,
    );
  }

  Widget _buildTimerPage() {
    return PomodoroHome(
      title: 'Timer',
      openNavigationDrawer: () {
        _scaffoldKey.currentState?.openDrawer();
      },
      showAppBar: false,
    );
  }

  Widget _buildTasksPage() {
    return TaskPage(
      openNavigationDrawer: () {
        _scaffoldKey.currentState?.openDrawer();
      },
      showAppBar: false,
    );
  }

  Widget _buildStatsPage() {
    return InsightsPage(
      openNavigationDrawer: () {
        _scaffoldKey.currentState?.openDrawer();
      },
      showAppBar: false,
    );
  }



  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Alerts';
      case 1:
        return 'Habits';
      case 2:
        return 'Timer';
      case 3:
        return 'Tasks';
      case 4:
        return 'Statistics';
      default:
        return 'Alerts';
    }
  }

  List<Widget> _getAppBarActions() {
    switch (_currentIndex) {
      case 0: // Alerts
        return [
          IconButton(
            icon: Icon(started ? Icons.stop : Icons.play_arrow),
            onPressed: started ? stopListening : startListening,
            tooltip: started ? 'Stop Listening' : 'Start Listening',
          ),
        ];
      case 2: // Timer
        return [
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pushNamed(context, '/pomodoro');
            },
            tooltip: 'Open Timer',
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: _getAppBarActions(),
      ),
      drawer: NavigationDrawerWidget(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildPage(0),
          _buildPage(1),
          _buildPage(2),
          _buildPage(3),
          _buildPage(4),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes_outlined),
            activeIcon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
