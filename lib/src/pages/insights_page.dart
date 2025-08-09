import 'package:flutter/material.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';
import 'package:notifoo/src/util/glow.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({
    Key? key, 
    this.openNavigationDrawer,
    this.showAppBar = true,
  }) : super(key: key);
  final VoidCallback? openNavigationDrawer;
  final bool showAppBar;

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  bool _isLoading = true;
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalHabits = 0;
  int _completedHabits = 0;
  int _totalPomodoros = 0;
  int _totalFocusTime = 0;
  double _taskCompletionRate = 0.0;
  double _habitCompletionRate = 0.0;
  List<Map<String, dynamic>> _weeklyData = [];

  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  Future<void> _loadInsightsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load tasks data
      final tasks = await DatabaseHelper.instance.getAllTasks();
      _totalTasks = tasks.length;
      _completedTasks = tasks.where((task) => task.isCompleted == 1).length;
      _taskCompletionRate = _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

      // Load habits data
      final habits = await DatabaseHelper.instance.getHabits();
      _totalHabits = habits.length;
      _completedHabits = habits.where((habit) => habit.isCompleted == 1).length;
      _habitCompletionRate = _totalHabits > 0 ? _completedHabits / _totalHabits : 0.0;

      // Mock pomodoro data
      _totalPomodoros = 12;
      _totalFocusTime = 300; // 5 hours

      // Generate weekly data for heatmap
      _generateWeeklyData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateWeeklyData() {
    _weeklyData = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final completionRate = 0.3 + (0.7 * (i / 6)); // Mock data
      
      _weeklyData.add({
        'day': dayName,
        'date': date,
        'completionRate': completionRate,
        'tasks': 3 + (i * 2),
        'habits': 2 + i,
        'pomodoros': 1 + i,
      });
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  Color _getHeatmapColor(double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.6) return Colors.lightGreen;
    if (rate >= 0.4) return Colors.orange;
    if (rate >= 0.2) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Text('Insights'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInsightsData,
            tooltip: 'Refresh Data',
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
                  Text(
                    'Your Progress Insights',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your productivity and growth over time',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Overview Cards
                  _buildOverviewCards(),
                  SizedBox(height: 24),

                  // Weekly Heatmap
                  _buildWeeklyHeatmap(),
                  SizedBox(height: 24),

                  // Progress Charts
                  _buildProgressCharts(),
                  SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tasks',
                '$_completedTasks/$_totalTasks',
                Icons.task,
                Theme.of(context).colorScheme.primary,
                _taskCompletionRate,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Habits',
                '$_completedHabits/$_totalHabits',
                Icons.track_changes,
                Colors.green,
                _habitCompletionRate,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pomodoros',
                '$_totalPomodoros',
                Icons.timer,
                Colors.orange,
                0.0, // No progress bar for count
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Focus Time',
                '${(_totalFocusTime / 60).round()}h',
                Icons.schedule,
                Colors.purple,
                0.0, // No progress bar for time
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double progress) {
    return Glows.wrapGlow(
      color: color,
      blur: 14,
      child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
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
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (progress > 0) ...[
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildWeeklyHeatmap() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Text(
            'Weekly Activity Heatmap',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: _weeklyData.map((dayData) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(dayData['completionRate']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${(dayData['completionRate'] * 100).round()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      dayData['day'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Trends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildProgressRow('Tasks', _taskCompletionRate, Theme.of(context).colorScheme.primary),
              SizedBox(height: 16),
              _buildProgressRow('Habits', _habitCompletionRate, Colors.green),
              SizedBox(height: 16),
              _buildProgressRow('Focus Sessions', 0.75, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, double progress, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        SizedBox(width: 12),
        Text(
          '${(progress * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Completed "Morning Exercise" habit',
                '2 hours ago',
                Icons.track_changes,
                Colors.green,
              ),
              SizedBox(height: 12),
              _buildActivityItem(
                'Finished 25-min Pomodoro session',
                '1 hour ago',
                Icons.timer,
                Colors.orange,
              ),
              SizedBox(height: 12),
              _buildActivityItem(
                'Added new task "Review project"',
                '30 minutes ago',
                Icons.task,
                Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Row(
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
