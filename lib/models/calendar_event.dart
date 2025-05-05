import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class Event {
  final DateTime date;
  final String title;

  Event({required this.date, required this.title});

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'title': title,
  };

  static Future<void> updateCalendarWidget(List<Event> events) async {
    try {
      final calendarData = _generateCalendarData(events);
      final jsonString = jsonEncode(calendarData);
      debugPrint('전송 데이터: $jsonString'); // ✅ 디버그 로그

      await HomeWidget.saveWidgetData<String>('calendar_events', jsonString);
      await HomeWidget.updateWidget(name: 'HomeCalendarWidgetProvider');
    } catch (e) {
      debugPrint('위젯 업데이트 실패: ${e.toString()}');
      rethrow;
    }
  }

  static Map<String, dynamic> _generateCalendarData(List<Event> events) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);

    return {
      'days': List.generate(42, (index) {
        final day = firstDay.add(Duration(days: index - firstDay.weekday));
        return {
          'date': day.toIso8601String(),
          'events':
              events
                  .where((e) => _isSameDay(e.date, day))
                  .map((e) => e.title)
                  .toList(),
        };
      }),
    };
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
