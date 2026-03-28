import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:myplan_app/core/models/category.dart';
import 'package:myplan_app/screens/home/models/timeline_segment.dart';

class HomeTimelineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Category>> watchTodayCategories(List<Category> categories) {
    if (categories.isEmpty) {
      return Stream.value(const <Category>[]);
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final categoryMap = {
      for (final category in categories) category.id: category,
    };

    return _firestore
        .collectionGroup('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      final todayCategoryIds = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final parentCategoryId = doc.reference.parent.parent?.id;
        final storedCategoryId = data['categoryId'] as String?;
        final categoryId =
            (storedCategoryId != null && storedCategoryId.isNotEmpty)
                ? storedCategoryId
                : (parentCategoryId ?? '');

        if (categoryMap.containsKey(categoryId)) {
          todayCategoryIds.add(categoryId);
        }
      }

      final result = categories
          .where((category) => todayCategoryIds.contains(category.id))
          .toList();

      result.sort((a, b) => a.name.compareTo(b.name));
      return result;
    });
  }

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
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      final List<TimelineSegment> segments = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final parentCategoryId = doc.reference.parent.parent?.id;
        final storedCategoryId = data['categoryId'] as String?;
        final categoryId =
            (storedCategoryId != null && storedCategoryId.isNotEmpty)
                ? storedCategoryId
                : (parentCategoryId ?? '');

        final category = categoryMap[categoryId];
        if (category == null) continue;

        final startMinutes = _parseMinutes(data['startTime'] as String?);
        final endMinutes = _parseMinutes(data['endTime'] as String?);

        if (startMinutes == null || endMinutes == null) continue;
        if (endMinutes <= startMinutes) continue;

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