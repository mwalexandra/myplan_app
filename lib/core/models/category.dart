class Category {
  final String id;
  final String name;     // 'Schule', 'Sport' и т.д.
  final String icon;     // имя иконки: 'school', 'sports_soccer'
  final String color;     // цвет категории

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'help',
      color: data['color'] ?? '0xFF00FF00',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
}
