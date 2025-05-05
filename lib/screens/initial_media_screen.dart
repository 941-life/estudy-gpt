import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class InitialMediaScreen extends StatelessWidget {
  final List<SharedMediaFile> files;

  const InitialMediaScreen({required this.files});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('초기 공유 파일'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 종료됐다가 실행될 때 공유받은 파일',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (files.isEmpty)
              Center(
                child: Text(
                  '공유된 파일이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(_getIconForFile(file)),
                        title: Text(file.path.split('/').last),
                        subtitle: Text(file.type.toString().split('.').last),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFile(SharedMediaFile file) {
    final type = file.type.toString().toLowerCase();
    if (type.contains('image')) return Icons.image;
    if (type.contains('video')) return Icons.video_file;
    if (type.contains('audio')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }
}
