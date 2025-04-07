import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/firebase_utils.dart';
import '../utils/webview_utils.dart';

class WebViewBridge extends StatefulWidget {
  final User user;

  const WebViewBridge({super.key, required this.user});

  @override
  _WebViewBridgeState createState() => _WebViewBridgeState();
}

class _WebViewBridgeState extends State<WebViewBridge> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
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
          ..loadRequest(
            Uri.parse('https://kmeanseo.github.io/estudy_gpt_web/'),
          );
  }

  Future<void> _sendUserDataToReact() async {
    final String? accessToken = await getUserAccessToken(widget.user);
    if (accessToken != null) {
      sendUserDataToReact(
        _controller,
        widget.user.email ?? '',
        widget.user.displayName ?? '',
        widget.user.photoURL ?? '',
        accessToken,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: WebViewWidget(controller: _controller));
  }
}
