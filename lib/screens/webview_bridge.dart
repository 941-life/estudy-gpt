import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/firebase_utils.dart';
import '../utils/webview_utils.dart';
import 'dart:async';

class WebViewBridge extends StatefulWidget {
  final User? user;
  final String initialUrl;
  final void Function(String)? onTitleChanged; // 추가

  const WebViewBridge({
    super.key,
    required this.user,
    required this.initialUrl,
    this.onTitleChanged, // 추가
  });

  @override
  _WebViewBridgeState createState() => _WebViewBridgeState();
}

class _WebViewBridgeState extends State<WebViewBridge> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

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
              onPageFinished: (String url) async {
                _sendUserDataToReact();
                // 페이지 타이틀 가져오기
                final title = await _controller.getTitle();
                if (title != null && title.isNotEmpty && widget.onTitleChanged != null) {
                  widget.onTitleChanged!(title);
                }
              },
            ),
          )
          ..loadRequest(initialUri);
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
        widget.user!.uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(_pageTitle)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
