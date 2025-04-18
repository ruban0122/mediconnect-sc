// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatScreen extends StatefulWidget {
//   final String appointmentId;

//   const ChatScreen({super.key, required this.appointmentId});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//   void _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;

//     final messageData = {
//       'senderId': currentUserId,
//       'message': text,
//       'type': 'text',
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .add(messageData);

//     // update meta
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'lastMessage': text,
//       'lastUpdated': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     _messageController.clear();
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent + 60,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   Widget _buildMessage(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final isMe = data['senderId'] == currentUserId;

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue[100] : Colors.grey[200],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(data['message']),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messageStream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat"),
//         backgroundColor: const Color(0xFF2B479A),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: messageStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//                 final docs = snapshot.data!.docs;
//                 return ListView.builder(
//                   controller: _scrollController,
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) => _buildMessage(docs[index]),
//                 );
//               },
//             ),
//           ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: _sendMessage,
//                   icon: const Icon(Icons.send, color: Color(0xFF2B479A)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//HELPPPPPPPPPPPPPPP
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class ChatScreen extends StatefulWidget {
//   final String appointmentId;

//   const ChatScreen({Key? key, required this.appointmentId}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   bool _isTyping = false;

//   void _sendMessage({String? text, File? imageFile}) async {
//     if ((text == null || text.trim().isEmpty) && imageFile == null) return;

//     String? imageUrl;
//     if (imageFile != null) {
//       // Upload image to Firebase Storage and get the URL
//       // For brevity, the upload code is omitted
//       // Assume imageUrl is obtained after upload
//     }

//     final messageData = {
//       'senderId': currentUserId,
//       'message': text ?? '',
//       'imageUrl': imageUrl ?? '',
//       'type': imageFile != null ? 'image' : 'text',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     };

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .add(messageData);

//     // Update chat metadata
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'lastMessage': text ?? 'Image',
//       'lastUpdated': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     _messageController.clear();
//     setState(() {
//       _isTyping = false;
//     });
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent + 60,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   Widget _buildMessage(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final isMe = data['senderId'] == currentUserId;
//     final messageType = data['type'] ?? 'text';
//     final messageText = data['message'] ?? '';
//     final imageUrl = data['imageUrl'] ?? '';
//     final timestamp = data['timestamp'] as Timestamp?;
//     final timeString = timestamp != null
//         ? DateFormat('hh:mm a').format(timestamp.toDate())
//         : '';

//     return Align(
//       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isMe ? Colors.blue[100] : Colors.grey[200],
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           crossAxisAlignment:
//               isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//           children: [
//             if (messageType == 'text')
//               Text(
//                 messageText,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             if (messageType == 'image' && imageUrl.isNotEmpty)
//               Image.network(imageUrl),
//             const SizedBox(height: 4),
//             Text(
//               timeString,
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
//     if (pickedFile != null) {
//       final imageFile = File(pickedFile.path);
//       _sendMessage(imageFile: imageFile);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messageStream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Chat"),
//         backgroundColor: const Color(0xFF2B479A),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: messageStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final docs = snapshot.data!.docs;
//                 return ListView.builder(
//                   controller: _scrollController,
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) =>
//                       _buildMessage(docs[index]),
//                 );
//               },
//             ),
//           ),
//           if (_isTyping)
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Typing...",
//                   style: TextStyle(fontStyle: FontStyle.italic),
//                 ),
//               ),
//             ),
//           const Divider(height: 1),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image),
//                   onPressed: _pickImage,
//                 ),
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(),
//                       isDense: true,
//                     ),
//                     onChanged: (text) {
//                       setState(() {
//                         _isTyping = text.isNotEmpty;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   onPressed: () => _sendMessage(text: _messageController.text),
//                   icon: const Icon(Icons.send, color: Color(0xFF2B479A)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//NEW UI
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class ChatScreen extends StatefulWidget {
//   final String appointmentId;
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserImageUrl;

//   const ChatScreen({
//     Key? key,
//     required this.appointmentId,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserImageUrl,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   bool _isTyping = false;
//   bool _otherUserIsTyping = false;
//   Timer? _typingTimer;

//   @override
//   void initState() {
//     super.initState();
//     _setupTypingListener();
//   }

//   @override
//   void dispose() {
//     _typingTimer?.cancel();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _setupTypingListener() {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         final typingData = snapshot.data()?['typing'] ?? {};
//         if (typingData[widget.otherUserId] == true) {
//           setState(() => _otherUserIsTyping = true);
//           _typingTimer?.cancel();
//           _typingTimer = Timer(const Duration(seconds: 3), () {
//             setState(() => _otherUserIsTyping = false);
//           });
//         }
//       }
//     });
//   }

//   void _updateTypingStatus(bool isTyping) {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'typing': {
//         currentUserId: isTyping,
//       },
//     }, SetOptions(merge: true));
//   }

//   Future<void> _sendMessage({String? text, File? imageFile}) async {
//     if ((text == null || text.trim().isEmpty) && imageFile == null) return;

//     String? imageUrl;
//     if (imageFile != null) {
//       // Upload image logic here
//     }

//     final messageData = {
//       'senderId': currentUserId,
//       'message': text ?? '',
//       'imageUrl': imageUrl ?? '',
//       'type': imageFile != null ? 'image' : 'text',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     };

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .add(messageData);

//     // Update chat metadata
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'lastMessage': text ?? 'Image',
//       'lastUpdated': FieldValue.serverTimestamp(),
//       'typing': {
//         currentUserId: false,
//       },
//     }, SetOptions(merge: true));

//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessage(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final isMe = data['senderId'] == currentUserId;
//     final messageType = data['type'] ?? 'text';
//     final messageText = data['message'] ?? '';
//     final imageUrl = data['imageUrl'] ?? '';
//     final timestamp = data['timestamp'] as Timestamp?;
//     final timeString = timestamp != null
//         ? DateFormat('hh:mm a').format(timestamp.toDate())
//         : '';

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isMe && widget.otherUserImageUrl != null)
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//             ),
//           if (!isMe) const SizedBox(width: 8),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 12,
//                 horizontal: 16,
//               ),
//               decoration: BoxDecoration(
//                 color: isMe
//                     ? const Color(0xFF2B479A)
//                     : Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(18),
//                   topRight: const Radius.circular(18),
//                   bottomLeft:
//                       isMe ? const Radius.circular(18) : Radius.zero,
//                   bottomRight:
//                       isMe ? Radius.zero : const Radius.circular(18),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   if (messageType == 'text')
//                     Text(
//                       messageText,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: isMe ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   if (messageType == 'image' && imageUrl.isNotEmpty)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         imageUrl,
//                         width: 200,
//                         height: 200,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                   Text(
//                     timeString,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: isMe
//                           ? Colors.white.withOpacity(0.7)
//                           : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isMe) const SizedBox(width: 8),
//           if (isMe)
//             const CircleAvatar(
//               radius: 16,
//               backgroundColor: Color(0xFF2B479A),
//               child: Icon(Icons.person, size: 16, color: Colors.white),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );
//     if (pickedFile != null) {
//       final imageFile = File(pickedFile.path);
//       await _sendMessage(imageFile: imageFile);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messageStream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         backgroundColor: const Color(0xFF2B479A),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             if (widget.otherUserImageUrl != null)
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//               ),
//             const SizedBox(width: 12),
//             Text(
//               widget.otherUserName,
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: messageStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF2B479A),
//                     ),
//                   );
//                 }
//                 final docs = snapshot.data!.docs;
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.only(top: 16),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) => _buildMessage(docs[index]),
//                 );
//               },
//             ),
//           ),
//           if (_otherUserIsTyping)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "${widget.otherUserName.split(' ')[0]} is typing...",
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image, color: Color(0xFF2B479A)),
//                   onPressed: _pickImage,
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: const InputDecoration(
//                         hintText: "Type a message...",
//                         border: InputBorder.none,
//                       ),
//                       onChanged: (text) {
//                         _updateTypingStatus(text.isNotEmpty);
//                         setState(() => _isTyping = text.isNotEmpty);
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: const Color(0xFF2B479A),
//                   ),
//                   child: IconButton(
//                     onPressed: () {
//                       if (_messageController.text.trim().isNotEmpty) {
//                         _sendMessage(text: _messageController.text);
//                       }
//                     },
//                     icon: const Icon(Icons.send, color: Colors.white),
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

//ADDED message read status
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:async';

// class ChatScreen extends StatefulWidget {
//   final String appointmentId;
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserImageUrl;

//   const ChatScreen({
//     Key? key,
//     required this.appointmentId,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserImageUrl,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   bool _isTyping = false;
//   bool _otherUserIsTyping = false;
//   Timer? _typingTimer;
//   StreamSubscription? _messagesSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _setupTypingListener();
//     _markMessagesAsRead();
//     _setupMessageListener();
//   }

//   @override
//   void dispose() {
//     _typingTimer?.cancel();
//     _messagesSubscription?.cancel();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _setupMessageListener() {
//     _messagesSubscription = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .where('senderId', isEqualTo: widget.otherUserId)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         _markMessagesAsRead();
//       }
//     });
//   }

//   void _setupTypingListener() {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         final typingData = snapshot.data()?['typing'] ?? {};
//         if (typingData[widget.otherUserId] == true) {
//           setState(() => _otherUserIsTyping = true);
//           _typingTimer?.cancel();
//           _typingTimer = Timer(const Duration(seconds: 3), () {
//             setState(() => _otherUserIsTyping = false);
//           });
//         }
//       }
//     });
//   }

//   void _updateTypingStatus(bool isTyping) {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'typing': {
//         currentUserId: isTyping,
//       },
//     }, SetOptions(merge: true));
//   }

//   Future<void> _markMessagesAsRead() async {
//     final messages = await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .where('senderId', isEqualTo: widget.otherUserId)
//         .where('isRead', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in messages.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }
//     await batch.commit();
//   }

//   Future<void> _sendMessage({String? text, File? imageFile}) async {
//     if ((text == null || text.trim().isEmpty) && imageFile == null) return;

//     String? imageUrl;
//     if (imageFile != null) {
//       // Implement your image upload logic here
//     }

//     final messageData = {
//       'senderId': currentUserId,
//       'message': text ?? '',
//       'imageUrl': imageUrl ?? '',
//       'type': imageFile != null ? 'image' : 'text',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     };

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .add(messageData);

//     // Update chat metadata
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'lastMessage': text ?? 'Image',
//       'lastUpdated': FieldValue.serverTimestamp(),
//       'typing': {
//         currentUserId: false,
//       },
//     }, SetOptions(merge: true));

//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Widget _buildMessage(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final isMe = data['senderId'] == currentUserId;
//     final isRead = data['isRead'] ?? false;
//     final messageType = data['type'] ?? 'text';
//     final messageText = data['message'] ?? '';
//     final imageUrl = data['imageUrl'] ?? '';
//     final timestamp = data['timestamp'] as Timestamp?;
//     final timeString = timestamp != null
//         ? DateFormat('hh:mm a').format(timestamp.toDate())
//         : '';

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isMe && widget.otherUserImageUrl != null)
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//             ),
//           if (!isMe) const SizedBox(width: 8),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isMe
//                     ? const Color(0xFF2B479A)
//                     : Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(18),
//                   topRight: const Radius.circular(18),
//                   bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
//                   bottomRight: isMe ? Radius.zero : const Radius.circular(18),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   if (messageType == 'text')
//                     Text(
//                       messageText,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isMe ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   if (messageType == 'image' && imageUrl.isNotEmpty)
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         imageUrl,
//                         width: 200,
//                         height: 200,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         timeString,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: isMe ? Colors.white70 : Colors.grey,
//                         ),
//                       ),
//                       if (isMe) const SizedBox(width: 4),
//                       if (isMe)
//                         Icon(
//                           isRead ? Icons.done_all : Icons.done,
//                           size: 16,
//                           color: isMe
//                               ? (isRead
//                                   ? Colors.lightBlueAccent
//                                   : Colors.white54)
//                               : Colors.grey,
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isMe) const SizedBox(width: 8),
//           if (isMe)
//             const CircleAvatar(
//               radius: 16,
//               backgroundColor: Color(0xFF2B479A),
//               child: Icon(Icons.person, size: 16, color: Colors.white),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );
//     if (pickedFile != null) {
//       final imageFile = File(pickedFile.path);
//       await _sendMessage(imageFile: imageFile);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messageStream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         backgroundColor: const Color(0xFF2B479A),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             if (widget.otherUserImageUrl != null)
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//               ),
//             const SizedBox(width: 12),
//             Text(
//               widget.otherUserName,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: messageStream,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFF2B479A),
//                     ),
//                   );
//                 }
//                 final docs = snapshot.data!.docs;
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });
//                 return ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.only(top: 16),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) => _buildMessage(docs[index]),
//                 );
//               },
//             ),
//           ),
//           if (_otherUserIsTyping)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "${widget.otherUserName.split(' ')[0]} is typing...",
//                 style: TextStyle(
//                   fontStyle: FontStyle.italic,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.image, color: Color(0xFF2B479A)),
//                   onPressed: _pickImage,
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: const InputDecoration(
//                         hintText: "Type a message...",
//                         border: InputBorder.none,
//                       ),
//                       onChanged: (text) {
//                         _updateTypingStatus(text.isNotEmpty);
//                         setState(() => _isTyping = text.isNotEmpty);
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: const Color(0xFF2B479A),
//                   ),
//                   child: IconButton(
//                     onPressed: () {
//                       if (_messageController.text.trim().isNotEmpty) {
//                         _sendMessage(text: _messageController.text);
//                       }
//                     },
//                     icon: const Icon(Icons.send, color: Colors.white),
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

//ADDED IMAGE PICKER
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:async';

// class ChatScreen extends StatefulWidget {
//   final String appointmentId;
//   final String otherUserId;
//   final String otherUserName;
//   final String? otherUserImageUrl;

//   const ChatScreen({
//     Key? key,
//     required this.appointmentId,
//     required this.otherUserId,
//     required this.otherUserName,
//     this.otherUserImageUrl,
//   }) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//   bool _isTyping = false;
//   bool _otherUserIsTyping = false;
//   bool _isLoading = false;
//   Timer? _typingTimer;
//   StreamSubscription? _messagesSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _setupTypingListener();
//     _markMessagesAsRead();
//     _setupMessageListener();
//   }

//   @override
//   void dispose() {
//     _typingTimer?.cancel();
//     _messagesSubscription?.cancel();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _setupMessageListener() {
//     _messagesSubscription = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .where('senderId', isEqualTo: widget.otherUserId)
//         .where('isRead', isEqualTo: false)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.docs.isNotEmpty) {
//         _markMessagesAsRead();
//       }
//     });
//   }

//   void _setupTypingListener() {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         final typingData = snapshot.data()?['typing'] ?? {};
//         if (typingData[widget.otherUserId] == true) {
//           setState(() => _otherUserIsTyping = true);
//           _typingTimer?.cancel();
//           _typingTimer = Timer(const Duration(seconds: 3), () {
//             setState(() => _otherUserIsTyping = false);
//           });
//         }
//       }
//     });
//   }

//   void _updateTypingStatus(bool isTyping) {
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'typing': {
//         currentUserId: isTyping,
//       },
//     }, SetOptions(merge: true));
//   }

//   Future<void> _markMessagesAsRead() async {
//     final messages = await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .where('senderId', isEqualTo: widget.otherUserId)
//         .where('isRead', isEqualTo: false)
//         .get();

//     final batch = FirebaseFirestore.instance.batch();
//     for (var doc in messages.docs) {
//       batch.update(doc.reference, {'isRead': true});
//     }
//     await batch.commit();
//   }

//   Future<String?> _uploadImage(File imageFile) async {
//     try {
//       final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final Reference storageRef = FirebaseStorage.instance
//           .ref()
//           .child('chat_images/${widget.appointmentId}/$fileName');

//       final UploadTask uploadTask = storageRef.putFile(imageFile);
//       final TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print('Error uploading image: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
//       );
//       return null;
//     }
//   }

//   Future<void> _sendMessage(
//       {String? text, File? imageFile, String? imageUrl}) async {
//     if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

//     final messageData = {
//       'senderId': currentUserId,
//       'message': text ?? '',
//       'imageUrl': imageUrl ?? '',
//       'type': imageUrl != null ? 'image' : 'text',
//       'timestamp': FieldValue.serverTimestamp(),
//       'isRead': false,
//     };

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .add(messageData);

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .set({
//       'lastMessage': text ?? 'Image',
//       'lastUpdated': FieldValue.serverTimestamp(),
//       'typing': {
//         currentUserId: false,
//       },
//     }, SetOptions(merge: true));

//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       setState(() => _isLoading = true);
//       try {
//         final File imageFile = File(pickedFile.path);
//         final String? imageUrl = await _uploadImage(imageFile);
//         if (imageUrl != null) {
//           await _sendMessage(imageUrl: imageUrl);
//         }
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Widget _buildMessage(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final isMe = data['senderId'] == currentUserId;
//     final isRead = data['isRead'] ?? false;
//     final messageType = data['type'] ?? 'text';
//     final messageText = data['message'] ?? '';
//     final imageUrl = data['imageUrl'] ?? '';
//     final timestamp = data['timestamp'] as Timestamp?;
//     final timeString = timestamp != null
//         ? DateFormat('hh:mm a').format(timestamp.toDate())
//         : '';

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment:
//             isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isMe && widget.otherUserImageUrl != null)
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//             ),
//           if (!isMe) const SizedBox(width: 8),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isMe
//                     ? const Color(0xFF2B479A)
//                     : Colors.grey.withOpacity(0.1),
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(18),
//                   topRight: const Radius.circular(18),
//                   bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
//                   bottomRight: isMe ? Radius.zero : const Radius.circular(18),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment:
//                     isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   if (messageType == 'text')
//                     Text(
//                       messageText,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: isMe ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   if (messageType == 'image' && imageUrl.isNotEmpty)
//                     GestureDetector(
//                       onTap: () => _showFullScreenImage(imageUrl),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.network(
//                           imageUrl,
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Container(
//                               width: 200,
//                               height: 200,
//                               color: Colors.grey[200],
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   value: loadingProgress.expectedTotalBytes !=
//                                           null
//                                       ? loadingProgress.cumulativeBytesLoaded /
//                                           loadingProgress.expectedTotalBytes!
//                                       : null,
//                                 ),
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                             width: 200,
//                             height: 200,
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.error),
//                           ),
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         timeString,
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: isMe ? Colors.white70 : Colors.grey,
//                         ),
//                       ),
//                       if (isMe) const SizedBox(width: 4),
//                       if (isMe)
//                         Icon(
//                           isRead ? Icons.done_all : Icons.done,
//                           size: 16,
//                           color: isMe
//                               ? (isRead
//                                   ? Colors.lightBlueAccent
//                                   : Colors.white54)
//                               : Colors.grey,
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isMe) const SizedBox(width: 8),
//           if (isMe)
//             const CircleAvatar(
//               radius: 16,
//               backgroundColor: Color(0xFF2B479A),
//               child: Icon(Icons.person, size: 16, color: Colors.white),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showFullScreenImage(String imageUrl) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             backgroundColor: Colors.black,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           body: Center(
//             child: InteractiveViewer(
//               child: Image.network(imageUrl),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final messageStream = FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.appointmentId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots();

//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         backgroundColor: const Color(0xFF2B479A),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             if (widget.otherUserImageUrl != null)
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(widget.otherUserImageUrl!),
//               ),
//             const SizedBox(width: 12),
//             Text(
//               widget.otherUserName,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: messageStream,
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF2B479A),
//                         ),
//                       );
//                     }
//                     final docs = snapshot.data!.docs;
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       _scrollToBottom();
//                     });
//                     return ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.only(top: 16),
//                       itemCount: docs.length,
//                       itemBuilder: (context, index) =>
//                           _buildMessage(docs[index]),
//                     );
//                   },
//                 ),
//               ),
//               if (_otherUserIsTyping)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     "${widget.otherUserName.split(' ')[0]} is typing...",
//                     style: TextStyle(
//                       fontStyle: FontStyle.italic,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 color: Colors.white,
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.image, color: Color(0xFF2B479A)),
//                       onPressed: _isLoading ? null : _pickImage,
//                     ),
//                     Expanded(
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                         child: TextField(
//                           controller: _messageController,
//                           decoration: const InputDecoration(
//                             hintText: "Type a message...",
//                             border: InputBorder.none,
//                           ),
//                           onChanged: (text) {
//                             _updateTypingStatus(text.isNotEmpty);
//                             setState(() => _isTyping = text.isNotEmpty);
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: const Color(0xFF2B479A),
//                       ),
//                       child: IconButton(
//                         onPressed: _isLoading
//                             ? null
//                             : () {
//                                 if (_messageController.text.trim().isNotEmpty) {
//                                   _sendMessage(text: _messageController.text);
//                                 }
//                               },
//                         icon: const Icon(Icons.send, color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF2B479A),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String appointmentId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImageUrl;

  const ChatScreen({
    Key? key,
    required this.appointmentId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImageUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isTyping = false;
  bool _otherUserIsTyping = false;
  bool _isLoading = false;
  Timer? _typingTimer;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _setupTypingListener();
    _markMessagesAsRead();
    _setupMessageListener();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupMessageListener() {
    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _markMessagesAsRead();
      }
    });
  }

  void _setupTypingListener() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final typingData = snapshot.data()?['typing'] ?? {};
        if (typingData[widget.otherUserId] == true) {
          setState(() => _otherUserIsTyping = true);
          _typingTimer?.cancel();
          _typingTimer = Timer(const Duration(seconds: 3), () {
            setState(() => _otherUserIsTyping = false);
          });
        }
      }
    });
  }

  void _updateTypingStatus(bool isTyping) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .set({
      'typing': {
        currentUserId: isTyping,
      },
    }, SetOptions(merge: true));
  }

  Future<void> _markMessagesAsRead() async {
    final messages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_images/${widget.appointmentId}/$fileName');

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _sendMessage({String? text, String? imageUrl}) async {
    if ((text == null || text.trim().isEmpty) && imageUrl == null) return;

    final messageData = {
      'senderId': currentUserId,
      'message': text ?? '',
      'imageUrl': imageUrl ?? '',
      'type': imageUrl != null ? 'image' : 'text',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .collection('messages')
        .add(messageData);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .set({
      'lastMessage': text ?? 'Image',
      'lastUpdated': FieldValue.serverTimestamp(),
      'typing': {
        currentUserId: false,
      },
    }, SetOptions(merge: true));

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Send Image From"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _captureImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery (Single)"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections),
              title: const Text("Gallery (Multiple)"),
              onTap: () {
                Navigator.pop(context);
                _pickMultipleImages();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      await _processAndSendImage(File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      await _processAndSendImage(File(pickedFile.path));
    }
  }

  Future<void> _pickMultipleImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 2000,
      maxHeight: 2000,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        for (final pickedFile in pickedFiles) {
          await _processAndSendImage(File(pickedFile.path));
          await Future.delayed(
              const Duration(milliseconds: 300)); // Stagger uploads
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processAndSendImage(File imageFile) async {
    try {
      final String? imageUrl = await _uploadImage(imageFile);
      if (imageUrl != null) {
        await _sendMessage(imageUrl: imageUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: ${e.toString()}')),
      );
    }
  }

  Widget _buildMessage(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final isMe = data['senderId'] == currentUserId;
    final isRead = data['isRead'] ?? false;
    final messageType = data['type'] ?? 'text';
    final messageText = data['message'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final timeString = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && widget.otherUserImageUrl != null)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.otherUserImageUrl!),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                    ? const Color(0xFF2B479A)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (messageType == 'text')
                    Text(
                      messageText,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  if (messageType == 'image' && imageUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () => _showFullScreenImage(imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      if (isMe) const SizedBox(width: 4),
                      if (isMe)
                        Icon(
                          isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: isMe
                              ? (isRead
                                  ? Colors.lightBlueAccent
                                  : Colors.white54)
                              : Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF2B479A),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.appointmentId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: const Color(0xFF2B479A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (widget.otherUserImageUrl != null)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.otherUserImageUrl!),
              ),
            const SizedBox(width: 12),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: messageStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2B479A),
                        ),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) =>
                          _buildMessage(docs[index]),
                    );
                  },
                ),
              ),
              if (_otherUserIsTyping)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${widget.otherUserName.split(' ')[0]} is typing...",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.image, color: Color(0xFF2B479A)),
                      onSelected: (value) {
                        if (value == 'camera') {
                          _captureImageFromCamera();
                        } else if (value == 'gallery') {
                          _pickImageFromGallery();
                        } else if (value == 'multiple') {
                          _pickMultipleImages();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'camera',
                          child: Text("Take Photo"),
                        ),
                        const PopupMenuItem(
                          value: 'gallery',
                          child: Text("Choose from Gallery"),
                        ),
                        const PopupMenuItem(
                          value: 'multiple',
                          child: Text("Choose Multiple"),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                          ),
                          onChanged: (text) {
                            _updateTypingStatus(text.isNotEmpty);
                            setState(() => _isTyping = text.isNotEmpty);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2B479A),
                      ),
                      child: IconButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_messageController.text.trim().isNotEmpty) {
                                  _sendMessage(text: _messageController.text);
                                }
                              },
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2B479A),
              ),
            ),
        ],
      ),
    );
  }
}
