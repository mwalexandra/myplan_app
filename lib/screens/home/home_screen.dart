import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/utils/category_ui_mapper.dart';
import './models/timeline_segment.dart';
import 'home_timeline_service.dart';
import 'widgets/category_timeline_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final HomeTimelineService _homeTimelineService = HomeTimelineService();

  late final Stream<List<Category>> _categoriesStream;

  Stream<List<Category>>? _todayCategoriesStream;
  String _todayCategoriesSignature = '';

  Stream<List<TimelineSegment>>? _segmentsStream;
  String _segmentsSignature = '';

  @override
  void initState() {
    super.initState();
    _categoriesStream = _categoryService.getCategories();
    _seedDefaults();
  }

  Future<void> _seedDefaults() async {
    await _categoryService.ensureDefaultCategories();
  }

  Stream<List<Category>> _resolveTodayCategoriesStream(List<Category> categories) {
    if (categories.isEmpty) {
      _todayCategoriesSignature = '';
      _todayCategoriesStream = Stream.value(const <Category>[]);
      return _todayCategoriesStream!;
    }

    final sorted = [...categories]..sort((a, b) => a.id.compareTo(b.id));
    final nextSignature = sorted
        .map((c) => '${c.id}:${c.name}:${c.color}')
        .join('|');

    if (_todayCategoriesStream != null &&
        _todayCategoriesSignature == nextSignature) {
      return _todayCategoriesStream!;
    }

    _todayCategoriesSignature = nextSignature;
    _todayCategoriesStream =
        _homeTimelineService.watchTodayCategories(categories);
    return _todayCategoriesStream!;
  }

  Stream<List<TimelineSegment>> _resolveSegmentsStream(List<Category> categories) {
    if (categories.isEmpty) {
      _segmentsSignature = '';
      _segmentsStream = Stream.value(const <TimelineSegment>[]);
      return _segmentsStream!;
    }

    final sorted = [...categories]..sort((a, b) => a.id.compareTo(b.id));
    final nextSignature = sorted
        .map((c) => '${c.id}:${c.name}:${c.color}')
        .join('|');

    if (_segmentsStream != null && _segmentsSignature == nextSignature) {
      return _segmentsStream!;
    }

    _segmentsSignature = nextSignature;
    _segmentsStream = _homeTimelineService.watchTodaySegments(categories);
    return _segmentsStream!;
  }

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
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream: _categoriesStream,
          builder: (context, categorySnapshot) {
            if (categorySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (categorySnapshot.hasError) {
              return Center(
                child: Text('Fehler: ${categorySnapshot.error}'),
              );
            }

            final categories = categorySnapshot.data ?? const <Category>[];
            final segmentsStream = _resolveSegmentsStream(categories);
            final todayCategoriesStream =
                _resolveTodayCategoriesStream(categories);

            return StreamBuilder<List<TimelineSegment>>(
              stream: segmentsStream,
              builder: (context, segmentsSnapshot) {
                if (segmentsSnapshot.hasError) {
                  return Center(
                    child: Text('Fehler: ${segmentsSnapshot.error}'),
                  );
                }

                final segments =
                    segmentsSnapshot.data ?? const <TimelineSegment>[];

                return StreamBuilder<List<Category>>(
                  stream: todayCategoriesStream,
                  builder: (context, todayCategoriesSnapshot) {
                    if (todayCategoriesSnapshot.hasError) {
                      return Center(
                        child: Text('Fehler: ${todayCategoriesSnapshot.error}'),
                      );
                    }

                    final todayCategories =
                        todayCategoriesSnapshot.data ?? const <Category>[];

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _HomeHeader(
                          weekday: _weekdayName(now.weekday),
                          dateText: '${now.day}. ${_monthName(now.month)}',
                        ),
                        const SizedBox(height: 16),
                        CategoryTimelineBar(
                          categories: categories,
                          segments: segments,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Mein Plan heute',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/categories'),
                              child: const Text('Alle Kategorien'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (todayCategoriesSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            !todayCategoriesSnapshot.hasData)
                          const Center(child: CircularProgressIndicator())
                        else if (todayCategories.isEmpty)
                          const _EmptyTodayCategoriesState()
                        else
                          GridView.builder(
                            itemCount: todayCategories.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            itemBuilder: (context, index) {
                              final category = todayCategories[index];
                              return _CategoryCard(
                                category: category,
                                onTap: () =>
                                    context.push('/category/${category.id}'),
                              );
                            },
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/events/add'),
        backgroundColor: const Color(0xFF59D66F),
        child: const Icon(
          Icons.add_box,
          color: Colors.white,
          semanticLabel: 'Neues Ereignis',
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String weekday;
  final String dateText;

  const _HomeHeader({
    required this.weekday,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
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
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Chewy',
                fontWeight: FontWeight.w800,
                fontSize: 36,
                height: 1,
              ),
              children: [
                TextSpan(
                  text: 'My',
                  style: TextStyle(color: Color(0xFF34C759)),
                ),
                TextSpan(
                  text: 'Plan',
                  style: TextStyle(color: Color(0xFF3498DB)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekday,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                dateText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.menu_open,
            size: 42,
            color: Color(0xFF34C759),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryUiMapper.colorFromString(category.color);
    final icon = CategoryUiMapper.iconFromKey(category.iconKey);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Kategorie öffnen',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategoriesState extends StatelessWidget {
  const _EmptyCategoriesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Noch keine Kategorien vorhanden.'),
      ),
    );
  }
}

class _EmptyTodayCategoriesState extends StatelessWidget {
  const _EmptyTodayCategoriesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Für heute sind keine Kategorien mit Ereignissen geplant.'),
      ),
    );
  }
}