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

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
