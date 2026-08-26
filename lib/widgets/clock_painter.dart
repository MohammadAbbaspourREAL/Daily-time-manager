import 'dart:math';
import 'package:flutter/material.dart';
import '../models/daily_task.dart';
import '../theme/app_colors.dart';
import '../utils/persian_utils.dart';

const double hourAngle = 2 * pi / 24;

/// زاویه‌ی یک ساعت مشخص روی دایره، طوری‌که ساعت ۰ بالای دایره (۱۲ عقربه‌ای) باشد
/// و جهت حرکت ساعت‌گرد باشد.
double angleForHour(double hour) => -pi / 2 + hour * hourAngle;

class ClockPainter extends CustomPainter {
  final List<DailyTask> tasks;
  final double currentHour;
  final double? dragSelectionStart;
  final double? dragSelectionEnd;

  ClockPainter({
    required this.tasks,
    required this.currentHour,
    this.dragSelectionStart,
    this.dragSelectionEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = min(size.width, size.height) / 2 - 4;
    const ringThickness = 46.0;
    final midRadius = outerRadius - ringThickness / 2;
    final rect = Rect.fromCircle(center: center, radius: midRadius);

    // حلقه‌ی پس‌زمینه (قسمت‌های خالی)
    final basePaint = Paint()
      ..color = AppColors.ringEmpty
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringThickness
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, midRadius, basePaint);

    // خطوط جداکننده‌ی هر ساعت
    final tickPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 1.4;
    for (int h = 0; h < 24; h++) {
      final a = angleForHour(h.toDouble());
      final p1 = center +
          Offset(cos(a), sin(a)) * (outerRadius - ringThickness);
      final p2 = center + Offset(cos(a), sin(a)) * outerRadius;
      canvas.drawLine(p1, p2, tickPaint);
    }

    // بازه‌ی در حال انتخاب (کشیدن انگشت)
    if (dragSelectionStart != null && dragSelectionEnd != null) {
      final selPaint = Paint()
        ..color = AppColors.textSecondary.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        angleForHour(dragSelectionStart!),
        (dragSelectionEnd! - dragSelectionStart!) * hourAngle,
        false,
        selPaint,
      );
    }

    // قسمت‌های پر شده با کار
    for (final task in tasks) {
      final sweep = (task.endHour - task.startHour) * hourAngle;
      final paint = Paint()
        ..color = task.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringThickness
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, angleForHour(task.startHour), sweep, false, paint);
      _paintTaskLabel(canvas, center, midRadius, task, sweep);
    }

    // نشانگر لحظه‌ی اکنون
    final nowAngle = angleForHour(currentHour);
    final nowPaint = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.fill;
    final nowPoint = center +
        Offset(cos(nowAngle), sin(nowAngle)) * (outerRadius - 1);
    canvas.drawCircle(nowPoint, 4, nowPaint);

    // متن مرکز دایره
    _paintCenterText(canvas, center);
  }

  void _paintTaskLabel(
    Canvas canvas,
    Offset center,
    double midRadius,
    DailyTask task,
    double sweep,
  ) {
    final midAngle = angleForHour(task.startHour) + sweep / 2;
    final labelCenter =
        center + Offset(cos(midAngle), sin(midAngle)) * midRadius;

    final arcLength = midRadius * sweep;
    final maxWidth = (arcLength * 0.86).clamp(28.0, 130.0);

    final textColor = _readableTextColor(task.color);

    var fontSize = 12.5;
    var maxLines = 1;
    var painter = TextPainter(
      text: TextSpan(
        text: task.name,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);

    if (painter.didExceedMaxLines || painter.width >= maxWidth - 1) {
      fontSize = 10.5;
      maxLines = 2;
      painter = TextPainter(
        text: TextSpan(
          text: task.name,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            height: 1.12,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        maxLines: maxLines,
        ellipsis: '…',
      )..layout(maxWidth: maxWidth);
    }

    final offset = labelCenter -
        Offset(painter.width / 2, painter.height / 2);
    painter.paint(canvas, offset);
  }

  Color _readableTextColor(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance > 0.5 ? const Color(0xFF141414) : Colors.white;
  }

  void _paintCenterText(Canvas canvas, Offset center) {
    final timeText = PersianUtils.formatClock(currentHour);
    final timePainter = TextPainter(
      text: TextSpan(
        text: timeText,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    timePainter.paint(
      canvas,
      center - Offset(timePainter.width / 2, timePainter.height + 2),
    );

    final captionPainter = TextPainter(
      text: const TextSpan(
        text: 'اکنون',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    captionPainter.paint(
      canvas,
      center - Offset(captionPainter.width / 2, -6),
    );
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.currentHour != currentHour ||
        oldDelegate.dragSelectionStart != dragSelectionStart ||
        oldDelegate.dragSelectionEnd != dragSelectionEnd;
  }
}
