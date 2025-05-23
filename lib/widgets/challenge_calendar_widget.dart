import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../models/wrong_note.dart';

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
    // 동기 부여 메시지 생성
    final message = _getMotivationalMessage(hasCreatedNote);
    
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

  static String _getMotivationalMessage(bool hasCreatedNote) {
    if (hasCreatedNote) {
      final messages = [
        '오늘의 학습을 완료했어요! 대단해요! 🎉',
        '훌륭해요! 오늘도 성장하는 하루였어요! ✨',
        '학습 목표 달성! 내일도 이 기세로! 🌟'
      ];
      return messages[DateTime.now().microsecond % messages.length];
    } else {
      final messages = [
        '아직 오늘의 학습을 시작하지 않았어요!',
        '새로운 도전이 기다리고 있어요!',
        '오늘의 학습으로 한 걸음 더 성장해보세요!'
      ];
      return messages[DateTime.now().microsecond % messages.length];
    }
  }

  // 앱이 시작될 때 위젯 초기화
  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId(appGroupId);
    
    // 위젯 클릭 시 앱 실행을 위한 리스너 등록
    HomeWidget.widgetClicked.listen((uri) {
      // 위젯 클릭 시 앱의 특정 화면으로 이동하는 로직
    });
  }
} 