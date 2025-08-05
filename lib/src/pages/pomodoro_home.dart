import 'package:flutter/material.dart';
import 'package:notifoo/src/widgets/Pomodoro/BannerPomodoro.dart';
import 'package:notifoo/src/widgets/Pomodoro/PomodoroTaskWidget.dart';
import 'package:notifoo/src/widgets/Pomodoro/pomodoroSavedListW.dart';
import 'package:notifoo/src/widgets/Topbar.dart';
import 'package:notifoo/src/widgets/headline.dart';
import 'package:notifoo/src/widgets/home/home_banner_widget.dart';

class PomodoroHome extends StatefulWidget {
  PomodoroHome({
    Key? key, 
    this.title, 
    this.openNavigationDrawer,
    this.showAppBar = true,
  }) : super(key: key);
  final String? title;
  final VoidCallback? openNavigationDrawer;
  final bool showAppBar;

  @override
  _PomodoroHomeState createState() => _PomodoroHomeState();
}

class _PomodoroHomeState extends State<PomodoroHome> with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _breathingController;
  
  int _workDuration = 25; // minutes
  int _breakDuration = 5; // minutes
  int _currentTime = 0; // seconds
  bool _isRunning = false;
  bool _isWorkTime = true;
  int _completedPomodoros = 0;
  int _totalFocusTime = 0; // minutes

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: Duration(minutes: _workDuration),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _breathingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    _timerController.addListener(() {
      setState(() {
        _currentTime = (_timerController.value * _workDuration * 60).round();
      });
    });

    // Start breathing animation
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      _timerController.forward();
      _pulseController.repeat();
      _glowController.repeat();
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      setState(() {
        _isRunning = false;
      });
      _timerController.stop();
      _pulseController.stop();
      _glowController.stop();
    }
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _currentTime = 0;
      _isWorkTime = true;
    });
    _timerController.reset();
    _pulseController.stop();
    _glowController.stop();
  }

  void _completePomodoro() {
    setState(() {
      _completedPomodoros++;
      _totalFocusTime += _workDuration;
      _isWorkTime = !_isWorkTime;
    });
    _resetTimer();
    
    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWorkTime 
            ? 'Break completed! Time to focus again.' 
            : 'Pomodoro completed! Take a break.'),
        backgroundColor: _isWorkTime 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.showAppBar ? AppBar(
        title: Text('Pomodoro'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: widget.openNavigationDrawer,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showSettings(),
            tooltip: 'Timer Settings',
          ),
        ],
      ) : null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Timer',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stay focused with the Pomodoro technique',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Stats Card
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
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '$_completedPomodoros pomodoros • $_totalFocusTime min focused',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
            
            // Timer Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Timer Display
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Timer Circle with Glow Effect
                        AnimatedBuilder(
                          animation: _breathingController,
                          builder: (context, child) {
                            return Container(
                              width: 280,
                              height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow Effect
                                  if (_isRunning)
                                    Container(
                                      width: 280 + (_breathingController.value * 20),
                                      height: 280 + (_breathingController.value * 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isWorkTime 
                                                ? Theme.of(context).colorScheme.primary
                                                : Theme.of(context).colorScheme.secondary)
                                                .withOpacity(0.3 + (_glowController.value * 0.2)),
                                            blurRadius: 30 + (_breathingController.value * 10),
                                            spreadRadius: 5 + (_breathingController.value * 5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  // Progress Circle
                                  Container(
                                    width: 280,
                                    height: 280,
                                    child: CircularProgressIndicator(
                                      value: _isRunning ? _timerController.value : 0,
                                      strokeWidth: 12,
                                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _isWorkTime 
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                  
                                  // Time Display
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatTime(_currentTime),
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _isWorkTime 
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _isWorkTime ? 'Focus Time' : 'Break Time',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 32),
                        
                        // Timer Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isRunning ? _pauseTimer : _startTimer,
                              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                              label: Text(_isRunning ? 'Pause' : 'Start'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRunning 
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _resetTimer,
                              icon: Icon(Icons.refresh),
                              label: Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                foregroundColor: Theme.of(context).colorScheme.onSurface,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Quick Actions
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () => _startQuickSession(25),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.work,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '25 min',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Focus',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () => _startQuickSession(5),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.coffee,
                                      color: Theme.of(context).colorScheme.secondary,
                                      size: 32,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '5 min',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Break',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }

  void _startQuickSession(int minutes) {
    setState(() {
      _workDuration = minutes;
      _isWorkTime = minutes > 10; // 25+ min is work time
      _currentTime = 0;
      _isRunning = false;
    });
    
    _timerController.duration = Duration(minutes: minutes);
    _timerController.reset();
    _startTimer();
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Timer Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Work Duration'),
              subtitle: Text('$_workDuration minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (_workDuration > 1) {
                        setState(() => _workDuration--);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() => _workDuration++);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Break Duration'),
              subtitle: Text('$_breakDuration minutes'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      if (_breakDuration > 1) {
                        setState(() => _breakDuration--);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() => _breakDuration++);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}
