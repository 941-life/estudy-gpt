import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('캘린더')),
        body: MonthView(),
      ),
    );
  }
}
