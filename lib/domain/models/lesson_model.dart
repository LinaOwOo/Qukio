class LessonModel {
  final String id;
  final String title;
  final String content;
  final String courseId;
  final int order;
  final int? progress;
  final bool? isCompleted;

  LessonModel({
    required this.id,
    required this.title,
    required this.content,
    required this.courseId,
    required this.order,
    this.progress,
    this.isCompleted,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Без названия',
      content: map['content'] as String? ?? '',
      courseId: map['courseId'] as String? ?? 'unknown',
      order: map['order'] as int? ?? 0,
      progress: map['progress'] as int?,
      isCompleted: map['isCompleted'] as bool?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'courseId': courseId,
      'order': order,
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }
}
