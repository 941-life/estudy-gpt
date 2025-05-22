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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final uid = userCredential.user!.uid;

      final dbRef = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await dbRef.get();

      if (!snapshot.exists) {
        await dbRef.set({
          'cefrLevel': 'A1',
          'createdAt': ServerValue.timestamp,
          'totalSessions': 0,
          'recentScores': [],
          'chat': {
            'Conversation': {'createdAt': ServerValue.timestamp},
          },
          'wrongNote': {},
          'Vocabulary': {'createdAt': ServerValue.timestamp},
          'Context': {'createdAt': ServerValue.timestamp},
        });
      } else {
        Map<String, dynamic> updates = {};
        if (!snapshot.hasChild('Conversation') && !snapshot.hasChild('chat')) {
          updates['chat/Conversation'] = {'createdAt': ServerValue.timestamp};
        }
        if (!snapshot.hasChild('Vocabulary')) {
          updates['Vocabulary'] = {'createdAt': ServerValue.timestamp};
        }
        if (!snapshot.hasChild('Context')) {
          updates['Context'] = {'createdAt': ServerValue.timestamp};
        }
        if (updates.isNotEmpty) {
          await dbRef.update(updates);
        }
      }

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(user: userCredential.user!),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('로그인이 필요합니다', style: TextStyle(fontSize: width * 0.055)),
            SizedBox(height: height * 0.03),
            SizedBox(
              width: width * 0.7,
              height: height * 0.07,
              child: ElevatedButton(
                onPressed: () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(fontSize: width * 0.045),
                  padding: EdgeInsets.symmetric(vertical: height * 0.02),
                ),
                child: const Text('Google로 로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
