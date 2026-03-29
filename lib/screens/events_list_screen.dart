import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/event.dart';
import '../../core/models/category.dart';
import '../../core/services/event_service.dart';
import '../../core/services/category_service.dart';

enum EventsListMode { today, upcoming }
class EventsListScreen extends StatefulWidget {
  final String id;

  const EventsListScreen({
    super.key,
    required this.id,
  });

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();

  late final Future<Category?> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = _categoryService.getCategoryById(widget.id);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.';
  }

  IconData _statusIcon(String status) {
    if (status == 'Erledigt') return Icons.check_box_outlined;
    return Icons.check_box_outline_blank;
  }

  Color _colorFromHex(String value) {
    final hex = value
      .toUpperCase()
      .replaceAll('#', '')
      .replaceAll('0X', '');

    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ereignisse'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<Category?>(
        future: _categoryFuture,
        builder: (context, categorySnapshot) {
          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categorySnapshot.hasError) {
            return Center(
              child: Text('Fehler: ${categorySnapshot.error}'),
            );
          }

          final category = categorySnapshot.data;
          final avatarColor = _colorFromHex(category?.color ?? '#2196F3');

          return StreamBuilder<List<Event>>(
            stream: _eventService.getTodayEventsByCategory(widget.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Fehler: ${snapshot.error}'),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(
                  child: Text('Noch keine Ereignisse vorhanden.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: avatarColor,
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 62,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(event.date),
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                event.startTimeLabel,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                event.endTimeLabel,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.repeat,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.repeatLabel,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            Icon(_statusIcon(event.status), size: 26),
                            const SizedBox(height: 8),
                            Text(
                              event.status,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/category/${widget.id}/add-event');
        },
        icon: const Icon(Icons.add),
        label: const Text('Neues Ereignis'),
      ),
    );
  }
}