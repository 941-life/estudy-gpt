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
