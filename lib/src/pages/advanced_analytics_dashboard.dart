import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';
import 'package:notifoo/src/services/push_notification_service.dart';
import 'dart:math' as math;

class AdvancedAnalyticsDashboard extends StatefulWidget {
  const AdvancedAnalyticsDashboard({
    Key? key, 
    this.openNavigationDrawer,
    this.showAppBar = true,
  }) : super(key: key);
  final VoidCallback? openNavigationDrawer;
  final bool showAppBar;

  @override
  _AdvancedAnalyticsDashboardState createState() => _AdvancedAnalyticsDashboardState();
}

class _AdvancedAnalyticsDashboardState extends State<AdvancedAnalyticsDashboard> {
  bool _isLoading = true;
  String _selectedTimeRange = 'week'; // week, month, year
  
  // Analytics Data
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _productivityTrends = [];
  List<Map<String, dynamic>> _focusSessions = [];
  List<Map<String, dynamic>> _habitStreaks = [];
  List<Map<String, dynamic>> _taskCompletionRates = [];
  
  // Performance Metrics
  double _overallProductivityScore = 0.0;
  double _focusEfficiency = 0.0;
  double _habitConsistency = 0.0;
  double _taskCompletionRate = 0.0;
  
  // Time-based data
  Map<String, int> _dailyActivity = {};
  Map<String, double> _hourlyProductivity = {};
  List<Map<String, dynamic>> _weeklyProgress = [];

  @override
  void initState() {
    super.initState();
    _loadAdvancedAnalytics();
  }

  Future<void> _loadAdvancedAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all data
      final tasks = await DatabaseHelper.instance.getAllTasks();
      final habits = await DatabaseHelper.instance.getHabits();
      
      // Calculate comprehensive analytics
      await _calculateProductivityMetrics(tasks, habits);
      await _generateProductivityTrends();
      await _analyzeFocusSessions();
      await _calculateHabitStreaks(habits);
      await _analyzeTaskCompletionRates(tasks);
      await _generateTimeBasedAnalytics();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateProductivityMetrics(List<Tasks> tasks, List<HabitsModel> habits) async {
    // Overall Productivity Score (0-100)
    int completedTasks = tasks.where((task) => task.isCompleted == 1).length;
    int completedHabits = habits.where((habit) => habit.isCompleted == 1).length;
    
    double taskScore = tasks.isNotEmpty ? (completedTasks / tasks.length) * 40 : 0;
    double habitScore = habits.isNotEmpty ? (completedHabits / habits.length) * 30 : 0;
    double focusScore = 25; // Mock focus session score
    double consistencyScore = 5; // Mock consistency bonus
    
    _overallProductivityScore = (taskScore + habitScore + focusScore + consistencyScore).clamp(0, 100);
    
    // Focus Efficiency
    _focusEfficiency = 78.5; // Mock data
    
    // Habit Consistency
    _habitConsistency = habits.isNotEmpty ? (completedHabits / habits.length) * 100 : 0;
    
    // Task Completion Rate
    _taskCompletionRate = tasks.isNotEmpty ? (completedTasks / tasks.length) * 100 : 0;
  }

