import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'category_edit_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  final StorageService storage;

  const CategoryManagementScreen({super.key, required this.storage});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<TaskCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final categories = await widget.storage.loadCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await widget.storage.saveCategories(_categories);
  }

  Future<void> _addCategory() async {
    final result = await Navigator.of(context).push<TaskCategory>(
      MaterialPageRoute(builder: (_) => const CategoryEditScreen()),
    );
    if (result != null) {
      setState(() => _categories.add(result));
      await _persist();
    }
  }

  Future<void> _editCategory(TaskCategory category) async {
    final result = await Navigator.of(context).push<TaskCategory>(
      MaterialPageRoute(
        builder: (_) => CategoryEditScreen(existingCategory: category),
      ),
    );
    if (result != null) {
      setState(() {
        final index = _categories.indexWhere((c) => c.id == category.id);
        _categories[index] = result;
      });
      await _persist();
    }
  }

  Future<void> _deleteCategory(TaskCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('حذف دسته‌بندی'),
        content: Text(
          'دسته‌بندی «${category.name}» حذف می‌شود. کارهایی که با این دسته‌بندی ثبت شده‌اند حذف نمی‌شوند، فقط دسته‌بندی‌شان خالی می‌ماند.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('انصراف')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _categories.removeWhere((c) => c.id == category.id));
      await _persist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دسته‌بندی‌ها')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        backgroundColor: AppColors.palette[0],
        foregroundColor: const Color(0xFF04342C),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? const Center(
                  child: Text(
                    'هنوز دسته‌بندی‌ای نساختی',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        onTap: () => _editCategory(category),
                        leading: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(category.name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(
                          '${category.fields.length} فیلد سفارشی',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
