// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';

// class WrongNoteScreen extends StatelessWidget {
//   const WrongNoteScreen({super.key});

//   Future<List<Map<String, dynamic>>> _fetchWrongNotes() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return [];
//     //  final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/wrongNote');

//     final dbRef = FirebaseDatabase.instance.ref(
//       'users/6aXZoouLskON99JvBbqflAZXy5u1/wrongNote',
//     );
//     final snapshot = await dbRef.get();

//     if (!snapshot.exists) return [];

//     List<Map<String, dynamic>> notes = [];
//     for (final child in snapshot.children) {
//       final value = child.value;
//       if (value is Map<dynamic, dynamic>) {
//         notes.add({
//           'id': child.key,
//           ...value.map((k, v) => MapEntry(k.toString(), v)),
//         });
//       }
//     }
//     return notes;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('오답노트')),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _fetchWrongNotes(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('오답노트를 불러올 수 없습니다.\n${snapshot.error}'));
//           }
//           final notes = snapshot.data ?? [];
//           if (notes.isEmpty) {
//             return const Center(child: Text('저장된 오답노트가 없습니다.'));
//           }
//           return ListView.builder(
//             itemCount: notes.length,
//             itemBuilder: (context, idx) {
//               final note = notes[idx];
//               final messages =
//                   (note['messages'] as List<dynamic>?)
//                       ?.map((m) => m['content']?.toString() ?? '')
//                       .toList();
//               final corrections = note['corrections'] as List<dynamic>?;

