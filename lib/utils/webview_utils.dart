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
  String accessToken,
  String uuid,
) async {
  controller.runJavaScript('''
    window.postMessage({
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
