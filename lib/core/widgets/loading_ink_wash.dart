import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 水墨扩散加载动画
class LoadingInkWash extends StatefulWidget {
  final double size;
  final String? message;

  const LoadingInkWash({
    super.key,
    this.size = 120,
    this.message,
  });

  @override
  State<LoadingInkWash> createState() => _LoadingInkWashState();
}

class _LoadingInkWashState extends State<LoadingInkWash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _InkWashPainter(_controller.value),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _InkWashPainter extends CustomPainter {
  final double progress;

  _InkWashPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Multiple expanding ink circles
    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = phase * size.width / 2;
      final opacity = (1.0 - phase) * 0.4;

      final paint = Paint()
        ..color = AppColors.ink.withValues(alpha: opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, paint);
    }

    // Central dot
    final centerPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(_InkWashPainter oldDelegate) => true;
}
