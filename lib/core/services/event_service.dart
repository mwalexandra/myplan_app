import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../../screens/home/models/timeline_segment.dart';
import '../models/category.dart'; 

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // All events ordered by date
  Stream<List<Event>> getEvents() {
    return _firestore
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Events by category
  Stream<List<Event>> getEventsByCategory(String categoryId) {
    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Create event
  Future<String> createEvent(String categoryId, Event event) async {
    final docRef = await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .add(event.toFirestore());
    return docRef.id;
  }

  // Update event
  Future<void> updateEvent(String categoryId, String eventId, Event event) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .doc(eventId)
        .update(event.toFirestore());
  }

  // Delete event
  Future<void> deleteEvent(String categoryId, String eventId) async {
        await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  Stream<List<TimelineSegment>> getTimelineSegments(List<Category> categories) {
    // Берём события на сегодня
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final futures = categories.map((category) async {
        final snapshot = await _firestore
            .collection('categories')
            .doc(category.id)
            .collection('events')
            .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
            .where('date', isLessThan: endOfDay.toIso8601String())
            .get();

        if (snapshot.docs.isNotEmpty) {
          final event = Event.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
          return TimelineSegment(
            categoryId: category.id,
            categoryName: category.name,
            color: category.color,
            startMinutes: event.startTime.hour * 60 + event.startTime.minute,
            endMinutes: event.endTime.hour * 60 + event.endTime.minute,
          );
        }
        return null;
      });

      return Stream.periodic(const Duration(seconds: 5)).asyncMap((_) async {
        final results = await Future.wait(futures);
        return results.whereType<TimelineSegment>().toList();
      });
  }
}
