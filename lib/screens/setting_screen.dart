import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingScreen extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    try {
      // 1. Google 로그아웃 추가
      await GoogleSignIn().signOut();

      // 2. Firebase 로그아웃
      await FirebaseAuth.instance.signOut();

      // 3. 스낵바 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그아웃 되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );

      // 4. 네비게이션 스택 정리 (옵션)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그아웃 실패: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
