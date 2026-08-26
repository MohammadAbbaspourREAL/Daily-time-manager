import 'package:flutter/material.dart';
import 'task_field_value.dart';

class DailyTask {
  final String id;
  final String name;
  final int colorValue;
  final String categoryId;
  final double startHour; // 0..24
  final double endHour; // 0..24, همیشه > startHour
  final String description;
  final List<TaskFieldValue> fieldValues;

  const DailyTask({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.categoryId,
    required this.startHour,
    required this.endHour,
    this.description = '',
    this.fieldValues = const [],
  });

  Color get color => Color(colorValue);

  bool coversHour(double hour) => hour >= startHour && hour < endHour;

  bool overlaps(double otherStart, double otherEnd) {
    return startHour < otherEnd && otherStart < endHour;
  }

  DailyTask copyWith({
    String? name,
    int? colorValue,
    String? categoryId,
    double? startHour,
    double? endHour,
    String? description,
    List<TaskFieldValue>? fieldValues,
  }) {
    return DailyTask(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      categoryId: categoryId ?? this.categoryId,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      description: description ?? this.description,
      fieldValues: fieldValues ?? this.fieldValues,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'categoryId': categoryId,
        'startHour': startHour,
        'endHour': endHour,
        'description': description,
        'fieldValues': fieldValues.map((f) => f.toJson()).toList(),
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF5DCAA5,
      categoryId: json['categoryId'] as String? ?? '',
      startHour: (json['startHour'] as num).toDouble(),
      endHour: (json['endHour'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      fieldValues: (json['fieldValues'] as List<dynamic>? ?? [])
          .map((f) => TaskFieldValue.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
