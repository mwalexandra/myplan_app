import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/utils/category_ui_mapper.dart';
import '../widgets/category_timeline_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _seedDefaults();
  }

  Future<void> _seedDefaults() async {
    await _categoryService.ensureDefaultCategories();
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
          stream: _categoryService.getCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Fehler: ${snapshot.error}'),
              );
            }

            final categories = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _HomeHeader(
                  weekday: _weekdayName(now.weekday),
                  dateText: '${now.day}. ${_monthName(now.month)}',
                ),
                const SizedBox(height: 16),
                CategoryTimelineBar(categories: categories),
                const SizedBox(height: 20),
                Text(
                  'Kategorien',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (categories.isEmpty)
                  const _EmptyCategoriesState()
                else
                  GridView.builder(
                    itemCount: categories.length,
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
                      final category = categories[index];
                      return _CategoryCard(
                        category: category,
                        onTap: () => context.push('/category/${category.id}'),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/add'),
        backgroundColor: const Color(0xFF59D66F),
        child: const Icon(Icons.add_box, color: Colors.white, semanticLabel: 'Kategorie hinzufügen'),
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
