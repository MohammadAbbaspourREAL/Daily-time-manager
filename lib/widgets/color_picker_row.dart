import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onChanged;

  const ColorPickerRow({
    super.key,
    required this.selectedColorValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppColors.palette.map((color) {
        final isSelected = color.value == selectedColorValue;
        return GestureDetector(
          onTap: () => onChanged(color.value),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
