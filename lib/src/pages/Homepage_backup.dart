import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:notifoo/src/components/notifications/notifications_banner.dart';
import 'package:notifoo/src/widgets/Notifications/notifications_list_widget.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';
import 'package:notifoo/src/widgets/headers/subHeader.dart';
import 'package:notifoo/src/widgets/home/home_banner_widget.dart';
import 'package:notifoo/src/widgets/BottomBar.dart';
import 'package:notifoo/src/widgets/circular_progress_widget.dart';
import '../components/notifications/notifications_list.dart';
import '../helper/NotificationsHelper.dart';
import '../helper/notificationCatHelper.dart';
import '../model/Notifications.dart';
import '../model/notificationCategory.dart';
import '../pages/habit_hub_page.dart';
import '../pages/task_page.dart';
import '../pages/insights_page.dart';
import '../pages/pomodoro_home.dart';
import '../pages/activity_page.dart';
import '../pages/app_usage_page.dart';
import '../pages/advanced_analytics_dashboard.dart';
import '../pages/settings_page.dart';
import '../pages/subscription_page.dart';
import '../services/subscription_service.dart';
import '../model/subscription_model.dart';
import '../services/steps_service.dart';
import '../services/calendar_service.dart';
import '../services/motivational_quote_service.dart';
import '../model/tasks.dart';
import '../model/habits_model.dart';

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

