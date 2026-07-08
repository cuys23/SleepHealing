import 'package:flutter/material.dart';
import 'package:medyo/config/app_colors.dart';

/// Circular progress ring with a gradient stroke, used by Sleep Tracker's
/// score ring and Meditation's countdown ring.
class CircularProgressRing extends StatelessWidget {
  const CircularProgressRing({
    super.key,
    required this.progress,
    required this.size,
    this.strokeWidth = 6,
    this.gradientColors = const [
      AppColors.accentPrimary,
      AppColors.accentSecondary,
    ],
    this.trackColor,
    this.child,
  });

  /// 0.0 - 1.0
  final double progress;
  final double size;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color? trackColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              gradientColors: gradientColors,
              trackColor: trackColor ?? AppColors.divider,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.28319, false, trackPaint);

    final sweep = 6.28319 * progress;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: 6.28319,
        transform: const GradientRotation(-1.5708),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -1.5708, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.trackColor != trackColor;
}
