import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import './category_service.dart'; 

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
  Stream<List<Event>> getEventsByCategory(String category) {
    return _firestore
        .collection('events')
        .where('category', isEqualTo: category)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Create/update event
  Future<void> saveEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).set(event.toFirestore());
  }

  // Delete event
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  // Add sample data
  Future<void> addSampleEventsForCategory(String categoryId) async {
    final samples = [
      Event(
        id: '',
        title: 'Beispiel Event 1',
        category: categoryId,
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        description: 'Erstes Beispielereignis',
      ),
      Event(
        id: '',
        title: 'Beispiel Event 2',
        category: categoryId,
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 12, minute: 0),
        description: 'Zweites Beispielereignis',
      ),
    ];

    for (final event in samples) {
      await _firestore.collection('events').add(event.toFirestore());
    }
  }
}
