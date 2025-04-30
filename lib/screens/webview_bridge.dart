import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/firebase_utils.dart';
import '../utils/webview_utils.dart';
import 'dart:async';

class WebViewBridge extends StatefulWidget {
  final User? user;
  final String initialUrl;

  const WebViewBridge({
    super.key,
    required this.user,
    required this.initialUrl,
  });

  @override
  _WebViewBridgeState createState() => _WebViewBridgeState();
}

class _WebViewBridgeState extends State<WebViewBridge> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // UID 파라미터가 포함된 URL 생성
    final initialUri = Uri.parse(widget.initialUrl);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..addJavaScriptChannel(
            'FlutterBridge',
            onMessageReceived: (message) {
              handleWebViewMessage(_controller, message.message);
            },
          )
          ..setUserAgent('Mozilla/5.0')
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                _sendUserDataToReact();
              },
            ),
          )
          ..loadRequest(initialUri); // 수정된 URL 사용
  }

  Future<void> _sendUserDataToReact() async {
    if (widget.user == null) return;

    final String? accessToken = await getUserAccessToken(widget.user!);
    if (accessToken != null) {
      sendUserDataToReact(
        _controller,
        widget.user!.email ?? '',
        widget.user!.displayName ?? '',
        widget.user!.photoURL ?? '',
        accessToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView Page'), // 앱 바 유지
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
