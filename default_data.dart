import '../models/category.dart';
import '../models/category_field.dart';
import '../models/category_field_option.dart';
import '../theme/app_colors.dart';
import '../utils/id_generator.dart';

/// دسته‌بندی‌های نمونه برای اولین اجرای اپ. کاربر می‌تواند همه‌ی این‌ها را
/// ویرایش، حذف یا موارد جدید اضافه کند — هیچ محدودیتی روی این لیست نیست.
List<TaskCategory> buildDefaultCategories() {
  return [
    TaskCategory(
      id: generateId(),
      name: 'کار',
      colorValue: AppColors.palette[0].value,
      fields: [
        CategoryField(
          id: generateId(),
          title: 'محل / لینک',
          type: FieldType.text,
        ),
      ],
    ),
    TaskCategory(
      id: generateId(),
      name: 'ورزش',
      colorValue: AppColors.palette[1].value,
      fields: [
        CategoryField(
          id: generateId(),
          title: 'شدت تمرین',
          type: FieldType.select,
          options: [
            CategoryFieldOption(id: generateId(), label: 'کم'),
            CategoryFieldOption(id: generateId(), label: 'متوسط'),
            CategoryFieldOption(
              id: generateId(),
              label: 'زیاد',
              hasExtraText: true,
            ),
          ],
        ),
      ],
    ),
    TaskCategory(
      id: generateId(),
      name: 'مطالعه',
      colorValue: AppColors.palette[2].value,
      fields: [
        CategoryField(
          id: generateId(),
          title: 'موضوع',
          type: FieldType.text,
        ),
      ],
    ),
    TaskCategory(
      id: generateId(),
      name: 'استراحت',
      colorValue: AppColors.palette[4].value,
      fields: const [],
    ),
  ];
}
