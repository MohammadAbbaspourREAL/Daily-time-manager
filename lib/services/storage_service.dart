import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/daily_task.dart';
import 'default_data.dart';

/// لایه‌ی ذخیره‌سازی محلی. همه‌چیز به‌صورت JSON در SharedPreferences نگه داشته می‌شود.
/// ساده، بدون وابستگی به کدهای تولیدشده (build_runner)، و پایدار برای بیلد خودکار.
class StorageService {
  static const _categoriesKey = 'categories_v1';
  static const _tasksKey = 'tasks_v1';

  Future<List<TaskCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_categoriesKey);
    if (raw == null) {
      final defaults = buildDefaultCategories();
      await saveCategories(defaults);
      return defaults;
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCategories(List<TaskCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, raw);
  }

  Future<List<DailyTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DailyTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveTasks(List<DailyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, raw);
  }
}
