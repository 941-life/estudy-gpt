import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/wrong_note.dart';
import '../widgets/challenge_calendar.dart';
import '../widgets/common_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedChallenge = '';  // 빈 문자열로 초기화
  final DateTime _today = DateTime.now();
  Map<DateTime, List<WrongNote>> _wrongNotes = {};
  
  @override
  void initState() {
    super.initState();
    _loadWrongNotes();
  }

  Future<void> _loadWrongNotes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final dbRef = FirebaseDatabase.instance.ref(
        'users/${user.uid}/wrongNote',
      );
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        final Map<DateTime, List<WrongNote>> tempNotes = {};
        DateTime? firstNoteDate;
        
        for (final child in snapshot.children) {
          final value = child.value;
          if (value is Map) {
            final Map<String, dynamic> noteMap = {
              'id': child.key,
              ...Map<String, dynamic>.from(value),
            };

            final wrongNote = WrongNote.fromMap(noteMap);
            final DateTime dateOnly = DateTime(
              wrongNote.analyzedAt.year,
              wrongNote.analyzedAt.month,
              wrongNote.analyzedAt.day,
            );
            
            // 첫 노트 날짜 업데이트
            if (firstNoteDate == null || dateOnly.isBefore(firstNoteDate)) {
              firstNoteDate = dateOnly;
            }
            
            if (tempNotes[dateOnly] == null) {
              tempNotes[dateOnly] = [];
            }
            tempNotes[dateOnly]!.add(wrongNote);
          }
        }

        // 학습 일수 계산 (첫 노트부터 현재까지)
        if (firstNoteDate != null) {
          final now = DateTime.now();
          final daysSinceStart = now.difference(firstNoteDate).inDays + 1;
          setState(() {
            _wrongNotes = tempNotes;
            _selectedChallenge = '$daysSinceStart days with English';
          });
        } else {
          setState(() {
            _wrongNotes = tempNotes;
            _selectedChallenge = 'Start your English journey';
          });
        }
      } else {
        setState(() {
          _wrongNotes = {};
          _selectedChallenge = 'Start your English journey';
        });
      }
    } catch (e) {
      setState(() {
        _wrongNotes = {};
        _selectedChallenge = 'Error loading data';
      });
    }
  }

  void _showWrongNotesForDate(DateTime date) {
    final notes = _wrongNotes[date] ?? [];
    if (notes.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.year}년 ${date.month}월 ${date.day}일',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (note.previousCefrLevel != null &&
                              note.newCefrLevel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '레벨: ${note.previousCefrLevel} → ${note.newCefrLevel}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          if (note.score != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '점수: ${note.score}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (note.summary != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              note.summary!,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getUserLevel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/cefrLevel');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      return snapshot.value as String?;
    }
    return null;
  }

  String _levelDescription(String level) {
    switch (level) {
      case 'A1':
        return '입문자 (Beginner)';
      case 'A2':
        return '초급 (Elementary)';
      case 'B1':
        return '중급 (Intermediate)';
      case 'B2':
        return '상급 (Upper-Intermediate)';
      case 'C1':
        return '고급 (Advanced)';
      case 'C2':
        return '최고급 (Proficient)';
      default:
        return '';
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'A1':
        return Colors.green.shade300;
      case 'A2':
        return Colors.lightGreen;
      case 'B1':
        return Colors.amber;
      case 'B2':
        return Colors.orange;
      case 'C1':
        return Colors.deepOrange;
      case 'C2':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleLogout() async {
    try {
      // 1. Google 로그아웃
      await GoogleSignIn().signOut();

      // 2. Firebase 로그아웃
      await FirebaseAuth.instance.signOut();

      // 3. 스낵바 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그아웃 실패: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: const CommonAppBar(title: 'Profile'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const CircleAvatar(
              radius: 48,
            ),
            const SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User Name',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'user@email.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String?>(
              future: _getUserLevel(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('레벨 정보를 불러올 수 없습니다');
                }
                final level = snapshot.data ?? '알 수 없음';

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _levelColor(level),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: _levelColor(level).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '현재 레벨: $level',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _levelDescription(level),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ChallengeCalendar(
              title: _selectedChallenge,
              initialDate: _today,
              wrongNotes: _wrongNotes,
              onDateSelected: _showWrongNotesForDate,
            ),
          ],
        ),
      ),
    );
  }
}