class _HomepageState extends State<Homepage> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  // Add PageController for sliding navigation
  late PageController _pageController;
  
  Future<List<Notifications>>? notificationsOfTheDay;
  Future<List<NotificationCategory>>? notificationsByCatFuture;
  int _notificationsCount = 0;
  bool _loading = false;
  bool isToday = true;
  Timer? _mockNotificationTimer;
  Timer? _quoteRefreshTimer;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Data for homepage
  int _todayTasks = 0;
  int _completedTasks = 0;
  int _activeHabits = 0;
  int _streakDays = 0;
  int _todaySteps = 0;
  int _focusMinutes = 0;
  String _greeting = '';
  String _currentMotivationalQuote = '';
  bool _isLoadingQuote = true;
  bool _hasQuoteError = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeAnimations();
    _initializeData();
    _setGreeting();
    _fetchMotivationalQuote();
    _startPulseAnimation();
    _startQuoteRefreshTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _slideController.forward();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }
  }

  Future<void> _fetchMotivationalQuote() async {
    setState(() {
      _isLoadingQuote = true;
      _hasQuoteError = false;
    });

    try {
      // Try to get a time-based quote for contextual motivation
      final quote = await MotivationalQuoteService.getTimeBasedQuote();
      setState(() {
        _currentMotivationalQuote = quote;
        _isLoadingQuote = false;
        _hasQuoteError = false;
      });
    } catch (e) {
      try {
        // Fallback to productivity quote
        final quote = await MotivationalQuoteService.getProductivityQuote();
        setState(() {
          _currentMotivationalQuote = quote;
          _isLoadingQuote = false;
          _hasQuoteError = false;
        });
      } catch (e) {
        try {
          // Fallback to general daily quote
          final quote = await MotivationalQuoteService.getDailyQuote();
          setState(() {
            _currentMotivationalQuote = quote;
            _isLoadingQuote = false;
            _hasQuoteError = false;
          });
        } catch (e) {
          // Use fallback quote if all APIs fail
          setState(() {
            _currentMotivationalQuote = _getMotivationalQuote();
            _isLoadingQuote = false;
            _hasQuoteError = false;
          });
        }
      }
    }
  }

  Future<void> _refreshMotivationalQuote() async {
    await _fetchMotivationalQuote();
  }

  String _getMotivationalQuote() {
    final quotes = [
      'The only way to do great work is to love what you do.',
      'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'Don\'t watch the clock; do what it does. Keep going.',
      'The future depends on what you do today.',
      'It always seems impossible until it\'s done.',
      'Small progress is still progress.',
      'Every expert was once a beginner.',
      'Make today amazing!',
    ];
    
    final random = math.Random();
    return quotes[random.nextInt(quotes.length)];
  }

  void _startQuoteRefreshTimer() {
    // Refresh quote every 4 hours
    _quoteRefreshTimer = Timer.periodic(const Duration(hours: 4), (timer) {
      _fetchMotivationalQuote();
    });
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/add-task');
                    },
                    icon: Icon(Icons.add_task),
                    label: Text('Add Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/habits');
                    },
                    icon: Icon(Icons.track_changes),
                    label: Text('Habits'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/pomodoro');
                    },
                    icon: Icon(Icons.timer),
                    label: Text('Timer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/insights');
                    },
                    icon: Icon(Icons.insights),
                    label: Text('Insights'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeData() async {
    setState(() {
      _loading = true;
    });
    
    try {
      // Mock data for now - you can replace with actual service calls
      _todayTasks = 8;
      _completedTasks = 5;
      _activeHabits = 12;
      _streakDays = 7;
      _todaySteps = 8432;
      _focusMinutes = 120;
      
      notificationsOfTheDay = NotificationsHelper.initializeDbGetNotificationsToday(0);
      notificationsByCatFuture = notificationsOfTheDay!.then((value) =>
          NotificationCatHelper.getNotificationsByCat(value, isToday));
          
      if (notificationsOfTheDay != null) {
        final notifications = await notificationsOfTheDay!;
        setState(() {
          _notificationsCount = notifications.length;
        });
      }
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _mockNotificationTimer?.cancel();
    _quoteRefreshTimer?.cancel();
    super.dispose();
  }

  List<Widget> _getAppBarActions() {
    return [
      Consumer<SubscriptionService>(
        builder: (context, subscriptionService, _) {
          final subscription = subscriptionService.currentSubscription;
          if (subscription == null) return SizedBox.shrink();
          
          final isTrial = subscription.status == SubscriptionStatus.trial;
          final isPro = subscription.tier == SubscriptionTier.pro || subscription.tier == SubscriptionTier.enterprise;
          
          return Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isTrial 
                ? Colors.blue.withOpacity(0.2)
                : isPro 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTrial 
                  ? Colors.blue.withOpacity(0.5)
                  : isPro 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isTrial ? Icons.access_time : isPro ? Icons.star : Icons.person,
                  color: isTrial 
                    ? Colors.blue 
                    : isPro 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  isTrial 
                    ? 'TRIAL'
                    : isPro 
                      ? 'PRO'
                      : 'FREE',
                  style: TextStyle(
                    color: isTrial 
                      ? Colors.blue 
                      : isPro 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.notifications_outlined),
        onPressed: () => Navigator.pushNamed(context, '/notifications'),
        tooltip: 'Notifications',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 24,
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
      body: _loading 
        ? _buildLoadingState()
        : PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              // Homepage content
              _buildHomepageContent(),
              // Alerts/Notifications page
              _buildAlertsPage(),
              // Habits page
              _buildHabitsPage(),
              // Timer page
              _buildTimerPage(),
              // Tasks page
              _buildTasksPage(),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionsSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
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
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Focus Fluke';
      case 1:
        return 'Alerts';
      case 2:
        return 'Habits';
      case 3:
        return 'Timer';
      case 4:
        return 'Tasks';
      default:
        return 'Notifoo';
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading your dashboard...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomepageContent() {
    return RefreshIndicator(
      onRefresh: _refreshMotivationalQuote,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildGreetingSection(),
              ),
              
              SizedBox(height: 32), // Increased spacing
              
              // Quick Stats Section
              SlideTransition(
                position: AlwaysStoppedAnimation(Offset(0, _slideAnimation.value)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.task_alt,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '0/0',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Tasks',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.track_changes,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '0',
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Habits',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32), // Increased spacing
              
              // Recent Activity Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No recent activity to show',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 32), // Increased spacing
              
              // Quick Actions
              SlideTransition(
                position: AlwaysStoppedAnimation(Offset(0, _slideAnimation.value)),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/add-task'),
                              icon: Icon(Icons.add_task),
                              label: Text('Add Task'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/habits'),
                              icon: Icon(Icons.track_changes),
                              label: Text('Habits'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 100), // Bottom padding for bottom navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay updated with your important notifications',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications list
          Expanded(
            child: NotificationsListWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build and track your daily habits',
                  style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
                    fontSize: 20, // Increased from 16
                    fontWeight: FontWeight.w600, // Added weight
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Habits list
          Expanded(
            child: HabitHubPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus and productivity timer',
                  style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
                    fontSize: 20, // Increased from 16
                    fontWeight: FontWeight.w600, // Added weight
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Timer content
          Expanded(
            child: PomodoroHome(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your daily tasks and to-dos',
                  style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
                    fontSize: 20, // Increased from 16
                    fontWeight: FontWeight.w600, // Added weight
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks list
          Expanded(
            child: TaskPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Greeting with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _getGreetingIcon(),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Ready to make today productive?',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Right side - Motivational quote (compact)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _isLoadingQuote
                        ? Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.amber.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Loading motivation...',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _currentMotivationalQuote.isNotEmpty 
                                ? _currentMotivationalQuote 
                                : 'Tap refresh for motivation',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: _refreshMotivationalQuote,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );


  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny;
    } else if (hour < 17) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.nightlight_round;
    }
  }

  String _getMotivationalQuote() {
    final quotes = [
      'The only way to do great work is to love what you do.',
      'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'Don\'t watch the clock; do what it does. Keep going.',
      'The future depends on what you do today.',
      'It always seems impossible until it\'s done.',
      'Small progress is still progress.',
      'Every expert was once a beginner.',
      'Make today amazing!',
    ];
    
    final random = math.Random();
    return quotes[random.nextInt(quotes.length)];
  }

  int _calculateOverallProgress() {
    final totalTasks = _todayTasks;
    final completedTasks = _completedTasks;
    final totalSteps = 10000; // Assuming 10k steps goal
    final todaySteps = _todaySteps;
    final totalFocus = 480; // Assuming 8 hours goal
    final todayFocus = _focusMinutes;

    final tasksProgress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    final stepsProgress = totalSteps > 0 ? (todaySteps / totalSteps) * 100 : 0;
    final focusProgress = totalFocus > 0 ? (todayFocus / totalFocus) * 100 : 0;

    // Simple average for overall progress
    return ((tasksProgress + stepsProgress + focusProgress) / 3).toInt();
  }

  Widget _buildProgressLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 20), // Increased from 16
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.task_alt,
                title: 'Tasks',
                value: '$_completedTasks/$_todayTasks',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/tasks'),
              ),
            ),
            SizedBox(width: 16), // Increased from 12
            Expanded(
              child: _buildStatCard(
                icon: Icons.track_changes,
                title: 'Habits',
                value: '$_activeHabits',
                color: Colors.blue,
                onTap: () => Navigator.pushNamed(context, '/habits'),
              ),
            ),
          ],
        ),
        SizedBox(height: 24), // Increased from 16
        // Enhanced radial graphs section - Apple Health style
        Container(
          padding: EdgeInsets.all(28), // Increased from 24
          constraints: BoxConstraints(
            maxWidth: double.infinity,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Main progress rings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tasks progress ring
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCircularProgressWidget(
                          progress: _todayTasks > 0 ? _completedTasks / _todayTasks : 0.0,
                          size: 90,
                          color: Color(0xFF27AE60), // Enhanced Green
                          backgroundColor: Color(0xFF27AE60).withOpacity(0.15),
                          strokeWidth: 10,
                          label: 'Tasks',
                          subtitle: '${_completedTasks}/${_todayTasks}',
                        ),
                        SizedBox(height: 12), // Increased from 8
                        Text(
                          '${_todayTasks > 0 ? ((_completedTasks / _todayTasks) * 100).toInt() : 0}%',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Steps progress ring
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCircularProgressWidget(
                          progress: _todaySteps / 10000.0, // 10k steps goal
                          size: 90,
                          color: Color(0xFFE74C3C), // Enhanced Red
                          backgroundColor: Color(0xFFE74C3C).withOpacity(0.15),
                          strokeWidth: 10,
                          label: 'Steps',
                          subtitle: '${(_todaySteps / 1000).toStringAsFixed(1)}k',
                        ),
                        SizedBox(height: 12), // Increased from 8
                        Text(
                          '${((_todaySteps / 10000.0) * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Focus progress ring
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedCircularProgressWidget(
                          progress: _focusMinutes / 480.0, // 8 hours goal
                          size: 90,
                          color: Color(0xFF3498DB), // Enhanced Blue
                          backgroundColor: Color(0xFF3498DB).withOpacity(0.15),
                          strokeWidth: 10,
                          label: 'Focus',
                          subtitle: '${(_focusMinutes / 60).toStringAsFixed(1)}h',
                        ),
                        SizedBox(height: 12), // Increased from 8
                        Text(
                          '${((_focusMinutes / 480.0) * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3498DB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 28), // Increased from 20
              
              // Progress details
              Row(
                children: [
                  Expanded(
                    child: _buildProgressDetail(
                      icon: Icons.track_changes,
                      title: 'Habits',
                      value: '$_activeHabits',
                      subtitle: 'Active',
                      color: Color(0xFF9B59B6), // Enhanced Purple
                      progress: _activeHabits / 10.0, // Assuming 10 habits is max
                    ),
                  ),
                  SizedBox(width: 20), // Increased from 16
                  Expanded(
                    child: _buildProgressDetail(
                      icon: Icons.local_fire_department,
                      title: 'Streak',
                      value: '$_streakDays',
                      subtitle: 'Days',
                      color: Color(0xFFF39C12), // Enhanced Orange
                      progress: _streakDays / 30.0, // Assuming 30 days is max
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetail({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required double progress,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20), // Increased from 16
        
        // Streak counter
        Container(
          margin: EdgeInsets.only(bottom: 20), // Increased from 16
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.amber.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '$_streakDays days',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🔥',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.task_alt,
                title: 'Completed morning routine',
                subtitle: '2 hours ago',
                color: Colors.green,
                progress: 1.0,
              ),
              Divider(height: 24), // Increased from 20
              _buildActivityItem(
                icon: Icons.track_changes,
                title: 'Logged daily meditation',
                subtitle: '4 hours ago',
                color: Colors.blue,
                progress: 1.0,
              ),
              Divider(height: 24), // Increased from 20
              _buildActivityItem(
                icon: Icons.timer,
                title: 'Finished focus session',
                subtitle: '6 hours ago',
                color: Colors.purple,
                progress: 1.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required double progress,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2), // Added spacing
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Icon(
                Icons.check,
                color: color,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.roboto( // Changed to Roboto for better aesthetics
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 20), // Increased from 16
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.add_task,
                label: 'Add Task',
                onTap: () => Navigator.pushNamed(context, '/add-task'),
              ),
            ),
            SizedBox(width: 16), // Increased from 12
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.track_changes,
                label: 'New Habit',
                onTap: () => Navigator.pushNamed(context, '/habits'),
              ),
            ),
            SizedBox(width: 16), // Increased from 12
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.timer,
                label: 'Start Timer',
                onTap: () => Navigator.pushNamed(context, '/pomodoro'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Use PageController to slide to the selected page
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _showQuickActionsSheet(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildQuickActionsModal(),
    );
  }

  Widget _buildQuickActionsModal() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              
              // Title
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24),
              
              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionModalButton(
                      icon: Icons.add_task,
                      label: 'Add Task',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/add-task');
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionModalButton(
                      icon: Icons.track_changes,
                      label: 'New Habit',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/habits');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionModalButton(
                      icon: Icons.timer,
                      label: 'Start Timer',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/pomodoro');
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionModalButton(
                      icon: Icons.analytics,
                      label: 'View Stats',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/insights');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionModalButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
