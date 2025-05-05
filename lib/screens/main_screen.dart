import 'package:estudy_gpt/screens/personal_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'webview_bridge.dart';
import 'login_screen.dart';
import 'calendar_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
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

  @override
  void initState() {
    super.initState();
    _initializeWebViews();
    _checkSharedData();
  }

  void _initializeWebViews() {
    _webViews = [
      WebViewBridge(user: widget.user, initialUrl: 'https://www.naver.com'),
      WebViewBridge(user: widget.user, initialUrl: 'https://www.google.com'),
      WebViewBridge(user: widget.user, initialUrl: 'https://www.youtube.com'),
    ];
  }

  void _checkSharedData() {
    if (widget.sharingType == 'text' || widget.sharingType == 'file') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _selectedIndex = 3);
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    if (_selectedIndex == 3) {
      return PersonalScreen(
        sharingType: widget.sharingType,
        sharedFiles: widget.sharedFiles,
        sharedText: widget.sharedText,
      );
    } else if (_selectedIndex == 0 && widget.user == null) {
      return const LoginScreen();
    }
    return IndexedStack(index: _selectedIndex, children: _webViews);
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: '학습'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        BottomNavigationBarItem(icon: Icon(Icons.abc_rounded), label: '개인'),
      ],
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
    );
  }
}
