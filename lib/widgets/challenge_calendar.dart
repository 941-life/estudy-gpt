import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/wrong_note.dart';

class ChallengeCalendar extends StatelessWidget {
  final String title;
  final DateTime currentDate;
  final Map<DateTime, List<WrongNote>> wrongNotes;
  final Function(DateTime) onDateSelected;

  const ChallengeCalendar({
    super.key,
    required this.title,
    required this.currentDate,
    required this.wrongNotes,
    required this.onDateSelected,
  });

  Widget _buildCalendarGrid() {
    // 현재 월의 첫 날과 마지막 날 계산
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    
    // 달력에 표시할 날짜 수 계산 (이전 월의 날짜 + 현재 월의 날짜)
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy').format(currentDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 요일 헤더
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
          itemCount: 42, // 6주 x 7일
          itemBuilder: (context, index) {
            // 달력에 표시할 날짜 계산
            final int displayDay = index - (firstWeekday - 1);
            if (displayDay < 1 || displayDay > daysInMonth) {
              return Container(); // 현재 월에 속하지 않는 날짜는 빈 컨테이너 표시
            }

            final date = DateTime(currentDate.year, currentDate.month, displayDay);
            final isToday = date.year == currentDate.year && 
                           date.month == currentDate.month && 
                           date.day == currentDate.day;
            final hasWrongNotes = wrongNotes.containsKey(date);
            
            return GestureDetector(
              onTap: hasWrongNotes ? () => onDateSelected(date) : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: hasWrongNotes
                      ? Colors.blue.shade100
                      : isToday
                          ? Colors.blue
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Colors.blue, width: 2)
                      : null,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                  ),
                  child: const Text(
                    'Nice pace!',
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
    );
  }
} 