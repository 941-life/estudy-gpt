import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 로그인
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final uid = userCredential.user!.uid;

      // Realtime Database 폴더 생성 (존재하지 않는 경우만)
      final dbRef = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await dbRef.get();

      Map<String, dynamic> updates = {};

      // 각 폴더 존재 여부 확인
      if (!snapshot.hasChild('Conversation')) {
        updates['Conversation'] = {'createdAt': ServerValue.timestamp};
      }
      if (!snapshot.hasChild('Vocabulary')) {
        updates['Vocabulary'] = {'createdAt': ServerValue.timestamp};
      }
      if (!snapshot.hasChild('Context')) {
        updates['Context'] = {'createdAt': ServerValue.timestamp};
      }

      // 필요한 경우에만 업데이트
      if (updates.isNotEmpty) {
        await dbRef.update(updates);
      }

      // 네비게이션
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(user: userCredential.user!),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로그인이 필요합니다', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleGoogleSignIn(context),
              child: const Text('Google로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
