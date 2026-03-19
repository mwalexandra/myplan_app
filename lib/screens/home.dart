import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Screen 1: Home', 
              style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/list'),
              child: const Text('Go to List of Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
