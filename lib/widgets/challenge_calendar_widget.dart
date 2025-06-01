import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/wrong_note.dart';
import 'challenge_calendar.dart';

// 위젯 업데이트를 위한 상수
const String appGroupId = 'group.com.estudygpt';
const String widgetName = 'ChallengeCalendarWidget';

// 위젯에서 사용할 키들
const String keyHasCreatedNote = 'has_created_note';
const String keyMotivationalMessage = 'motivational_message';
const String keyCurrentDate = 'current_date';

class ChallengeCalendarWidget {
  static Future<void> updateWidget({
    required bool hasCreatedNote,
    required DateTime currentDate,
  }) async {
    // ChallengeCalendar의 static 메서드 사용
    final message = ChallengeCalendar.getMotivationalMessage(hasCreatedNote);
    
    // 위젯 데이터 업데이트
    await HomeWidget.saveWidgetData(keyHasCreatedNote, hasCreatedNote);
    await HomeWidget.saveWidgetData(keyMotivationalMessage, message);
    await HomeWidget.saveWidgetData(
      keyCurrentDate, 
      DateFormat('yyyy-MM-dd').format(currentDate)
    );
    
    // 위젯 업데이트 요청
    await HomeWidget.updateWidget(
      name: widgetName,
      androidName: 'ChallengeCalendarWidgetProvider',
      iOSName: 'ChallengeCalendarWidget',
    );
  }

  // 앱이 시작될 때 위젯 초기화
  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId(appGroupId);
    
    // 위젯 클릭 시 앱 실행을 위한 리스너 등록
    HomeWidget.widgetClicked.listen((uri) {
      if (uri?.host == 'WIDGET_CLICK') {
        // 앱이 이미 실행 중인지 확인하고 적절한 처리
        // 여기서는 별도의 처리가 필요 없음 (Android에서 처리)
        print('Widget clicked: $uri');
      }
    });
  }
} 