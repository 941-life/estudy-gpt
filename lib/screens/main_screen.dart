import 'package:estudy_gpt/screens/personal_screen.dart';
import 'package:estudy_gpt/screens/profile_screen.dart';
import 'package:estudy_gpt/screens/wrong_note_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'webview_bridge.dart';
import 'login_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  final String sharingType;
  final List<SharedMediaFile> sharedFiles;
  final String sharedText;

  const MainScreen({
    super.key,
    required this.user,
    this.sharingType = 'none',
    this.sharedFiles = const [],
    this.sharedText = '',
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<WebViewBridge> _webViews;
  String _webTitle = '';

  @override
  void initState() {
    super.initState();
    _initializeWebViews();
    _checkSharedData();
  }

  void _initializeWebViews() {
    _webViews = [
      WebViewBridge(
        key: const ValueKey('webview_chat'),
        user: widget.user,
        initialUrl: 'https://estudy-5b2ba.web.app/',
        onTitleChanged: (_) => setState(() => _webTitle = 'Chat'),
      ),
      // WebViewBridge(
      //   key: const ValueKey('webview_wrong_note'),
      //   user: widget.user,
      //   initialUrl: 'https://estudy-5b2ba.web.app/',
      //   onTitleChanged: (_) => setState(() => _webTitle = 'Wrong note'),
      // ),
    ];
  }

  void _checkSharedData() {
    if (widget.sharingType == 'text' || widget.sharingType == 'file') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedIndex = 0);
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // 탭 전환 시 타이틀을 즉시 반영
      if (index == 1) {
        _webTitle = 'Chat';
      } else if (index == 2) {
        _webTitle = 'Wrong note';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          (_selectedIndex == 1 || _selectedIndex == 2)
              ? AppBar(
                title: Text(
                  _webTitle.isNotEmpty
                      ? _webTitle
                      : (_selectedIndex == 1 ? 'Chat' : 'Wrong note'),
                ),
              )
              : null,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        child: const Icon(Icons.calendar_today),
        tooltip: 'Open Calendar',
      ),
    );
  }

  Widget _buildBody() {
    // 로그인 체크
    if (widget.user == null) {
      return const LoginScreen();
    }
    if (_selectedIndex == 0) {
      return PersonalScreen(
        sharingType: widget.sharingType,
        sharedFiles: widget.sharedFiles,
        sharedText: widget.sharedText,
      );
    } else if (_selectedIndex == 1) {
      return _webViews[0];
    } else if (_selectedIndex == 2) {
      // return _webViews[1];
      return WrongNoteScreen();
    } else if (_selectedIndex == 3) {
      return ProfileScreen();
    } else {
      return const SizedBox.shrink();
    }
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: '학습'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '오답노트'),
        BottomNavigationBarItem(icon: Icon(Icons.abc_rounded), label: '프로필'),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}
