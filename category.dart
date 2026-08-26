import 'package:flutter/material.dart';
import 'category_field.dart';

class TaskCategory {
  final String id;
  final String name;
  final int colorValue;
  final List<CategoryField> fields;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    this.fields = const [],
  });

  Color get color => Color(colorValue);

  TaskCategory copyWith({
    String? name,
    int? colorValue,
    List<CategoryField>? fields,
  }) {
    return TaskCategory(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      fields: fields ?? this.fields,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'fields': fields.map((f) => f.toJson()).toList(),
      };

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF5DCAA5,
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((f) => CategoryField.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
