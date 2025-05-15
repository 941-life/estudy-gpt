// import 'package:flutter/material.dart';
// import 'package:estudy_gpt/models/shared_data.dart';
// import 'package:intl/intl.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:estudy_gpt/utils/local_storage.dart';
// import 'package:estudy_gpt/services/gemini_service.dart';

// class PersonalScreen extends StatefulWidget {
//   final String sharingType;
//   final List<SharedMediaFile> sharedFiles;
//   final String sharedText;

//   const PersonalScreen({
//     super.key,
//     required this.sharingType,
//     required this.sharedFiles,
//     required this.sharedText,
//   });

//   @override
//   State<PersonalScreen> createState() => _PersonalScreenState();
// }

// class _PersonalScreenState extends State<PersonalScreen> {
//   final GeminiService _geminiService = GeminiService();
//   List<SharedData> _history = [];
//   bool _showHistory = false;
//   List<Map<String, String>> _chatMessages = [];

//   Future<void> _loadHistory() async {
//     final history = await LocalStorage.loadData();
//     setState(() {
//       _history = history.reversed.toList();
//       _showHistory = true;
//     });
//   }

//   Future<void> _sendMessageToGemini(String message) async {
//     setState(() {
//       _chatMessages.add({'sender': 'user', 'message': message});
//     });

//     try {
//       final reply = await _geminiService.ask(message);
//       setState(() {
//         _chatMessages.add({'sender': 'gemini', 'message': reply});
//       });
//     } catch (e) {
//       setState(() {
//         _chatMessages.add({'sender': 'gemini', 'message': '오류 발생: $e'});
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _showHistory ? _buildHistoryScreen() : _buildMainScreen();
//   }

//   Widget _buildMainScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('개인 화면'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: _loadHistory,
//             tooltip: '히스토리 보기',
//           ),
//         ],
//       ),
//       body: _buildCurrentContent(),
//     );
//   }

//   Widget _buildHistoryScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('공유 기록'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => setState(() => _showHistory = false),
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: _history.length,
//         itemBuilder: (ctx, index) => _buildHistoryItem(_history[index]),
//       ),
//     );
//   }

//   Widget _buildCurrentContent() {
//     if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
//       return Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _chatMessages.length,
//               itemBuilder: (ctx, index) {
//                 final message = _chatMessages[index];
//                 final isUser = message['sender'] == 'user';
//                 return Align(
//                   alignment:
//                       isUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(
//                       vertical: 5,
//                       horizontal: 10,
//                     ),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: isUser ? Colors.blue : Colors.grey[300],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       message['message']!,
//                       style: TextStyle(
//                         color: isUser ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: TextEditingController(text: widget.sharedText),
//                     onSubmitted: (value) {
//                       if (value.isNotEmpty) {
//                         _sendMessageToGemini(value);
//                       }
//                     },
//                     decoration: const InputDecoration(
//                       hintText: '메시지를 입력하세요...',
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: () {
//                     if (widget.sharedText.isNotEmpty) {
//                       _sendMessageToGemini(widget.sharedText);
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     }

//     if ((widget.sharingType == 'file' ||
//             widget.sharingType == 'media_stream' ||
//             widget.sharingType == 'initial_media') &&
//         widget.sharedFiles.isNotEmpty) {
//       return ListView.builder(
//         itemCount: widget.sharedFiles.length,
//         itemBuilder:
//             (ctx, i) => ListTile(title: Text(widget.sharedFiles[i].path)),
//       );
//     }

//     return const Center(
//       child: Text(
//         '공유된 내용이 없습니다',
//         style: TextStyle(fontSize: 18, color: Colors.grey),
//       ),
//     );
//   }

