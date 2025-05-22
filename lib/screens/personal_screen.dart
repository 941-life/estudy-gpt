import 'dart:io';
import 'package:estudy_gpt/widgets/markdown_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:estudy_gpt/models/shared_data.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:estudy_gpt/services/gemini_service.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PersonalScreen extends StatefulWidget {
  final String sharingType;
  final List<SharedMediaFile> sharedFiles;
  final String sharedText;

  const PersonalScreen({
    super.key,
    required this.sharingType,
    required this.sharedFiles,
    required this.sharedText,
  });

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

enum LangOption { vocab, grammar, examples, dialogue, other }

enum ContentType { text, document, unknown }

class _PersonalScreenState extends State<PersonalScreen> {
  final GeminiService _geminiService = GeminiService();
  List<SharedData> _history = [];
  bool _showHistory = false;
  bool _isLoading = false;
  String? _result;
  LangOption? _selectedOption;
  final TextEditingController _otherController = TextEditingController();
  List<Map<String, String>> _parsedVocabList = [];
  String _detectedLang = 'en';
  ContentType _contentType = ContentType.unknown;
  String _extractedText = '';
  String? _documentPath;
  bool _isProcessingFile = false;
  String _userLevel = 'A1';

  @override
  void initState() {
    super.initState();
    _determineContentType();
    _loadUserLevel();
  }

