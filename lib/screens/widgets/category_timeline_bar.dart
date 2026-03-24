import 'package:flutter/material.dart';
import '../../../core/models/category.dart';
import '../../../core/utils/category_ui_mapper.dart';

class CategoryTimelineBar extends StatelessWidget {
  final List<Category> categories;

  const CategoryTimelineBar({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 230.0;
    const hours = ['07.00', '09.00', '11.00', '13.00', '15.00', '17.00', '19.00', '21.00'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: barHeight,
            child: Row(
              children: [
                SizedBox(
                  width: 54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: hours.map((hour) => Text(hour)).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ..._buildSegments(categories, barHeight),
                      Positioned(
                        left: 62,
                        top: barHeight * 0.43,
                        right: 0,
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'JETZT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: Colors.red.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: categories
                .map(
                  (category) => _LegendItem(
                    label: category.name,
                    color: CategoryUiMapper.colorFromString(category.color),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSegments(List<Category> categories, double barHeight) {
    if (categories.isEmpty) return [];

    final count = categories.length;
    final segmentHeight = (barHeight / (count + 1)).clamp(24.0, 56.0);

    return List.generate(count, (index) {
      final top = 12 + index * (segmentHeight + 10);

      return Positioned(
        left: 18,
        top: top,
        child: Container(
          width: 28,
          height: segmentHeight,
          decoration: BoxDecoration(
            color: CategoryUiMapper.colorFromString(categories[index].color),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 7, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
