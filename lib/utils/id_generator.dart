import 'dart:math';

final Random _random = Random();

/// یک شناسه‌ی یکتای ساده بر اساس زمان + عدد تصادفی.
/// برای این اپ (بدون سرور، فقط ذخیره‌سازی محلی) کافی و مطمئن است.
String generateId() {
  final timePart = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final randomPart = _random.nextInt(0x7FFFFFFF).toRadixString(36);
  return '$timePart$randomPart';
}
