import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/category_field.dart';
import '../models/daily_task.dart';
import '../models/task_field_value.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/id_generator.dart';
import '../utils/persian_utils.dart';
import '../widgets/color_picker_row.dart';

class TaskFormScreen extends StatefulWidget {
  final StorageService storage;
  final List<TaskCategory> categories;
  final List<DailyTask> allTasks;
  final DailyTask? existingTask;
  final double? startHour;
  final double? endHour;

  const TaskFormScreen({
    super.key,
    required this.storage,
    required this.categories,
    required this.allTasks,
    this.existingTask,
    this.startHour,
    this.endHour,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late int _colorValue;
  String? _selectedCategoryId;
  late double _startHour;
  late double _endHour;

  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String?> _selectedOptionByField = {};
  final Map<String, TextEditingController> _extraTextControllers = {};

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _nameController = TextEditingController(text: task?.name ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _colorValue = task?.colorValue ?? AppColors.palette[0].value;
    _startHour = task?.startHour ?? widget.startHour ?? 8;
    _endHour = task?.endHour ?? widget.endHour ?? 9;

    final initialCategoryId = task?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : null);
    _selectedCategoryId = initialCategoryId;

    final category = _findCategory(initialCategoryId);
    if (category != null) {
      _rebuildFieldControllers(category, initialValues: task?.fieldValues);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    for (final c in _extraTextControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TaskCategory? _findCategory(String? id) {
    if (id == null) return null;
    for (final c in widget.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _rebuildFieldControllers(TaskCategory category, {List<TaskFieldValue>? initialValues}) {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    for (final c in _extraTextControllers.values) {
      c.dispose();
    }
    _textControllers.clear();
    _selectedOptionByField.clear();
    _extraTextControllers.clear();

    for (final field in category.fields) {
      TaskFieldValue? existing;
      if (initialValues != null) {
        for (final v in initialValues) {
          if (v.fieldId == field.id) {
            existing = v;
            break;
          }
        }
      }
      if (field.type == FieldType.text) {
        _textControllers[field.id] = TextEditingController(text: existing?.text ?? '');
      } else {
        _selectedOptionByField[field.id] = existing?.selectedOptionId;
        _extraTextControllers[field.id] = TextEditingController(text: existing?.text ?? '');
      }
    }
  }

  void _onCategoryChanged(String categoryId) {
    final category = _findCategory(categoryId);
    if (category == null) return;
    setState(() {
      _selectedCategoryId = categoryId;
      _rebuildFieldControllers(category);
    });
  }

  Future<void> _pickHourRange() async {
    double start = _startHour;
    double end = _endHour;
    final result = await showDialog<List<double>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceAlt,
              title: const Text('بازه زمانی'),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: start.toInt(),
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceAlt,
                      items: List.generate(24, (h) => h)
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(PersianUtils.toPersianDigits(h)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          start = value.toDouble();
                          if (end <= start) end = start + 1;
                        });
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('تا'),
                  ),
                  Expanded(
                    child: DropdownButton<int>(
                      value: end.toInt(),
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceAlt,
                      items: List.generate(24, (h) => h + 1)
                          .where((h) => h > start)
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(PersianUtils.toPersianDigits(h)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => end = value.toDouble());
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('انصراف'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop([start, end]),
                  child: const Text('تایید'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result != null) {
      setState(() {
        _startHour = result[0];
        _endHour = result[1];
      });
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم کار رو وارد کن')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('یک دسته‌بندی انتخاب کن')),
      );
      return;
    }

    final conflict = widget.allTasks.any((t) =>
        t.id != widget.existingTask?.id && t.overlaps(_startHour, _endHour));
    if (conflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این بازه با یک کار دیگر تداخل دارد')),
      );
      return;
    }

    final category = _findCategory(_selectedCategoryId);
    final fieldValues = <TaskFieldValue>[];
    if (category != null) {
      for (final field in category.fields) {
        if (field.type == FieldType.text) {
          final text = _textControllers[field.id]?.text.trim() ?? '';
          if (text.isNotEmpty) {
            fieldValues.add(TaskFieldValue(fieldId: field.id, text: text));
          }
        } else {
          final selectedId = _selectedOptionByField[field.id];
          if (selectedId != null) {
            final option = field.options.where((o) => o.id == selectedId).isNotEmpty
                ? field.options.firstWhere((o) => o.id == selectedId)
                : null;
            final extraText = option != null && option.hasExtraText
                ? _extraTextControllers[field.id]?.text.trim()
                : null;
            fieldValues.add(TaskFieldValue(
              fieldId: field.id,
              selectedOptionId: selectedId,
              text: (extraText != null && extraText.isNotEmpty) ? extraText : null,
            ));
          }
        }
      }
    }

    final task = DailyTask(
      id: widget.existingTask?.id ?? generateId(),
      name: name,
      colorValue: _colorValue,
      categoryId: _selectedCategoryId!,
      startHour: _startHour,
      endHour: _endHour,
      description: _descriptionController.text.trim(),
      fieldValues: fieldValues,
    );

    final updatedTasks = List<DailyTask>.of(widget.allTasks);
    if (_isEditing) {
      final index = updatedTasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        updatedTasks[index] = task;
      } else {
        updatedTasks.add(task);
      }
    } else {
      updatedTasks.add(task);
    }

    await widget.storage.saveTasks(updatedTasks);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: const Text('حذف کار'),
        content: const Text('این کار حذف شود؟', style: TextStyle(fontSize: 13.5)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('انصراف')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final updatedTasks = List<DailyTask>.of(widget.allTasks)
      ..removeWhere((t) => t.id == widget.existingTask!.id);
    await widget.storage.saveTasks(updatedTasks);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final category = _findCategory(_selectedCategoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'ویرایش کار' : 'کار جدید'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: _delete,
            ),
          TextButton(onPressed: _save, child: const Text('ذخیره')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickHourRange,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PersianUtils.formatHourRange(_startHour, _endHour),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('نام کار', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _nameController),
          const SizedBox(height: 20),
          const Text('رنگ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ColorPickerRow(
            selectedColorValue: _colorValue,
            onChanged: (value) => setState(() => _colorValue = value),
          ),
          const SizedBox(height: 20),
          const Text('دسته‌بندی', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((c) {
              final selected = c.id == _selectedCategoryId;
              return GestureDetector(
                onTap: () => _onCategoryChanged(c.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? c.color.withOpacity(0.18) : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? c.color : AppColors.border,
                      width: selected ? 1.2 : 0.7,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 6),
                        decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                      ),
                      Text(c.name, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (category != null && category.fields.isNotEmpty) ...[
            const SizedBox(height: 24),
            ...category.fields.map((field) => _buildDynamicField(field)),
          ],
          const SizedBox(height: 20),
          const Text('توضیحات', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'اختیاری'),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildDynamicField(CategoryField field) {
    if (field.type == FieldType.text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: _textControllers[field.id]),
          ],
        ),
      );
    }

    final selectedId = _selectedOptionByField[field.id];
    final selectedOption = field.options.where((o) => o.id == selectedId).isNotEmpty
        ? field.options.firstWhere((o) => o.id == selectedId)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: field.options.map((option) {
              final selected = option.id == selectedId;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedOptionByField[field.id] = option.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.palette[0].withOpacity(0.18) : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.palette[0] : AppColors.border,
                      width: selected ? 1.2 : 0.7,
                    ),
                  ),
                  child: Text(option.label, style: const TextStyle(fontSize: 13)),
                ),
              );
            }).toList(),
          ),
          if (selectedOption != null && selectedOption.hasExtraText) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _extraTextControllers[field.id],
              decoration: const InputDecoration(hintText: 'جزئیات بیشتر'),
            ),
          ],
        ],
      ),
    );
  }
}
