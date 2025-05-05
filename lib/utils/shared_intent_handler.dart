import 'dart:async';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../models/shared_data.dart';
import 'local_storage.dart';

class SharedIntentHandler {
  static const platform = MethodChannel('app/text_processing');
  late StreamSubscription _mediaIntentSub;
  // _textIntentSub 제거 (MethodChannel만 사용 시)

  final void Function(String type, List<SharedMediaFile> files, String text)
  onDataReceived;

  SharedIntentHandler({required this.onDataReceived});

  void init() {
    platform.setMethodCallHandler(_handleMethod);

    // 파일 공유 리스너
    _mediaIntentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
      (files) => _processSharedData('file', files: files),
      onError: (err) => print('파일 스트림 오류: $err'),
    );

    // 초기 파일 공유 처리
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) _processSharedData('file', files: files);
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'processText') {
      _processSharedData('text', text: call.arguments); // 타입을 'text'로 통일
    }
    return null;
  }

  Future<void> _processSharedData(
    String type, {
    List<SharedMediaFile>? files,
    String? text,
  }) async {
    final sharedData = SharedData(
      type: type,
      filePaths: files?.map((f) => f.path).toList() ?? [],
      text: text ?? '',
      timestamp: DateTime.now(),
    );

    await LocalStorage.saveData(sharedData);
    onDataReceived(type, files ?? [], text ?? '');
  }

  void dispose() {
    _mediaIntentSub.cancel();
  }
}
