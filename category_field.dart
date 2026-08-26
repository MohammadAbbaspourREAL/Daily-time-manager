import 'category_field_option.dart';

/// نوع فیلد سفارشی:
/// text   -> یک باکس متن ساده
/// select -> یک لیست گزینه که هر گزینه می‌تواند باکس متن اضافه هم داشته باشد
enum FieldType { text, select }

class CategoryField {
  final String id;
  final String title;
  final FieldType type;
  final List<CategoryFieldOption> options;

  const CategoryField({
    required this.id,
    required this.title,
    required this.type,
    this.options = const [],
  });

  CategoryField copyWith({
    String? title,
    FieldType? type,
    List<CategoryFieldOption>? options,
  }) {
    return CategoryField(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'options': options.map((o) => o.toJson()).toList(),
      };

  factory CategoryField.fromJson(Map<String, dynamic> json) {
    return CategoryField(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      type: FieldType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => FieldType.text,
      ),
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => CategoryFieldOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}
