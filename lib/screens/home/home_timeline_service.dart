import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:myplan_app/core/models/category.dart';
import 'package:myplan_app/screens/home/models/timeline_segment.dart';

class HomeTimelineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TimelineSegment>> watchTodaySegments(List<Category> categories) {
    if (categories.isEmpty) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final categoryMap = {
      for (final category in categories) category.id: category,
    };

    return _firestore
        .collectionGroup('events')
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where(
          'date',
          isLessThan: Timestamp.fromDate(endOfDay),
        )
        .snapshots()
        .map((snapshot) {
      final List<TimelineSegment> segments = [];

      debugPrint('CATEGORIES IN MAP: ${categoryMap.keys.toList()}');
      debugPrint('TODAY EVENTS FOUND: ${snapshot.docs.length}');

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final parentCategoryId = doc.reference.parent.parent?.id;
        final storedCategoryId = data['categoryId'] as String?;
        final categoryId =
            (storedCategoryId != null && storedCategoryId.isNotEmpty)
                ? storedCategoryId
                : (parentCategoryId ?? '');

        debugPrint('--- EVENT DOC ---');
        debugPrint('doc path: ${doc.reference.path}');
        debugPrint('stored categoryId: $storedCategoryId');
        debugPrint('parent categoryId: $parentCategoryId');
        debugPrint('resolved categoryId: $categoryId');

        final category = categoryMap[categoryId];
        if (category == null) {
          debugPrint('SKIP: category not found in categoryMap');
          continue;
        }

        final startMinutes = _parseMinutes(data['startTime'] as String?);
        final endMinutes = _parseMinutes(data['endTime'] as String?);

        debugPrint('startMinutes: $startMinutes, endMinutes: $endMinutes');

        if (startMinutes == null || endMinutes == null) {
          debugPrint('SKIP: invalid time');
          continue;
        }

        if (endMinutes <= startMinutes) {
          debugPrint('SKIP: end <= start');
          continue;
        }

        debugPrint('ADD SEGMENT FOR: ${category.name}');

        segments.add(
          TimelineSegment(
            categoryId: category.id,
            categoryName: category.name,
            color: category.color,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
          ),
        );
      }

      segments.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
      debugPrint('EMITTED SEGMENTS: ${segments.length}');

      return segments;
    });
  }

  int? _parseMinutes(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }
}
