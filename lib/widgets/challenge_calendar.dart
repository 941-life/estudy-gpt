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

  @override
  Widget build(BuildContext context) {
    return Card(
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