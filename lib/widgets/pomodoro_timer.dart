import 'package:flutter/material.dart';
import 'dart:math' as math;

class PomodoroTimer extends StatelessWidget {
  final double progress; // 进度（0.0 - 1.0）
  final int timeRemaining; // 剩余时间（秒）
  final bool isRunning; // 是否正在运行
  final Color? progressColor; // 进度条颜色
  final Color? backgroundColor; // 背景颜色
  final VoidCallback? onStart; // 开始回调
  final VoidCallback? onPause; // 暂停回调
  final VoidCallback? onStop; // 停止回调
  final double size; // 计时器大小

  const PomodoroTimer({
    Key? key,
    required this.progress,
    required this.timeRemaining,
    this.isRunning = false,
    this.progressColor,
    this.backgroundColor,
    this.onStart,
    this.onPause,
    this.onStop,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = (timeRemaining / 60).floor();
    final seconds = timeRemaining % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final theme = Theme.of(context);
    final actualProgressColor = progressColor ?? theme.primaryColor;
    final actualBackgroundColor =
        backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 进度条
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: CircleProgressPainter(
                progress: progress,
                progressColor: actualProgressColor,
                backgroundColor: actualBackgroundColor,
                strokeWidth: size / 15,
              ),
            ),
          ),

          // 时间显示
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontSize: size / 6,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: size / 20),

              // 控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 开始/暂停按钮
                  IconButton(
                    icon: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: size / 10,
                    ),
                    onPressed: isRunning ? onPause : onStart,
                    color: theme.colorScheme.primary,
                    tooltip: isRunning ? '暂停' : '开始',
                  ),

                  SizedBox(width: size / 20),

                  // 停止按钮
                  IconButton(
                    icon: Icon(Icons.stop_rounded, size: size / 10),
                    onPressed: onStop,
                    color: theme.colorScheme.error,
                    tooltip: '停止',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircleProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    this.strokeWidth = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    // 画背景圆环
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 画进度圆环
    final progressPaint =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 从顶部开始，顺时针方向绘制
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
