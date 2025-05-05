// 메소드 채널 텍스트 화면 (네이티브 코드에서 전달된 텍스트용)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelTextScreen extends StatelessWidget {
  final String text;

  const MethodChannelTextScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Method Channel 텍스트'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Method Channel로 전달받은 텍스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isEmpty)
                      Text(
                        '텍스트가 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      )
                    else
                      Text(text, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 16),
                    if (text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.copy),
                            label: Text('복사'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('클립보드에 복사되었습니다')),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
