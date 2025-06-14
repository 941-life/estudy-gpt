import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

void handleWebViewMessage(WebViewController controller, String message) {
  final data = jsonDecode(message);
  if (data['type'] == 'router:push' && data['path'] != null) {
    controller.loadRequest(Uri.parse(data['path']));
  } else if (data['type'] == 'content:scraped' && data['content'] != null) {
    sendScrapedContentToWebView(controller, data['content']);
  } else {
    debugPrint('Unhandled message: $message');
  }
}

Future<void> sendUserDataToReact(
  WebViewController controller,
  String email,
  String displayName,
  String photoUrl,
  String accessToken,
  String uuid,
) async {
  debugPrint('sendUserDataToReact: uuid = $uuid'); // uuid 출력
  controller.runJavaScript('''
    window.postMessage({
      type: 'auth:success',
      email: '$email',
      displayName: '$displayName',
      photoUrl: '$photoUrl',
      accessToken: '$accessToken',
      uuid: '$uuid',
    }, '*');
  ''');
}

Future<void> sendScrapedContentToWebView(
  WebViewController controller,
  String content,
) async {
  controller.runJavaScript('''
    window.postMessage({
      type: 'content:received',
      content: '$content'
    }, '*');
  ''');
}
