class PersianUtils {
  static const List<String> _digits = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
  ];

  /// تبدیل ارقام انگلیسی داخل یک رشته به ارقام فارسی.
  static String toPersianDigits(Object input) {
    final str = input.toString();
    final buffer = StringBuffer();
    for (final ch in str.split('')) {
      final code = ch.codeUnitAt(0);
      if (code >= 48 && code <= 57) {
        buffer.write(_digits[code - 48]);
      } else {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// نمایش یک عدد ساعت اعشاری (مثلا ۱۶.۵) به شکل ۱۶:۳۰
  static String formatClock(double hour) {
    final normalized = hour % 24;
    final h = normalized.floor();
    final m = ((normalized - h) * 60).round();
    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return toPersianDigits('$hh:$mm');
  }

  /// نمایش بازه‌ی ساعت به شکل «۱۶ تا ۱۸»
  static String formatHourRange(double start, double end) {
    final s = toPersianDigits(start.floor());
    final e = toPersianDigits(end.floor());
    return '$s تا $e';
  }
}