//   Widget _buildHistoryItem(SharedData data) {
//     return ListTile(
//       leading: Icon(
//         data.type == 'text' ? Icons.text_snippet : Icons.file_copy,
//         color: Colors.blue,
//       ),
//       title: Text(
//         _getPreview(data),
//         style: const TextStyle(fontWeight: FontWeight.w500),
//       ),
//       subtitle: Text(
//         DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp),
//         style: const TextStyle(color: Colors.grey),
//       ),
//       onTap: () => _showDetailDialog(context, data),
//       trailing: IconButton(
//         icon: const Icon(Icons.delete, color: Colors.red),
//         onPressed: () => _deleteItem(data),
//       ),
//     );
//   }

//   String _getPreview(SharedData data) {
//     if (data.type == 'text') {
//       return data.text.isNotEmpty
//           ? (data.text.length > 20
//               ? '${data.text.substring(0, 20)}...'
//               : data.text)
//           : '텍스트 없음';
//     } else {
//       return data.filePaths.isNotEmpty
//           ? '${data.filePaths.length}개의 파일'
//           : '파일 없음';
//     }
//   }

//   void _showDetailDialog(BuildContext context, SharedData data) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('상세 정보'),
//             content: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
//               child:
//                   data.type == 'text'
//                       ? SingleChildScrollView(child: Text(data.text))
//                       : ListView(
//                         shrinkWrap: true,
//                         children:
//                             data.filePaths
//                                 .map(
//                                   (path) => Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 4,
//                                     ),
//                                     child: Text(
//                                       '• ${path.split('/').last}',
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                       ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('닫기'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _deleteItem(SharedData data) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('삭제 확인'),
//             content: const Text('이 항목을 정말 삭제하시겠습니까?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('취소'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('삭제'),
//               ),
//             ],
//           ),
//     );

//     if (confirm ?? false) {
//       final newHistory = _history.where((item) => item != data).toList();
//       await LocalStorage.saveAllData(newHistory);
//       setState(() => _history = newHistory);
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:estudy_gpt/models/shared_data.dart';
// import 'package:intl/intl.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:estudy_gpt/utils/local_storage.dart';
// import 'package:estudy_gpt/services/gemini_service.dart';

// class PersonalScreen extends StatefulWidget {
//   final String sharingType;
//   final List<SharedMediaFile> sharedFiles;
//   final String sharedText;

//   const PersonalScreen({
//     super.key,
//     required this.sharingType,
//     required this.sharedFiles,
//     required this.sharedText,
//   });

//   @override
//   State<PersonalScreen> createState() => _PersonalScreenState();
// }

// enum TextOption { summary, keywords, translate, other }

// class _PersonalScreenState extends State<PersonalScreen> {
//   final GeminiService _geminiService = GeminiService();
//   List<SharedData> _history = [];
//   bool _showHistory = false;
//   bool _isLoading = false;
//   String? _result;
//   TextOption? _selectedOption;
//   final TextEditingController _otherController = TextEditingController();
//   String _detectedLang = 'en'; // default

//   // 언어 감지: 한글이 30% 이상이면 한국어, 아니면 영어
//   String _detectLang(String text) {
//     final korean = RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]');
//     int koCount = korean.allMatches(text).length;
//     int total = text.replaceAll(RegExp(r'\s'), '').length;
//     if (total == 0) return 'en';
//     double ratio = koCount / total;
//     return ratio > 0.3 ? 'ko' : 'en';
//   }

//   // 옵션 라벨
//   Map<String, Map<TextOption, String>> optionLabels = {
//     'en': {
//       TextOption.summary: 'Summarize',
//       TextOption.keywords: 'Extract Keywords',
//       TextOption.translate: 'Translate to Korean',
//       TextOption.other: 'Other',
//     },
//     'ko': {
//       TextOption.summary: '요약해줘',
//       TextOption.keywords: '키워드 추출',
//       TextOption.translate: '영어로 번역',
//       TextOption.other: '기타',
//     },
//   };

//   // 안내문구
//   Map<String, String> instructionText = {
//     'en': 'Choose what you want to do with the text.',
//     'ko': '원하는 작업을 선택하세요.',
//   };

//   @override
//   void initState() {
//     super.initState();
//     if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
//       _detectedLang = _detectLang(widget.sharedText);
//     }
//   }

//   Future<void> _loadHistory() async {
//     final history = await LocalStorage.loadData();
//     setState(() {
//       _history = history.reversed.toList();
//       _showHistory = true;
//     });
//   }

//   Future<void> _handleOptionSubmit() async {
//     setState(() {
//       _isLoading = true;
//       _result = null;
//     });

//     String prompt = '';
//     String text = widget.sharedText;
//     String lang = _detectedLang;

//     switch (_selectedOption) {
//       case TextOption.summary:
//         prompt =
//             lang == 'ko'
//                 ? '"$text" 이 텍스트를 간결하게 요약해줘.'
//                 : 'Summarize the following text concisely: "$text"';
//         break;
//       case TextOption.keywords:
//         prompt =
//             lang == 'ko'
//                 ? '"$text" 이 텍스트에서 주요 키워드를 뽑아줘.'
//                 : 'Extract the main keywords from the following text: "$text"';
//         break;
//       case TextOption.translate:
//         prompt =
//             lang == 'ko'
//                 ? '"$text" 이 텍스트를 영어로 번역해줘.'
//                 : 'Translate the following text into Korean: "$text"';
//         break;
//       case TextOption.other:
//         String otherText = _otherController.text.trim();
//         String otherLang = _detectLang(otherText);
//         prompt = otherText;
//         break;
//       default:
//         prompt = '';
//     }

//     if (prompt.isEmpty) {
//       setState(() {
//         _isLoading = false;
//         _result =
//             lang == 'ko' ? '요청 내용을 입력해주세요.' : 'Please enter your request.';
//       });
//       return;
//     }

//     try {
//       final reply = await _geminiService.ask(prompt);
//       setState(() {
//         _result = reply;
//       });
//     } catch (e) {
//       setState(() {
//         _result = (lang == 'ko' ? '오류 발생: ' : 'Error: ') + e.toString();
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _otherController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _showHistory ? _buildHistoryScreen() : _buildMainScreen();
//   }

//   Widget _buildMainScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_detectedLang == 'ko' ? '개인 화면' : 'Personal'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: _loadHistory,
//             tooltip: _detectedLang == 'ko' ? '히스토리 보기' : 'View History',
//           ),
//         ],
//       ),
//       body: _buildCurrentContent(),
//       backgroundColor: Colors.grey[100],
//     );
//   }

//   Widget _buildHistoryScreen() {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_detectedLang == 'ko' ? '공유 기록' : 'Shared History'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => setState(() => _showHistory = false),
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: _history.length,
//         itemBuilder: (ctx, index) => _buildHistoryItem(_history[index]),
//       ),
//       backgroundColor: Colors.grey[100],
//     );
//   }

//   Widget _buildCurrentContent() {
//     if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
//       return SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   widget.sharedText,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 28),
//             Text(
//               instructionText[_detectedLang] ?? instructionText['en']!,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 17,
//                 color: Colors.blue[700],
//               ),
//             ),
//             const SizedBox(height: 18),
//             _buildRadioOptions(),
//             if (_selectedOption == TextOption.other)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, bottom: 8),
//                 child: TextField(
//                   controller: _otherController,
//                   decoration: InputDecoration(
//                     labelText:
//                         _detectedLang == 'ko'
//                             ? '기타 요청사항을 입력하세요'
//                             : 'Enter your custom request',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                   ),
//                   minLines: 1,
//                   maxLines: 3,
//                 ),
//               ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: _isLoading ? null : _handleOptionSubmit,
//               icon: const Icon(Icons.send, size: 20),
//               label: Text(
//                 _detectedLang == 'ko' ? '요청하기' : 'Submit',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size.fromHeight(48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 3,
//               ),
//             ),
//             const SizedBox(height: 32),
//             if (_isLoading) const Center(child: CircularProgressIndicator()),
//             if (_result != null)
//               Card(
//                 color: Colors.blue[50],
//                 margin: const EdgeInsets.only(top: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Text(_result!, style: const TextStyle(fontSize: 16)),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     if ((widget.sharingType == 'file' ||
//             widget.sharingType == 'media_stream' ||
//             widget.sharingType == 'initial_media') &&
//         widget.sharedFiles.isNotEmpty) {
//       return ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: widget.sharedFiles.length,
//         itemBuilder:
//             (ctx, i) => Card(
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               elevation: 2,
//               child: ListTile(
//                 leading: Icon(Icons.insert_drive_file, color: Colors.blue[400]),
//                 title: Text(
//                   widget.sharedFiles[i].path.split('/').last,
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//       );
//     }

//     return Center(
//       child: Text(
//         _detectedLang == 'ko' ? '공유된 내용이 없습니다' : 'No shared content found.',
//         style: const TextStyle(fontSize: 18, color: Colors.grey),
//       ),
//     );
//   }

//   Widget _buildRadioOptions() {
//     final labels = optionLabels[_detectedLang] ?? optionLabels['en']!;
//     return Column(
//       children: [
//         _buildOptionTile(TextOption.summary, labels[TextOption.summary]!),
//         const SizedBox(height: 4),
//         _buildOptionTile(TextOption.keywords, labels[TextOption.keywords]!),
//         const SizedBox(height: 4),
//         _buildOptionTile(TextOption.translate, labels[TextOption.translate]!),
//         const SizedBox(height: 4),
//         _buildOptionTile(TextOption.other, labels[TextOption.other]!),
//       ],
//     );
//   }

//   Widget _buildOptionTile(TextOption option, String label) {
//     final isSelected = _selectedOption == option;
//     return InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap:
//           () => setState(() {
//             _selectedOption = option;
//             if (option != TextOption.other) _otherController.clear();
//           }),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.ease,
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue[50] : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: Colors.blueAccent.withOpacity(0.08),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//         child: Row(
//           children: [
//             Radio<TextOption>(
//               value: option,
//               groupValue: _selectedOption,
//               onChanged:
//                   (val) => setState(() {
//                     _selectedOption = val;
//                     if (option != TextOption.other) _otherController.clear();
//                   }),
//               activeColor: Colors.blueAccent,
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? Colors.blueAccent : Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryItem(SharedData data) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: Colors.blue[100],
//           child: Icon(
//             data.type == 'text' ? Icons.text_snippet : Icons.file_copy,
//             color: Colors.blueAccent,
//           ),
//         ),
//         title: Text(
//           _getPreview(data),
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Text(
//           DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp),
//           style: const TextStyle(color: Colors.grey),
//         ),
//         onTap: () => _showDetailDialog(context, data),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.redAccent),
//           onPressed: () => _deleteItem(data),
//         ),
//       ),
//     );
//   }

//   String _getPreview(SharedData data) {
//     if (data.type == 'text') {
//       return data.text.isNotEmpty
//           ? (data.text.length > 20
//               ? '${data.text.substring(0, 20)}...'
//               : data.text)
//           : (_detectedLang == 'ko' ? '텍스트 없음' : 'No text');
//     } else {
//       return data.filePaths.isNotEmpty
//           ? '${data.filePaths.length}${_detectedLang == 'ko' ? '개의 파일' : ' files'}'
//           : (_detectedLang == 'ko' ? '파일 없음' : 'No file');
//     }
//   }

//   void _showDetailDialog(BuildContext context, SharedData data) {
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text(_detectedLang == 'ko' ? '상세 정보' : 'Detail'),
//             content: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
//               child:
//                   data.type == 'text'
//                       ? SingleChildScrollView(child: Text(data.text))
//                       : ListView(
//                         shrinkWrap: true,
//                         children:
//                             data.filePaths
//                                 .map(
//                                   (path) => Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 4,
//                                     ),
//                                     child: Text(
//                                       '• ${path.split('/').last}',
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                       ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(_detectedLang == 'ko' ? '닫기' : 'Close'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _deleteItem(SharedData data) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text(_detectedLang == 'ko' ? '삭제 확인' : 'Delete'),
//             content: Text(
//               _detectedLang == 'ko'
//                   ? '이 항목을 정말 삭제하시겠습니까?'
//                   : 'Are you sure you want to delete this item?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: Text(_detectedLang == 'ko' ? '취소' : 'Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: Text(_detectedLang == 'ko' ? '삭제' : 'Delete'),
//               ),
//             ],
//           ),
//     );

//     if (confirm ?? false) {
//       final newHistory = _history.where((item) => item != data).toList();
//       await LocalStorage.saveAllData(newHistory);
//       setState(() => _history = newHistory);
//     }
//   }
// }

import 'package:estudy_gpt/widgets/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:estudy_gpt/models/shared_data.dart';
import 'package:intl/intl.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:estudy_gpt/utils/local_storage.dart';
import 'package:estudy_gpt/services/gemini_service.dart';
import 'quiz_screen.dart';

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

enum LangOption {
  vocab, // 단어/표현 뽑기
  correction, // 문장 교정
  grammar, // 문법 설명
  examples, // 예문 만들기
  dialogue, // 회화 연습
  other, // 기타 요청
}

class _PersonalScreenState extends State<PersonalScreen> {
  final GeminiService _geminiService = GeminiService();
  List<SharedData> _history = [];
  bool _showHistory = false;
  bool _isLoading = false;
  String? _result;
  LangOption? _selectedOption;
  final TextEditingController _otherController = TextEditingController();
  List<Map<String, String>> _parsedVocabList = [];
  String _detectedLang = 'en'; // default

  // 언어 감지: 한글이 30% 이상이면 한국어, 아니면 영어
  String _detectLang(String text) {
    final korean = RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]');
    int koCount = korean.allMatches(text).length;
    int total = text.replaceAll(RegExp(r'\s'), '').length;
    if (total == 0) return 'en';
    double ratio = koCount / total;
    return ratio > 0.3 ? 'ko' : 'en';
  }

  // 옵션 라벨 및 설명
  final Map<String, Map<LangOption, Map<String, String>>> optionLabels = {
    'en': {
      LangOption.vocab: {
        'label': 'Extract Key Vocabulary',
        'desc': 'Get important words/phrases with definitions and examples.',
      },
      LangOption.correction: {
        'label': 'Correct My Sentences',
        'desc': 'Fix grammar and make your text more natural.',
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
      LangOption.correction: {
        'label': '문장 교정 및 피드백',
        'desc': '문법, 어색한 표현을 교정하고 자연스럽게 바꿔줍니다.',
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

  // 프롬프트 템플릿
  final Map<String, Map<LangOption, String Function(String)>>
  promptTemplates = {
    'en': {
      LangOption.vocab:
          (text) =>
              'Extract key vocabulary and expressions from the following text. Format your response as a markdown table with two columns: "Word" and "Definition & Example". In the Word column, put only the vocabulary word. In the Definition & Example column, put the definition first, then add the example sentence below in italics. Do not include any examples in the Word column. Example format:\n\n| Word | Definition & Example |\n| --- | --- |\n| example | meaning of the word\n*This is an example sentence.* |\n\nText: $text',

      LangOption.correction:
          (text) =>
              'Correct grammar, awkward expressions, and spelling in the following text, and provide improved sentences with explanations:\n$text',
      LangOption.grammar:
          (text) =>
              'Explain the main grammar points used in the following text for a B1 learner, with examples:\n$text',
      LangOption.examples:
          (text) =>
              'Select important words/phrases from the following text and make new example sentences for each:\n$text',
      LangOption.dialogue:
          (text) =>
              'Create a short dialogue (3 question-answer pairs) at B1 level based on the following topic/text:\n$text',
    },
    'ko': {
      LangOption.vocab:
          (text) =>
              '아래 텍스트에서 주요 단어와 표현을 뽑아서 마크다운 표로 정리해줘. 표는 두 개의 열로 구성하고, 왼쪽 열에는 단어를, 오른쪽 열에는 뜻(상단)과 예문(하단, 이탤릭체)을 함께 넣어줘. 예시 형식:\n\n| 단어 | 뜻 & 예문 |\n| --- | --- |\n| 예시 | 단어의 의미\n*이것은 예문입니다.* |\n\n텍스트: $text',
      LangOption.correction:
          (text) =>
              '아래 텍스트의 문법, 어색한 표현, 맞춤법을 교정하고, 더 자연스러운 문장으로 바꿔주고 설명해줘.\n$text',
      LangOption.grammar:
          (text) => '아래 텍스트에서 사용된 주요 문법 포인트를 B1 학습자 수준에서 예시와 함께 설명해줘.\n$text',
      LangOption.examples:
          (text) => '아래 텍스트에서 중요한 단어나 표현을 골라, 각 단어/표현별로 새로운 예문을 만들어줘.\n$text',
      LangOption.dialogue:
          (text) => '아래 주제(텍스트)로 B1 수준에 맞는 짧은 회화문(질문/답변 3세트)을 만들어줘.\n$text',
    },
  };

  // 안내문구
  final Map<String, String> instructionText = {
    'en': 'Choose a language learning task for this text.',
    'ko': '이 텍스트로 원하는 어학 학습 작업을 선택하세요.',
  };

  // Markdowm parsing
  List<Map<String, String>> _parseVocabTable(String text) {
    final lines = text.split('\n');
    final List<Map<String, String>> result = [];
    bool headerPassed = false;
    for (final line in lines) {
      if (line.trim().startsWith('|')) {
        final cells = line.split('|').map((e) => e.trim()).toList();
        if (cells.length >= 4 && cells[1].isNotEmpty) {
          // 헤더/구분선 건너뜀
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

  @override
  void initState() {
    super.initState();
    if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
      _detectedLang = _detectLang(widget.sharedText);
    }
  }

  Future<void> _loadHistory() async {
    final history = await LocalStorage.loadData();
    setState(() {
      _history = history.reversed.toList();
      _showHistory = true;
    });
  }

  Future<void> _handleOptionSubmit() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _parsedVocabList.clear();
    });

    String prompt = '';
    String text = widget.sharedText;
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
      prompt = otherText;
    } else {
      prompt = promptTemplates[lang]![_selectedOption!]!(text);
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

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showHistory ? _buildHistoryScreen() : _buildMainScreen();
  }

  Widget _buildMainScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _detectedLang == 'ko' ? '어학 학습 도우미' : 'Language Learning Helper',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _loadHistory,
            tooltip: _detectedLang == 'ko' ? '히스토리 보기' : 'View History',
          ),
        ],
      ),
      body: _buildCurrentContent(),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildHistoryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_detectedLang == 'ko' ? '공유 기록' : 'Shared History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _showHistory = false),
        ),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (ctx, index) => _buildHistoryItem(_history[index]),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildCurrentContent() {
    // 텍스트 공유일 때
    if (widget.sharingType == 'text' && widget.sharedText.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 공유된 텍스트 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.sharedText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 2. 안내문구
            Text(
              instructionText[_detectedLang] ?? instructionText['en']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 18),

            // 3. 어학 학습 옵션 카드 리스트
            _buildLangLearningOptions(),

            // 4. 기타 요청 입력란
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

            // 5. 요청하기 버튼
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleOptionSubmit,
              icon: const Icon(Icons.send, size: 20),
              label: Text(
                _detectedLang == 'ko' ? '요청하기' : 'Submit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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

            // 6. 로딩 인디케이터
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // 7. Gemini 결과 및 퀴즈 풀기 버튼
            if (_result != null)
              MarkdownResultCard(
                markdownText: _result!,
                bottomWidget:
                    (_selectedOption == LangOption.vocab &&
                            _parsedVocabList.isNotEmpty)
                        ? ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        QuizScreen(vocabList: _parsedVocabList),
                              ),
                            );
                          },
                          icon: const Icon(Icons.quiz),
                          label: Text(
                            _detectedLang == 'ko' ? '퀴즈 풀기' : 'Start Quiz',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        )
                        : null,
              ),
            // Card(
            //   color: Colors.blue[50],
            //   margin: const EdgeInsets.only(top: 12),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(14),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(20),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.stretch,
            //       children: [
            //         Text(_result!, style: const TextStyle(fontSize: 16)),
            //         // "주요 단어/표현 뽑기" 결과 + 퀴즈 풀기 버튼
            //         if (_selectedOption == LangOption.vocab &&
            //             _parsedVocabList.isNotEmpty)
            //           Padding(
            //             padding: const EdgeInsets.only(top: 20),
            //             child: ElevatedButton.icon(
            //               onPressed: () {
            //                 Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder:
            //                         (_) => QuizScreen(
            //                           vocabList: _parsedVocabList,
            //                         ),
            //                   ),
            //                 );
            //               },
            //                       icon: const Icon(Icons.quiz),
            //                       label: Text(
            //                         _detectedLang == 'ko' ? '퀴즈 풀기' : 'Start Quiz',
            //                       ),
            //                       style: ElevatedButton.styleFrom(
            //                         minimumSize: const Size.fromHeight(48),
            //                       ),
            //                     ),
            //                   ),
            //               ],
            //             ),
            //           ),
            //         ),
          ],
        ),
      );
    }

    // 파일 공유 등 다른 경우
    if ((widget.sharingType == 'file' ||
            widget.sharingType == 'media_stream' ||
            widget.sharingType == 'initial_media') &&
        widget.sharedFiles.isNotEmpty) {
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
              ),
            ),
      );
    }

    // 아무것도 없을 때
    return Center(
      child: Text(
        _detectedLang == 'ko' ? '공유된 내용이 없습니다' : 'No shared content found.',
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildLangLearningOptions() {
    final labels = optionLabels[_detectedLang]!;
    final icons = {
      LangOption.vocab: Icons.language,
      LangOption.correction: Icons.spellcheck,
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

  Widget _buildHistoryItem(SharedData data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            data.type == 'text' ? Icons.text_snippet : Icons.file_copy,
            color: Colors.blueAccent,
          ),
        ),
        title: Text(
          _getPreview(data),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('yyyy-MM-dd HH:mm').format(data.timestamp),
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () => _showDetailDialog(context, data),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _deleteItem(data),
        ),
      ),
    );
  }

  String _getPreview(SharedData data) {
    if (data.type == 'text') {
      return data.text.isNotEmpty
          ? (data.text.length > 20
              ? '${data.text.substring(0, 20)}...'
              : data.text)
          : (_detectedLang == 'ko' ? '텍스트 없음' : 'No text');
    } else {
      return data.filePaths.isNotEmpty
          ? '${data.filePaths.length}${_detectedLang == 'ko' ? '개의 파일' : ' files'}'
          : (_detectedLang == 'ko' ? '파일 없음' : 'No file');
    }
  }

  void _showDetailDialog(BuildContext context, SharedData data) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(_detectedLang == 'ko' ? '상세 정보' : 'Detail'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 400),
              child:
                  data.type == 'text'
                      ? SingleChildScrollView(child: Text(data.text))
                      : ListView(
                        shrinkWrap: true,
                        children:
                            data.filePaths
                                .map(
                                  (path) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '• ${path.split('/').last}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_detectedLang == 'ko' ? '닫기' : 'Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteItem(SharedData data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(_detectedLang == 'ko' ? '삭제 확인' : 'Delete'),
            content: Text(
              _detectedLang == 'ko'
                  ? '이 항목을 정말 삭제하시겠습니까?'
                  : 'Are you sure you want to delete this item?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_detectedLang == 'ko' ? '취소' : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_detectedLang == 'ko' ? '삭제' : 'Delete'),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      final newHistory = _history.where((item) => item != data).toList();
      await LocalStorage.saveAllData(newHistory);
      setState(() => _history = newHistory);
    }
  }
}
