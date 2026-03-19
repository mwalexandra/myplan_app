import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';    

class AddCategoryScreen extends StatelessWidget {
  const AddCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pop(), 
          child: const Text('Go Back'),
          ),
        ),
      );
  }
}
