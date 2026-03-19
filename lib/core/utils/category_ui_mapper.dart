import 'package:flutter/material.dart';

class CategoryUiMapper {
  static const Map<String, IconData> icons = {
    'school': Icons.school,
    'sports_soccer': Icons.sports_soccer,
    'family': Icons.family_restroom,
    'gamepad': Icons.videogame_asset,
    'home': Icons.home,
    'favorite': Icons.favorite,
    'book': Icons.menu_book,
    'music': Icons.music_note,
  };

  static const Map<String, String> colors = {
    'green': '0xFF4CAF50',
    'blue': '0xFF2196F3',
    'pink': '0xFFE91E63',
    'orange': '0xFFFF9800',
    'purple': '0xFF9C27B0',
    'teal': '0xFF009688',
    'red': '0xFFF44336',
    'amber': '0xFFFFC107',
  };

  static IconData iconFromKey(String key) {
    return icons[key] ?? Icons.category;
  }

  static Color colorFromString(String value) {
    try {
      return Color(int.parse(value));
    } catch (_) {
      return const Color(0xFF2196F3);
    }
  }
}
