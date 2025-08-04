import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';
  double _timerDuration = 25.0;
  double _breakDuration = 5.0;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _themes = ['System', 'Light', 'Dark'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Customize your app experience',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            _buildSwitchTile(
              'Enable Notifications',
              'Receive alerts for tasks and habits',
              Icons.notifications_outlined,
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchTile(
              'Sound Alerts',
              'Play sound for notifications',
              Icons.volume_up_outlined,
              _soundEnabled,
              (value) => setState(() => _soundEnabled = value),
            ),
            _buildSwitchTile(
              'Vibration',
              'Vibrate for notifications',
              Icons.vibration_outlined,
              _vibrationEnabled,
              (value) => setState(() => _vibrationEnabled = value),
            ),
            SizedBox(height: 24),

            // Appearance Section
            _buildSectionTitle('Appearance'),
            _buildDropdownTile(
              'Theme',
              'Choose your preferred theme',
              Icons.palette_outlined,
              _selectedTheme,
              _themes,
              (value) => setState(() => _selectedTheme = value!),
            ),
            _buildDropdownTile(
              'Language',
              'Select your language',
              Icons.language_outlined,
              _selectedLanguage,
              _languages,
              (value) => setState(() => _selectedLanguage = value!),
            ),
            SizedBox(height: 24),

            // Timer Settings Section
            _buildSectionTitle('Timer Settings'),
            _buildSliderTile(
              'Focus Duration',
              '${_timerDuration.round()} minutes',
              Icons.timer_outlined,
              _timerDuration,
              5.0,
              60.0,
              (value) => setState(() => _timerDuration = value),
            ),
            _buildSliderTile(
              'Break Duration',
              '${_breakDuration.round()} minutes',
              Icons.coffee_outlined,
              _breakDuration,
              1.0,
              30.0,
              (value) => setState(() => _breakDuration = value),
            ),
            SizedBox(height: 24),

            // Account Section
            _buildSectionTitle('Account'),
            _buildAccountTile(),
            SizedBox(height: 24),

            // Data & Privacy Section
            _buildSectionTitle('Data & Privacy'),
            _buildActionTile(
              'Export Data',
              'Download your data',
              Icons.download_outlined,
              () => _exportData(),
            ),
            _buildActionTile(
              'Clear Cache',
              'Free up storage space',
              Icons.cleaning_services_outlined,
              () => _clearCache(),
            ),
            _buildActionTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip_outlined,
              () => _showPrivacyPolicy(),
            ),
            SizedBox(height: 24),

            // About Section
            _buildSectionTitle('About'),
            _buildInfoTile(
              'Version',
              '1.0.0',
              Icons.info_outline,
            ),
            _buildActionTile(
              'Terms of Service',
              'Read our terms of service',
              Icons.description_outlined,
              () => _showTermsOfService(),
            ),
            _buildActionTile(
              'Rate App',
              'Rate us on the app store',
              Icons.star_outline,
              () => _rateApp(),
            ),
            SizedBox(height: 32),

            // Reset Button
            Container(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetToDefaults,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Reset to Defaults'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSliderTile(String title, String value, IconData icon, double sliderValue, double min, double max, ValueChanged<double> onChanged) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Slider(
              value: sliderValue,
              min: min,
              max: max,
              divisions: ((max - min) / 5).round(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile() {
    final user = FirebaseAuth.instance.currentUser;
    
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user?.photoURL != null 
              ? NetworkImage(user!.photoURL!) 
              : null,
          child: user?.photoURL == null 
              ? Icon(Icons.person, color: Colors.white)
              : null,
        ),
        title: Text(user?.displayName ?? 'Guest User'),
        subtitle: Text(user?.email ?? 'Not signed in'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showAccountDialog(),
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save settings to local storage or backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAccountDialog() {
    final user = FirebaseAuth.instance.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Name: ${user.displayName ?? 'N/A'}'),
              SizedBox(height: 8),
              Text('Email: ${user.email ?? 'N/A'}'),
              SizedBox(height: 16),
              Text('Account created: ${user.metadata.creationTime?.toString().split(' ')[0] ?? 'N/A'}'),
            ] else ...[
              Text('Not signed in'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data export started'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Cache'),
        content: Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: Text('Our privacy policy can be found at notifoo.com/privacy'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms of Service'),
        content: Text('Our terms of service can be found at notifoo.com/terms'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening app store...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset to Defaults'),
        content: Text('Are you sure you want to reset all settings to their default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _notificationsEnabled = true;
                _darkModeEnabled = false;
                _soundEnabled = true;
                _vibrationEnabled = true;
                _selectedLanguage = 'English';
                _selectedTheme = 'System';
                _timerDuration = 25.0;
                _breakDuration = 5.0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
} 