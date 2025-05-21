import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class WrongNoteScreen extends StatelessWidget {
  const WrongNoteScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchWrongNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final dbRef = FirebaseDatabase.instance.ref(
      'users/6aXZoouLskON99JvBbqflAZXy5u1/wrongNote',
    );
    final snapshot = await dbRef.get();

    if (!snapshot.exists) return [];

    List<Map<String, dynamic>> notes = [];
    for (final child in snapshot.children) {
      final value = child.value as Map<dynamic, dynamic>;
      notes.add({
        'id': child.key,
        ...value.map((k, v) => MapEntry(k.toString(), v)),
      });
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오답노트')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchWrongNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('오답노트를 불러올 수 없습니다.'));
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
              final corrections =
                  (note['corrections'] as List<dynamic>?)
                      ?.map((c) => c.toString())
                      .toList();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오답노트 ID: ${note['id']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (note['analyzedAt'] != null)
                        Text('분석일: ${note['analyzedAt']}'),
                      if (note['score'] != null) Text('점수: ${note['score']}'),
                      if (note['previousCefrLevel'] != null &&
                          note['newCefrLevel'] != null)
                        Text(
                          '레벨 변화: ${note['previousCefrLevel']} → ${note['newCefrLevel']}',
                        ),
                      const SizedBox(height: 8),
                      if (messages != null && messages.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '메시지:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            ...messages.map((msg) => Text('- $msg')),
                          ],
                        ),
                      if (corrections != null && corrections.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              '수정 사항:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            ...corrections.map((cor) => Text('- $cor')),
                          ],
                        ),
                      if (note['summary'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '요약: ${note['summary']}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ],
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
