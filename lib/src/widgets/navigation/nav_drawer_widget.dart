import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/src/pages/Homepage.dart';
import 'package:notifoo/src/pages/Pomodoro.dart';
import 'package:notifoo/src/pages/Profile.dart';
import 'package:notifoo/src/pages/SignIn.dart';
import 'package:notifoo/src/pages/habit_hub_page.dart';
import 'package:notifoo/src/pages/task_page.dart';
import 'package:notifoo/src/pages/insights_page.dart';
import 'package:notifoo/src/pages/advanced_analytics_dashboard.dart';
import 'package:notifoo/src/pages/settings_page.dart';
import 'package:notifoo/src/pages/pomodoro_home.dart';

class NavigationDrawerWidget extends StatefulWidget {
  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20);
  final user = FirebaseAuth.instance.currentUser;
  
  @override
  Widget build(BuildContext context) {
    final name = user != null ? user!.displayName : 'Guest User';
    final email = user != null ? user!.email : 'Sign in to sync data';
    final backupImg = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';
    final urlImage = user != null ? user!.photoURL : backupImg;

    return Drawer(
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          children: <Widget>[
            buildHeader(
              urlImage: urlImage, 
              name: name, 
              email: email, 
              onClicked: () => _handleProfileTap(context, user),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  //commenting search, since its irrelevant for now, if not needed, remove it
                  // const SizedBox(height: 12),
                  // buildSearchField(),
                  const SizedBox(height: 24),
                  
                  // Main Navigation Section
                   _buildSectionTitle('Trackers'),
                   const SizedBox(height: 8),
                   buildMenuItem(
                    text: 'Activity',
                    icon: Icons.directions_walk,
                    onClicked: () => _navigateToPage(context, 10),
                  ),
                  buildMenuItem(
                    text: 'Usage',
                    icon: Icons.insights,
                    onClicked: () => _navigateToPage(context, 11),
                  ),
                  // buildMenuItem(
                  //   text: 'Alerts',
                  //   icon: Icons.notifications_outlined,
                  //   onClicked: () => _navigateToPage(context, 0),
                  // ),
                  // buildMenuItem(
                  //   text: 'Habits',
                  //   icon: Icons.track_changes_outlined,
                  //   onClicked: () => _navigateToPage(context, 1),
                  // ),
                  // buildMenuItem(
                  //   text: 'Timer',
                  //   icon: Icons.timer_outlined,
                  //   onClicked: () => _navigateToPage(context, 2),
                  // ),
                  // buildMenuItem(
                  //   text: 'Tasks',
                  //   icon: Icons.task_outlined,
                  //   onClicked: () => _navigateToPage(context, 3),
                  // ),
                  // buildMenuItem(
                  //   text: 'Stats',
                  //   icon: Icons.analytics_outlined,
                  //   onClicked: () => _navigateToPage(context, 4),
                  // ),
                  
                  const SizedBox(height: 24),
                  Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  
                  // Insights Section
                  const SizedBox(height: 8),
                  _buildSectionTitle('Insights'),
                  buildMenuItem(
                    text: 'Stats',
                    icon: Icons.insights,
                    onClicked: () => _navigateToPage(context, 4),
                  ),
                  buildMenuItem(
                    text: 'Advanced Analytics',
                    icon: Icons.analytics,
                    onClicked: () => _navigateToPage(context, 7),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  
                  const SizedBox(height: 8),
                  _buildSectionTitle('Settings & More'),
                  buildMenuItem(
                    text: 'Profile',
                    icon: Icons.person_outline,
                    onClicked: () => _navigateToPage(context, 5),
                  ),
                  buildMenuItem(
                    text: 'Settings',
                    icon: Icons.settings_outlined,
                    onClicked: () => _navigateToPage(context, 6),
                  ),
                  
                  buildMenuItem(
                    text: 'Help & Support',
                    icon: Icons.help_outline,
                    onClicked: () => _navigateToPage(context, 8),
                  ),
                  buildMenuItem(
                    text: 'About',
                    icon: Icons.info_outline,
                    onClicked: () => _navigateToPage(context, 9),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign In/Out Button
                  if (user == null)
                    _buildSignInButton(context)
                  else
                    _buildSignOutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToSignIn(context),
        icon: Icon(Icons.login, size: 18),
        label: Text('Sign In with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _signOut(context),
        icon: Icon(Icons.logout, size: 18),
        label: Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget buildHeader({
    String? urlImage,
    String? name,
    String? email,
    VoidCallback? onClicked,
  }) {
    return InkWell(
      onTap: onClicked,
      child: Container(
        padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(urlImage!),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return TextField(
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintText: 'Search...',
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    IconData? icon,
    VoidCallback? onClicked,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        size: 22,
      ),
      title: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
      onTap: onClicked,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _handleProfileTap(BuildContext context, User? user) {
    if (user == null) {
      _navigateToSignIn(context);
    } else {
      _navigateToPage(context, 5); // Profile page
    }
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignIn(),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    Navigator.of(context).pop();
    
    switch (index) {
      case 0: // Alerts
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(
              title: 'Alerts',
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 1: // Habits
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitHubPage(
              title: 'Habits',
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 2: // Timer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PomodoroHome(
              title: 'Timer',
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 3: // Tasks
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskPage(
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 4: // Stats
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsightsPage(
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 5: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              title: 'Profile',
            ),
          ),
        );
        break;
      case 6: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(),
          ),
        );
        break;
      case 7: // Advanced Analytics
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdvancedAnalyticsDashboard(
              openNavigationDrawer: () {},
            ),
          ),
        );
        break;
      case 8: // Help & Support
        _showHelpDialog(context);
        break;
      case 9: // About
        _showAboutDialog(context);
        break;
      case 10: // Activity
        Navigator.pushNamed(context, '/activity');
        break;
      case 11: // Usage
        Navigator.pushNamed(context, '/usage');
        break;
    }
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop();
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
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text('Need help? Contact us at support@notifoo.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About FocusFluke'),
        content: Text('Version 1.0.0\n\nA productivity app to help you stay focused and organized.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
