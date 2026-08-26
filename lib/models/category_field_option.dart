/// یک گزینه‌ی داخل یک فیلد از نوع انتخابی (select).
/// اگر hasExtraText فعال باشد، با انتخاب این گزینه یک باکس متن اضافه
/// برای جزئیات بیشتر در فرم ثبت کار نمایش داده می‌شود.
class CategoryFieldOption {
  final String id;
  final String label;
  final bool hasExtraText;

  const CategoryFieldOption({
    required this.id,
    required this.label,
    this.hasExtraText = false,
  });

  CategoryFieldOption copyWith({
    String? label,
    bool? hasExtraText,
  }) {
    return CategoryFieldOption(
      id: id,
      label: label ?? this.label,
      hasExtraText: hasExtraText ?? this.hasExtraText,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'hasExtraText': hasExtraText,
      };

  factory CategoryFieldOption.fromJson(Map<String, dynamic> json) {
    return CategoryFieldOption(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      hasExtraText: json['hasExtraText'] as bool? ?? false,
    );
  }
}
