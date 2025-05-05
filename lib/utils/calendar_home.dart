import 'package:estudy_gpt/models/calendar_event.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';

void updateHomeWidget(List<Event> events) async {
  await HomeWidget.saveWidgetData<String>(
    'calendar_events',
    jsonEncode(events.map((e) => e.toJson()).toList()),
  );
  await HomeWidget.updateWidget(
    name: 'HomeCalendarWidgetProvider',
    iOSName: 'HomeCalendarWidget',
  );
}
