// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Custom Context Menu Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.light,
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark,
//       ),
//       themeMode: ThemeMode.system,
//       home: const MyHomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1A237E),
//         title: Row(
//           children: [
//             Icon(Icons.home, color: Colors.white),
//             SizedBox(width: 16),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF3949AB),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.menu, color: Colors.white, size: 20),
//                     SizedBox(width: 8),
//                     Text(
//                       'news.hada.io/topic',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
//             Icon(Icons.add, color: Colors.white),
//             SizedBox(width: 16),
//             Container(
//               padding: EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: Text("11", style: TextStyle(color: Colors.white)),
//             ),
//             SizedBox(width: 16),
//             Icon(Icons.more_vert, color: Colors.white),
//           ],
//         ),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               color: const Color(0xFFF5F5F5),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             'GeekNews',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Text('최신글 댓글 예전글 Ask Show GN+'),
//                         ],
//                       ),
//                       Icon(Icons.search),
//                     ],
//                   ),
//                   SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [Text('Weekly | 글등록'), Text('로그인')],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.arrow_upward, color: Colors.grey),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'JAVA 문자열(String) 성능 대폭 향상',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Icon(Icons.link),
//                     ],
//                   ),
//                   Divider(),
//                   Text('(inside.java)', style: TextStyle(color: Colors.grey)),
//                   SizedBox(height: 8),
//                   Text(
//                     '5P by baeba 1일전 | ★ favorite | 댓글과 토론',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   SizedBox(height: 24),
//                   Text(
//                     '서론',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 16),
//                   // Custom selectable text with context menu
//                   SelectableText(
//                     '• JDK 25에서 String 분 상수 풀링 처리됨\n'
//                     '• 불변 Map에서 문자열 키 기반 조회 성능 향상됨\n'
//                     '• 내부적으로 String.compact 및 @Stable 적용, hashCode 최적화된 JVM이 캐시 신뢰함\n'
//                     '• 이로 인해 해시 계산, Map 인덱스 계산, 메서드 핸들 조회가 모두 컴파일 타임에 상수로 처리됨\n'
//                     '• benchmark 결과, 기존 JDK 24 대비 최대 8배 이상 성능 개선 확인됨',
//                     style: TextStyle(fontSize: 16, height: 1.5),
//                     contextMenuBuilder: (context, editableTextState) {
//                       return _buildCustomContextMenu(
//                         context,
//                         editableTextState,
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomContextMenu(
//     BuildContext context,
//     EditableTextState editableTextState,
//   ) {
//     // 선택된 텍스트 가져오기
//     final TextEditingValue value = editableTextState.textEditingValue;
//     final String selectedText = value.selection.textInside(value.text);

//     // 메뉴 항목 스타일 정의
//     const TextStyle menuItemStyle = TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w500,
//     );

//     // 커스텀 메뉴 항목 위젯 생성
//     List<Widget> menuItems = [
//       // Dictionary 옵션
//       Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Text('Dictionary', style: menuItemStyle),
//       ),
//       Divider(height: 1),

//       // Ask Perplexity 옵션
//       GestureDetector(
//         onTap: () {
//           ContextMenuController.removeAny();
//           _askPerplexity(context, selectedText);
//         },
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           child: Text('Ask Perplexity', style: menuItemStyle),
//         ),
//       ),
//       Divider(height: 1),

//       // M365 Copilot Note 옵션
//       Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Text('M365 Copilot Note', style: menuItemStyle),
//       ),
//       Divider(height: 1),

//       // Translate with Papago 옵션
//       Container(
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Text('Translate with Papago', style: menuItemStyle),
//       ),
//     ];

//     // 커스텀 컨텍스트 메뉴 UI 생성
//     return Material(
//       elevation: 4.0,
//       borderRadius: BorderRadius.circular(8),
//       color: Colors.white,
//       child: Container(
//         width: 250, // 메뉴 너비 설정
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: menuItems,
//         ),
//       ),
//     );
//   }

//   // Perplexity API 연동 샘플
//   void _askPerplexity(BuildContext context, String text) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('선택된 텍스트를 Perplexity에 질문합니다: "$text"'),
//         duration: Duration(seconds: 2),
//       ),
//     );

//     // 실제 구현에서는 여기에 Perplexity API 호출 로직 추가
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Text Processing App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   static const platform = MethodChannel('app/text_processing');
//   String _processedText = '';

//   @override
//   void initState() {
//     super.initState();
//     platform.setMethodCallHandler(_handleMethod);

//     // iOS에서 URL Scheme으로 전달된 경우 처리
//     // 이 부분은 사용하는 패키지에 따라 다를 수 있음
//   }

//   Future<dynamic> _handleMethod(MethodCall call) async {
//     switch (call.method) {
//       case 'processText':
//         setState(() {
//           _processedText = call.arguments;
//         });
//         break;
//       default:
//         print('Method not implemented: ${call.method}');
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Text Processing App')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_processedText.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Text(
//                           '선택된 텍스트:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(_processedText),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             if (_processedText.isEmpty) Text('다른 앱에서 텍스트를 선택하고 이 앱으로 공유하세요'),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 파일 공유를 위한 변수
  late StreamSubscription _mediaIntentSub;
  final _sharedFiles = <SharedMediaFile>[];

  // 텍스트 공유를 위한 변수
  late StreamSubscription _textIntentSub;
  String _sharedText = '';

  // MethodChannel 설정
  static const platform = MethodChannel('app/text_processing');

  // 현재 공유 방식을 추적하는 변수
  String _sharingType =
      'none'; // 'none', 'media_stream', 'initial_media', 'method_channel'

  @override
  void initState() {
    super.initState();

    // MethodChannel 핸들러 설정
    platform.setMethodCallHandler(_handleMethod);

    // 1. 미디어 파일 공유 처리 (앱이 실행 중일 때)
    _mediaIntentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
          _sharingType = 'media_stream';
          print("공유받은 파일(스트림): ${_sharedFiles.map((f) => f.toMap())}");
        });
      },
      onError: (err) {
        print("getMediaStream 오류: $err");
      },
    );

    // 2. 미디어 파일 공유 처리 (앱이 종료되었다가 공유로 실행될 때)
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFiles.clear();
          _sharedFiles.addAll(value);
          _sharingType = 'initial_media';
          print("초기 공유받은 파일: ${_sharedFiles.map((f) => f.toMap())}");

          // 인텐트 처리 완료 알림
          ReceiveSharingIntent.instance.reset();
        });
      }
    });
  }

  // MethodChannel로부터 호출되는 핸들러
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'processText':
        setState(() {
          _sharedText = call.arguments;
          _sharingType = 'method_channel';
        });
        break;
      default:
        print('Method not implemented: ${call.method}');
    }
    return null;
  }

  @override
  void dispose() {
    _mediaIntentSub.cancel();
    _textIntentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '공유받기 예제',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              // 공유 방식에 따라 다른 화면 표시
              switch (_sharingType) {
                case 'media_stream':
                  return MediaStreamScreen(files: _sharedFiles);
                case 'initial_media':
                  return InitialMediaScreen(files: _sharedFiles);
                case 'method_channel':
                  return MethodChannelTextScreen(text: _sharedText);
                case 'text_stream':
                  return TextStreamScreen(text: _sharedText);
                case 'initial_text':
                  return InitialTextScreen(text: _sharedText);
                default:
                  return HomeScreen(
                    onNavigateToMediaStream: () {
                      setState(() => _sharingType = 'media_stream');
                    },
                    onNavigateToInitialMedia: () {
                      setState(() => _sharingType = 'initial_media');
                    },
                    onNavigateToMethodChannel: () {
                      setState(() => _sharingType = 'method_channel');
                    },
                  );
              }
            },
          );
        },
      ),
    );
  }
}

