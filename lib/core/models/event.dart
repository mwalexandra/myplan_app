import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRepeating;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.isRepeating = false,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    final rawDate = data['date'];

    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.parse(rawDate);
    } else {
      parsedDate = DateTime.now();
    }

    return Event(
      id: id,
      title: (data['title'] as String? ?? '').trim(),
      description: (data['description'] as String? ?? '').trim(),
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      category: (data['category'] as String? ?? data['categoryId'] as String? ?? '').trim(),
      startTime: Event.parseTimeOfDay(data['startTime'] as String? ?? '09:00'),
      endTime: Event.parseTimeOfDay(data['endTime'] as String? ?? '10:00'),
      isRepeating: data['isRepeating'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'description': description.trim(),
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
      'category': category,
      'categoryId': category,
      'startTime': formatTimeOfDay(startTime),
      'endTime': formatTimeOfDay(endTime),
      'isRepeating': isRepeating,
    };
  }

  static TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String get startTimeLabel => formatTimeOfDay(startTime);

  String get endTimeLabel => formatTimeOfDay(endTime);

  String get repeatLabel => isRepeating ? 'Wiederholt' : 'Einmalig';

  String get status => 'Offen';
}