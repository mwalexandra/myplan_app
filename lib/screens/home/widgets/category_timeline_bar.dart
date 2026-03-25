import 'package:flutter/material.dart';
import '../../../../core/models/category.dart';
import '../../../../core/utils/category_ui_mapper.dart';
import '../models/timeline_segment.dart';

class CategoryTimelineBar extends StatelessWidget {
  final List<Category> categories;
  final List<TimelineSegment> segments;

  const CategoryTimelineBar({
    super.key,
    required this.categories,
    required this.segments,
  });

  static const double _barHeight = 230;
  static const int _startMinute = 7 * 60;
  static const int _endMinute = 21 * 60;

  double _topForMinutes(int minutes) {
    final clamped = minutes.clamp(_startMinute, _endMinute);
    return ((clamped - _startMinute) / (_endMinute - _startMinute)) * _barHeight;
  }

  double _heightForRange(int startMinutes, int endMinutes) {
    final top = _topForMinutes(startMinutes);
    final bottom = _topForMinutes(endMinutes);
    final raw = bottom - top;
    return raw < 18 ? 18 : raw;
  }

  @override
  Widget build(BuildContext context) {
    const hours = [
      '07.00',
      '09.00',
      '11.00',
      '13.00',
      '15.00',
      '17.00',
      '19.00',
      '21.00',
    ];

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final nowTop = _topForMinutes(nowMinutes);

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
            height: _barHeight,
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
                      ...segments.map((segment) {
                        return Positioned(
                          left: 18,
                          top: _topForMinutes(segment.startMinutes),
                          child: Container(
                            width: 28,
                            height: _heightForRange(
                              segment.startMinutes,
                              segment.endMinutes,
                            ),
                            decoration: BoxDecoration(
                              color: CategoryUiMapper.colorFromString(segment.color),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }),
                      Positioned(
                        left: 62,
                        top: nowTop,
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
