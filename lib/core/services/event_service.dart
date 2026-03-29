import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents() {
    return const Stream.empty();
  }

  Stream<List<Event>> getTodayEventsByCategory(String categoryId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data(), doc.id))
          .where((event) {
            final eventDate = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            return !eventDate.isBefore(startOfToday) &&
                eventDate.isBefore(endOfToday);
          })
          .toList();

      events.sort((a, b) {
        final aStart = a.startTime.hour * 60 + a.startTime.minute;
        final bStart = b.startTime.hour * 60 + b.startTime.minute;
        return aStart.compareTo(bStart);
      });

      return events;
    });
  }

  Stream<List<Event>> getUpcomingEventsByCategory(String categoryId) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('events')
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map((doc) => Event.fromFirestore(doc.data(), doc.id))
          .where((event) {
            final eventDate = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            return !eventDate.isBefore(startOfToday);
          })
          .toList();

      events.sort((a, b) {
        final dateCompare = a.date.compareTo(b.date);
        if (dateCompare != 0) return dateCompare;

        final aStart = a.startTime.hour * 60 + a.startTime.minute;
        final bStart = b.startTime.hour * 60 + b.startTime.minute;
        return aStart.compareTo(bStart);
      });

      return events;
    });
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