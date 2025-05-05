import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'utils/shared_intent_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sharingType = 'none';
  List<SharedMediaFile> _sharedFiles = [];
  String _sharedText = '';
  late SharedIntentHandler _sharedIntentHandler;

  @override
  void initState() {
    super.initState();
    requestStoragePermission(); // 앱 시작 시 권한 요청
    _sharedIntentHandler = SharedIntentHandler(
      onDataReceived: (type, files, text) {
        if (!mounted) return;
        setState(() {
          _sharingType = type;
          _sharedFiles = files;
          _sharedText = text;
        });
      },
    );
    _sharedIntentHandler.init();
  }

  // 저장소 권한 요청 함수
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      // 권한 거부 시 사용자 안내
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('권한 필요'),
                content: const Text('공유 파일을 저장하려면 저장소 접근 권한이 필요합니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sharedIntentHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return snapshot.hasData
              ? MainScreen(
                user: snapshot.data!,
                sharingType: _sharingType,
                sharedFiles: _sharedFiles,
                sharedText: _sharedText,
              )
              : const LoginScreen();
        },
      ),
    );
  }
}
