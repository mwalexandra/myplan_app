import 'package:flutter/material.dart';

class Event {
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRepeating; // пока только да/нет, без статуса

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
      startTime: Event.parseTimeOfDay(data['startTime'] as String),
      endTime: Event.parseTimeOfDay(data['endTime'] as String),
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

  // Удобная строка для показа времени, например "08:05"
  String get startTimeLabel =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  String get endTimeLabel =>
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  // Временно: повторяется/нет
  String get repeatLabel => isRepeating ? 'Wiederholt' : 'Einmalig';

  // Пока статуса нет – можно зашить, потом заменим на поле в модели
  String get status => 'Offen';
}
