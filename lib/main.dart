// import 'package:flutter/material.dart';
// import 'package:calendar_view/calendar_view.dart';
// import 'package:estudy_gpt/models/calendar_event.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'screens/login_screen.dart';
// import 'screens/main_screen.dart';
// import 'utils/shared_intent_handler.dart';
// import "dart:io";

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'eStudy GPT',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: CalendarControllerProvider(
//         controller: EventController(),
//         child: const AppContent(),
//       ),
//     );
//   }
// }

// class AppContent extends StatefulWidget {
//   const AppContent({super.key});

//   @override
//   State<AppContent> createState() => _AppContentState();
// }

// class _AppContentState extends State<AppContent> {
//   String _sharingType = 'none';
//   List<SharedMediaFile> _sharedFiles = [];
//   String _sharedText = '';
//   late SharedIntentHandler _sharedIntentHandler;

//   List<Event> events = [
//     Event(date: DateTime(2025, 5, 5), title: "석가탄신일"),
//     Event(date: DateTime(2025, 5, 10), title: "어버이날"),
//     Event(date: DateTime(2025, 5, 15), title: "스승의 날"),
//     Event(date: DateTime(2025, 5, 19), title: "부처님오신날"),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     await _initWidget();
//     _initSharing();
//     _addTestData();
//   }

//   Future<void> _initWidget() async {
//     try {
//       await Event.updateCalendarWidget(events);
//       debugPrint('위젯 업데이트 성공: ${events.length}개 이벤트');
//     } catch (e) {
//       _showErrorDialog('위젯 초기화 실패', e.toString());
//     }
//   }

//   void _addTestData() {
//     if (events.length < 6) {
//       setState(() {
//         events.addAll([
//           Event(date: DateTime.now(), title: "오늘의 일정"),
//           Event(
//             date: DateTime.now().add(const Duration(days: 2)),
//             title: "플러터 프로젝트 마감",
//           ),
//         ]);
//       });
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Event.updateCalendarWidget(events);
//       });
//     }
//   }

//   void _initSharing() {
//     _sharedIntentHandler = SharedIntentHandler(
//       onDataReceived: (type, files, text) {
//         if (!mounted) return;
//         setState(() {
//           _sharingType = type;
//           _sharedFiles = files;
//           _sharedText = text;
//         });
//       },
//     );
//     _sharedIntentHandler.init();
//   }

//   void _showErrorDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text(title),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('확인'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   void dispose() {
//     _sharedIntentHandler.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         return snapshot.hasData
//             ? MainScreen(
//               user: snapshot.data!,
//               sharingType: _sharingType,
//               sharedFiles: _sharedFiles,
//               sharedText: _sharedText,
//             )
//             : const LoginScreen();
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:estudy_gpt/models/calendar_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'utils/shared_intent_handler.dart';
import "dart:io";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eStudy GPT',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalendarControllerProvider(
        controller: EventController(),
        child: const AppContent(),
      ),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  State<AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  String _sharingType = 'none';
  List<SharedMediaFile> _sharedFiles = [];
  String _sharedText = '';
  late SharedIntentHandler _sharedIntentHandler;

  // MethodChannel 추가
  static const platform = MethodChannel('app/text_processing');

  List<Event> events = [
    Event(date: DateTime(2025, 5, 5), title: "석가탄신일"),
    Event(date: DateTime(2025, 5, 10), title: "어버이날"),
    Event(date: DateTime(2025, 5, 15), title: "스승의 날"),
    Event(date: DateTime(2025, 5, 19), title: "부처님오신날"),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();

    // MethodChannel 핸들러 설정
    platform.setMethodCallHandler(_handleMethodCall);
  }

  // 네이티브 코드에서 전달된 메서드 호출 처리
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'receivedUrl':
        final String url = call.arguments;
        debugPrint('Received URL from Chrome: $url');
        setState(() {
          _sharingType = 'text';
          _sharedText = url;
          _sharedFiles = [];
        });
        break;
      case 'receivedText':
        final String text = call.arguments;
        debugPrint('Received text from Chrome: $text');
        setState(() {
          _sharingType = 'text';
          _sharedText = text;
          _sharedFiles = [];
        });
        break;
      case 'processText':
        final String text = call.arguments;
        debugPrint('Received processText: $text');
        setState(() {
          _sharingType = 'text';
          _sharedText = text;
          _sharedFiles = [];
        });
        break;
    }
  }

  Future<void> _initializeApp() async {
    await _initWidget();
    _initSharing();
    _addTestData();
  }

  Future<void> _initWidget() async {
    try {
      await Event.updateCalendarWidget(events);
      debugPrint('위젯 업데이트 성공: ${events.length}개 이벤트');
    } catch (e) {
      _showErrorDialog('위젯 초기화 실패', e.toString());
    }
  }

  void _addTestData() {
    if (events.length < 6) {
      setState(() {
        events.addAll([
          Event(date: DateTime.now(), title: "오늘의 일정"),
          Event(
            date: DateTime.now().add(const Duration(days: 2)),
            title: "플러터 프로젝트 마감",
          ),
        ]);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Event.updateCalendarWidget(events);
      });
    }
  }

  void _initSharing() {
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _sharedIntentHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
    );
  }
}
