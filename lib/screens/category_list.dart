import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of Categories')),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item $index'),
          onTap: () => context.go('/detail/$index'),
        ),
      ),
    );
  }
}
