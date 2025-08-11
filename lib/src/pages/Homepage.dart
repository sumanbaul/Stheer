import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/src/services/motivational_quote_service.dart';
import 'package:notifoo/src/widgets/navigation/nav_drawer_widget.dart';
import 'package:notifoo/src/widgets/circular_progress_widget.dart';
import 'package:notifoo/src/widgets/Notifications/notifications_list_widget.dart';
import 'package:notifoo/src/pages/habit_hub_page.dart';
import 'package:notifoo/src/pages/pomodoro_home.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  final String title;
  final VoidCallback openNavigationDrawer;

  const Homepage({
    Key? key,
    required this.title,
    required this.openNavigationDrawer,
  }) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Page controller for bottom navigation
  late PageController _pageController;
  int _currentIndex = 0;
  
  // Scaffold key for navigation drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State variables
  String _greeting = '';
  String _currentMotivationalQuote = 'Loading motivational quote...';
  bool _isLoadingQuote = true;
  bool _hasQuoteError = false;
  Timer? _quoteRefreshTimer;

  // Sample data (replace with actual data from your services)
  int _todaySteps = 6500;
  int _focusMinutes = 240;
  int _todayTasks = 8;
  int _completedTasks = 5;
  int _activeHabits = 3;
  int _streakDays = 7;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _fetchMotivationalQuote();
    _startQuoteRefreshTimer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _quoteRefreshTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Page controller
    _pageController = PageController(initialPage: 0);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeData() async {
    // Initialize with sample data (replace with actual service calls)
    setState(() {
      _todaySteps = 6500;
      _focusMinutes = 240;
      _todayTasks = 8;
      _completedTasks = 5;
      _activeHabits = 3;
      _streakDays = 7;
      
      // Initialize greeting based on time of day
      final hour = DateTime.now().hour;
      if (hour < 12) {
        _greeting = 'Good Morning';
      } else if (hour < 17) {
        _greeting = 'Good Afternoon';
      } else {
        _greeting = 'Good Evening';
      }
    });
  }

  Future<void> _fetchMotivationalQuote() async {
    setState(() {
      _isLoadingQuote = true;
      _hasQuoteError = false;
    });

    try {
      if (kDebugMode) {
        print('Homepage: Starting to fetch motivational quote...');
      }
      
      // Try time-based quote first
      final quote = await MotivationalQuoteService.getTimeBasedQuote();
      if (kDebugMode) {
        print('Homepage: Successfully fetched time-based quote: $quote');
      }
      
      if (kDebugMode) {
        print('Homepage: About to set state with quote: $quote');
      }
      
      setState(() {
        _currentMotivationalQuote = quote;
        _isLoadingQuote = false;
        _hasQuoteError = false;
      });
      
      if (kDebugMode) {
        print('Homepage: State updated. Quote is now: $_currentMotivationalQuote');
        print('Homepage: Loading state: $_isLoadingQuote, Error state: $_hasQuoteError');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Homepage: Error fetching time-based quote: $e');
        print('Homepage: Trying productivity quote as fallback...');
      }
      
      try {
        final fallbackQuote = await MotivationalQuoteService.getProductivityQuote();
        if (kDebugMode) {
          print('Homepage: Successfully fetched productivity quote: $fallbackQuote');
        }
        
        if (kDebugMode) {
          print('Homepage: About to set state with fallback quote: $fallbackQuote');
        }
        
        setState(() {
          _currentMotivationalQuote = fallbackQuote;
          _isLoadingQuote = false;
          _hasQuoteError = false;
        });
        
        if (kDebugMode) {
          print('Homepage: State updated with fallback. Quote is now: $_currentMotivationalQuote');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Homepage: Error fetching productivity quote: $e');
          print('Homepage: Trying daily quote as final fallback...');
        }
        
        try {
          final dailyQuote = await MotivationalQuoteService.getDailyQuote();
          if (kDebugMode) {
            print('Homepage: Successfully fetched daily quote: $dailyQuote');
          }
          
          if (kDebugMode) {
            print('Homepage: About to set state with daily quote: $dailyQuote');
          }
          
          setState(() {
            _currentMotivationalQuote = dailyQuote;
            _isLoadingQuote = false;
            _hasQuoteError = false;
          });
          
          if (kDebugMode) {
            print('Homepage: State updated with daily quote. Quote is now: $_currentMotivationalQuote');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Homepage: All API calls failed, using hardcoded fallback: $e');
          }
          
          if (kDebugMode) {
            print('Homepage: About to set state with hardcoded fallback quote');
          }
          
          setState(() {
            _currentMotivationalQuote = 'The only way to do great work is to love what you do.';
            _isLoadingQuote = false;
            _hasQuoteError = true;
          });
          
          if (kDebugMode) {
            print('Homepage: State updated with hardcoded quote. Quote is now: $_currentMotivationalQuote');
          }
        }
      }
    }
  }

  Future<void> _refreshMotivationalQuote() async {
    await _fetchMotivationalQuote();
  }

  void _startQuoteRefreshTimer() {
    // Refresh quote every 4 hours
    _quoteRefreshTimer = Timer.periodic(const Duration(hours: 4), (timer) {
      if (kDebugMode) {
        print('Homepage: Auto-refreshing motivational quote...');
      }
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

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Alerts';
      case 2:
        return 'Habits';
      case 3:
        return 'Timer';
      case 4:
        return 'Tasks';
      default:
        return 'Home';
    }
  }

  List<Widget> _getAppBarActions() {
    switch (_currentIndex) {
      case 0:
        return [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Update greeting based on time of day
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 17) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

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
      body: PageView(
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

  Widget _buildHomepageContent() {
    return RefreshIndicator(
      onRefresh: _refreshMotivationalQuote,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section with Space Optimization
            _buildGreetingSection(),
            
            SizedBox(height: 32),
            
            // Apple Health Style Multi-Radial Progress Bar
            _buildAppleHealthStyleProgress(),
            
            SizedBox(height: 32),
            
            // Quick Stats Section with Radial Progress Bars
            _buildQuickStatsSection(),
            
            SizedBox(height: 32),
            
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
            
            SizedBox(height: 32),
            
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
    );
  }

  Widget _buildAppleHealthStyleProgress() {
    return Container(
      padding: EdgeInsets.all(24),
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
      child: Row(
        children: [
          // Left side - Multi-radial progress rings
          Container(
            width: 180,
            height: 180,
            child: Stack(
              children: [
                // Outer ring - Steps (Red)
                Positioned(
                  left: 10,
                  top: 10,
                  child: AnimatedCircularProgressWidget(
                    progress: _todaySteps / 10000.0,
                    size: 160,
                    color: Color(0xFFE74C3C), // Red
                    backgroundColor: Color(0xFFE74C3C).withOpacity(0.15),
                    strokeWidth: 14,
                    showPercentage: false,
                  ),
                ),
                
                // Middle ring - Focus (Green)
                Positioned(
                  left: 26,
                  top: 26,
                  child: AnimatedCircularProgressWidget(
                    progress: _focusMinutes / 480.0,
                    size: 128,
                    color: Color(0xFF27AE60), // Green
                    backgroundColor: Color(0xFF27AE60).withOpacity(0.15),
                    strokeWidth: 14,
                    showPercentage: false,
                  ),
                ),
                
                // Inner ring - Tasks (Blue)
                Positioned(
                  left: 42,
                  top: 42,
                  child: AnimatedCircularProgressWidget(
                    progress: _todayTasks > 0 ? _completedTasks / _todayTasks : 0.0,
                    size: 96,
                    color: Color(0xFF3498DB), // Blue
                    backgroundColor: Color(0xFF3498DB).withOpacity(0.15),
                    strokeWidth: 14,
                    showPercentage: false,
                  ),
                ),
                
                // Center content
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_calculateOverallProgress()}%',
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Complete',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: 24),
          
          // Right side - Progress legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Steps
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFFE74C3C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Steps',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${((_todaySteps / 10000.0) * 100).toInt()}%',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE74C3C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.directions_walk,
                      size: 16,
                      color: Color(0xFFE74C3C),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Focus
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF27AE60),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Focus',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${((_focusMinutes / 480.0) * 100).toInt()}%',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                     Icon(
                      Icons.timer,
                      size: 16,
                      color: Color(0xFF27AE60),
                    ),
                  ],
                ),
                
                SizedBox(height: 20),
                
                // Tasks
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(0xFF3498DB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tasks',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${_todayTasks > 0 ? ((_completedTasks / _todayTasks) * 100).toInt() : 0}%',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3498DB),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.task_alt,
                      size: 16,
                      color: Color(0xFF3498DB),
                    ),
                  ],
                ),
              ],
            ),
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
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Greeting with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
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
              Expanded(
                child: Text(
                  _greeting,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Bottom row - Motivational quote with refresh button
          Row(
            children: [
              Expanded(
                child: Text(
                  _currentMotivationalQuote.isNotEmpty ? _currentMotivationalQuote : 'Ready to make today productive?',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 16),
              // Refresh button
              GestureDetector(
                onTap: _refreshMotivationalQuote,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isLoadingQuote 
                        ? Colors.blue.withOpacity(0.2) 
                        : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoadingQuote
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          size: 20,
                          color: Colors.amber,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Column(
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
              child: _buildStatCard(
                icon: Icons.task_alt,
                title: 'Tasks',
                value: '$_completedTasks/$_todayTasks',
                color: Colors.green,
                onTap: () => Navigator.pushNamed(context, '/tasks'),
              ),
            ),
            SizedBox(width: 16),
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
        SizedBox(height: 24),
        // Enhanced radial graphs section - Apple Health style
        Container(
          padding: EdgeInsets.all(28),
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
                          strokeWidth: 12,
                          label: 'Tasks',
                          subtitle: '${_completedTasks}/${_todayTasks}',
                        ),
                        SizedBox(height: 12),
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
                          strokeWidth: 12,
                          label: 'Steps',
                          subtitle: '${(_todaySteps / 1000).toStringAsFixed(1)}k',
                        ),
                        SizedBox(height: 12),
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
                          strokeWidth: 12,
                          label: 'Focus',
                          subtitle: '${(_focusMinutes / 60).toStringAsFixed(1)}h',
                        ),
                        SizedBox(height: 12),
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
              
              SizedBox(height: 28),
              
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
                  SizedBox(width: 20),
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '$value $subtitle',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // Actual page content for navigation
  Widget _buildAlertsPage() {
    return NotificationsListWidget();
  }

  Widget _buildHabitsPage() {
    return HabitHubPage(showAppBar: false);
  }

  Widget _buildTimerPage() {
    return PomodoroHome(showAppBar: false);
  }

  Widget _buildTasksPage() {
    return TaskPage(showAppBar: false);
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

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return Icons.wb_sunny;
    } else if (hour < 17) {
      return Icons.wb_sunny_outlined;
    } else {
      return Icons.nightlight;
    }
  }
}
