// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// class MarkdownResultCard extends StatelessWidget {
//   final String markdownText;
//   final Widget? bottomWidget;

//   const MarkdownResultCard({
//     super.key,
//     required this.markdownText,
//     this.bottomWidget,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color(0xFFE3F2FD), // 이미지의 가장 연한 파란색
//       margin: const EdgeInsets.only(top: 16, bottom: 8),
//       elevation: 2.5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: const Color(0xFFBBDEFB),
//           width: 0.5,
//         ), // 두 번째 파란색
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(22),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             MarkdownBody(
//               data: markdownText,
//               styleSheet: MarkdownStyleSheet(
//                 h1: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1976D2), // 네 번째 파란색
//                   height: 1.4,
//                 ),
//                 h2: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2196F3), // 세 번째 파란색
//                   height: 1.4,
//                 ),
//                 p: const TextStyle(
//                   fontSize: 15,
//                   height: 1.5,
//                   color: Color(0xFF212121),
//                 ),
//                 tableHead: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 16,
//                   color: Color(0xFF1565C0), // 가장 진한 파란색
//                 ),
//                 tableBorder: TableBorder.all(
//                   color: const Color(0xFFBBDEFB), // 두 번째 파란색
//                   width: 1.0,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 tableBody: const TextStyle(
//                   fontSize: 14,
//                   color: Color(0xFF212121),
//                   height: 1.3,
//                 ),
//                 tableCellsPadding: const EdgeInsets.symmetric(
//                   vertical: 10,
//                   horizontal: 12,
//                 ),
//                 tableHeadAlign: TextAlign.center,
//                 blockSpacing: 16.0,
//                 listBullet: const TextStyle(
//                   color: Color(0xFF2196F3), // 세 번째 파란색
//                   fontSize: 16,
//                 ),
//                 strong: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF1565C0), // 가장 진한 파란색
//                 ),
//                 em: const TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Color(0xFF1976D2), // 네 번째 파란색
//                 ),
//               ),
//             ),
//             if (bottomWidget != null) ...[
//               const SizedBox(height: 24),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border(
//                     top: BorderSide(
//                       color: const Color(0xFFBBDEFB), // 두 번째 파란색
//                       width: 1.0,
//                     ),
//                   ),
//                 ),
//                 padding: const EdgeInsets.only(top: 16),
//                 child: bottomWidget!,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownResultCard extends StatelessWidget {
  final String markdownText;
  final Widget? bottomWidget;

  const MarkdownResultCard({
    super.key,
    required this.markdownText,
    this.bottomWidget,
  });

  // HTML 태그를 마크다운으로 변환하는 함수
  String _processHtmlTags(String text) {
    // <span style="font-style:italic"> 태그를 마크다운 이탤릭으로 변환
    var processed = text.replaceAllMapped(
      RegExp(r'<span style="font-style:italic">(.*?)</span>', dotAll: true),
      (match) => '*${match.group(1)}*',
    );

    // <strong> 태그를 마크다운 볼드로 변환
    processed = processed.replaceAllMapped(
      RegExp(r'<strong>(.*?)</strong>', dotAll: true),
      (match) => '**${match.group(1)}**',
    );

    // <em> 태그를 마크다운 이탤릭으로 변환
    processed = processed.replaceAllMapped(
      RegExp(r'<em>(.*?)</em>', dotAll: true),
      (match) => '*${match.group(1)}*',
    );

    // <br> 태그를 줄바꿈으로 변환
    processed = processed.replaceAll('<br>', '\n');

    // 테이블 내 줄바꿈 정리
    processed = processed.replaceAll(RegExp(r'\|\s*\n\s*\|'), '|\n|');

    return processed;
  }

  @override
  Widget build(BuildContext context) {
    // HTML 태그를 마크다운으로 변환
    final processedText = _processHtmlTags(markdownText);

    return Card(
      color: const Color(0xFFE3F2FD), // 이미지의 가장 연한 파란색
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      elevation: 2.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFBBDEFB),
          width: 0.5,
        ), // 두 번째 파란색
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MarkdownBody(
              data: processedText,
              selectable: true, // 텍스트 선택 가능하도록
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2), // 네 번째 파란색
                  height: 1.4,
                ),
                h2: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2196F3), // 세 번째 파란색
                  height: 1.4,
                ),
                p: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF212121),
                ),
                tableHead: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1565C0), // 가장 진한 파란색
                ),
                tableBorder: TableBorder.all(
                  color: const Color(0xFFBBDEFB), // 두 번째 파란색
                  width: 1.0,
                  borderRadius: BorderRadius.circular(4),
                ),
                tableBody: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF212121),
                  height: 1.3,
                ),
                tableCellsPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                tableHeadAlign: TextAlign.center,
                blockSpacing: 16.0,
                listBullet: const TextStyle(
                  color: Color(0xFF2196F3), // 세 번째 파란색
                  fontSize: 16,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1565C0), // 가장 진한 파란색
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF1976D2), // 네 번째 파란색
                ),
              ),
            ),
            if (bottomWidget != null) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFBBDEFB), // 두 번째 파란색
                      width: 1.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(top: 16),
                child: bottomWidget!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
