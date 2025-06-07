import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  // API 키를 직접 하드코딩
  static const String _apiKey = 'ENV.GEMINI_API_KEY';

  GeminiService() {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 정의되지 않았습니다.');
    }

    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<String> ask(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '답변을 받지 못했습니다.';
  }
}
