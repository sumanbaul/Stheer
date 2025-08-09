import 'dart:ui' show Offset;
import 'package:flutter/material.dart';

class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> entry;
  const ActivityDetailPage({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = entry['date'] as DateTime;
    final int steps = (entry['steps'] as int?) ?? 0;
    final double distKm = (entry['distanceKm'] as double?) ?? 0.0;
    final int minutes = (entry['activeMinutes'] as int?) ?? 0;
    final int points = (entry['points'] as int?) ?? 0;
    final List<Offset> route = (entry['route'] as List).cast<Offset>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: Text('Activity ${date.day}/${date.month}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withOpacity(0.12)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _RouteDetailPainter(points: route, color: cs.primary),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _statRow(context, 'Steps', steps.toString()),
          _statRow(context, 'Distance', '${distKm.toStringAsFixed(2)} km'),
          _statRow(context, 'Active Minutes', '$minutes min'),
          _statRow(context, 'Points', '$points'),
          const SizedBox(height: 12),
          Text('Achievements', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip(context, Icons.flag_outlined, 'Goal Reached', points >= 100),
              _chip(context, Icons.trending_up, 'Consistency', points >= 150),
              _chip(context, Icons.bolt_outlined, 'Active 30m', minutes >= 30),
            ],
          )
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cs.onSurface.withOpacity(0.8)))),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String label, bool achieved) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achieved ? cs.primary.withOpacity(0.15) : cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: achieved ? cs.primary.withOpacity(0.4) : cs.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: achieved ? cs.primary : cs.onSurface.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _RouteDetailPainter extends CustomPainter {
  final List<Offset> points; // normalized 0..1
  final Color color;
  _RouteDetailPainter({required this.points, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final bg = Paint()..color = color.withOpacity(0.08);
    canvas.drawRect(Offset.zero & size, bg);

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
    canvas.drawCircle(Offset(points.first.dx * size.width, points.first.dy * size.height), 4, dot);
    canvas.drawCircle(Offset(points.last.dx * size.width, points.last.dy * size.height), 4, dot);
  }
  @override
  bool shouldRepaint(covariant _RouteDetailPainter oldDelegate) => oldDelegate.points != points || oldDelegate.color != color;
}


