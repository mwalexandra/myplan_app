import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';

class EventsListScreen extends StatelessWidget {
  final String id;

  const EventsListScreen({
    super.key,
    required this.id,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.';
  }

  IconData _statusIcon(String status) {
    if (status == 'Erledigt') return Icons.check_box_outlined;
    return Icons.check_box_outline_blank;
  }

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: eventService.getEventsByCategory(id),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Noch keine Ereignisse in dieser Kategorie'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => eventService.addSampleEventsForCategory(id),
                    child: const Text('Testdaten hinzufügen'),
                  ),
                ],
              ),
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
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Color(0xFF2196F3),
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
                            event.startTime,
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            event.endTime,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // потом откроем AddEditEventScreen
        },
        icon: const Icon(Icons.add),
        label: const Text('Neues Ereignis'),
      ),
    );
  }
}
