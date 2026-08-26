import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/category_field.dart';
import '../theme/app_colors.dart';
import '../utils/id_generator.dart';
import '../widgets/color_picker_row.dart';
import 'field_edit_screen.dart';

class CategoryEditScreen extends StatefulWidget {
  final TaskCategory? existingCategory;

  const CategoryEditScreen({super.key, this.existingCategory});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  late final TextEditingController _nameController;
  late int _colorValue;
  late List<CategoryField> _fields;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCategory;
    _nameController = TextEditingController(text: c?.name ?? '');
    _colorValue = c?.colorValue ?? AppColors.palette[0].value;
    _fields = List.of(c?.fields ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addField() async {
    final result = await Navigator.of(context).push<CategoryField>(
      MaterialPageRoute(builder: (_) => const FieldEditScreen()),
    );
    if (result != null) {
      setState(() => _fields.add(result));
    }
  }

  Future<void> _editField(CategoryField field) async {
    final result = await Navigator.of(context).push<CategoryField>(
      MaterialPageRoute(builder: (_) => FieldEditScreen(existingField: field)),
    );
    if (result != null) {
      setState(() {
        final index = _fields.indexWhere((f) => f.id == field.id);
        _fields[index] = result;
      });
    }
  }

  void _removeField(String id) {
    setState(() => _fields.removeWhere((f) => f.id == id));
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم دسته‌بندی رو وارد کن')),
      );
      return;
    }
    final category = TaskCategory(
      id: widget.existingCategory?.id ?? generateId(),
      name: name,
      colorValue: _colorValue,
      fields: _fields,
    );
    Navigator.of(context).pop(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCategory == null ? 'دسته‌بندی جدید' : 'ویرایش دسته‌بندی'),
        actions: [
          TextButton(onPressed: _save, child: const Text('ذخیره')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('اسم دسته‌بندی', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _nameController),
          const SizedBox(height: 20),
          const Text('رنگ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          ColorPickerRow(
            selectedColorValue: _colorValue,
            onChanged: (value) => setState(() => _colorValue = value),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('فیلدهای سفارشی این دسته‌بندی',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              TextButton.icon(
                onPressed: _addField,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('فیلد جدید'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (_fields.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'این دسته‌بندی هنوز فیلد سفارشی نداره',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            )
          else
            ..._fields.map((field) => _FieldTile(
                  field: field,
                  onTap: () => _editField(field),
                  onDelete: () => _removeField(field.id),
                )),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  final CategoryField field;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FieldTile({required this.field, required this.onTap, required this.onDelete});

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.title, style: const TextStyle(fontSize: 13.5)),
                  const SizedBox(height: 2),
                  Text(
                    field.type == FieldType.text
                        ? 'متن ساده'
                        : 'انتخابی · ${field.options.length} گزینه',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
