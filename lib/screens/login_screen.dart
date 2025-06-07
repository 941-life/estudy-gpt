import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

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
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 로고 이미지
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/icon.png',
                                width: width * 0.3,
                                height: width * 0.3,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.06),

                        // 앱 제목
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'eStudy GPT',
                                  style: TextStyle(
                                    fontSize: width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1976D2),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Text(
                                  'AI와 함께하는 스마트 학습',
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.08),

                        // 로그인 안내 메시지
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.06,
                                vertical: height * 0.025,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.blue[100]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: width * 0.08,
                                    color: Colors.blue[600],
                                  ),
                                  SizedBox(height: height * 0.015),
                                  Text(
                                    '안전한 학습을 위해\n로그인이 필요합니다',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: width * 0.04,
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.06),

                        // Google 로그인 버튼 (이미지 사용)
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:
                                      _isLoading
                                          ? null
                                          : () => _handleGoogleSignIn(context),
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      _isLoading
                                          ? Container(
                                            width: width * 0.6,
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.blue[600]!),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    '로그인 중...',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/images/android_neutral_rd_SI.svg', // SVG 파일 경로
                                              width: width * 0.6,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        // 추가 정보
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            '로그인하면 학습 진도와 성과를\n안전하게 저장할 수 있습니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.032,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // 개인정보 처리방침 링크
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: TextButton(
                            onPressed: () {
                              // 개인정보 처리방침 페이지로 이동
                            },
                            child: Text(
                              '개인정보 처리방침',
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
