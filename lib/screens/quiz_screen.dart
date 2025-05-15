import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, String>> vocabList;

  const QuizScreen({super.key, required this.vocabList});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<TextEditingController> _controllers = [];
  final List<bool?> _isCorrect = [];
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _controllers.addAll(
      List.generate(widget.vocabList.length, (_) => TextEditingController()),
    );
    _isCorrect.addAll(List.generate(widget.vocabList.length, (_) => null));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkAnswer(int index) {
    final userAnswer = _controllers[index].text.trim().toLowerCase();
    final correct = widget.vocabList[index]['vocab']!.toLowerCase();
    setState(() {
      _isCorrect[index] = userAnswer == correct;
      _score = _isCorrect.where((v) => v == true).length;
    });
  }

  void _showAllResult() {
    setState(() {
      _showResult = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      for (final c in _controllers) {
        c.clear();
      }
      for (int i = 0; i < _isCorrect.length; i++) {
        _isCorrect[i] = null;
      }
      _score = 0;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
        actions: [
          if (!_showResult)
            TextButton(
              onPressed: _showAllResult,
              child: const Text('결과 보기', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body:
          _showResult
              ? _buildResultScreen()
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: widget.vocabList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) => _buildQuizCard(index),
              ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildQuizCard(int index) {
    final item = widget.vocabList[index];
    final isAnswered = _isCorrect[index] != null;
    final isCorrect = _isCorrect[index] == true;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['definition'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.edit_note, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['example'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    enabled: !isAnswered,
                    decoration: InputDecoration(
                      labelText: '정답을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          isAnswered
                              ? (isCorrect ? Colors.green[50] : Colors.red[50])
                              : Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isAnswered ? null : () => _checkAnswer(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAnswered
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isAnswered ? (isCorrect ? '정답' : '오답') : '정답 보기'),
                ),
              ],
            ),
            if (isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '정답: ${item['vocab']}',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _score == widget.vocabList.length
                  ? Icons.emoji_events
                  : Icons.school,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 24),
            Text(
              '퀴즈 완료!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '정답: $_score / ${widget.vocabList.length}',
              style: const TextStyle(fontSize: 20, color: Colors.blueAccent),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _resetQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 풀기'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
