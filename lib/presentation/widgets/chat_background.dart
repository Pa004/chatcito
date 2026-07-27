import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatBackgroundPainter extends CustomPainter {
  ChatBackgroundPainter({required this.color});

  final Color color;

  Path _hexagonPath(double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60.0 * i - 30) * (math.pi / 180.0);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const hexR = 12.0;
    const w = hexR * 3;
    const h = hexR * 1.732;
    const halfW = w / 2;

    for (double y = hexR; y < size.height + hexR; y += h) {
      final rowOffset = ((y / h).floor() % 2 == 0) ? 0.0 : halfW;
      for (double x = hexR + rowOffset; x < size.width + hexR; x += w) {
        canvas.drawPath(_hexagonPath(x, y, hexR), paint);
      }
    }
  }

  @override
  bool shouldRepaint(ChatBackgroundPainter oldDelegate) =>
      oldDelegate.color != color;
}

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
              ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E3345), AppTheme.chatBgDark],
                  )
              : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD0C4B4), Color(0xFFDCD0C0)],
                  ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: ChatBackgroundPainter(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppTheme.lightTextSecondary.withValues(alpha: 0.25),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