// 홈 화면 (공유 내용이 없을 때)
class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToMediaStream;
  final VoidCallback onNavigateToInitialMedia;
  final VoidCallback onNavigateToMethodChannel;

  const HomeScreen({
    required this.onNavigateToMediaStream,
    required this.onNavigateToInitialMedia,
    required this.onNavigateToMethodChannel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공유받기 예제'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 24),
            Text(
              '다른 앱에서 텍스트나 파일을\n이 앱으로 공유해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 48),
            Text(
              '테스트용 화면 전환',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onNavigateToMediaStream,
              child: Text('미디어 스트림 화면으로 이동'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onNavigateToInitialMedia,
              child: Text('초기 미디어 화면으로 이동'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: onNavigateToMethodChannel,
              child: Text('메소드 채널 화면으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

// 미디어 스트림 화면 (앱이 실행 중일 때 공유된 파일용)
class MediaStreamScreen extends StatelessWidget {
  final List<SharedMediaFile> files;

  const MediaStreamScreen({required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실행 중 공유 파일'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 실행 중일 때 공유받은 파일',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (files.isEmpty)
              Center(
                child: Text(
                  '공유된 파일이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getIconForFile(file)),
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.type.toString().split('.').last),
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

  IconData _getIconForFile(SharedMediaFile file) {
    final type = file.type.toString().toLowerCase();
    if (type.contains('image')) return Icons.image;
    if (type.contains('video')) return Icons.video_file;
    if (type.contains('audio')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }
}

// 초기 미디어 화면 (앱이 종료됐다가 실행될 때 공유된 파일용)
class InitialMediaScreen extends StatelessWidget {
  final List<SharedMediaFile> files;

  const InitialMediaScreen({required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('초기 공유 파일'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 종료됐다가 실행될 때 공유받은 파일',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (files.isEmpty)
              Center(
                child: Text(
                  '공유된 파일이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getIconForFile(file)),
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.type.toString().split('.').last),
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

  IconData _getIconForFile(SharedMediaFile file) {
    final type = file.type.toString().toLowerCase();
    if (type.contains('image')) return Icons.image;
    if (type.contains('video')) return Icons.video_file;
    if (type.contains('audio')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }
}

// 메소드 채널 텍스트 화면 (네이티브 코드에서 전달된 텍스트용)
class MethodChannelTextScreen extends StatelessWidget {
  final String text;

  const MethodChannelTextScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Method Channel 텍스트'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Method Channel로 전달받은 텍스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isEmpty)
                      Text(
                        '텍스트가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      )
                    else
                      Text(text, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    if (text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.copy),
                            label: Text('복사'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('클립보드에 복사되었습니다')),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 텍스트 스트림 화면 (앱이 실행 중일 때 공유된 텍스트용)
class TextStreamScreen extends StatelessWidget {
  final String text;

  const TextStreamScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('스트림 텍스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 실행 중일 때 공유받은 텍스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isEmpty)
                      Text(
                        '텍스트가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      )
                    else
                      Text(text, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    if (text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.copy),
                            label: Text('복사'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('클립보드에 복사되었습니다')),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 초기 텍스트 화면 (앱이 종료됐다가 실행될 때 공유된 텍스트용)
class InitialTextScreen extends StatelessWidget {
  final String text;

  const InitialTextScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('초기 텍스트'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 종료됐다가 실행될 때 공유받은 텍스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isEmpty)
                      Text(
                        '텍스트가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      )
                    else
                      Text(text, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    if (text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.copy),
                            label: Text('복사'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('클립보드에 복사되었습니다')),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
