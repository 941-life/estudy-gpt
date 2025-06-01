import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wrong_note.dart';

class ChallengeCalendar extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final Map<DateTime, List<WrongNote>> wrongNotes;
  final Function(DateTime) onDateSelected;

  const ChallengeCalendar({
    super.key,
    required this.title,
    required this.initialDate,
    required this.wrongNotes,
    required this.onDateSelected,
  });

  static String getMotivationalMessage(bool hasCreatedNote) {
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

  @override
  State<ChallengeCalendar> createState() => _ChallengeCalendarState();
}

class _ChallengeCalendarState extends State<ChallengeCalendar> {
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  bool _hasWrongNotesForDate(DateTime date) {
    return widget.wrongNotes.entries.any((entry) {
      final noteDate = entry.key;
      return noteDate.year == date.year && 
             noteDate.month == date.month && 
             noteDate.day == date.day;
    });
  }

  bool _hasCreatedTodayNote() {
    final now = DateTime.now();
    return _hasWrongNotesForDate(now);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blue.shade100,
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Keep going!',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCalendarGrid(),
              ],
            ),
          ),
        ),
        _buildTodayTask(),
      ],
    );
  }

  Widget _buildTodayTask() {
    final hasCreatedNote = _hasCreatedTodayNote();
    final motivationalMessage = ChallengeCalendar.getMotivationalMessage(hasCreatedNote);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Today's Task",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                hasCreatedNote ? 'assets/images/thumbup.png' : 'assets/images/sad.png',
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              motivationalMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    final hasCreatedNote = _hasCreatedTodayNote();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasCreatedNote ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCreatedNote ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: hasCreatedNote ? Colors.green.shade700 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(_currentDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['일', '월', '화', '수', '목', '금', '토'].map((day) => 
            Text(
              day,
              style: TextStyle(
                color: day == '일' ? Colors.red : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final int displayDay = index - (firstWeekday - 1);
            if (displayDay < 1 || displayDay > daysInMonth) {
              return Container();
            }

            final date = DateTime(_currentDate.year, _currentDate.month, displayDay);
            final isToday = date.year == widget.initialDate.year && 
                           date.month == widget.initialDate.month && 
                           date.day == widget.initialDate.day;
            final hasWrongNotes = _hasWrongNotesForDate(date);
            
            return GestureDetector(
              onTap: hasWrongNotes ? () => widget.onDateSelected(date) : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: hasWrongNotes
                      ? Colors.blue.shade50
                      : isToday
                          ? Colors.blue
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Colors.blue, width: 2)
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        displayDay.toString(),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.black87,
                          fontWeight: isToday || hasWrongNotes
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasWrongNotes)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 