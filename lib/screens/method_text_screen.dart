import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelTextScreen extends StatelessWidget {
  final String text;

  const MethodChannelTextScreen({required this.text});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Method Channel 텍스트',
          style: TextStyle(fontSize: width * 0.05),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        toolbarHeight: height * 0.08,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Method Channel로 전달받은 텍스트',
              style: TextStyle(
                fontSize: width * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.03),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (text.isEmpty)
                      Text(
                        '텍스트가 없습니다',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Colors.grey[600],
                        ),
                      )
                    else
                      Text(text, style: TextStyle(fontSize: width * 0.048)),
                    SizedBox(height: height * 0.02),
                    if (text.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            icon: Icon(Icons.copy, size: width * 0.06),
                            label: Text(
                              '복사',
                              style: TextStyle(fontSize: width * 0.04),
                            ),
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