  void _determineContentType() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
        _contentType = ContentType.text;
        _extractedText = widget.sharedText;
        _detectedLang = _detectLang(_extractedText);
      } else if ((widget.sharingType == 'file' ||
              widget.sharingType == 'media_stream' ||
              widget.sharingType == 'initial_media') &&
          widget.sharedFiles.isNotEmpty) {
        final filePath = widget.sharedFiles.first.path;
        final extension = path.extension(filePath).toLowerCase();

        if (extension == '.pdf' ||
            extension == '.txt' ||
            extension == '.doc' ||
            extension == '.docx') {
          _contentType = ContentType.document;
          _documentPath = filePath;

          await _extractDocumentContent(filePath, extension);
        } else {
          _contentType = ContentType.unknown;
        }
      }
    } catch (e) {
      print('Error determining content type: $e');
      _contentType = ContentType.unknown;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserLevel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final dbRef = FirebaseDatabase.instance.ref('users/${user.uid}/cefrLevel');
    final snapshot = await dbRef.get();
    if (snapshot.exists && snapshot.value is String) {
      setState(() {
        _userLevel = snapshot.value as String;
      });
    }
  }

  Future<void> _extractDocumentContent(
    String filePath,
    String extension,
  ) async {
    setState(() {
      _isProcessingFile = true;
    });

    try {
      if (extension == '.txt') {
        final file = File(filePath);
        _extractedText = await file.readAsString();
        _detectedLang = _detectLang(_extractedText);
      } else if (extension == '.pdf') {
        _documentPath = filePath;

        final bytes = await File(filePath).readAsBytes();
        final document = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(document);
        _extractedText = extractor.extractText();
        document.dispose();

        _detectedLang = _detectLang(_extractedText);
      } else {
        _documentPath = filePath;
        _extractedText = "문서 파일에서 추출된 텍스트입니다. 실제 앱에서는 문서 텍스트 추출 라이브러리를 사용하세요.";
        _detectedLang = 'ko';
      }
    } catch (e) {
      print('Error extracting document content: $e');
      _extractedText = "파일 내용을 추출하는 중 오류가 발생했습니다.";
      _detectedLang = 'ko';
    } finally {
      setState(() {
        _isProcessingFile = false;
      });
    }
  }

  String _detectLang(String text) {
    final korean = RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]');
    int koCount = korean.allMatches(text).length;
    int total = text.replaceAll(RegExp(r'\s'), '').length;
    if (total == 0) return 'en';
    double ratio = koCount / total;
    return ratio > 0.3 ? 'ko' : 'en';
  }

  final Map<String, Map<LangOption, Map<String, String>>> optionLabels = {
    'en': {
      LangOption.vocab: {
        'label': 'Extract Key Vocabulary',
        'desc': 'Get important words/phrases with definitions and examples.',
      },
      LangOption.grammar: {
        'label': 'Explain Grammar',
        'desc': 'Describe main grammar points with examples.',
      },
      LangOption.examples: {
        'label': 'Make Example Sentences',
        'desc': 'Create new sentences using important words/phrases.',
      },
      LangOption.dialogue: {
        'label': 'Practice Conversation',
        'desc': 'Generate a short dialogue based on your text.',
      },
      LangOption.other: {
        'label': 'Other',
        'desc': 'Custom request (type below)',
      },
    },
    'ko': {
      LangOption.vocab: {
        'label': '주요 단어/표현 뽑기',
        'desc': '중요한 단어/표현과 뜻, 예문을 받아보세요.',
      },
      LangOption.grammar: {
        'label': '문법 설명해줘',
        'desc': '주요 문법 포인트를 예시와 함께 설명해줍니다.',
      },
      LangOption.examples: {
        'label': '예문 만들어줘',
        'desc': '중요 단어/표현으로 새로운 예문을 만들어줍니다.',
      },
      LangOption.dialogue: {'label': '회화 연습', 'desc': '해당 주제로 짧은 회화문을 만들어줍니다.'},
      LangOption.other: {'label': '기타 요청', 'desc': '직접 요청을 입력하세요.'},
    },
  };

  final Map<String, Map<LangOption, String Function(String, String)>>
  promptTemplates = {
    'en': {
      LangOption.vocab:
          (text, level) =>
              'Extract key vocabulary and expressions from the following text. Please answer at the $level level (CEFR). Format your response as a numbered list (not a table). For each item, include: 1) the word or phrase in bold with its meaning in parentheses, 2) an example of usage in italics, and 3) a brief explanation. Example format:\n\n1. **Word** ("meaning"): *"example sentence..."* Explanation of usage and context.\n\n2. **Another word** ("meaning"): *"example sentence..."* Explanation of usage and context.\n\nText: $text',

      LangOption.grammar:
          (text, level) =>
              'Identify and explain 3-5 key grammar points used in the following text. Please answer at the $level level (CEFR). Format your response as a numbered list. For each grammar point: 1) Name the grammar structure in bold, 2) Explain when and how to use it, 3) Show examples from the text in italics, 4) Provide 2 additional example sentences, and 5) Include common mistakes to avoid. Use clear, simple language suitable for $level level English learners.\n\nExample format:\n\n1. **Present Perfect Continuous**\n   - **Usage**: To talk about actions that started in the past and continue until now, often emphasizing duration.\n   - **Example from text**: *"She has been studying English for three years."*\n   - **Additional examples**:\n     a) I have been waiting for you since 2 PM.\n     b) They have been working on this project all week.\n   - **Common mistakes**: Confusing it with simple present perfect; forgetting the auxiliary "been".\n\nText: $text',

      LangOption.examples:
          (text, level) =>
              'Select 5-7 important words or phrases from the following text. Please answer at the $level level (CEFR). For each word/phrase: 1) Show the word in bold, 2) Provide its part of speech and brief definition in parentheses, 3) Include the original sentence from the text in italics, and 4) Create 3 new example sentences using the word/phrase in different contexts, ranging from simple to more complex usage. Make sure the examples are natural and useful for a $level level English learner.\n\nExample format:\n\n1. **overcome** (verb, to succeed in dealing with a problem)\n   - *Original: "She overcame many challenges to reach her goal."*\n   - New examples:\n     a) It took me years to overcome my fear of heights.\n     b) The team had to overcome several obstacles before winning the championship.\n     c) With determination, you can overcome almost any difficulty you face in life.\n\nText: $text',

      LangOption.dialogue:
          (text, level) =>
              'Create a natural, conversational dialogue based on the following text. Please answer at the $level level (CEFR). The dialogue should:\n1) Include 3-4 question-answer pairs between two people (named A and B)\n2) Incorporate key vocabulary and themes from the text\n3) Be at $level level (CEFR) with appropriate vocabulary and grammar\n4) Include common conversational expressions and natural responses\n5) End with a logical conclusion\n\nFormat the dialogue clearly with names and line breaks. After the dialogue, include a "Language Notes" section that explains 3-4 useful expressions or grammar points used in the dialogue.\n\nExample format:\n\nA: [First question or statement]\nB: [Response, possibly with a follow-up question]\nA: [Response to B\'s question]\n...\n\nLanguage Notes:\n1. "[expression]" - explanation and how to use it\n2. "[grammar point]" - explanation with example\n\nText: $text',
    },

    'ko': {
      LangOption.vocab:
          (text, level) =>
              '아래 텍스트에서 주요 단어와 표현을 뽑아서 번호가 매겨진 목록으로 정리해줘. 이 결과는 $level 수준(CEFR) 학습자에게 맞춰 작성해줘. 각 항목은 1) 단어나 표현을 굵게 표시하고 괄호 안에 의미 표시, 2) 이탤릭체로 된 예문, 3) 간단한 설명을 포함해야 함. 예시 형식:\n\n1. **단어** ("의미"): *"예문..."* 사용법과 맥락에 대한 설명.\n\n2. **다른 단어** ("의미"): *"예문..."* 사용법과 맥락에 대한 설명.\n\n텍스트: $text',

      LangOption.grammar:
          (text, level) =>
              '아래 텍스트에서 사용된 주요 문법 포인트 3-5개를 찾아 설명해줘. 이 결과는 $level 수준(CEFR) 학습자에게 맞춰 작성해줘. 번호가 매겨진 목록 형식으로 작성하고, 각 문법 포인트마다: 1) 문법 구조 이름을 굵게 표시, 2) 언제, 어떻게 사용하는지 설명, 3) 텍스트에서 발췌한 예문을 이탤릭체로 표시, 4) 추가 예문 2개 제공, 5) 흔히 저지르는 실수 포함. $level 수준의 학습자가 이해할 수 있는 명확하고 간단한 언어로 설명해줘.\n\n예시 형식:\n\n1. **현재완료진행형**\n   - **용법**: 과거에 시작해서 현재까지 계속되는 행동을 표현할 때 사용하며, 주로 기간을 강조함.\n   - **텍스트 속 예문**: *"그녀는 3년 동안 영어를 공부해오고 있다."*\n   - **추가 예문**:\n     a) 나는 오후 2시부터 너를 기다리고 있어.\n     b) 그들은 일주일 내내 이 프로젝트에 매달려 왔어.\n   - **흔한 실수**: 단순 현재완료와 혼동하거나, 조동사 "been"을 빼먹는 경우.\n\n텍스트: $text',

      LangOption.examples:
          (text, level) =>
              '아래 텍스트에서 중요한 단어나 표현 5-7개를 선택해줘. 이 결과는 $level 수준(CEFR) 학습자에게 맞춰 작성해줘. 각 단어/표현마다: 1) 단어를 굵게 표시, 2) 품사와 간단한 정의를 괄호 안에 표시, 3) 텍스트에서 사용된 원래 문장을 이탤릭체로 표시, 4) 다양한 맥락에서 해당 단어/표현을 사용한 새로운 예문 3개를 제공(간단한 것부터 복잡한 것까지). 예문은 자연스럽고 $level 수준의 학습자에게 유용해야 함.\n\n예시 형식:\n\n1. **극복하다** (동사, 문제를 해결하는 데 성공하다)\n   - *원문: "그녀는 목표에 도달하기 위해 많은 도전을 극복했다."*\n   - 새로운 예문:\n     a) 나는 고소공포증을 극복하는 데 몇 년이 걸렸다.\n     b) 팀은 우승하기 전에 여러 장애물을 극복해야 했다.\n     c) 결심만 있다면, 인생에서 마주하는 거의 모든 어려움을 극복할 수 있다.\n\n텍스트: $text',

      LangOption.dialogue:
          (text, level) =>
              '아래 텍스트를 바탕으로 자연스러운 대화를 만들어줘. 이 결과는 $level 수준(CEFR) 학습자에게 맞춰 작성해줘. 대화는 다음 조건을 충족해야 함:\n1) A와 B 두 사람 간의 질문-답변 3-4쌍 포함\n2) 텍스트의 주요 어휘와 주제 반영\n3) $level 수준(CEFR)으로, 약간 도전적인 어휘가 있되 맥락이 명확해야 함\n4) 일상적인 대화 표현과 자연스러운 응답 포함\n5) 논리적인 결론으로 마무리\n\n대화는 이름과 줄바꿈으로 명확하게 구분해줘. 대화 후에는 "언어 노트" 섹션을 추가하여 대화에서 사용된 유용한 표현이나 문법 포인트 3-4개를 설명해줘.\n\n예시 형식:\n\nA: [첫 번째 질문이나 발언]\nB: [응답, 가능하면 후속 질문 포함]\nA: [B의 질문에 대한 응답]\n...\n\n언어 노트:\n1. "[표현]" - 설명 및 사용법\n2. "[문법 포인트]" - 예시와 함께 설명\n\n텍스트: $text',
    },
  };

  final Map<String, String> instructionText = {
    'en': 'Choose a language learning task for this text.',
    'ko': '이 텍스트로 원하는 어학 학습 작업을 선택하세요.',
  };

  final Map<String, Map<String, String>> contentTypeLabels = {
    'en': {
      'text': 'Text Content',
      'document': 'Document Content',
      'unknown': 'Unknown Content',
    },
    'ko': {'text': '텍스트 내용', 'document': '문서 내용', 'unknown': '알 수 없는 내용'},
  };

  List<Map<String, String>> _parseVocabTable(String text) {
    final lines = text.split('\n');
    final List<Map<String, String>> result = [];
    bool headerPassed = false;
    for (final line in lines) {
      if (line.trim().startsWith('|')) {
        final cells = line.split('|').map((e) => e.trim()).toList();
        if (cells.length >= 4 && cells[1].isNotEmpty) {
          if (!headerPassed) {
            headerPassed = true;
            continue;
          }
          if (cells[1].toLowerCase() == 'vocab' || cells[1].startsWith('---'))
            continue;
          result.add({
            'vocab': cells[1],
            'definition': cells[2],
            'example': cells[3],
          });
        }
      }
    }
    return result;
  }

  Future<void> _handleOptionSubmit() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _parsedVocabList.clear();
    });

    String prompt = '';
    String text = _extractedText;
    String lang = _detectedLang;

    if (_selectedOption == null) {
      setState(() {
        _isLoading = false;
        _result = lang == 'ko' ? '옵션을 선택하세요.' : 'Please select an option.';
      });
      return;
    }

    if (_selectedOption == LangOption.other) {
      String otherText = _otherController.text.trim();
      if (otherText.isEmpty) {
        setState(() {
          _isLoading = false;
          _result =
              lang == 'ko' ? '요청 내용을 입력하세요.' : 'Please enter your request.';
        });
        return;
      }
      prompt = '$otherText\n\n$text';
    } else {
      prompt = promptTemplates[lang]![_selectedOption!]!(text, _userLevel);
    }

    try {
      final reply = await _geminiService.ask(prompt);
      setState(() {
        _result = reply;
        if (_selectedOption == LangOption.vocab) {
          _parsedVocabList = _parseVocabTable(reply);
        }
      });
    } catch (e) {
      setState(() {
        _result = (lang == 'ko' ? '오류 발생: ' : 'Error: ') + e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewPdf(String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(path.basename(filePath)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareFile(filePath),
                  ),
                ],
              ),
              body: PDFView(
                filePath: filePath,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: false,
                pageSnap: true,
                defaultPage: 0,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
              ),
            ),
      ),
    );
  }

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('파일 공유 중 오류가 발생했습니다: $e')));
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainScreen();
  }

  Widget _buildMainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _detectedLang == 'ko' ? '어학 학습 도우미' : 'Language Learning Helper',
        ),
      ),
      body:
          _isLoading && !_isProcessingFile
              ? const Center(child: CircularProgressIndicator())
              : _buildCurrentContent(),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildCurrentContent() {
    if (_isProcessingFile) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_contentType) {
      case ContentType.text:
        return _buildTextContent();
      case ContentType.document:
        return _buildDocumentContent();
      case ContentType.unknown:
      default:
        if (widget.sharedFiles.isNotEmpty) {
          return _buildUnsupportedFilesContent();
        } else {
          return Center(
            child: Text(
              _detectedLang == 'ko'
                  ? '공유된 내용이 없습니다'
                  : 'No shared content found.',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
    }
  }

  Widget _buildTextContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contentTypeLabels[_detectedLang]!['text']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Divider(),
                  Text(
                    _extractedText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            instructionText[_detectedLang] ?? instructionText['en']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 18),

          _buildLangLearningOptions(),

          if (_selectedOption == LangOption.other)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: TextField(
                controller: _otherController,
                decoration: InputDecoration(
                  labelText:
                      _detectedLang == 'ko'
                          ? '기타 요청을 입력하세요'
                          : 'Enter your custom request',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleOptionSubmit,
            icon: const Icon(Icons.send, size: 20),
            label: Text(
              _detectedLang == 'ko' ? '요청하기' : 'Submit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
          ),

          const SizedBox(height: 32),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_result != null)
            MarkdownResultCard(
              markdownText: _result!,
              isVocabResult: _selectedOption == LangOption.vocab,
              bottomWidget: null,
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contentTypeLabels[_detectedLang]!['document']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      if (_documentPath != null)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Colors.blue,
                              ),
                              onPressed: () => _viewPdf(_documentPath!),
                              tooltip:
                                  _detectedLang == 'ko'
                                      ? '문서 보기'
                                      : 'View Document',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share, color: Colors.blue),
                              onPressed: () => _shareFile(_documentPath!),
                              tooltip:
                                  _detectedLang == 'ko'
                                      ? '문서 공유'
                                      : 'Share Document',
                            ),
                          ],
                        ),
                    ],
                  ),
                  const Divider(),
                  if (_documentPath != null)
                    Text(
                      '${_detectedLang == 'ko' ? '파일명: ' : 'File: '}${path.basename(_documentPath!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            instructionText[_detectedLang] ?? instructionText['en']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 18),

          _buildLangLearningOptions(),

          if (_selectedOption == LangOption.other)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: TextField(
                controller: _otherController,
                decoration: InputDecoration(
                  labelText:
                      _detectedLang == 'ko'
                          ? '기타 요청을 입력하세요'
                          : 'Enter your custom request',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleOptionSubmit,
            icon: const Icon(Icons.send, size: 20),
            label: Text(
              _detectedLang == 'ko' ? '요청하기' : 'Submit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
            ),
          ),

          const SizedBox(height: 32),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          if (_result != null)
            MarkdownResultCard(
              markdownText: _result!,
              isVocabResult: _selectedOption == LangOption.vocab,
              bottomWidget: null,
            ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedFilesContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.sharedFiles.length,
      itemBuilder:
          (ctx, i) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.blue[400]),
              title: Text(
                widget.sharedFiles[i].path.split('/').last,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _detectedLang == 'ko'
                    ? '지원되지 않는 파일 형식입니다.'
                    : 'Unsupported file format.',
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.share, color: Colors.blue),
                onPressed: () => _shareFile(widget.sharedFiles[i].path),
              ),
            ),
          ),
    );
  }

  Widget _buildLangLearningOptions() {
    final labels = optionLabels[_detectedLang]!;
    final icons = {
      LangOption.vocab: Icons.language,
      LangOption.grammar: Icons.rule,
      LangOption.examples: Icons.edit_note,
      LangOption.dialogue: Icons.forum,
      LangOption.other: Icons.tune,
    };

    return Column(
      children:
          LangOption.values.map((option) {
            final isSelected = _selectedOption == option;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap:
                    () => setState(() {
                      _selectedOption = option;
                      if (option != LangOption.other) _otherController.clear();
                    }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[option],
                        color:
                            isSelected ? Colors.blueAccent : Colors.grey[600],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labels[option]!['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.blueAccent
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              labels[option]!['desc']!,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    isSelected
                                        ? Colors.blue[700]
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<LangOption>(
                        value: option,
                        groupValue: _selectedOption,
                        onChanged:
                            (val) => setState(() {
                              _selectedOption = val;
                              if (option != LangOption.other)
                                _otherController.clear();
                            }),
                        activeColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
