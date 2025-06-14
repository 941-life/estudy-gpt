import 'package:estudy_gpt/screens/personal_screen.dart';
import 'package:estudy_gpt/screens/profile_screen.dart';
import 'package:estudy_gpt/screens/wrong_note_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'webview_bridge.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeWebViews();
    _checkInitialTab();
  }

  void _initializeWebViews() {
    _webViews = [
      WebViewBridge(
        key: const ValueKey('webview_chat'),
        user: widget.user,
        initialUrl: 'https://estudy-5b2ba.web.app/',
        onTitleChanged: (_) {},
      ),
    ];
  }

  void _checkInitialTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.sharingType == 'text' || widget.sharingType == 'file') {
        setState(() => _selectedIndex = 0);
      } else if (widget.sharingType == 'none' &&
          widget.sharedText.isEmpty &&
          widget.sharedFiles.isEmpty) {
        setState(() => _selectedIndex = 1);
      } else {
        setState(() => _selectedIndex = 0);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: null,
      body: _buildBody(width, height),
      bottomNavigationBar: _buildBottomNavBar(width, height),
    );
  }

  Widget _buildBody(double width, double height) {
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
      return WrongNoteScreen();
    } else if (_selectedIndex == 3) {
      return ProfileScreen();
    } else {
      return const SizedBox.shrink();
    }
  }

  BottomNavigationBar _buildBottomNavBar(double width, double height) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 16,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded, size: width * 0.07),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_rounded, size: width * 0.07),
          label: '학습',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_note_rounded, size: width * 0.07),
          label: '오답노트',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded, size: width * 0.07),
          label: '프로필',
        ),
      ],
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey[400],
      selectedFontSize: width * 0.032,
      unselectedFontSize: width * 0.032,
    );
  }
}
