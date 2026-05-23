class QuoteModel {
  final String id;
  final String userId;
  final String lessonId;
  final String text;
  final DateTime createdAt;

  const QuoteModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.text,
    required this.createdAt,
  });

  QuoteModel copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? text,
    DateTime? createdAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
