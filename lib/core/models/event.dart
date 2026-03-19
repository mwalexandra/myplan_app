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
    return Event(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      date: DateTime.parse(data['date'] as String),
      category: data['category'] as String,
      startTime: TimeOfDay(
        hour: int.parse((data['startTime'] as String).split(':')[0]),
        minute: int.parse((data['startTime'] as String).split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse((data['endTime'] as String).split(':')[0]),
        minute: int.parse((data['endTime'] as String).split(':')[1]),
      ),
      isRepeating: data['isRepeating'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'isRepeating': isRepeating,
    };
  }

  static TimeOfDay parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}