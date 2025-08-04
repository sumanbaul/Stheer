import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/src/helper/DatabaseHelper.dart';
import 'package:notifoo/src/model/tasks.dart';
import 'package:notifoo/src/model/habits_model.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  
  // User statistics
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalHabits = 0;
  int _completedHabits = 0;
  int _totalPomodoros = 0;
  int _totalFocusTime = 0;
  double _taskCompletionRate = 0.0;
  double _habitCompletionRate = 0.0;
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
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
      _currentStreak = 7;
      _longestStreak = 15;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with Profile Info
                  _buildProfileHeader(),
                  
                  // Statistics Section
                  _buildStatisticsSection(),
                  
                  // Achievements Section
                  _buildAchievementsSection(),
                  
                  // Activity Section
                  _buildActivitySection(),
                  
                  // Settings Section
                  _buildSettingsSection(),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final displayName = user?.displayName ?? 'Guest User';
    final email = user?.email ?? 'Not signed in';
    final photoURL = user?.photoURL ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(photoURL),
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          
          // User Name
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          
          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 16),
          
          // Join Date
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Member since ${user?.metadata.creationTime?.toString().split(' ')[0] ?? 'Recently'}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Tasks',
                '$_completedTasks/$_totalTasks',
                Icons.task,
                Theme.of(context).colorScheme.primary,
                _taskCompletionRate,
              ),
              _buildStatCard(
                'Habits',
                '$_completedHabits/$_totalHabits',
                Icons.track_changes,
                Colors.green,
                _habitCompletionRate,
              ),
              _buildStatCard(
                'Pomodoros',
                '$_totalPomodoros',
                Icons.timer,
                Colors.orange,
                0.0,
              ),
              _buildStatCard(
                'Focus Time',
                '${(_totalFocusTime / 60).round()}h',
                Icons.schedule,
                Colors.purple,
                0.0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, double progress) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
    );
  }

  Widget _buildAchievementsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  'Current Streak',
                  '$_currentStreak days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  'Longest Streak',
                  '$_longestStreak days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Achievement badges
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Badges',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadge('First Task', Icons.star, Colors.amber),
                    _buildBadge('Habit Master', Icons.track_changes, Colors.green),
                    _buildBadge('Focus Pro', Icons.timer, Colors.blue),
                    _buildBadge('Consistent', Icons.trending_up, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          
          Container(
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
                Divider(height: 1),
                _buildActivityItem(
                  'Finished 25-min Pomodoro session',
                  '1 hour ago',
                  Icons.timer,
                  Colors.orange,
                ),
                Divider(height: 1),
                _buildActivityItem(
                  'Added new task "Review project"',
                  '30 minutes ago',
                  Icons.task,
                  Theme.of(context).colorScheme.primary,
                ),
                Divider(height: 1),
                _buildActivityItem(
                  'Achieved 7-day streak!',
                  '1 day ago',
                  Icons.local_fire_department,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        time,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
                  title: Text('Edit Profile'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
                  title: Text('Notification Settings'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                  title: Text('Privacy & Security'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to help
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                  onTap: () => _signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signed out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
