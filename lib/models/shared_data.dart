import 'package:flutter/foundation.dart';

@immutable
class SharedData {
  final String type;
  final List<String> filePaths;
  final String text;
  final DateTime timestamp;
  SharedData({
    required this.type,
    this.filePaths = const [],
    this.text = '',
    required this.timestamp,
  });
  Map<String, dynamic> toJson() => {
    'type': type,
    'filePaths': filePaths,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };
  factory SharedData.fromJson(Map<String, dynamic> json) => SharedData(
    type: json['type'],
    filePaths: List<String>.from(json['filePaths']),
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
// class SharedData {
//   final String type; // 'text' or 'file'
//   final String text;
//   final List<String> filePaths;
//   final DateTime timestamp;
//   final String? question; // 추가: 선택한 질문
//   final String? answer; // 추가: Gemini 답변

//   SharedData({
//     required this.type,
//     required this.text,
//     required this.filePaths,
//     required this.timestamp,
//     this.question,
//     this.answer,
//   });

//   factory SharedData.fromJson(Map<String, dynamic> json) => SharedData(
//     type: json['type'],
//     text: json['text'],
//     filePaths: List<String>.from(json['filePaths']),
//     timestamp: DateTime.parse(json['timestamp']),
//     question: json['question'],
//     answer: json['answer'],
//   );

//   Map<String, dynamic> toJson() => {
//     'type': type,
//     'text': text,
//     'filePaths': filePaths,
//     'timestamp': timestamp.toIso8601String(),
//     'question': question,
//     'answer': answer,
//   };
// }
