class TimelineSegment {
  final String categoryId;
  final String categoryName;
  final String color;
  final int startMinutes;
  final int endMinutes;

  const TimelineSegment({
    required this.categoryId,
    required this.categoryName,
    required this.color,
    required this.startMinutes,
    required this.endMinutes,
  });
}
