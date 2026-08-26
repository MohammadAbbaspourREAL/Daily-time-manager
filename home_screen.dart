import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/daily_task.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/persian_utils.dart';
import '../widgets/circular_clock.dart';
import 'category_management_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();

  List<TaskCategory> _categories = [];
  List<DailyTask> _tasks = [];
  bool _loading = true;
  Timer? _clockTimer;
  double _currentHour = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentHour();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updateCurrentHour();
    });
    _loadData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateCurrentHour() {
    final now = DateTime.now();
    setState(() {
      _currentHour = now.hour + now.minute / 60.0;
    });
  }

  Future<void> _loadData() async {
    final categories = await _storage.loadCategories();
    final tasks = await _storage.loadTasks();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _tasks = tasks;
      _loading = false;
    });
  }

  TaskCategory? _categoryFor(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> _openTaskForm({
    DailyTask? existingTask,
    double? startHour,
    double? endHour,
  }) async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اول یک دسته‌بندی بساز تا بتونی کار اضافه کنی'),
        ),
      );
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          storage: _storage,
          categories: _categories,
          existingTask: existingTask,
          allTasks: _tasks,
          startHour: startHour,
          endHour: endHour,
        ),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _openCategoryManagement() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryManagementScreen(storage: _storage),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sortedTasks = [..._tasks]
      ..sort((a, b) => a.startHour.compareTo(b.startHour));

    return Scaffold(
      appBar: AppBar(
        title: const Text('کارهای امروز'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'مدیریت دسته‌بندی‌ها',
            onPressed: _openCategoryManagement,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                PersianUtils.toPersianDigits(sortedTasks.length) + ' کار',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: CircularClock(
                tasks: _tasks,
                currentHour: _currentHour,
                size: 300,
                onTaskTap: (task) => _openTaskForm(existingTask: task),
                onRangeSelected: (start, end) =>
                    _openTaskForm(startHour: start, endHour: end),
              ),
            ),
            const SizedBox(height: 24),
            if (sortedTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'روی ساعت لمس کن تا اولین کار رو اضافه کنی',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ...sortedTasks.map((task) {
                final category = _categoryFor(task.categoryId);
                return _TaskTile(
                  task: task,
                  categoryName: category?.name ?? '',
                  onTap: () => _openTaskForm(existingTask: task),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final DailyTask task;
  final String categoryName;
  final VoidCallback onTap;

  const _TaskTile({
    required this.task,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: task.color,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    PersianUtils.formatHourRange(task.startHour, task.endHour) +
                        (categoryName.isNotEmpty ? ' · $categoryName' : ''),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