//               return Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(18.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 상단 뱃지 영역
//                       Row(
//                         children: [
//                           if (note['previousCefrLevel'] != null &&
//                               note['newCefrLevel'] != null)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               margin: const EdgeInsets.only(right: 8),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '레벨: ${note['previousCefrLevel']} → ${note['newCefrLevel']}',
//                                 style: const TextStyle(
//                                   color: Colors.blue,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if (note['score'] != null)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               margin: const EdgeInsets.only(right: 8),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.shade50,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '점수: ${note['score']}',
//                                 style: const TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           if (note['analyzedAt'] != null)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade200,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 '분석일: ${(note['analyzedAt'] as String).split("T").first}',
//                                 style: const TextStyle(
//                                   color: Colors.black54,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       // 수정 사항 영역
//                       if (corrections != null && corrections.isNotEmpty)
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.orange.shade50,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(10),
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 '수정 사항',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                   color: Colors.deepOrange,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               ...corrections.map((cor) {
//                                 if (cor is Map) {
//                                   return Container(
//                                     margin: const EdgeInsets.only(bottom: 8),
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(8),
//                                       border: Border.all(
//                                         color: Colors.orange.shade200,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             const Text(
//                                               '원본: ',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                             Text(
//                                               cor['original']?.toString() ?? '',
//                                               style: const TextStyle(
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             const Text(
//                                               '수정: ',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.green,
//                                               ),
//                                             ),
//                                             Text(
//                                               cor['corrected']?.toString() ??
//                                                   '',
//                                               style: const TextStyle(
//                                                 color: Colors.green,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         if (cor['explanation'] != null)
//                                           Padding(
//                                             padding: const EdgeInsets.only(
//                                               top: 4,
//                                             ),
//                                             child: Row(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 const Icon(
//                                                   Icons.info_outline,
//                                                   size: 16,
//                                                   color: Colors.orange,
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Expanded(
//                                                   child: Text(
//                                                     cor['explanation']
//                                                         .toString(),
//                                                     style: const TextStyle(
//                                                       color: Colors.orange,
//                                                       fontSize: 13,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   );
//                                 } else {
//                                   // fallback for string or other type
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 2,
//                                     ),
//                                     child: Text('• $cor'),
//                                   );
//                                 }
//                               }).toList(),
//                             ],
//                           ),
//                         ),
//                       // 요약 영역
//                       if (note['summary'] != null)
//                         Container(
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: Colors.yellow.shade100,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           padding: const EdgeInsets.all(12),
//                           margin: const EdgeInsets.only(top: 4),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Icon(
//                                 Icons.lightbulb,
//                                 color: Colors.amber,
//                                 size: 22,
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   note['summary'],
//                                   style: const TextStyle(
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       // 오답노트 ID (작게)
//                       Align(
//                         alignment: Alignment.bottomRight,
//                         child: Text(
//                           'ID: ${note['id']}',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WrongNoteScreen extends StatelessWidget {
  const WrongNoteScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchWrongNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    //  final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/wrongNote');

    final dbRef = FirebaseDatabase.instance.ref(
      'users/6aXZoouLskON99JvBbqflAZXy5u1/wrongNote',
    );
    final snapshot = await dbRef.get();

    if (!snapshot.exists) return [];

    List<Map<String, dynamic>> notes = [];
    for (final child in snapshot.children) {
      final value = child.value;
      if (value is Map<dynamic, dynamic>) {
        notes.add({
          'id': child.key,
          ...value.map((k, v) => MapEntry(k.toString(), v)),
        });
      }
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchWrongNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오답노트를 불러올 수 없습니다.\n${snapshot.error}'));
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('저장된 오답노트가 없습니다.'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, idx) {
              final note = notes[idx];
              final messages =
                  (note['messages'] as List<dynamic>?)
                      ?.map((m) => m['content']?.toString() ?? '')
                      .toList();
              final corrections = note['corrections'] as List<dynamic>?;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.012,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.045),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: height * 0.6, // 카드 최대 높이 제한
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.045),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상단 뱃지 영역
                          Row(
                            children: [
                              if (note['previousCefrLevel'] != null &&
                                  note['newCefrLevel'] != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.025,
                                    vertical: height * 0.008,
                                  ),
                                  margin: EdgeInsets.only(right: width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.03,
                                    ),
                                  ),
                                  child: Text(
                                    '레벨: ${note['previousCefrLevel']} → ${note['newCefrLevel']}',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                ),
                              if (note['score'] != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.025,
                                    vertical: height * 0.008,
                                  ),
                                  margin: EdgeInsets.only(right: width * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.03,
                                    ),
                                  ),
                                  child: Text(
                                    '점수: ${note['score']}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.035,
                                    ),
                                  ),
                                ),
                              if (note['analyzedAt'] != null)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.025,
                                    vertical: height * 0.008,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.03,
                                    ),
                                  ),
                                  child: Text(
                                    '분석일: ${(note['analyzedAt'] as String).split("T").first}',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: width * 0.032,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: height * 0.012),
                          // 수정 사항 영역
                          if (corrections != null && corrections.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(
                                  width * 0.025,
                                ),
                              ),
                              padding: EdgeInsets.all(width * 0.025),
                              margin: EdgeInsets.only(bottom: height * 0.01),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '수정 사항',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: width * 0.042,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.008),
                                  ...corrections.map((cor) {
                                    if (cor is Map) {
                                      return Container(
                                        margin: EdgeInsets.only(
                                          bottom: height * 0.01,
                                        ),
                                        padding: EdgeInsets.all(width * 0.025),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            width * 0.02,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  '원본: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                    fontSize: width * 0.038,
                                                  ),
                                                ),
                                                Text(
                                                  cor['original']?.toString() ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: width * 0.038,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '수정: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                    fontSize: width * 0.038,
                                                  ),
                                                ),
                                                Text(
                                                  cor['corrected']
                                                          ?.toString() ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: width * 0.038,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (cor['explanation'] != null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: height * 0.004,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      size: width * 0.045,
                                                      color: Colors.orange,
                                                    ),
                                                    SizedBox(
                                                      width: width * 0.01,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        cor['explanation']
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontSize:
                                                              width * 0.034,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // fallback for string or other type
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: height * 0.004,
                                        ),
                                        child: Text(
                                          '• $cor',
                                          style: TextStyle(
                                            fontSize: width * 0.035,
                                          ),
                                        ),
                                      );
                                    }
                                  }).toList(),
                                ],
                              ),
                            ),
                          // 요약 영역
                          if (note['summary'] != null)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade100,
                                borderRadius: BorderRadius.circular(
                                  width * 0.025,
                                ),
                              ),
                              padding: EdgeInsets.all(width * 0.03),
                              margin: EdgeInsets.only(top: height * 0.006),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.amber,
                                    size: width * 0.06,
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Text(
                                      note['summary'],
                                      style: TextStyle(
                                        fontSize: width * 0.042,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 오답노트 ID (작게)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              'ID: ${note['id']}',
                              style: TextStyle(
                                fontSize: width * 0.03,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
