import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:notifoo/src/util/glow.dart';
import 'package:notifoo/src/services/app_usage_service.dart';

class AppUsagePage extends StatefulWidget {
  const AppUsagePage({Key? key}) : super(key: key);

  @override
  State<AppUsagePage> createState() => _AppUsagePageState();
}

class _AppUsagePageState extends State<AppUsagePage> {
  final AppUsageService _usage = AppUsageService();
  bool _loading = true;
  bool _hasPermission = false;
  int _screenTimeMinutes = 0;
  int _pickups = 0;
  List<Map<String, dynamic>> _mostUsed = [];
  List<int> _weekDailyMinutes = const [0,0,0,0,0,0,0];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!Platform.isAndroid) {
      setState(() { _loading = false; });
      return;
    }
    final hasPerm = await _usage.hasPermission();
    if (!hasPerm) {
      setState(() { _hasPermission = false; _loading = false; });
      return;
    }
    await _loadData();
  }

  Future<void> _requestPermission() async {
    await _usage.openPermissionSettings();
    // Give user time to toggle, then recheck when returning
    await Future.delayed(const Duration(seconds: 1));
    final ok = await _usage.hasPermission();
    setState(() { _hasPermission = ok; });
    if (ok) {
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; });
    final summary = await _usage.getDailySummary();
    final apps = await _usage.getMostUsedApps(limit: 10);
    // native weekly minutes via UsageStatsManager per day
    final weekly = await _usage.getWeeklyMinutes();
    _weekDailyMinutes = weekly.isNotEmpty ? weekly : [40, 52, 65, 30, 80, 70, 45];
    setState(() {
      _hasPermission = true;
      _screenTimeMinutes = (summary['screenTimeMinutes'] ?? 0) as int;
      _pickups = (summary['pickups'] ?? 0) as int;
      _mostUsed = apps;
      _loading = false;
    });
  }

  String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h <= 0) return '${m}m';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final mostUsed = _mostUsed.isNotEmpty
        ? _mostUsed
        : [
            {'packageName': 'com.instagram.android', 'minutes': 82, 'type': 'Distracting', 'color': Colors.redAccent},
            {'packageName': 'com.google.android.youtube', 'minutes': 64, 'type': 'Distracting', 'color': Colors.redAccent},
            {'packageName': 'com.whatsapp', 'minutes': 28, 'type': 'Neutral', 'color': cs.primary},
          ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Usage')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Platform.isAndroid && !_hasPermission) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Usage access required to read Digital Wellbeing stats', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _requestPermission, child: const Text('Enable')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Screen time summary & focus score
            // Header KPI card cluster with gradient
            // KPI card with glowing border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: cs.primary.withOpacity(0.25), blurRadius: 24, spreadRadius: 2),
                ],
                gradient: LinearGradient(colors: [cs.primary.withOpacity(0.20), cs.secondary.withOpacity(0.20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SCREEN TIME TODAY', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, color: cs.onSurface.withOpacity(0.6))),
                          const SizedBox(height: 8),
                          Text(_fmtMinutes(_screenTimeMinutes), style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('FOCUS SCORE', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, color: cs.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 8),
                        Text('81%', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: Colors.greenAccent)),
                        const SizedBox(height: 12),
                        Text('PICKUPS', style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.1, color: cs.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 8),
                        Text('$_pickups', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Weekly bar chart with rounded bars
            Text('This Week', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 12),
            _WeeklyRoundedBars(values: _weekDailyMinutes.map((e) => e.toDouble()).toList(), color: cs.primary),

            const SizedBox(height: 20),
            Text('Most Used', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 12),
            Column(
              children: mostUsed.map((app) {
                return Glows.wrapGlow(
                  color: (app['color'] as Color? ?? cs.primary),
                  blur: 12,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (app['color'] as Color? ?? cs.primary).withOpacity(0.15),
                        child: _AppIconFromBase64(base64: app['iconBase64'] as String?),
                      ),
                      title: Row(
                        children: [
                          Expanded(child: Text((app['label'] ?? app['packageName']) as String, overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (app['color'] as Color? ?? cs.primary).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text((app['type'] as String? ?? 'Neutral'), style: TextStyle(color: (app['color'] as Color? ?? cs.primary), fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      trailing: Text(_fmtMinutes((app['minutes'] ?? 0) as int), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Block action
            // Gradient action button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Block Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.surface,
                    foregroundColor: cs.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppIconFromBase64 extends StatelessWidget {
  final String? base64;
  const _AppIconFromBase64({this.base64});
  @override
  Widget build(BuildContext context) {
    if (base64 == null || base64!.isEmpty) {
      return const Icon(Icons.apps);
    }
    try {
      final bytes = const Base64Decoder().convert(base64!);
      return Image.memory(bytes, width: 20, height: 20, fit: BoxFit.contain);
    } catch (_) {
      return const Icon(Icons.apps);
    }
  }
}

class _WeeklyRoundedBars extends StatelessWidget {
  final List<double> values; // minutes per day
  final Color color;
  const _WeeklyRoundedBars({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxVal = (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0).clamp(1, double.infinity);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = i < values.length ? values[i] : 0;
          final h = (v / maxVal) * 100 + 8;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.85), color.withOpacity(0.55)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, spreadRadius: 0, offset: const Offset(0, 6))],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


