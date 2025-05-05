// import 'package:flutter/material.dart';
// import 'package:estudy_gpt/models/shared_data.dart';
// import 'package:intl/intl.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:estudy_gpt/utils/local_storage.dart';

// class PersonalScreen extends StatefulWidget {
//   final String sharingType;
//   final List<SharedMediaFile> sharedFiles;
//   final String sharedText;

//   const PersonalScreen({
//     super.key,
//     required this.sharingType,
//     required this.sharedFiles,
//     required this.sharedText,
//   });

//   @override
//   State<PersonalScreen> createState() => _PersonalScreenState();
// }

// class _PersonalScreenState extends State<PersonalScreen> {
//   List<SharedData> _history = [];
//   bool _showHistory = false;

//   Future<void> _loadHistory() async {
//     final history = await LocalStorage.loadData();
//     setState(() {
//       _history = history.reversed.toList(); // 최신순 정렬
//       _showHistory = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _showHistory ? _buildHistoryScreen() : _buildMainScreen();
//   }

//   Widget _buildMainScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('개인 화면'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: _loadHistory,
//             tooltip: '히스토리 보기',
//           ),
//         ],
//       ),
//       body: _buildCurrentContent(),
//     );
//   }

//   Widget _buildHistoryScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('공유 히스토리'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => setState(() => _showHistory = false),
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: _history.length,
//         itemBuilder: (ctx, index) => _buildHistoryItem(_history[index]),
//       ),
//     );
//   }

//   Widget _buildCurrentContent() {
//     if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(widget.sharedText),
//       );
//     } else if ((widget.sharingType == 'file' ||
//             widget.sharingType == 'media_stream' ||
//             widget.sharingType == 'initial_media') &&
//         widget.sharedFiles.isNotEmpty) {
//       return ListView.builder(
//         itemCount: widget.sharedFiles.length,
//         itemBuilder:
//             (ctx, i) => ListTile(title: Text(widget.sharedFiles[i].path)),
//       );
//     }
//     return const Center(child: Text('공유된 내용이 없습니다'));
//   }

//   Widget _buildHistoryItem(SharedData data) {
//     return ListTile(
//       leading: Icon(data.type == 'text' ? Icons.text_snippet : Icons.file_copy),
//       title:
//           data.type == 'text'
//               ? Text(data.text.isNotEmpty ? data.text : "텍스트 없음")
//               : Text('${data.filePaths.length}개의 파일'),
//       subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp)),
//     );
//   }

//   String _getPreview(SharedData data) {
//     return data.type == 'text'
//         ? (data.text.isNotEmpty
//             ? '${data.text.substring(0, 20)}...'
//             : '텍스트 내용 없음')
//         : '${data.filePaths.length}개의 파일';
//   }

//   void _showDetailDialog(SharedData data) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('상세 정보'),
//             content:
//                 data.type == 'text'
//                     ? SingleChildScrollView(child: Text(data.text))
//                     : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children:
//                           data.filePaths
//                               .map((path) => Text('• $path'))
//                               .toList(),
//                     ),
//           ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:estudy_gpt/models/shared_data.dart';
import 'package:intl/intl.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:estudy_gpt/utils/local_storage.dart';

class PersonalScreen extends StatefulWidget {
  final String sharingType;
  final List<SharedMediaFile> sharedFiles;
  final String sharedText;

  const PersonalScreen({
    super.key,
    required this.sharingType,
    required this.sharedFiles,
    required this.sharedText,
  });

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  List<SharedData> _history = [];
  bool _showHistory = false;

  Future<void> _loadHistory() async {
    final history = await LocalStorage.loadData();
    setState(() {
      _history = history.reversed.toList(); // 최신 항목이 위로
      _showHistory = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showHistory ? _buildHistoryScreen() : _buildMainScreen();
  }

  Widget _buildMainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인 화면'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _loadHistory,
            tooltip: '히스토리 보기',
          ),
        ],
      ),
      body: _buildCurrentContent(),
    );
  }

  Widget _buildHistoryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공유 기록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showHistory = false),
        ),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (ctx, index) => _buildHistoryItem(_history[index]),
      ),
    );
  }

  Widget _buildCurrentContent() {
    // 1. 텍스트 공유 처리
    if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(widget.sharedText, style: const TextStyle(fontSize: 18)),
      );
    }

    // 2. 파일 공유 처리
    if ((widget.sharingType == 'file' ||
            widget.sharingType == 'media_stream' ||
            widget.sharingType == 'initial_media') &&
        widget.sharedFiles.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.sharedFiles.length,
        itemBuilder:
            (ctx, i) => ListTile(title: Text(widget.sharedFiles[i].path)),
      );
    }

    // 3. 공유 데이터 없음
    return const Center(
      child: Text(
        '공유된 내용이 없습니다',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildHistoryItem(SharedData data) {
    return ListTile(
      leading: Icon(
        data.type == 'text' ? Icons.text_snippet : Icons.file_copy,
        color: Colors.blue,
      ),
      title: Text(
        _getPreview(data),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp),
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () => _showDetailDialog(context, data),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteItem(data),
      ),
    );
  }

  String _getPreview(SharedData data) {
    if (data.type == 'text') {
      return data.text.isNotEmpty
          ? (data.text.length > 20
              ? '${data.text.substring(0, 20)}...'
              : data.text)
          : '텍스트 없음';
    } else {
      return data.filePaths.isNotEmpty
          ? '${data.filePaths.length}개의 파일'
          : '파일 없음';
    }
  }

  void _showDetailDialog(BuildContext context, SharedData data) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('상세 정보'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
              child:
                  data.type == 'text'
                      ? SingleChildScrollView(child: Text(data.text))
                      : ListView(
                        shrinkWrap: true,
                        children:
                            data.filePaths
                                .map(
                                  (path) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '• ${path.split('/').last}', // 파일명만 표시
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteItem(SharedData data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('이 항목을 정말 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제'),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      final newHistory = _history.where((item) => item != data).toList();
      await LocalStorage.saveAllData(newHistory);
      setState(() => _history = newHistory);
    }
  }
}
