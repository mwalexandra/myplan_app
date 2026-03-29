import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/category.dart';
import '../../core/services/category_service.dart';
import '../../core/utils/category_ui_mapper.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _seedDefaults();
  }

  Future<void> _seedDefaults() async {
    await _categoryService.ensureDefaultCategories();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Löschen bestätigen'),
          content: Text('Möchten Sie "${category.name}" löschen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _categoryService.deleteCategory(category.id);
    }
  }

  void _openAddCategory() {
    context.push('/categories/add');
  }

  void _openEditCategory(Category category) {
    context.push('/categories/edit', extra: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPlan - Kategorien'),
      ),
      body: StreamBuilder<List<Category>>(
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

          if (categories.isEmpty) {
            return const Center(
              child: Text('Keine Kategorien gefunden.'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final color = CategoryUiMapper.colorFromString(category.color);
                final icon = CategoryUiMapper.iconFromKey(category.iconKey);

                return Material(
                  color: color,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/category/${category.id}?mode=upcoming'),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 8,
                          right: 8,
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _openEditCategory(category);
                              }
                              if (value == 'delete') {
                                _deleteCategory(category);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Bearbeiten'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Löschen'),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 44,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                category.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.isDefault ? 'Standard Kategorie' : ' Benutzerdefinierte Kategorie',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCategory,
        icon: const Icon(Icons.add),
        label: const Text('Kategorie hinzufügen'),
      ),
    );
  }
}
