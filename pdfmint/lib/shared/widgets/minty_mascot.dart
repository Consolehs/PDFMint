import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

enum MintyMood { happy, thinking, celebrating, sad, working }

class MintyMascot extends StatefulWidget {
  final MintyMood mood;
  final double size;
  final String? message;
  final bool showMessage;
  final bool animate;

  const MintyMascot({
    super.key,
    this.mood = MintyMood.happy,
    this.size = 80,
    this.message,
    this.showMessage = false,
    this.animate = true,
  });

  @override
  State<MintyMascot> createState() => _MintyMascotState();
}

class _MintyMascotState extends State<MintyMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _bounceController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, widget.animate ? _bounceAnimation.value : 0),
              child: child,
            );
          },
          child: _buildMintyBody(),
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 12),
          _buildMessageBubble(),
        ],
      ],
    );
  }

  Widget _buildMintyBody() {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.2,
      child: CustomPaint(
        painter: MintyPainter(mood: widget.mood),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.message!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }
}

class MintyPainter extends CustomPainter {
  final MintyMood mood;

  MintyPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Gövde (PDF sayfası şeklinde)
    final bodyPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final bodyShadowPaint = Paint()
      ..color = AppColors.primaryDark.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Gölge
    final shadowPath = Path();
    shadowPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.08, w * 0.84, h * 0.82),
      const Radius.circular(12),
    ));
    canvas.drawPath(shadowPath, bodyShadowPaint);

    // Ana gövde
    final bodyPath = Path();
    // Köşe kırpmalı PDF sayfası
    bodyPath.moveTo(w * 0.05, h * 0.05);
    bodyPath.lineTo(w * 0.75, h * 0.05);
    bodyPath.lineTo(w * 0.95, h * 0.20);
    bodyPath.lineTo(w * 0.95, h * 0.88);
    bodyPath.quadraticBezierTo(w * 0.95, h * 0.95, w * 0.88, h * 0.95);
    bodyPath.lineTo(w * 0.12, h * 0.95);
    bodyPath.quadraticBezierTo(w * 0.05, h * 0.95, w * 0.05, h * 0.88);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Köşe katlama
    final foldPaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.fill;
    final foldPath = Path();
    foldPath.moveTo(w * 0.75, h * 0.05);
    foldPath.lineTo(w * 0.95, h * 0.20);
    foldPath.lineTo(w * 0.75, h * 0.20);
    foldPath.close();
    canvas.drawPath(foldPath, foldPaint);

    // Satırlar (PDF içeriği temsili)
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.18, h * 0.35),
      Offset(w * 0.72, h * 0.35),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.18, h * 0.44),
      Offset(w * 0.82, h * 0.44),
      linePaint,
    );
    canvas.drawLine(
      Offset(w * 0.18, h * 0.53),
      Offset(w * 0.65, h * 0.53),
      linePaint,
    );

    // Yüz - Gözler
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final eyeOutlinePaint = Paint()
      ..color = AppColors.primaryDeep
      ..style = PaintingStyle.fill;

    // Sol göz
    canvas.drawCircle(Offset(w * 0.35, h * 0.65), w * 0.085, eyeOutlinePaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.65), w * 0.065, eyePaint);
    canvas.drawCircle(Offset(w * 0.37, h * 0.63), w * 0.025, eyeOutlinePaint);

    // Sağ göz
    canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.085, eyeOutlinePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.065, eyePaint);
    canvas.drawCircle(Offset(w * 0.67, h * 0.63), w * 0.025, eyeOutlinePaint);

    // Ruh haline göre ağız
    _drawMouth(canvas, size);

    // Yanak pembesi
    final blushPaint = Paint()
      ..color = Colors.pink.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.22, h * 0.72),
        width: w * 0.18,
        height: h * 0.08,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.78, h * 0.72),
        width: w * 0.18,
        height: h * 0.08,
      ),
      blushPaint,
    );
  }

  void _drawMouth(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final mouthPaint = Paint()
      ..color = AppColors.primaryDeep
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (mood) {
      case MintyMood.happy:
      case MintyMood.celebrating:
        // Gülümseme
        final path = Path();
        path.moveTo(w * 0.35, h * 0.76);
        path.quadraticBezierTo(w * 0.50, h * 0.85, w * 0.65, h * 0.76);
        canvas.drawPath(path, mouthPaint);

        if (mood == MintyMood.celebrating) {
          // Kutlama için dişler
          final teethPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          final teethPath = Path();
          teethPath.moveTo(w * 0.35, h * 0.76);
          teethPath.quadraticBezierTo(w * 0.50, h * 0.85, w * 0.65, h * 0.76);
          teethPath.lineTo(w * 0.65, h * 0.80);
          teethPath.quadraticBezierTo(w * 0.50, h * 0.89, w * 0.35, h * 0.80);
          teethPath.close();
          canvas.drawPath(teethPath, teethPaint);
          canvas.drawPath(teethPath, mouthPaint);
        }
        break;

      case MintyMood.thinking:
        // Düşünme ifadesi
        final path = Path();
        path.moveTo(w * 0.38, h * 0.78);
        path.quadraticBezierTo(w * 0.50, h * 0.75, w * 0.62, h * 0.78);
        canvas.drawPath(path, mouthPaint);
        break;

      case MintyMood.sad:
        // Üzgün ifade
        final path = Path();
        path.moveTo(w * 0.35, h * 0.82);
        path.quadraticBezierTo(w * 0.50, h * 0.74, w * 0.65, h * 0.82);
        canvas.drawPath(path, mouthPaint);
        break;

      case MintyMood.working:
        // Çalışma ifadesi - dil çıkarmış
        final path = Path();
        path.moveTo(w * 0.38, h * 0.76);
        path.quadraticBezierTo(w * 0.50, h * 0.82, w * 0.62, h * 0.76);
        canvas.drawPath(path, mouthPaint);
        final tonguePaint = Paint()
          ..color = Colors.pink.withOpacity(0.7)
          ..style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.50, h * 0.84),
            width: w * 0.14,
            height: h * 0.07,
          ),
          tonguePaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(MintyPainter oldDelegate) => oldDelegate.mood != mood;
}

// Minty ile birlikte gösterilecek yardım balonu
class MintyHelpBubble extends StatelessWidget {
  final String message;
  final MintyMood mood;
  final double mascotSize;

  const MintyHelpBubble({
    super.key,
    required this.message,
    this.mood = MintyMood.happy,
    this.mascotSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MintyMascot(
            mood: mood,
            size: mascotSize,
            animate: true,
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }
}
