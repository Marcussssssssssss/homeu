import 'package:flutter/material.dart';
import 'package:homeu/core/theme/homeu_app_theme.dart';

class HomeUStatusFilterChips<T> extends StatelessWidget {
  const HomeUStatusFilterChips({
    super.key,
    required this.statuses,
    required this.selected,
    required this.labelBuilder,
    required this.onSelected,
    this.keyBuilder,
  });

  final List<T> statuses;
  final T selected;
  final String Function(T status) labelBuilder;
  final ValueChanged<T> onSelected;
  final Key? Function(T status)? keyBuilder;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses
            .map((status) {
              final bool isSelected = status == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: keyBuilder?.call(status),
                  label: Text(labelBuilder(status)),
                  selected: isSelected,
                  onSelected: (_) => onSelected(status),
                  selectedColor: const Color(0xFF1E3A8A),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF1E3A8A) : context.homeuSoftBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
