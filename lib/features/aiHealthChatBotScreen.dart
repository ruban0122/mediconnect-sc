import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AiHealthBotScreen extends StatefulWidget {
  const AiHealthBotScreen({Key? key}) : super(key: key);

  @override
  State<AiHealthBotScreen> createState() => _AiHealthBotScreenState();
}

class _AiHealthBotScreenState extends State<AiHealthBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final String _apiKey =
      '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';
  final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final String _model = 'llama3-70b-8192';

  // Suggested questions organized by categories
  final Map<String, List<String>> _suggestedQuestions = {
    'General Health': [
      "How can I boost my immune system?",
      "What are signs I need more sleep?",
      "How much water should I drink daily?"
    ],
    'Symptoms': [
      "What should I do for a headache?",
      "How can I treat a cough at home?",
      "What are the symptoms of dehydration?"
    ],
    'Medication': [
      "Can I take paracetamol for fever?",
      "What's the difference between ibuprofen and acetaminophen?",
      "How to store medicines properly?"
    ],
    'Prevention': [
      "How to prevent seasonal flu?",
      "What are some heart-healthy habits?",
      "Tips for maintaining good mental health?"
    ]
  };

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": _model,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are MediConnect AI, a friendly health assistant in a healthcare app. Provide clear, concise health information. Be professional yet approachable. Offer general advice only, emphasizing when to see a doctor. Keep responses under 150 words unless more detail is requested. Format responses with bullet points when appropriate."
            },
            ..._messages.map((msg) => {
                  "role": msg["role"],
                  "content": msg["content"],
                }),
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];

        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _isLoading = false;
        });

        // Save chat history to Firebase Firestore
        await _saveChatHistory();
      } else {
        throw Exception('API request failed');
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content':
              '⚠️ Sorry, I\'m having trouble responding. Please try again later.'
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _saveChatHistory() async {
    final chatHistoryRef = FirebaseFirestore.instance.collection('ai_health_bot_chats');
    final chatDocRef = chatHistoryRef.doc(); // Creates a new document

    // Store the chat messages as a list of maps
    await chatDocRef.set({
      'messages': _messages,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF2B479A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue[50] : Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isUser
                          ? const Radius.circular(12)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(12),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.blue[100]! : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    msg['content'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isUser ? 'You' : 'MediBot',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversation?'),
        content: const Text('This will delete all messages in this chat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestionChip(String question) {
  return GestureDetector(
    onTap: () => _sendMessage(question),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        question,
        style: TextStyle(
          color: Color(0xFF2B479A),
          fontSize: 13,
        ),
      ),
    ),
  );
}


  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'MediConnect AI',
          style: TextStyle(
            color: Color(0xFF2B479A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: _clearChat,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For medical emergencies, contact healthcare professionals immediately',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 40,
                              color: Color(0xFF2B479A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            'MediConnect AI Assistant',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Ask me general health questions',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ..._suggestedQuestions.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Color(0xFF2B479A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                children: entry.value
                                    .map((q) => _buildSuggestedQuestionChip(q))
                                    .toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (_, i) => _buildMessage(_messages[i]),
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'MediBot is typing...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your health question...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => _sendMessage(_controller.text),
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


//DEEPSEEK AI

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AiHealthBotScreen extends StatefulWidget {
//   const AiHealthBotScreen({Key? key}) : super(key: key);

//   @override
//   State<AiHealthBotScreen> createState() => _AiHealthBotScreenState();
// }

// class _AiHealthBotScreenState extends State<AiHealthBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, String>> _messages = [];
//   bool _isLoading = false;

//   final String _apiKey =
//       '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';
//   final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
//   final String _model = 'llama3-70b-8192';

//   // Suggested questions organized by categories
//   final Map<String, List<String>> _suggestedQuestions = {
//     'General Health': [
//       "How can I boost my immune system?",
//       "What are signs I need more sleep?",
//       "How much water should I drink daily?"
//     ],
//     'Symptoms': [
//       "What should I do for a headache?",
//       "How can I treat a cough at home?",
//       "What are the symptoms of dehydration?"
//     ],
//     'Medication': [
//       "Can I take paracetamol for fever?",
//       "What's the difference between ibuprofen and acetaminophen?",
//       "How to store medicines properly?"
//     ],
//     'Prevention': [
//       "How to prevent seasonal flu?",
//       "What are some heart-healthy habits?",
//       "Tips for maintaining good mental health?"
//     ]
//   };

//   Future<void> _sendMessage(String text) async {
//     if (text.trim().isEmpty) return;

//     setState(() {
//       _messages.add({'role': 'user', 'content': text});
//       _isLoading = true;
//       _controller.clear();
//     });

//     _scrollToBottom();

//     try {
//       final response = await http.post(
//         Uri.parse(_apiUrl),
//         headers: {
//           'Authorization': 'Bearer $_apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "model": _model,
//           "messages": [
//             {
//               "role": "system",
//               "content":
//                   "You are MediConnect AI, a friendly health assistant in a healthcare app. Provide clear, concise health information. Be professional yet approachable. Offer general advice only, emphasizing when to see a doctor. Keep responses under 150 words unless more detail is requested. Format responses with bullet points when appropriate."
//             },
//             ..._messages.map((msg) => {
//                   "role": msg["role"],
//                   "content": msg["content"],
//                 }),
//           ]
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final reply = data['choices'][0]['message']['content'];

//         setState(() {
//           _messages.add({'role': 'assistant', 'content': reply});
//           _isLoading = false;
//         });
//       } else {
//         throw Exception('API request failed');
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add({
//           'role': 'assistant',
//           'content':
//               '⚠️ Sorry, I\'m having trouble responding. Please try again later.'
//         });
//         _isLoading = false;
//       });
//     }

//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessage(Map<String, String> msg) {
//     final isUser = msg['role'] == 'user';
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isUser) ...[
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Color(0xFF2B479A),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(
//                 Icons.local_hospital,
//                 size: 18,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//                   isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: isUser ? Colors.blue[50] : Colors.grey[50],
//                     borderRadius: BorderRadius.only(
//                       topLeft: const Radius.circular(12),
//                       topRight: const Radius.circular(12),
//                       bottomLeft: isUser
//                           ? const Radius.circular(12)
//                           : const Radius.circular(4),
//                       bottomRight: isUser
//                           ? const Radius.circular(4)
//                           : const Radius.circular(12),
//                     ),
//                     border: Border.all(
//                       color: isUser ? Colors.blue[100]! : Colors.grey[200]!,
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     msg['content'] ?? '',
//                     style: TextStyle(
//                       color: Colors.grey[800],
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   isUser ? 'You' : 'MediBot',
//                   style: TextStyle(
//                     color: Colors.grey[500],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isUser) ...[
//             const SizedBox(width: 8),
//             Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: Colors.blue[600],
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Icon(
//                 Icons.person,
//                 size: 18,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   void _clearChat() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear conversation?'),
//         content: const Text('This will delete all messages in this chat.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() => _messages.clear());
//               Navigator.pop(context);
//             },
//             child: const Text(
//               'Clear',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSuggestedQuestionChip(String question) {
//     return GestureDetector(
//       onTap: () => _sendMessage(question),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.blue[100]!),
//         ),
//         child: Text(
//           question,
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 13,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text(
//       //     'MediConnect AI',
//       //     style: TextStyle(fontWeight: FontWeight.bold),
//       //   ),
//       //   backgroundColor: Color(0xFF2B479A),
//       //   foregroundColor: Colors.white,
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.delete_outline),
//       //       tooltip: 'Clear Chat',
//       //       onPressed: _clearChat,
//       //     )
//       //   ],
//       // ),
//       appBar: AppBar(
//         elevation: 0,
//         centerTitle: true,
//         title: const Text(
//           'MediConnect AI',
//           style: TextStyle(
//             color: Color(0xFF2B479A),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_outline),
//             tooltip: 'Clear Chat',
//             onPressed: _clearChat,
//           )
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.blue[50],
//             child: const Row(
//               children: [
//                 Icon(Icons.info_outline, color: Colors.blue, size: 18),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'For medical emergencies, contact healthcare professionals immediately',
//                     style: TextStyle(
//                       color: Colors.blueAccent,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: _messages.isEmpty
//                 ? SingleChildScrollView(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 40),
//                         Center(
//                           child: Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               color: Colors.blue[100],
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             child: const Icon(
//                               Icons.health_and_safety,
//                               size: 40,
//                               color: Color(0xFF2B479A),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         const Center(
//                           child: Text(
//                             'MediConnect AI Assistant',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Center(
//                           child: Text(
//                             'Ask me general health questions',
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//                         ..._suggestedQuestions.entries.map((entry) {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 entry.key,
//                                 style: const TextStyle(
//                                   color: Color(0xFF2B479A),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Wrap(
//                                 children: entry.value
//                                     .map((q) => _buildSuggestedQuestionChip(q))
//                                     .toList(),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     controller: _scrollController,
//                     itemCount: _messages.length,
//                     padding: const EdgeInsets.only(top: 8),
//                     itemBuilder: (_, i) => _buildMessage(_messages[i]),
//                   ),
//           ),
//           if (_isLoading)
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 children: [
//                   const SizedBox(width: 40),
//                   Text(
//                     'MediBot is typing...',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey[200]!,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: _sendMessage,
//                     minLines: 1,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: 'Type your health question...',
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 12),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(24),
//                         borderSide: BorderSide(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[50],
//                       suffixIcon: IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed: () => _sendMessage(_controller.text),
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


//CHATGPT CODE
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class AiHealthBotScreen extends StatefulWidget {
//   const AiHealthBotScreen({Key? key}) : super(key: key);

//   @override
//   State<AiHealthBotScreen> createState() => _AiHealthBotScreenState();
// }

// class _AiHealthBotScreenState extends State<AiHealthBotScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, String>> _messages = [];
//   bool _isLoading = false;

//   final String _apiKey = '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'; // Replace with your Groq key
//   final String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
//   final String _model = 'llama3-70b-8192'; // New supported model

//   Future<void> _sendMessage(String text) async {
//     if (text.trim().isEmpty) return;

//     setState(() {
//       _messages.add({'role': 'user', 'content': text});
//       _isLoading = true;
//       _controller.clear();
//     });

//     _scrollToBottom();

//     final response = await http.post(
//       Uri.parse(_apiUrl),
//       headers: {
//         'Authorization': 'Bearer $_apiKey',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         "model": _model,
//         "messages": [
//           {
//             "role": "system",
//             "content":
//                 "You are an AI health assistant. Provide helpful, general health-related advice only. Do not give medical diagnoses or prescriptions. Always recommend consulting a real doctor."
//           },
//           ..._messages.map((msg) => {
//                 "role": msg["role"],
//                 "content": msg["content"],
//               }),
//         ]
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final reply = data['choices'][0]['message']['content'];

//       setState(() {
//         _messages.add({'role': 'assistant', 'content': reply});
//         _isLoading = false;
//       });

//       _scrollToBottom();
//     } else {
//       setState(() {
//         _messages.add({
//           'role': 'assistant',
//           'content':
//               '⚠️ Something went wrong. Please try again or check your connection.'
//         });
//         _isLoading = false;
//       });

//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessage(Map<String, String> msg) {
//     final isUser = msg['role'] == 'user';
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isUser ? Colors.blue[100] : Colors.grey[200],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(
//               radius: 12,
//               backgroundColor: isUser ? Colors.blue : Colors.grey,
//               child: Icon(
//                 isUser ? Icons.person : Icons.local_hospital,
//                 size: 16,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Flexible(child: Text(msg['content'] ?? '')),
//           ],
//         ),
//       ),
//     );
//   }

//   void _clearChat() {
//     setState(() {
//       _messages.clear();
//     });
//   }

//   // Suggested Questions
//   final List<String> _suggestedQuestions = [
//     "What should I do for a headache?",
//     "How can I treat a cough at home?",
//     "What are the symptoms of dehydration?",
//     "Can I take paracetamol for fever?",
//     "How can I boost my immune system?",
//   ];

//   // Handle tap on suggested question
//   void _onSuggestedQuestionTap(String question) {
//     _sendMessage(question);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AI HealthBot'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_forever),
//             tooltip: 'Clear Chat',
//             onPressed: _clearChat,
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(12.0),
//             child: Card(
//               color: Colors.amberAccent,
//               child: Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text(
//                   '⚠️ This AI provides general health guidance only. Always consult a licensed doctor for medical decisions.',
//                   style: TextStyle(fontSize: 14),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               itemCount: _messages.length,
//               padding: const EdgeInsets.all(8),
//               itemBuilder: (_, i) => _buildMessage(_messages[i]),
//             ),
//           ),
//           if (_isLoading)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text('HealthBot is typing...'),
//             ),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _controller,
//                   textInputAction: TextInputAction.send,
//                   onSubmitted: _sendMessage,
//                   decoration: const InputDecoration(
//                     hintText: 'Ask your health question here...',
//                     contentPadding: EdgeInsets.symmetric(horizontal: 16),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.send),
//                 onPressed: () => _sendMessage(_controller.text),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           // Suggested Questions
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _suggestedQuestions.map((question) {
//                 return ElevatedButton(
//                   onPressed: () => _onSuggestedQuestionTap(question),
//                   child: Text(
//                     question,
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

