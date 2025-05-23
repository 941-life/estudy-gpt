class WrongNote {
  final String id;
  final String? previousCefrLevel;
  final String? newCefrLevel;
  final int? score;
  final String? summary;
  final DateTime analyzedAt;

  WrongNote({
    required this.id,
    this.previousCefrLevel,
    this.newCefrLevel,
    this.score,
    this.summary,
    required this.analyzedAt,
  });

  factory WrongNote.fromMap(Map<String, dynamic> map) {
    return WrongNote(
      id: map['id'] as String,
      previousCefrLevel: map['previousCefrLevel'] as String?,
      newCefrLevel: map['newCefrLevel'] as String?,
      score: map['score'] as int?,
      summary: map['summary'] as String?,
      analyzedAt: DateTime.parse(map['analyzedAt']).toLocal(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'previousCefrLevel': previousCefrLevel,
      'newCefrLevel': newCefrLevel,
      'score': score,
      'summary': summary,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }
} 