import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/services/event_service.dart';  

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService categoryService = CategoryService();
  final EventService eventService = EventService();  

  IconData _getIcon(String iconName) {
    final icons = {
      'school': Icons.school,
      'sports_soccer': Icons.sports_soccer,
      'gamepad': Icons.gamepad,
      'group': Icons.group,
    };
    return icons[iconName] ?? Icons.help_outline;
  }

  Color _colorFromString(String colorStr) {
    return Color(int.parse(colorStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPlan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: categoryService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No categories found.'),
                  ElevatedButton(
                    onPressed: () => categoryService.ensureDefaultCategories(),  // умный seed
                    child: const Text('Load Default Categories'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return FutureBuilder<int>(
                  future: eventService
                      .getEventsByCategory(category.name)
                      .first
                      .then((events) => events.length),
                  builder: (context, countSnapshot) {
                    final count = countSnapshot.data ?? 0;
                    return GestureDetector(
                      onTap: () => context.go('/category/${category.name}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _colorFromString(category.color),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getIcon(category.icon), 
                                size: 48, color: Colors.white),
                            Text(category.name, 
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 18, 
                                  fontWeight: FontWeight.w600
                                )),
                            Text('$count Events', 
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-category'), 
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
