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
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.check, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                      ],
                      Text(labelBuilder(status)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelected(status),
                  selectedColor: const Color(0xFF1E3A8A),
                  backgroundColor: Colors.white,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
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
