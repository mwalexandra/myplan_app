import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import './category_service.dart'; 

class EventRepository {
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
  Future<void> addSampleEvents() async {
    final samples = [
      Event(
        id: '',
        title: 'Fußballtraining',
        category: 'Sport',
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 16, minute: 30),
        endTime: const TimeOfDay(hour: 17, minute: 30), 
        description: 'Fußballtraining mit dem Verein',
      ),
      Event(
        id: '',
        title: 'Mathe',
        category: 'Schule',
        date: DateTime.now(),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 0),
        description: 'Matheunterricht in der Schule',
      ),
    ];

    for (var event in samples) {
      await _firestore.collection('events').add(event.toFirestore());
    }
  }
}