  Future<void> _generateProductivityTrends() async {
    // Generate mock productivity trends for the last 7 days
    _productivityTrends = List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      return {
        'date': date,
        'productivity': 60 + (math.Random().nextDouble() * 40), // 60-100%
        'tasks_completed': math.Random().nextInt(8) + 2, // 2-10 tasks
        'habits_completed': math.Random().nextInt(5) + 1, // 1-6 habits
        'focus_time': math.Random().nextInt(180) + 60, // 60-240 minutes
      };
    });
  }

  Future<void> _analyzeFocusSessions() async {
    // Mock focus session data
    _focusSessions = [
      {'date': DateTime.now().subtract(Duration(days: 1)), 'duration': 25, 'completed': true},
      {'date': DateTime.now().subtract(Duration(days: 1)), 'duration': 25, 'completed': true},
      {'date': DateTime.now().subtract(Duration(days: 2)), 'duration': 25, 'completed': true},
      {'date': DateTime.now().subtract(Duration(days: 2)), 'duration': 15, 'completed': false},
      {'date': DateTime.now().subtract(Duration(days: 3)), 'duration': 25, 'completed': true},
      {'date': DateTime.now().subtract(Duration(days: 4)), 'duration': 25, 'completed': true},
      {'date': DateTime.now().subtract(Duration(days: 5)), 'duration': 20, 'completed': false},
    ];
  }

  Future<void> _calculateHabitStreaks(List<HabitsModel> habits) async {
    // Mock habit streak data
    _habitStreaks = habits.map((habit) {
      return {
        'habit_name': habit.habitTitle,
        'current_streak': math.Random().nextInt(15) + 1,
        'longest_streak': math.Random().nextInt(30) + 10,
        'completion_rate': (math.Random().nextDouble() * 40) + 60, // 60-100%
        'last_completed': DateTime.now().subtract(Duration(days: math.Random().nextInt(3))),
      };
    }).toList();
  }

  Future<void> _analyzeTaskCompletionRates(List<Tasks> tasks) async {
    // Group tasks by type and calculate completion rates
    Map<String, List<Tasks>> tasksByType = {};
    for (var task in tasks) {
      tasksByType.putIfAbsent(task.taskType ?? 'Other', () => []).add(task);
    }
    
    _taskCompletionRates = tasksByType.entries.map((entry) {
      int completed = entry.value.where((task) => task.isCompleted == 1).length;
      double rate = entry.value.isNotEmpty ? (completed / entry.value.length) * 100 : 0;
      
      return {
        'task_type': entry.key,
        'total_tasks': entry.value.length,
        'completed_tasks': completed,
        'completion_rate': rate,
      };
    }).toList();
  }

  Future<void> _generateTimeBasedAnalytics() async {
    // Daily activity for the last 7 days
    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      _dailyActivity[date.toString().split(' ')[0]] = math.Random().nextInt(50) + 20;
    }
    
    // Hourly productivity (24 hours)
    for (int hour = 0; hour < 24; hour++) {
      _hourlyProductivity[hour.toString()] = math.Random().nextDouble() * 100;
    }
    
    // Weekly progress
    _weeklyProgress = List.generate(7, (index) {
      return {
        'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
        'productivity': 60 + (math.Random().nextDouble() * 40),
        'tasks': math.Random().nextInt(10) + 1,
        'habits': math.Random().nextInt(5) + 1,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Text('Advanced Analytics'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTimeRange = value;
              });
              _loadAdvancedAnalytics();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'week', child: Text('This Week')),
              PopupMenuItem(value: 'month', child: Text('This Month')),
              PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedTimeRange.toUpperCase()),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAdvancedAnalytics,
            tooltip: 'Refresh Analytics',
          ),
        ],
      ) : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  SizedBox(height: 24),
                  
                  // Key Metrics
                  _buildKeyMetrics(),
                  SizedBox(height: 24),
                  
                  // Productivity Score
                  _buildProductivityScore(),
                  SizedBox(height: 24),
                  
                  // Productivity Trends
                  _buildProductivityTrends(),
                  SizedBox(height: 24),
                  
                  // Focus Sessions Analysis
                  _buildFocusSessionsAnalysis(),
                  SizedBox(height: 24),
                  
                  // Habit Streaks
                  _buildHabitStreaks(),
                  SizedBox(height: 24),
                  
                  // Task Completion by Type
                  _buildTaskCompletionByType(),
                  SizedBox(height: 24),
                  
                  // Time-based Analytics
                  _buildTimeBasedAnalytics(),
                  SizedBox(height: 24),
                  
                  // Weekly Progress
                  _buildWeeklyProgress(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Analytics Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Deep insights into your productivity patterns and performance trends',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Performance Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Productivity Score',
                '${_overallProductivityScore.toStringAsFixed(1)}%',
                Icons.trending_up,
                Theme.of(context).colorScheme.primary,
                _overallProductivityScore / 100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Focus Efficiency',
                '${_focusEfficiency.toStringAsFixed(1)}%',
                Icons.timer,
                Colors.orange,
                _focusEfficiency / 100,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Habit Consistency',
                '${_habitConsistency.toStringAsFixed(1)}%',
                Icons.track_changes,
                Colors.green,
                _habitConsistency / 100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Task Completion',
                '${_taskCompletionRate.toStringAsFixed(1)}%',
                Icons.task_alt,
                Colors.purple,
                _taskCompletionRate / 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityScore() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Overall Productivity Score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _overallProductivityScore / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '${_overallProductivityScore.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _getProductivityMessage(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getProductivityMessage() {
    if (_overallProductivityScore >= 90) return 'Excellent! You\'re performing at peak productivity levels.';
    if (_overallProductivityScore >= 80) return 'Great job! You\'re maintaining high productivity standards.';
    if (_overallProductivityScore >= 70) return 'Good progress! Keep up the consistent effort.';
    if (_overallProductivityScore >= 60) return 'You\'re on the right track. Focus on completing more tasks.';
    return 'There\'s room for improvement. Try setting smaller, achievable goals.';
  }

  Widget _buildProductivityTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productivity Trends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _productivityTrends.length,
            itemBuilder: (context, index) {
              final trend = _productivityTrends[index];
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: trend['productivity'] / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${trend['productivity'].toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${trend['date'].day}/${trend['date'].month}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFocusSessionsAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus Sessions Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_focusSessions.length}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ..._focusSessions.take(5).map((session) {
                bool isCompleted = session['completed'] as bool;
                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.cancel,
                        color: isCompleted ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${session['duration']} min session',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${session['date'].day}/${session['date'].month}/${session['date'].year}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitStreaks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Streaks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ..._habitStreaks.map((streak) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak['habit_name'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Current: ${streak['current_streak']} days | Longest: ${streak['longest_streak']} days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${streak['completion_rate'].toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTaskCompletionByType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Completion by Type',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ..._taskCompletionRates.map((rate) {
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rate['task_type'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${rate['completed_tasks']}/${rate['total_tasks']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: rate['completion_rate'] / 100,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
                SizedBox(height: 4),
                Text(
                  '${rate['completion_rate'].toStringAsFixed(1)}% completion rate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTimeBasedAnalytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Productivity Pattern',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hourlyProductivity.length,
            itemBuilder: (context, index) {
              int hour = index;
              double productivity = _hourlyProductivity[hour.toString()] ?? 0;
              
              return Container(
                width: 30,
                margin: EdgeInsets.only(right: 4),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: productivity / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$hour',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Progress Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: _weeklyProgress.map((day) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        day['day'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${day['productivity'].toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${day['tasks']} tasks, ${day['habits']} habits',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: day['productivity'] / 100,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 