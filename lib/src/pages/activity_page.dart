import 'package:flutter/material.dart';
import 'package:notifoo/src/services/steps_service.dart';
import 'package:notifoo/src/util/glow.dart';
import 'package:notifoo/src/services/location_service.dart';
import 'package:notifoo/src/services/settings_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final TextEditingController _manualStepsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StepsService>().initialize();
      // Auto start route if enabled
      final auto = SettingsService().getBool(SettingsService.kAutoRouteRecord, defaultValue: false);
      if (auto) {
        context.read<LocationService>().startTracking();
      }
    });
  }

  @override
  void dispose() {
    _manualStepsController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Future<void> _refreshData() async {
    try {
      await context.read<StepsService>().refreshData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _connectGoogleFit() async {
    try {
      final success = await context.read<StepsService>().connectGoogleFit();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully connected to Google Fit!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // Check if permission is permanently denied
          final isPermanentlyDenied = await context.read<StepsService>().isActivityRecognitionPermissionPermanentlyDenied();
          if (isPermanentlyDenied) {
            _showPermissionDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to connect to Google Fit. Please check permissions.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error connecting to Google Fit: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Activity Recognition permission is required to access Google Fit step data. '
            'This permission has been permanently denied. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<StepsService>().openAppSettingsForPermission();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = context.watch<StepsService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Ring + Goal card
              Glows.wrapGlow(
                color: cs.primary,
                blur: 14,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      // Connection Status Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: steps.usingRealData 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: steps.usingRealData 
                                ? Colors.green.withOpacity(0.3) 
                                : Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              steps.usingRealData ? Icons.fitness_center : Icons.fitness_center_outlined,
                              size: 16,
                              color: steps.usingRealData ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              steps.usingRealData 
                                  ? 'Connected to Google Fit' 
                                  : 'Using Demo Data',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: steps.usingRealData ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Permission Status Indicator
                      FutureBuilder<bool>(
                        future: context.read<StepsService>().isActivityRecognitionPermissionPermanentlyDenied(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Permission Required',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _showPermissionDialog(),
                                    child: Text(
                                      'Fix',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      if (steps.usingRealData && steps.lastUpdated != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${_formatTime(steps.lastUpdated!)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _ProgressRing(
                            progress: (steps.todaySteps / steps.dailyGoal).clamp(0.0, 1.0),
                            size: 90,
                            color: cs.primary,
                            label: '${steps.todaySteps}',
                            sublabel: 'steps',
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Steps", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                                const SizedBox(height: 6),
                                Text('Goal: ${steps.dailyGoal}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    _SmallStat(icon: Icons.local_fire_department, label: '${steps.caloriesKcal} kcal'),
                                    _SmallStat(icon: Icons.access_time, label: '${steps.activeMinutes} min'),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: cs.primary,
                                onPressed: () => steps.setGoal(steps.dailyGoal + 500),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: cs.primary,
                                onPressed: () => steps.setGoal(steps.dailyGoal - 500),
                              ),
                              const SizedBox(height: 8),
                              _GoogleFitButton(steps: steps),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Manual step entry form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Step Entry',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _manualStepsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Steps',
                                hintText: 'Enter steps',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter steps';
                                }
                                final steps = int.tryParse(value);
                                if (steps == null || steps < 0) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final steps = int.parse(_manualStepsController.text);
                                context.read<StepsService>().addManualSteps(steps);
                                _manualStepsController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added $steps steps!'),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use this to add steps manually or correct your count. '
                        'This works alongside device sensors and Google Fit.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Troubleshooting Section
              if (!steps.usingRealData) ...[
                Glows.wrapGlow(
                  color: Colors.blue.withOpacity(0.3),
                  blur: 8,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Google Fit Connection Help',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'If you\'re having trouble connecting to Google Fit:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _TroubleshootingItem(
                          icon: Icons.check_circle_outline,
                          text: 'Make sure you have a Google account signed in',
                        ),
                        _TroubleshootingItem(
                          icon: Icons.check_circle_outline,
                          text: 'Ensure Google Fit app is installed and updated',
                        ),
                        _TroubleshootingItem(
                          icon: Icons.check_circle_outline,
                          text: 'Grant fitness data permissions when prompted',
                        ),
                        _TroubleshootingItem(
                          icon: Icons.check_circle_outline,
                          text: 'Check your internet connection',
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _connectGoogleFit,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Connecting Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Hourly bar (mock) – simple visualization
              Text('Hourly Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(12, (i) {
                    final h = (i % 2 == 0) ? 60.0 : 28.0;
                    final productive = i % 3 != 0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          height: h,
                          decoration: BoxDecoration(
                            color: productive ? cs.primary.withOpacity(0.8) : Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Weekly Steps + quick metrics
              Text('This Week', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 12),
              Row(
                children: List.generate(7, (i) {
                  final value = steps.weeklySteps[i];
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: (value / (steps.dailyGoal.toDouble())).clamp(0.0, 1.0) * 70 + 8,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(['M','T','W','T','F','S','S'][i], style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Distance / Streak / Goal cards + tracking control
              Row(
                children: [
                  Expanded(
                    child: Glows.wrapGlow(
                      color: cs.primary,
                      blur: 10,
                      child: _InfoCard(
                        icon: Icons.map_outlined,
                        title: 'Distance',
                        value: '${steps.distanceKm.toStringAsFixed(2)} km',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Glows.wrapGlow(
                      color: cs.primary,
                      blur: 10,
                      child: _InfoCard(
                        icon: Icons.emoji_events_outlined,
                        title: 'Streak',
                        value: '${steps.streakDays} days',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Consumer<LocationService>(
                builder: (context, loc, _) => Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: loc.isTracking ? null : () => loc.startTracking(),
                      icon: const Icon(Icons.route),
                      label: const Text('Start Route'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: loc.isTracking ? () => loc.stopTracking() : null,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('Stop'),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              // Tracking Method Status
              Consumer<StepsService>(
                builder: (context, steps, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: steps.usingRealData 
                        ? Colors.green.withOpacity(0.3)
                        : steps.usingDeviceSensors
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            steps.usingRealData 
                              ? Icons.fitness_center
                              : steps.usingDeviceSensors
                                ? Icons.sensors
                                : Icons.edit_note,
                            color: steps.usingRealData 
                              ? Colors.green
                              : steps.usingDeviceSensors
                                ? Colors.blue
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tracking Method',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps.getTrackingStatusDescription(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      if (steps.usingDeviceSensors) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              steps.isWalking ? Icons.directions_walk : Icons.pause,
                              color: steps.isWalking ? Colors.green : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              steps.isWalking 
                                ? 'Walking detected (${steps.consecutiveSteps} consecutive steps)'
                                : 'Waiting for movement',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: steps.isWalking ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Device sensors are tracking your steps in real-time using accelerometer data. '
                          'Connect to Google Fit for cloud sync and backup.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        if (steps.isWalking) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Sensor Accuracy: ${steps.sensorAccuracyInfo}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recommendations Section
              Consumer<StepsService>(
                builder: (context, steps, _) {
                  final recommendations = steps.getStepTrackingRecommendations();
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: steps.shouldRecommendGoogleFit
                          ? Colors.orange.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              steps.shouldRecommendGoogleFit
                                ? Icons.lightbulb_outline
                                : Icons.check_circle_outline,
                              color: steps.shouldRecommendGoogleFit
                                ? Colors.orange
                                : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Step Tracking Recommendations',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                        if (steps.shouldRecommendGoogleFit) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No Google Fit? No Problem!',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your device can track steps using built-in sensors in real-time. '
                                  'The app will automatically switch to device tracking when Google Fit is unavailable. '
                                  'You can also manually enter your steps for accurate tracking.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Sensor Calibration Section (only show when using device sensors)
              Consumer<StepsService>(
                builder: (context, steps, _) {
                  if (!steps.usingDeviceSensors) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.tune,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sensor Calibration',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Adjust step detection sensitivity. Higher values detect more subtle movements, lower values only detect clear steps.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Threshold: ${steps.stepThreshold.toStringAsFixed(1)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Slider(
                                    value: steps.stepThreshold,
                                    min: 1.0,
                                    max: 10.0,
                                    divisions: 18,
                                    activeColor: Colors.purple,
                                    onChanged: (value) {
                                      steps.setStepThreshold(value);
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Sensitive',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Standard',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'Strict',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tip: Start with the default setting and adjust based on your walking pattern.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.purple.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Debug Section (only show in debug mode)
              if (kDebugMode) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bug_report, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Debug Information (Debug Mode Only)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Consumer<StepsService>(
                        builder: (context, steps, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Service Status:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text('• Google Fit: ${steps.isConnected} (${steps.usingRealData})'),
                            Text('• Device Sensors: ${steps.usingDeviceSensors}'),
                            Text('• Walking: ${steps.isWalking}'),
                            Text('• Consecutive Steps: ${steps.consecutiveSteps}'),
                            Text('• Step Threshold: ${steps.stepThreshold}'),
                            Text('• Device Step Count: ${steps.currentDeviceStepCount}'),
                            Text('• Today Steps: ${steps.todaySteps}'),
                            const SizedBox(height: 8),
                            Text('Sensor Health:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Builder(
                              builder: (context) {
                                final healthInfo = steps.getSensorHealthInfo();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('• Receiving Data: ${healthInfo['isReceivingData']}'),
                                    Text('• Buffer Size: ${healthInfo['bufferSize']}'),
                                    Text('• Last Magnitude: ${(healthInfo['lastMagnitude'] as double).toStringAsFixed(2)}'),
                                    Text('• Last Step Time: ${healthInfo['lastStepTime'] ?? 'Never'}'),
                                    Text('• Total Events: ${healthInfo['totalSensorEvents']}'),
                                    Text('• Event Frequency: ${(healthInfo['sensorEventFrequency'] as double).toStringAsFixed(1)} Hz'),
                                    Text('• First Event: ${healthInfo['firstSensorEvent'] ?? 'Never'}'),
                                    Text('• Last Event: ${healthInfo['lastSensorEvent'] ?? 'Never'}'),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text('Current Status:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text('• Tracking Method: ${steps.getTrackingMethod()}'),
                            Text('• Accuracy: ${steps.getTrackingAccuracy()}'),
                            Text('• Data Source: ${steps.dataSource}'),
                            Text('• Has Step Data: ${steps.hasStepData}'),
                            Text('• Last Update: ${steps.lastStepUpdateTime?.toString() ?? 'Never'}'),
                            const SizedBox(height: 8),
                            Text('Step Detection Settings:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text('• Current Threshold: ${steps.stepThreshold.toStringAsFixed(1)}'),
                            Text('• Min Step Interval: 300ms'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: steps.stepThreshold,
                                    min: 1.0,
                                    max: 10.0,
                                    divisions: 18,
                                    activeColor: Colors.red,
                                    onChanged: (value) {
                                      steps.setStepThreshold(value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text('${steps.stepThreshold.toStringAsFixed(1)}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sensitive', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                Text('Standard', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                Text('Strict', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Permission Status:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            FutureBuilder<bool>(
                              future: context.read<StepsService>().isActivityRecognitionPermissionPermanentlyDenied(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text('• Activity Recognition: ${snapshot.data! ? "Permanently Denied" : "Available"}');
                                }
                                return Text('• Activity Recognition: Checking...');
                              },
                            ),
                            const SizedBox(height: 16),
                            // Wrap buttons in a scrollable row to prevent overflow
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await context.read<StepsService>().refreshData();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Data refreshed')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Refresh Data'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final connected = await context.read<StepsService>().checkConnectionStatus();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Connection: $connected')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Check Connection'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await context.read<StepsService>().testSensorFunctionality();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Sensor test completed - check console for details')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Test Sensors'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await context.read<StepsService>().reinitializeSensors();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Sensors reinitialized')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Reinitialize Sensors'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().resetStepThreshold();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Step threshold reset to default')),
                                      );
                                    },
                                    child: const Text('Reset Threshold'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().simulateWalking();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Walking simulation started - check console for details')),
                                      );
                                    },
                                    child: const Text('Simulate Walking'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().testStepDetection();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Step detection test completed - check console for details')),
                                      );
                                    },
                                    child: const Text('Test Step Detection'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        final isWorking = await context.read<StepsService>().checkAccelerometerWorking();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Accelerometer: ${isWorking ? "Working" : "Not Working"}'),
                                            backgroundColor: isWorking ? Colors.green : Colors.red,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Test Accelerometer'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().addTestStep();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Test step added!')),
                                      );
                                    },
                                    child: const Text('Add Test Step'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().clearSensorPerformanceData();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sensor performance data cleared')),
                                      );
                                    },
                                    child: const Text('Clear Data'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<StepsService>().resetConnectingState();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Connecting state reset')),
                                      );
                                    },
                                    child: const Text('Reset Connecting'),
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
                const SizedBox(height: 20),
              ],

              // Daily activity list with route preview and points
              Text('Daily Activity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 12),
              Column(
                children: steps.dailyHistory.map((entry) {
                  final DateTime date = entry['date'] as DateTime;
                  final int stepsCount = (entry['steps'] as int?) ?? 0;
                  final double distKm = (entry['distanceKm'] as double?) ?? 0.0;
                  final int points = (entry['points'] as int?) ?? 0;
                  // Merge live route (if recording today) for preview
                  final loc = context.read<LocationService>();
                  final List<Offset> route = (entry['date'].day == DateTime.now().day && loc.todayRoute.isNotEmpty)
                      ? loc.todayRoute
                      : (entry['route'] as List).cast<Offset>();
                  return Glows.wrapGlow(
                    color: cs.primary,
                    blur: 8,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.primary.withOpacity(0.12)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomPaint(
                            painter: _RoutePreviewPainter(points: route, color: cs.primary.withOpacity(0.9)),
                            size: const Size(56, 56),
                          ),
                        ),
                      ),
                      title: Text('${date.day}/${date.month}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      subtitle: Text('$stepsCount steps · ${distKm.toStringAsFixed(2)} km · $points pts', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.75))),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).pushNamed('/activity-detail', arguments: entry);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleFitButton extends StatelessWidget {
  final StepsService steps;

  const _GoogleFitButton({required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isConnecting) {
      return SizedBox(
        width: 80,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Connecting...', style: TextStyle(fontSize: 10)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
        ),
      );
    }

    if (steps.usingRealData) {
      return Column(
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final ok = await steps.connectGoogleFit();
                if (!context.mounted) return;
                if (ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google Fit reconnected'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to reconnect to Google Fit'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error reconnecting: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.favorite, size: 16, color: Colors.green),
            label: const Text('Connected', style: TextStyle(fontSize: 10)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              side: BorderSide(color: Colors.green),
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Disconnect Google Fit'),
                  content: const Text('Are you sure you want to disconnect from Google Fit?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && context.mounted) {
                try {
                  await steps.disconnectFromGoogleFit();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Disconnected from Google Fit'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error disconnecting: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.link_off, size: 12),
            label: const Text('Disconnect', style: TextStyle(fontSize: 8)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              side: BorderSide(color: Colors.red.withOpacity(0.7)),
            ),
          ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: () async {
        try {
          final ok = await steps.connectGoogleFit();
          if (!context.mounted) return;
          if (ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Google Fit connected successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please grant Google Fit permissions in the Google dialog'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error connecting: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      icon: const Icon(Icons.favorite_outline, size: 16),
      label: const Text('Connect Fit', style: TextStyle(fontSize: 10)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmallStat({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.8))),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final double size;
  final Color color;
  final String label;
  final String sublabel;
  const _ProgressRing({required this.progress, required this.size, required this.color, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.25);
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ).createShader(rect),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _RingPainter(progress: value, color: color),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
              Text(sublabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            ],
          )
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final Rect rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.3), color, color.withOpacity(0.3)],
        stops: const [0.0, 0.6, 1.0],
        startAngle: -3.14 / 2,
        endAngle: -3.14 / 2 + 6.28,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    // background circle
    canvas.drawCircle(center, radius, bgPaint);

    // arc
    final sweep = progress * 6.28318530718;
    final start = -3.14159265359 / 2;
    final rectArc = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rectArc, start, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color;
}

class _RoutePreviewPainter extends CustomPainter {
  final List<Offset> points; // normalized 0..1
  final Color color;
  _RoutePreviewPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    // subtle background panel
    final bgPaint = Paint()..color = color.withOpacity(0.08);
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    canvas.drawRRect(rrect, bgPaint);

    final path = Path();
    path.moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (int i = 1; i < points.length; i++) {
      final o = points[i];
      path.lineTo(o.dx * size.width, o.dy * size.height);
    }

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawPath(path, line);

    final dot = Paint()..color = color;
    final s = points.first;
    final e = points.last;
    canvas.drawCircle(Offset(s.dx * size.width, s.dy * size.height), 3, dot);
    canvas.drawCircle(Offset(e.dx * size.width, e.dy * size.height), 3, dot);
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) => oldDelegate.points != points || oldDelegate.color != color;
}

class _TroubleshootingItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TroubleshootingItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue,),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


