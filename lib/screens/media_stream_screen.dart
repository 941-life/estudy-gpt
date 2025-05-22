import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MediaStreamScreen extends StatelessWidget {
  final List<SharedMediaFile> files;

  const MediaStreamScreen({required this.files});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('실행 중 공유 파일', style: TextStyle(fontSize: width * 0.05)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        toolbarHeight: height * 0.08,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앱이 실행 중일 때 공유받은 파일',
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.02),
            if (files.isEmpty)
              Center(
                child: Text(
                  '공유된 파일이 없습니다',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Colors.grey[600],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: height * 0.015),
                      child: ListTile(
                        leading: Icon(
                          _getIconForFile(file),
                          size: width * 0.08,
                        ),
                        title: Text(
                          file.path.split('/').last,
                          style: TextStyle(fontSize: width * 0.045),
                        ),
                        subtitle: Text(
                          file.type.toString().split('.').last,
                          style: TextStyle(fontSize: width * 0.035),
                        ),
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
