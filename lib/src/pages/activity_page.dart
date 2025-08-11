import 'package:flutter/material.dart';
import 'dart:ui' show Offset;
import 'package:notifoo/src/services/steps_service.dart';
import 'package:notifoo/src/util/glow.dart';
import 'package:notifoo/src/services/location_service.dart';
import 'package:notifoo/src/services/settings_service.dart';
import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
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
  Widget build(BuildContext context) {
    final steps = context.watch<StepsService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Activity')),
      body: SingleChildScrollView(
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
                child: Row(
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
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ok = await steps.connectGoogleFit();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok ? 'Google Fit connected' : 'Grant Google Fit permissions in the Google dialog'),
                            ));
                          },
                          icon: const Icon(Icons.favorite_outline, size: 16),
                          label: Text(steps.usingRealData ? 'Connected' : 'Connect Fit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

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
    final bg = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.25);
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


