import 'package:flutter/material.dart';

class Glows {
  // Tighter, subtler glow with lower opacity for readability
  static List<BoxShadow> softGlow(
    Color color, {
    double blur = 10,
    double spread = 0.25,
    double opacity = 0.12,
    Offset offset = const Offset(0, 6),
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread,
        offset: offset,
      ),
      BoxShadow(
        color: color.withOpacity(opacity * 0.6),
        blurRadius: blur * 0.6,
        spreadRadius: spread * 0.3,
        offset: offset * 0.6,
      ),
    ];
  }

  static Widget wrapGlow({
    required Widget child,
    required Color color,
    double radius = 16,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double blur = 16,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: softGlow(color, blur: blur),
      ),
      child: child,
    );
  }

  static Widget pulseGlow({
    required Widget child,
    required Color color,
    double minBlur = 8,
    double maxBlur = 18,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minBlur, end: maxBlur),
      duration: duration ?? const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: softGlow(color, blur: value),
          ),
          child: child,
        );
      },
      onEnd: () {
        // Loop the animation by reversing bounds
      },
    );
  }
}


