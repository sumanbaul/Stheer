import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final String? label;
  final String? subtitle;
  final bool showPercentage;

  const CircularProgressWidget({
    Key? key,
    required this.progress,
    this.size = 120,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 12,
    this.label,
    this.subtitle,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      constraints: BoxConstraints(
        maxWidth: size,
        maxHeight: size,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle - Apple Watch style
          CustomPaint(
            size: Size(size, size),
            painter: AppleStyleCirclePainter(
              progress: 1.0,
              color: backgroundColor.withOpacity(0.15),
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress circle - Apple Watch style
          CustomPaint(
            size: Size(size, size),
            painter: AppleStyleCirclePainter(
              progress: progress,
              color: color,
              strokeWidth: strokeWidth,
            ),
          ),
          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showPercentage)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.roboto(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
              if (label != null) ...[
                SizedBox(height: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (subtitle != null) ...[
                SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: size * 0.09,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class AppleStyleCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AppleStyleCirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle - Apple Watch style
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc - Apple Watch style
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -math.pi / 2; // Start from top (12 o'clock)
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is AppleStyleCirclePainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

class AnimatedCircularProgressWidget extends StatefulWidget {
  final double progress;
  final double size;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final String? label;
  final String? subtitle;
  final bool showPercentage;
  final Duration duration;

  const AnimatedCircularProgressWidget({
    Key? key,
    required this.progress,
    this.size = 120,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 12,
    this.label,
    this.subtitle,
    this.showPercentage = true,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<AnimatedCircularProgressWidget> createState() =>
      _AnimatedCircularProgressWidgetState();
}

class _AnimatedCircularProgressWidgetState
    extends State<AnimatedCircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation immediately
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      // Reset animation for new progress value
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      // Restart animation from beginning
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CircularProgressWidget(
          progress: _animation.value,
          size: widget.size,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          strokeWidth: widget.strokeWidth,
          label: widget.label,
          subtitle: widget.subtitle,
          showPercentage: widget.showPercentage,
        );
      },
    );
  }
}
