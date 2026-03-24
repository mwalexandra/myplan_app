import 'package:flutter/material.dart';
import '../../core/models/event.dart';
import '../../core/services/event_service.dart';
import '../../core/utils/category_ui_mapper.dart';
import '../screens/home/day_timeline_card.dart';
import '../screens/home/today_event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _minutesOfDay(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: StreamBuilder<List<Event>>(
          stream: _eventService.getEvents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final allEvents = snapshot.data ?? [];

            final todayEvents = allEvents
                .where((event) => _isSameDay(event.date, now))
                .toList()
              ..sort((a, b) =>
                  _minutesOfDay(a.startTime).compareTo(_minutesOfDay(b.startTime)));

            final nextEvent = todayEvents.cast<Event?>().firstWhere(
                  (event) => event != null && _minutesOfDay(event.startTime) >=
                      _minutesOfDay(TimeOfDay.now()),
                  orElse: () => todayEvents.isNotEmpty ? todayEvents.first : null,
                );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _HomeHeader(now: now),
                const SizedBox(height: 16),
                DayTimelineCard(
                  events: todayEvents,
                  now: now,
                ),
                const SizedBox(height: 20),
                if (todayEvents.isEmpty)
                  const _EmptyTodayState()
                else
                  ...todayEvents.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TodayEventCard(
                        event: event,
                        isNext: nextEvent?.id == event.id,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final DateTime now;

  const _HomeHeader({required this.now});

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Montag';
      case DateTime.tuesday:
        return 'Dienstag';
      case DateTime.wednesday:
        return 'Mittwoch';
      case DateTime.thursday:
        return 'Donnerstag';
      case DateTime.friday:
        return 'Freitag';
      case DateTime.saturday:
        return 'Samstag';
      case DateTime.sunday:
        return 'Sonntag';
      default:
        return '';
    }
  }

  String _monthName(int month) {
    switch (month) {
      case DateTime.january:
        return 'Januar';
      case DateTime.february:
        return 'Februar';
      case DateTime.march:
        return 'März';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'Mai';
      case DateTime.june:
        return 'Juni';
      case DateTime.july:
        return 'Juli';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'Oktober';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'Dezember';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topText = _weekdayName(now.weekday);
    final bottomText = '${now.day}. ${_monthName(now.month)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF34C759), Color(0xFF3498DB)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'MyPlan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                topText,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                bottomText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dark_mode_outlined),
          ),
        ],
      ),
    );
  }
}

class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Heute sind noch keine Ereignisse geplant.'),
      ),
    );
  }
}
