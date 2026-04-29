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
                        Icon(
                          Icons.check,
                          color: context.colors.onPrimary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(labelBuilder(status)),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelected(status),
                  selectedColor: context.homeuAccent,
                  backgroundColor: context.homeuCard,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? context.colors.onPrimary
                        : context.homeuAccent,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                  ),
                  side: BorderSide(
                    color:
                        isSelected ? context.homeuAccent : context.homeuSoftBorder,
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
