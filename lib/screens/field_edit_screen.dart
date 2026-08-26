import 'package:flutter/material.dart';
import '../models/category_field.dart';
import '../models/category_field_option.dart';
import '../theme/app_colors.dart';
import '../utils/id_generator.dart';

class FieldEditScreen extends StatefulWidget {
  final CategoryField? existingField;

  const FieldEditScreen({super.key, this.existingField});

  @override
  State<FieldEditScreen> createState() => _FieldEditScreenState();
}

class _FieldEditScreenState extends State<FieldEditScreen> {
  late final TextEditingController _titleController;
  late FieldType _type;
  late List<CategoryFieldOption> _options;

  @override
  void initState() {
    super.initState();
    final f = widget.existingField;
    _titleController = TextEditingController(text: f?.title ?? '');
    _type = f?.type ?? FieldType.text;
    _options = List.of(f?.options ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add(CategoryFieldOption(id: generateId(), label: ''));
    });
  }

  void _removeOption(String id) {
    setState(() {
      _options.removeWhere((o) => o.id == id);
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عنوان فیلد رو وارد کن')),
      );
      return;
    }
    if (_type == FieldType.select) {
      final cleanedOptions = _options
          .where((o) => o.label.trim().isNotEmpty)
          .toList();
      if (cleanedOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حداقل یک گزینه اضافه کن')),
        );
        return;
      }
      final field = CategoryField(
        id: widget.existingField?.id ?? generateId(),
        title: title,
        type: _type,
        options: cleanedOptions,
      );
      Navigator.of(context).pop(field);
      return;
    }

    final field = CategoryField(
      id: widget.existingField?.id ?? generateId(),
      title: title,
      type: _type,
      options: const [],
    );
    Navigator.of(context).pop(field);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingField == null ? 'فیلد جدید' : 'ویرایش فیلد'),
        actions: [
          TextButton(onPressed: _save, child: const Text('ذخیره')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('عنوان فیلد', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _titleController),
          const SizedBox(height: 20),
          const Text('نوع فیلد', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TypeOption(
                  label: 'متن ساده',
                  selected: _type == FieldType.text,
                  onTap: () => setState(() => _type = FieldType.text),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeOption(
                  label: 'انتخابی',
                  selected: _type == FieldType.select,
                  onTap: () => setState(() => _type = FieldType.select),
                ),
              ),
            ],
          ),
          if (_type == FieldType.select) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('گزینه‌ها', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('گزینه جدید'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ..._options.map((option) => _OptionRow(
                  key: ValueKey(option.id),
                  option: option,
                  onChanged: (updated) {
                    setState(() {
                      final index = _options.indexWhere((o) => o.id == option.id);
                      _options[index] = updated;
                    });
                  },
                  onDelete: () => _removeOption(option.id),
                )),
          ],
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.palette[0].withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.palette[0] : AppColors.border,
            width: selected ? 1.2 : 0.7,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            color: selected ? AppColors.palette[0] : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatefulWidget {
  final CategoryFieldOption option;
  final ValueChanged<CategoryFieldOption> onChanged;
  final VoidCallback onDelete;

  const _OptionRow({
    super.key,
    required this.option,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<_OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<_OptionRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.option.label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'نام گزینه',
                    isDense: true,
                  ),
                  onChanged: (value) {
                    widget.onChanged(widget.option.copyWith(label: value));
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'با انتخاب این گزینه، باکس متن اضافه هم نشون داده بشه',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ),
              Switch(
                value: widget.option.hasExtraText,
                onChanged: (value) {
                  widget.onChanged(widget.option.copyWith(hasExtraText: value));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
