import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents() {
    return const Stream.empty();
  }

  Stream<List<Event>> getEventsByCategory(String categoryId) {
    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Event>> getTodayEventsByCategory(String categoryId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Event.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<String> createEvent(String categoryId, Event event) async {
    final docRef = await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .add(event.toFirestore());

    return docRef.id;
  }

  Future<void> updateEvent(String categoryId, String eventId, Event event) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .doc(eventId)
        .update(event.toFirestore());
  }

  Future<void> deleteEvent(String categoryId, String eventId) async {
    await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .doc(eventId)
        .delete();
  }
}