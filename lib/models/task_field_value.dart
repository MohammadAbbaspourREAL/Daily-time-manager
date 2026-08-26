/// مقدار واقعی که کاربر برای یک فیلد سفارشی (CategoryField) در یک کار خاص وارد کرده.
/// برای فیلد متنی: فقط text پر می‌شود.
/// برای فیلد انتخابی: selectedOptionId پر می‌شود و اگر آن گزینه hasExtraText داشت،
/// text هم مقدار باکس اضافه را نگه می‌دارد.
class TaskFieldValue {
  final String fieldId;
  final String? text;
  final String? selectedOptionId;

  const TaskFieldValue({
    required this.fieldId,
    this.text,
    this.selectedOptionId,
  });

  TaskFieldValue copyWith({
    String? text,
    String? selectedOptionId,
    bool clearText = false,
    bool clearSelection = false,
  }) {
    return TaskFieldValue(
      fieldId: fieldId,
      text: clearText ? null : (text ?? this.text),
      selectedOptionId:
          clearSelection ? null : (selectedOptionId ?? this.selectedOptionId),
    );
  }

  Map<String, dynamic> toJson() => {
        'fieldId': fieldId,
        'text': text,
        'selectedOptionId': selectedOptionId,
      };

  factory TaskFieldValue.fromJson(Map<String, dynamic> json) {
    return TaskFieldValue(
      fieldId: json['fieldId'] as String,
      text: json['text'] as String?,
      selectedOptionId: json['selectedOptionId'] as String?,
    );
  }
}
