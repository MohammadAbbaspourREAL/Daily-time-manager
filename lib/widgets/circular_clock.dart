import 'dart:math';
import 'package:flutter/material.dart';
import '../models/daily_task.dart';
import 'clock_painter.dart';

class CircularClock extends StatefulWidget {
  final List<DailyTask> tasks;
  final double currentHour;
  final double size;
  final void Function(DailyTask task) onTaskTap;
  final void Function(double startHour, double endHour) onRangeSelected;

  const CircularClock({
    super.key,
    required this.tasks,
    required this.currentHour,
    required this.onTaskTap,
    required this.onRangeSelected,
    this.size = 300,
  });

  @override
  State<CircularClock> createState() => _CircularClockState();
}

class _CircularClockState extends State<CircularClock> {
  double? _dragStartHour;
  double? _dragCurrentHour;

  double _hourFromLocalPosition(Offset local) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    double angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;
    final hour = angle / (2 * pi) * 24;
    return hour;
  }

  DailyTask? _taskAtHour(double hour) {
    for (final task in widget.tasks) {
      if (task.coversHour(hour)) return task;
    }
    return null;
  }

  void _handleTapUp(TapUpDetails details) {
    final hour = _hourFromLocalPosition(details.localPosition);
    final task = _taskAtHour(hour);
    if (task != null) {
      widget.onTaskTap(task);
      return;
    }
    final block = hour.floorToDouble();
    final overlapping = _taskAtHour(block) ?? _taskAtHour(block + 0.99);
    if (overlapping != null) {
      widget.onTaskTap(overlapping);
      return;
    }
    widget.onRangeSelected(block, block + 1);
  }

  void _handlePanStart(DragStartDetails details) {
    final hour = _hourFromLocalPosition(details.localPosition);
    setState(() {
      _dragStartHour = hour.floorToDouble();
      _dragCurrentHour = _dragStartHour! + 1;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragStartHour == null) return;
    final hour = _hourFromLocalPosition(details.localPosition);
    setState(() {
      _dragCurrentHour = hour.ceilToDouble();
      if (_dragCurrentHour! <= _dragStartHour!) {
        _dragCurrentHour = _dragStartHour! + 1;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    final start = _dragStartHour;
    final end = _dragCurrentHour;
    setState(() {
      _dragStartHour = null;
      _dragCurrentHour = null;
    });
    if (start == null || end == null) return;
    if (end - start < 1) return;

    final hasConflict = widget.tasks.any((t) => t.overlaps(start, end));
    if (hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این بازه با یک کار دیگر تداخل دارد')),
      );
      return;
    }
    widget.onRangeSelected(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: _handleTapUp,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: ClockPainter(
            tasks: widget.tasks,
            currentHour: widget.currentHour,
            dragSelectionStart: _dragStartHour,
            dragSelectionEnd: _dragCurrentHour,
          ),
        ),
      ),
    );
  }
}
