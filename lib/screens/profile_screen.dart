import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              // backgroundImage: AssetImage('assets/profile_placeholder.png'),
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
          ],
        ),
      ),
    );
  }
}
