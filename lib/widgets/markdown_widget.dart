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
  final bool isVocabResult;

  const MarkdownResultCard({
    super.key,
    required this.markdownText,
    this.bottomWidget,
    this.isVocabResult = false,
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

  // 테이블 형식을 번호 목록 형식으로 변환 (필요한 경우)
  String _convertTableToNumberedList(String text) {
    // 테이블 형식인지 확인
    if (text.contains('| Word | Definition') || text.contains('| 단어 | 뜻')) {
      final lines = text.split('\n');
      final result = <String>[];
      int itemCount = 0;

      // 헤더와 구분선 건너뛰기
      bool headerPassed = false;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];

        // 테이블 헤더와 구분선 건너뛰기
        if (line.contains('| Word |') ||
            line.contains('| 단어 |') ||
            line.contains('|---')) {
          headerPassed = true;
          continue;
        }

        // 테이블 행 처리
        if (headerPassed &&
            line.trim().startsWith('|') &&
            line.trim().endsWith('|')) {
          // 테이블 셀 추출
          final cells = line.split('|');
          if (cells.length >= 3) {
            itemCount++;
            final word = cells[1].trim();
            final definition = cells[2].trim();

            // 번호 목록 형식으로 변환
            result.add('$itemCount. **$word**: $definition');
          }
        } else if (!line.trim().startsWith('|')) {
          // 테이블이 아닌 일반 텍스트는 그대로 추가
          result.add(line);
        }
      }

      return result.join('\n\n');
    }

    // 테이블 형식이 아니면 원본 반환
    return text;
  }

  @override
  Widget build(BuildContext context) {
    // HTML 태그를 마크다운으로 변환하고 필요시 테이블을 번호 목록으로 변환
    var processedText = _processHtmlTags(markdownText);

    // 어휘 결과일 때만 번호 목록 형식으로 변환
    if (isVocabResult) {
      processedText = _convertTableToNumberedList(processedText);
    }

    return Card(
      color: const Color(0xFFE3F2FD),
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      elevation: 2.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFFBBDEFB), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조정
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 마크다운 내용을 Expanded와 함께 사용하여 가능한 공간 차지
            Flexible(
              child: MarkdownBody(
                data: processedText,
                selectable: true,
                shrinkWrap: true, // 내용에 맞게 크기 조정
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                    height: 1.4,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
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
                    color: Color(0xFF1565C0),
                  ),
                  tableBorder: TableBorder.all(
                    color: const Color(0xFFBBDEFB),
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
                  blockSpacing: 20.0,
                  listIndent: 20.0,
                  listBullet: const TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                    fontSize: 16,
                  ),
                  em: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF1976D2),
                    fontSize: 15,
                  ),
                  orderedListAlign: WrapAlignment.start,
                  unorderedListAlign: WrapAlignment.start,
                  textAlign: WrapAlignment.start,
                ),
              ),
            ),
            // 하단 위젯이 있을 경우 표시 (항상 표시됨)
            if (bottomWidget != null) ...[
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: const Color(0xFFBBDEFB), width: 1.0),
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
