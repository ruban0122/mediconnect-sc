// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen_doctor.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String userRole;
//   final String appointmentId;

//   const VideoCallScreen({
//     super.key,
//     required this.channelName,
//     required this.userRole,
//     required this.appointmentId,
//   });

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   static const String appId = 'a49de82128904c6db10e48851bba1b55';
//   String? token;
//   int? _localUid;

//   bool _isLoading = true;
//   bool _isJoined = false;
//   bool _isMuted = false;
//   bool _isVideoDisabled = false;
//   bool _isFrontCamera = true;

//   RtcEngine? _engine;
//   final Map<int, bool> _remoteUserVideo = {};

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     await [Permission.camera, Permission.microphone].request();
//     token = await _fetchToken(widget.channelName);
//     if (token == null) return _showError('Failed to get token');

//     _engine = createAgoraRtcEngine();
//     await _engine!.initialize(RtcEngineContext(appId: appId));
//     await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine!.enableVideo();

//     _engine!.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//         setState(() {
//           _isJoined = true;
//           _localUid = connection.localUid;
//           _isLoading = false;
//         });
//       },
//       onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//         setState(() => _remoteUserVideo[remoteUid] = false);
//       },
//       onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
//         setState(() => _remoteUserVideo[remoteUid] = muted);
//       },
//       // onUserOffline: (RtcConnection connection, int remoteUid,
//       //     UserOfflineReasonType reason) {
//       //   setState(() => _remoteUserVideo.remove(remoteUid));

//       //   if (widget.userRole == 'patient') {
//       //     // Patient should see that doctor left, but not auto-end
//       //     ScaffoldMessenger.of(context).showSnackBar(
//       //       const SnackBar(content: Text('The doctor has left the session.')),
//       //     );
//       //   } else {
//       //     // Doctor should see that patient left
//       //     ScaffoldMessenger.of(context).showSnackBar(
//       //       const SnackBar(content: Text('The patient has left the session.')),
//       //     );
//       //   }
//       // },
//       onUserOffline: (RtcConnection connection, int remoteUid,
//           UserOfflineReasonType reason) async {
//         setState(() => _remoteUserVideo.remove(remoteUid));

//         // Check if the session has ended
//         final doc = await FirebaseFirestore.instance
//             .collection('appointments')
//             .doc(widget.appointmentId)
//             .get();

//         final status = doc.data()?['status'];
//         if (status == 'completed') {
//           if (!mounted) return;

//           await _engine?.leaveChannel();

//           if (widget.userRole == 'doctor') {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const AppointmentCompleteScreenDoctor()),
//             );
//           } else {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => const AppointmentCompleteScreen()),
//             );
//           }
//         } else {
//           // If session not marked as completed yet, just show snack message
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 widget.userRole == 'patient'
//                     ? 'The doctor has left the session.'
//                     : 'The patient has left the session.',
//               ),
//             ),
//           );
//         }
//       },

//       onError: (ErrorCodeType code, String message) {
//         _showError("Agora Error [$code]: $message");
//       },
//     ));

//     await _engine!.joinChannel(
//       token: token!,
//       channelId: widget.channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   Future<String?> _fetchToken(String channelName) async {
//     final url = Uri.parse(
//       'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=0&role=publisher',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body)['token'];
//       } else {
//         debugPrint('Token error: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Token fetch failed: $e');
//       return null;
//     }
//   }

//   Future<String?> _fetchPatientId() async {
//     final doc = await FirebaseFirestore.instance
//         .collection('appointments')
//         .doc(widget.appointmentId)
//         .get();
//     return doc['patientId'];
//   }

//   void _openHealthRecordDialog() async {
//     final patientId = await _fetchPatientId();
//     if (patientId == null) return;

//     final doc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(patientId)
//         .collection('records')
//         .doc('health')
//         .get();

//     if (!doc.exists || !mounted) return;

//     final data = doc.data()!;
//     final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             const Text("Patient's Health Record",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 12),
//             _recordTile("Blood Type", data['bloodType']),
//             _recordTile("Allergies", data['allergies']),
//             _recordTile("Cronic Conditions", data['chronic']),
//             _recordTile("Medications", data['medications']),
//             _recordTile("Height (cm)", data['height'].toString()),
//             _recordTile("Weight (kg)", data['weight'].toString()),
//             if (updatedAt != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 16),
//                 child: Text(
//                   "Last Updated: ${DateFormat('dd MMM yyyy').format(updatedAt)}",
//                   style: const TextStyle(fontSize: 13, color: Colors.grey),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _recordTile(String label, String? value) {
//     return ListTile(
//       title: Text(label),
//       subtitle: Text(value?.isNotEmpty == true ? value! : "Not specified"),
//     );
//   }

//   void _showCallEndedMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Ending Session...')),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) Navigator.pop(context);
//     });
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     Navigator.pop(context);
//   }

//   void _toggleMute() {
//     setState(() => _isMuted = !_isMuted);
//     _engine?.muteLocalAudioStream(_isMuted);
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoDisabled = !_isVideoDisabled);
//     _engine?.muteLocalVideoStream(_isVideoDisabled);
//   }

//   void _switchCamera() {
//     _engine?.switchCamera().then((_) {
//       setState(() => _isFrontCamera = !_isFrontCamera);
//     });
//   }

//   // Future<void> _endCall() async {
//   //   await _engine?.leaveChannel();
//   //   if (mounted) Navigator.pop(context);
//   // }
//   // Future<void> _endCall() async {
//   //   final isDoctor = widget.userRole == 'doctor';

//   //   if (isDoctor) {
//   //     final confirm = await showDialog<bool>(
//   //       context: context,
//   //       builder: (context) => AlertDialog(
//   //         title: const Text('End Appointment'),
//   //         content: const Text('Are you sure you want to end this session?'),
//   //         actions: [
//   //           TextButton(
//   //             onPressed: () =>
//   //                 Navigator.pop(context, false), // Cancel stays the same
//   //             child: const Text('Cancel'),
//   //           ),
//   //           ElevatedButton(
//   //             onPressed: () {
//   //               // Close the dialog first
//   //               Navigator.pop(context);

//   //               // Then navigate to the completed screen
//   //               Navigator.pushReplacement(
//   //                 context,
//   //                 MaterialPageRoute(
//   //                   builder: (context) => const AppointmentCompleteScreen(),
//   //                 ),
//   //               );
//   //             },
//   //             child: const Text('End'),
//   //           ),
//   //         ],
//   //       ),
//   //     );

//   //     if (confirm == true) {
//   //       // Update Firestore
//   //       await FirebaseFirestore.instance
//   //           .collection('appointments')
//   //           .doc(widget.appointmentId)
//   //           .update({'status': 'completed'});
//   //     } else {
//   //       return; // Cancelled
//   //     }
//   //   }

//   //   await _engine?.leaveChannel();
//   //   if (mounted) Navigator.pop(context);
//   // }

//   // @override
//   // void dispose() {
//   //   _engine?.leaveChannel();
//   //   _engine?.release();
//   //   super.dispose();
//   // }

//   Future<void> _endCall() async {
//     final isDoctor = widget.userRole == 'doctor';

//     if (isDoctor) {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('End Appointment'),
//           content: const Text('Are you sure you want to end this session?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false), // Cancel
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true), // Confirm
//               child: const Text('End'),
//             ),
//           ],
//         ),
//       );

//       if (confirm == true) {
//         // Update Firestore status
//         await FirebaseFirestore.instance
//             .collection('appointments')
//             .doc(widget.appointmentId)
//             .update({'status': 'completed'});

//         await _engine?.leaveChannel();

//         // Navigate to doctor completion screen
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AppointmentCompleteScreenDoctor(),
//             ),
//           );
//         }
//       } else {
//         return; // Doctor cancelled
//       }
//     } else {
//       // Patient ending or leaving the session
//       await _engine?.leaveChannel();

//       // Navigate patient to feedback or summary screen
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 const AppointmentCompleteScreen(), // Create this screen
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           _renderRemoteVideo(),
//           _renderLocalPreview(),
//           _renderControls(),
//           if (_isLoading) _renderLoading(),
//           if (widget.userRole == 'doctor')
//             Positioned(
//               top: 40,
//               right: 20,
//               child: FloatingActionButton(
//                 heroTag: 'records',
//                 backgroundColor: Colors.teal,
//                 onPressed: _openHealthRecordDialog,
//                 child: const Icon(Icons.description),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _renderRemoteVideo() {
//     if (_remoteUserVideo.isEmpty) {
//       return Center(
//         child: Text(
//           _isJoined ? 'Waiting for participant...' : 'Connecting...',
//           style: const TextStyle(color: Colors.white),
//         ),
//       );
//     }

//     final remoteUid = _remoteUserVideo.keys.first;
//     final isMuted = _remoteUserVideo[remoteUid]!;

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         if (!isMuted)
//           AgoraVideoView(
//             controller: VideoViewController.remote(
//               rtcEngine: _engine!,
//               canvas: VideoCanvas(uid: remoteUid),
//               connection: RtcConnection(channelId: widget.channelName),
//             ),
//           )
//         else
//           const Icon(Icons.videocam_off, size: 80, color: Colors.white),
//       ],
//     );
//   }

//   Widget _renderLocalPreview() {
//     if (!_isJoined) return const SizedBox.shrink();

//     return Positioned(
//       top: 24,
//       right: 16,
//       child: Container(
//         width: 120,
//         height: 160,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.white),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.black,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               if (!_isVideoDisabled)
//                 AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: _engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 )
//               else
//                 const Icon(Icons.videocam_off, size: 40, color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _renderControls() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 36),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _controlButton(
//               icon: _isMuted ? Icons.mic_off : Icons.mic,
//               color: _isMuted ? Colors.grey : Colors.blue,
//               onPressed: _toggleMute,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: Icons.call_end,
//               color: Colors.red,
//               onPressed: _endCall,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
//               color: _isVideoDisabled ? Colors.grey : Colors.blue,
//               onPressed: _toggleVideo,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: Icons.cameraswitch,
//               color: Colors.orange,
//               onPressed: _switchCamera,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _renderLoading() {
//     return const Center(
//       child: CircularProgressIndicator(color: Colors.white),
//     );
//   }

//   Widget _controlButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return CircleAvatar(
//       radius: 26,
//       backgroundColor: color,
//       child: IconButton(
//         icon: Icon(icon, color: Colors.white),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }

//WORKING CURRENTLY
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/appointment/booking_success_screen.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen_doctor.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String userRole;
//   final String appointmentId;

//   const VideoCallScreen({
//     super.key,
//     required this.channelName,
//     required this.userRole,
//     required this.appointmentId,
//   });

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   static const String appId = 'a49de82128904c6db10e48851bba1b55';
//   String? token;
//   int? _localUid;
//   Timer? _tokenTimer;

//   bool _isLoading = true;
//   bool _isJoined = false;
//   bool _isMuted = false;
//   bool _isVideoDisabled = false;
//   bool _isFrontCamera = true;
//   String? _errorMessage;

//   RtcEngine? _engine;
//   final Map<int, bool> _remoteUserVideo = {};

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   @override
//   void dispose() {
//     _tokenTimer?.cancel();
//     _engine?.leaveChannel();
//     _engine?.release();
//     _engine = null;
//     super.dispose();
//   }

//   Future<void> _initAgora() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       // Request permissions
//       final status = await [Permission.camera, Permission.microphone].request();
//       if (!status[Permission.camera]!.isGranted ||
//           !status[Permission.microphone]!.isGranted) {
//         throw Exception('Camera/Microphone permission denied');
//       }

//       // Fetch token
//       token = await _fetchToken(widget.channelName);
//       if (token == null) {
//         throw Exception('Failed to get token');
//       }

//       // Create and initialize engine
//       _engine = createAgoraRtcEngine();
//       await _engine!.initialize(RtcEngineContext(
//         appId: appId,
//         logConfig: const LogConfig(level: LogLevel.logLevelInfo),
//       ));

//       // Enable video and set client role
//       await _engine!.enableVideo();
//       await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//       await _engine!
//           .setChannelProfile(ChannelProfileType.channelProfileCommunication);

//       // Register event handlers
//       _engine!.registerEventHandler(RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint('Joined channel successfully');
//           setState(() {
//             _isJoined = true;
//             _localUid = connection.localUid;
//             _isLoading = false;
//           });
//           _startTokenRenewal();
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint('Remote user joined: $remoteUid');
//           setState(() => _remoteUserVideo[remoteUid] = false);
//         },
//         onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
//           debugPrint('Remote user video mute: $muted');
//           setState(() => _remoteUserVideo[remoteUid] = muted);
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) async {
//           debugPrint('User offline: $remoteUid, reason: $reason');
//           setState(() => _remoteUserVideo.remove(remoteUid));

//           final doc = await FirebaseFirestore.instance
//               .collection('appointments')
//               .doc(widget.appointmentId)
//               .get();

//           final status = doc.data()?['status'];
//           if (status == 'completed') {
//             if (!mounted) return;

//             await _engine?.leaveChannel();

//             if (widget.userRole == 'doctor') {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AppointmentCompleteScreenDoctor()),
//               );
//             } else {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AppointmentCompleteScreen()),
//               );
//             }
//           } else {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     widget.userRole == 'patient'
//                         ? 'The doctor has left the session.'
//                         : 'The patient has left the session.',
//                   ),
//                 ),
//               );
//             }
//           }
//         },
//         onError: (ErrorCodeType code, String message) {
//           debugPrint('Agora Error [$code]: $message');
//           if (code == ErrorCodeType.errJoinChannelRejected) {
//             _showError('Failed to join channel (rejected). Please try again.');
//           } else {
//             _showError('Agora Error: $message');
//           }
//         },
//         onConnectionStateChanged: (RtcConnection connection,
//             ConnectionStateType state, ConnectionChangedReasonType reason) {
//           debugPrint('Connection state changed: $state, reason: $reason');
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint('Token will expire soon');
//           _renewToken();
//         },
//       ));

//       // Join channel with retry logic
//       await _joinChannelWithRetry();
//     } catch (e) {
//       debugPrint('Agora initialization error: $e');
//       _showError('Failed to initialize video call: ${e.toString()}');
//     }
//   }

//   Future<void> _joinChannelWithRetry({int maxRetries = 3}) async {
//     int attempts = 0;
//     while (attempts < maxRetries) {
//       try {
//         await _engine!.joinChannel(
//           token: token!,
//           channelId: widget.channelName,
//           uid: 0,
//           options: const ChannelMediaOptions(
//             channelProfile: ChannelProfileType.channelProfileCommunication,
//             clientRoleType: ClientRoleType.clientRoleBroadcaster,
//           ),
//         );
//         return; // Success
//       } catch (e) {
//         attempts++;
//         debugPrint('Join channel attempt $attempts failed: $e');
//         if (attempts >= maxRetries) rethrow;
//         await Future.delayed(const Duration(seconds: 1));
//       }
//     }
//   }

//   Future<String?> _fetchToken(String channelName) async {
//     try {
//       final url = Uri.parse(
//         'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=0&role=publisher',
//       );

//       final response = await http.get(url).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['token'] != null) {
//           return data['token'] as String;
//         }
//       }
//       debugPrint(
//           'Token error: Status ${response.statusCode}, Body: ${response.body}');
//       return null;
//     } catch (e) {
//       debugPrint('Token fetch failed: $e');
//       return null;
//     }
//   }

//   void _startTokenRenewal() {
//     _tokenTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
//       await _renewToken();
//     });
//   }

//   Future<void> _renewToken() async {
//     try {
//       final newToken = await _fetchToken(widget.channelName);
//       if (newToken != null) {
//         await _engine?.renewToken(newToken);
//         token = newToken;
//         debugPrint('Token renewed successfully');
//       }
//     } catch (e) {
//       debugPrint('Token renewal failed: $e');
//     }
//   }

//   Future<String?> _fetchPatientId() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointmentId)
//           .get();
//       return doc['patientId'];
//     } catch (e) {
//       debugPrint('Error fetching patient ID: $e');
//       return null;
//     }
//   }

//   void _openHealthRecordDialog() async {
//     try {
//       final patientId = await _fetchPatientId();
//       if (patientId == null) return;

//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(patientId)
//           .collection('records')
//           .doc('health')
//           .get();

//       if (!doc.exists || !mounted) return;

//       final data = doc.data()!;
//       final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

//       showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (_) {
//           return ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               const Text("Patient's Health Record",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               _recordTile("Blood Type", data['bloodType']),
//               _recordTile("Allergies", data['allergies']),
//               _recordTile("Chronic Conditions", data['chronic']),
//               _recordTile("Medications", data['medications']),
//               _recordTile("Height (cm)", data['height']?.toString()),
//               _recordTile("Weight (kg)", data['weight']?.toString()),
//               if (updatedAt != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16),
//                   child: Text(
//                     "Last Updated: ${DateFormat('dd MMM yyyy').format(updatedAt)}",
//                     style: const TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                 ),
//             ],
//           );
//         },
//       );
//     } catch (e) {
//       debugPrint('Error opening health record: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to load health records')),
//         );
//       }
//     }
//   }

//   Widget _recordTile(String label, String? value) {
//     return ListTile(
//       title: Text(label),
//       subtitle: Text(value?.isNotEmpty == true ? value! : "Not specified"),
//     );
//   }

//   void _showError(String msg) {
//     setState(() {
//       _errorMessage = msg;
//       _isLoading = false;
//     });
//   }

//   Future<void> _retryInitialization() async {
//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });
//     await _initAgora();
//   }

//   void _toggleMute() {
//     setState(() => _isMuted = !_isMuted);
//     _engine?.muteLocalAudioStream(_isMuted);
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoDisabled = !_isVideoDisabled);
//     _engine?.muteLocalVideoStream(_isVideoDisabled);
//   }

//   void _switchCamera() {
//     _engine?.switchCamera().then((_) {
//       setState(() => _isFrontCamera = !_isFrontCamera);
//     });
//   }

//   Future<void> _endCall() async {
//     final isDoctor = widget.userRole == 'doctor';

//     if (isDoctor) {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('End Appointment'),
//           content: const Text('Are you sure you want to end this session?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('End'),
//             ),
//           ],
//         ),
//       );

//       if (confirm == true) {
//         try {
//           await FirebaseFirestore.instance
//               .collection('appointments')
//               .doc(widget.appointmentId)
//               .update({'status': 'completed'});
//         } catch (e) {
//           debugPrint('Error updating appointment status: $e');
//         }
//       } else {
//         return; // Doctor cancelled
//       }
//     }

//     await _engine?.leaveChannel();

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => isDoctor
//               ? const AppointmentCompleteScreenDoctor()
//               : const AppointmentCompleteScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           _renderRemoteVideo(),
//           _renderLocalPreview(),
//           _renderControls(),
//           if (_isLoading) _renderLoading(),
//           if (widget.userRole == 'doctor')
//             Positioned(
//               top: 40,
//               right: 20,
//               child: FloatingActionButton(
//                 heroTag: 'records',
//                 backgroundColor: Colors.teal,
//                 onPressed: _openHealthRecordDialog,
//                 child: const Icon(Icons.description),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _renderRemoteVideo() {
//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error, color: Colors.red, size: 50),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage!,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _retryInitialization,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_remoteUserVideo.isEmpty) {
//       return Center(
//         child: Text(
//           _isJoined ? 'Waiting for participant...' : 'Connecting...',
//           style: const TextStyle(color: Colors.white),
//         ),
//       );
//     }

//     final remoteUid = _remoteUserVideo.keys.first;
//     final isMuted = _remoteUserVideo[remoteUid]!;

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         if (!isMuted)
//           AgoraVideoView(
//             controller: VideoViewController.remote(
//               rtcEngine: _engine!,
//               canvas: VideoCanvas(uid: remoteUid),
//               connection: RtcConnection(channelId: widget.channelName),
//             ),
//           )
//         else
//           const Icon(Icons.videocam_off, size: 80, color: Colors.white),
//       ],
//     );
//   }

//   Widget _renderLocalPreview() {
//     if (!_isJoined || _errorMessage != null) return const SizedBox.shrink();

//     return Positioned(
//       top: 24,
//       right: 16,
//       child: Container(
//         width: 120,
//         height: 160,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.white),
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.black,
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               if (!_isVideoDisabled)
//                 AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: _engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 )
//               else
//                 const Icon(Icons.videocam_off, size: 40, color: Colors.white),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _renderControls() {
//     if (_errorMessage != null) return const SizedBox.shrink();

//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 36),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _controlButton(
//               icon: _isMuted ? Icons.mic_off : Icons.mic,
//               color: _isMuted ? Colors.grey : Colors.blue,
//               onPressed: _toggleMute,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: Icons.call_end,
//               color: Colors.red,
//               onPressed: _endCall,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
//               color: _isVideoDisabled ? Colors.grey : Colors.blue,
//               onPressed: _toggleVideo,
//             ),
//             const SizedBox(width: 16),
//             _controlButton(
//               icon: Icons.cameraswitch,
//               color: Colors.orange,
//               onPressed: _switchCamera,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _renderLoading() {
//     return const Center(
//       child: CircularProgressIndicator(color: Colors.white),
//     );
//   }

//   Widget _controlButton({
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return CircleAvatar(
//       radius: 26,
//       backgroundColor: color,
//       child: IconButton(
//         icon: Icon(icon, color: Colors.white),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }
//WORKING CURRENTLY

//Currently NEW UI/UX

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mediconnect/features/appointment/booking_success_screen.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen.dart';
// import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen_doctor.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String userRole;
//   final String appointmentId;

//   const VideoCallScreen({
//     super.key,
//     required this.channelName,
//     required this.userRole,
//     required this.appointmentId,
//   });

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   static const String appId = 'a49de82128904c6db10e48851bba1b55';
//   String? token;
//   int? _localUid;
//   Timer? _tokenTimer;

//   bool _isLoading = true;
//   bool _isJoined = false;
//   bool _isMuted = false;
//   bool _isVideoDisabled = false;
//   bool _isFrontCamera = true;
//   String? _errorMessage;

//   RtcEngine? _engine;
//   final Map<int, bool> _remoteUserVideo = {};

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   @override
//   void dispose() {
//     _tokenTimer?.cancel();
//     _engine?.leaveChannel();
//     _engine?.release();
//     _engine = null;
//     super.dispose();
//   }

//   Future<void> _initAgora() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       final status = await [Permission.camera, Permission.microphone].request();
//       if (!status[Permission.camera]!.isGranted ||
//           !status[Permission.microphone]!.isGranted) {
//         throw Exception('Camera/Microphone permission denied');
//       }

//       token = await _fetchToken(widget.channelName);
//       if (token == null) {
//         throw Exception('Failed to get token');
//       }

//       _engine = createAgoraRtcEngine();
//       await _engine!.initialize(RtcEngineContext(
//         appId: appId,
//         logConfig: const LogConfig(level: LogLevel.logLevelInfo),
//       ));

//       await _engine!.enableVideo();
//       await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//       await _engine!
//           .setChannelProfile(ChannelProfileType.channelProfileCommunication);

//       _engine!.registerEventHandler(RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint('Joined channel successfully');
//           setState(() {
//             _isJoined = true;
//             _localUid = connection.localUid;
//             _isLoading = false;
//           });
//           _startTokenRenewal();
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint('Remote user joined: $remoteUid');
//           setState(() => _remoteUserVideo[remoteUid] = false);
//         },
//         onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
//           debugPrint('Remote user video mute: $muted');
//           setState(() => _remoteUserVideo[remoteUid] = muted);
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) async {
//           debugPrint('User offline: $remoteUid, reason: $reason');
//           setState(() => _remoteUserVideo.remove(remoteUid));

//           final doc = await FirebaseFirestore.instance
//               .collection('appointments')
//               .doc(widget.appointmentId)
//               .get();

//           final status = doc.data()?['status'];
//           if (status == 'completed') {
//             if (!mounted) return;

//             await _engine?.leaveChannel();

//             if (widget.userRole == 'doctor') {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AppointmentCompleteScreenDoctor()),
//               );
//             } else {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                     builder: (_) => const AppointmentCompleteScreen()),
//               );
//             }
//           } else {
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     widget.userRole == 'patient'
//                         ? 'The doctor has left the session.'
//                         : 'The patient has left the session.',
//                   ),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             }
//           }
//         },
//         onError: (ErrorCodeType code, String message) {
//           debugPrint('Agora Error [$code]: $message');
//           if (code == ErrorCodeType.errJoinChannelRejected) {
//             _showError('Failed to join channel (rejected). Please try again.');
//           } else {
//             _showError('Agora Error: $message');
//           }
//         },
//         onConnectionStateChanged: (RtcConnection connection,
//             ConnectionStateType state, ConnectionChangedReasonType reason) {
//           debugPrint('Connection state changed: $state, reason: $reason');
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint('Token will expire soon');
//           _renewToken();
//         },
//       ));

//       await _joinChannelWithRetry();
//     } catch (e) {
//       debugPrint('Agora initialization error: $e');
//       _showError('Failed to initialize video call: ${e.toString()}');
//     }
//   }

//   Future<void> _joinChannelWithRetry({int maxRetries = 3}) async {
//     int attempts = 0;
//     while (attempts < maxRetries) {
//       try {
//         await _engine!.joinChannel(
//           token: token!,
//           channelId: widget.channelName,
//           uid: 0,
//           options: const ChannelMediaOptions(
//             channelProfile: ChannelProfileType.channelProfileCommunication,
//             clientRoleType: ClientRoleType.clientRoleBroadcaster,
//           ),
//         );
//         return;
//       } catch (e) {
//         attempts++;
//         debugPrint('Join channel attempt $attempts failed: $e');
//         if (attempts >= maxRetries) rethrow;
//         await Future.delayed(const Duration(seconds: 1));
//       }
//     }
//   }

//   Future<String?> _fetchToken(String channelName) async {
//     try {
//       final url = Uri.parse(
//         'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=0&role=publisher',
//       );

//       final response = await http.get(url).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['token'] != null) {
//           return data['token'] as String;
//         }
//       }
//       debugPrint(
//           'Token error: Status ${response.statusCode}, Body: ${response.body}');
//       return null;
//     } catch (e) {
//       debugPrint('Token fetch failed: $e');
//       return null;
//     }
//   }

//   void _startTokenRenewal() {
//     _tokenTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
//       await _renewToken();
//     });
//   }

//   Future<void> _renewToken() async {
//     try {
//       final newToken = await _fetchToken(widget.channelName);
//       if (newToken != null) {
//         await _engine?.renewToken(newToken);
//         token = newToken;
//         debugPrint('Token renewed successfully');
//       }
//     } catch (e) {
//       debugPrint('Token renewal failed: $e');
//     }
//   }

//   Future<String?> _fetchPatientId() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('appointments')
//           .doc(widget.appointmentId)
//           .get();
//       return doc['patientId'];
//     } catch (e) {
//       debugPrint('Error fetching patient ID: $e');
//       return null;
//     }
//   }

//   void _openHealthRecordDialog() async {
//     try {
//       final patientId = await _fetchPatientId();
//       if (patientId == null) return;

//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(patientId)
//           .collection('records')
//           .doc('health')
//           .get();

//       if (!doc.exists || !mounted) return;

//       final data = doc.data()!;
//       final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

//       showModalBottomSheet(
//         context: context,
//         backgroundColor: Colors.white,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         isScrollControlled: true,
//         builder: (_) {
//           return Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const Text(
//                   "Patient's Health Record",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.teal,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       _recordTile("Blood Type", data['bloodType']),
//                       _recordTile("Allergies", data['allergies']),
//                       _recordTile("Chronic Conditions", data['chronic']),
//                       _recordTile("Medications", data['medications']),
//                       _recordTile("Height (cm)", data['height']?.toString()),
//                       _recordTile("Weight (kg)", data['weight']?.toString()),
//                       if (updatedAt != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Text(
//                             "Last Updated: ${DateFormat('dd MMM yyyy').format(updatedAt)}",
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     } catch (e) {
//       debugPrint('Error opening health record: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Failed to load health records'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   Widget _recordTile(String label, String? value) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         title: Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Text(
//           value?.isNotEmpty == true ? value! : "Not specified",
//           style: const TextStyle(fontSize: 14),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//     );
//   }

//   void _showError(String msg) {
//     setState(() {
//       _errorMessage = msg;
//       _isLoading = false;
//     });
//   }

//   Future<void> _retryInitialization() async {
//     setState(() {
//       _errorMessage = null;
//       _isLoading = true;
//     });
//     await _initAgora();
//   }

//   void _toggleMute() {
//     setState(() => _isMuted = !_isMuted);
//     _engine?.muteLocalAudioStream(_isMuted);
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoDisabled = !_isVideoDisabled);
//     _engine?.muteLocalVideoStream(_isVideoDisabled);
//   }

//   void _switchCamera() {
//     _engine?.switchCamera().then((_) {
//       setState(() => _isFrontCamera = !_isFrontCamera);
//     });
//   }

//   Future<void> _endCall() async {
//     final isDoctor = widget.userRole == 'doctor';

//     if (isDoctor) {
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('End Appointment'),
//           content: const Text('Are you sure you want to end this session?'),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('End Session'),
//             ),
//           ],
//         ),
//       );

//       if (confirm == true) {
//         try {
//           await FirebaseFirestore.instance
//               .collection('appointments')
//               .doc(widget.appointmentId)
//               .update({'status': 'completed'});
//         } catch (e) {
//           debugPrint('Error updating appointment status: $e');
//         }
//       } else {
//         return;
//       }
//     }

//     await _engine?.leaveChannel();

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => isDoctor
//               ? const AppointmentCompleteScreenDoctor()
//               : const AppointmentCompleteScreen(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           _renderRemoteVideo(),
//           _renderLocalPreview(),
//           _renderControls(),
//           if (_isLoading) _renderLoading(),
//           if (widget.userRole == 'doctor')
//             Positioned(
//               top: 40,
//               right: 20,
//               child: FloatingActionButton(
//                 heroTag: 'records',
//                 backgroundColor: Colors.teal,
//                 onPressed: _openHealthRecordDialog,
//                 child: const Icon(Icons.medical_services_outlined, size: 28),
//               ),
//             ),
//           Positioned(
//             top: 40,
//             left: 20,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 'Appointment ID: ${widget.appointmentId.substring(0, 8)}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _renderRemoteVideo() {
//     if (_errorMessage != null) {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, color: Colors.red, size: 50),
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//                 onPressed: _retryInitialization,
//                 child: const Text(
//                   'Retry Connection',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_remoteUserVideo.isEmpty) {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(color: Colors.white),
//               const SizedBox(height: 20),
//               Text(
//                 _isJoined ? 'Waiting for participant...' : 'Connecting...',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final remoteUid = _remoteUserVideo.keys.first;
//     final isMuted = _remoteUserVideo[remoteUid]!;

//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         if (!isMuted)
//           AgoraVideoView(
//             controller: VideoViewController.remote(
//               rtcEngine: _engine!,
//               canvas: VideoCanvas(uid: remoteUid),
//               connection: RtcConnection(channelId: widget.channelName),
//             ),
//           )
//         else
//           Container(
//             color: Colors.black,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.videocam_off, size: 80, color: Colors.white54),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Video is turned off',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.8),
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _renderLocalPreview() {
//     if (!_isJoined || _errorMessage != null) return const SizedBox.shrink();

//     return Positioned(
//       top: 24,
//       right: 16,
//       child: Container(
//         width: 120,
//         height: 160,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.white, width: 1.5),
//           borderRadius: BorderRadius.circular(12),
//           color: Colors.black,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 8,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               if (!_isVideoDisabled)
//                 AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: _engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 )
//               else
//                 Container(
//                   color: Colors.black,
//                   child: const Icon(
//                     Icons.videocam_off,
//                     size: 40,
//                     color: Colors.white54,
//                   ),
//                 ),
//               Positioned(
//                 bottom: 8,
//                 left: 8,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     'You',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _renderControls() {
//     if (_errorMessage != null) return const SizedBox.shrink();

//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 36),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 widget.userRole == 'doctor' ? 'Doctor' : 'Patient',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _controlButton(
//                   icon: _isMuted ? Icons.mic_off : Icons.mic,
//                   label: _isMuted ? 'Unmute' : 'Mute',
//                   color: _isMuted ? Colors.grey : Colors.blue,
//                   onPressed: _toggleMute,
//                 ),
//                 const SizedBox(width: 16),
//                 _controlButton(
//                   icon: Icons.call_end,
//                   label: 'End',
//                   color: Colors.red,
//                   onPressed: _endCall,
//                   isEndCall: true,
//                 ),
//                 const SizedBox(width: 16),
//                 _controlButton(
//                   icon: _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
//                   label: _isVideoDisabled ? 'Video On' : 'Video Off',
//                   color: _isVideoDisabled ? Colors.grey : Colors.blue,
//                   onPressed: _toggleVideo,
//                 ),
//                 const SizedBox(width: 16),
//                 _controlButton(
//                   icon: Icons.cameraswitch,
//                   label: 'Switch',
//                   color: Colors.orange,
//                   onPressed: _switchCamera,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _renderLoading() {
//     return Container(
//       color: Colors.black,
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: Colors.teal,
//               strokeWidth: 3,
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Setting up video call...',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _controlButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onPressed,
//     bool isEndCall = false,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: isEndCall ? 60 : 50,
//           height: isEndCall ? 60 : 50,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.3),
//                 blurRadius: 6,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: IconButton(
//             icon: Icon(
//               icon,
//               color: Colors.white,
//               size: isEndCall ? 28 : 24,
//             ),
//             onPressed: onPressed,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }

//Currently NEW UI/UX

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mediconnect/features/appointment/booking_success_screen.dart';
import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen.dart';
import 'package:mediconnect/features/videoCalling/appointment_session_complete_screen_doctor.dart';
import 'package:mediconnect/features/videoCalling/prescription_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String userRole;
  final String appointmentId;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.userRole,
    required this.appointmentId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static const String appId = 'a49de82128904c6db10e48851bba1b55';
  String? token;
  int? _localUid;
  Timer? _tokenTimer;
  Timer? _callDurationTimer;
  Duration _callDuration = Duration.zero;

  bool _isLoading = true;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isFrontCamera = true;
  bool _showControls = true;
  String? _errorMessage;

  RtcEngine? _engine;
  final Map<int, bool> _remoteUserVideo = {};

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startControlsAutoHide();
  }

  void _startControlsAutoHide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isJoined && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsAutoHide();
      }
    });
  }

  @override
  void dispose() {
    _tokenTimer?.cancel();
    _callDurationTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    _engine = null;
    super.dispose();
  }

  Future<void> _initAgora() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Request permissions
      final status = await [Permission.camera, Permission.microphone].request();
      if (!status[Permission.camera]!.isGranted ||
          !status[Permission.microphone]!.isGranted) {
        throw Exception('Camera/Microphone permission denied');
      }

      // Fetch token
      token = await _fetchToken(widget.channelName);
      if (token == null) {
        throw Exception('Failed to get token');
      }

      // Create and initialize engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        logConfig: const LogConfig(level: LogLevel.logLevelInfo),
      ));

      // Enable video and set client role
      await _engine!.enableVideo();
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);

      // Register event handlers
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('Joined channel successfully');
          setState(() {
            _isJoined = true;
            _localUid = connection.localUid;
            _isLoading = false;
          });
          _startTokenRenewal();
          _startCallTimer();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('Remote user joined: $remoteUid');
          setState(() => _remoteUserVideo[remoteUid] = false);
        },
        onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
          debugPrint('Remote user video mute: $muted');
          setState(() => _remoteUserVideo[remoteUid] = muted);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          debugPrint('User offline: $remoteUid, reason: $reason');
          setState(() => _remoteUserVideo.remove(remoteUid));

          final doc = await FirebaseFirestore.instance
              .collection('appointments')
              .doc(widget.appointmentId)
              .get();

          final status = doc.data()?['status'];
          if (status == 'completed') {
            if (!mounted) return;

            await _engine?.leaveChannel();
            _callDurationTimer?.cancel();

            if (widget.userRole == 'doctor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppointmentCompleteScreenDoctor()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppointmentCompleteScreen()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.userRole == 'patient'
                        ? 'The doctor has left the session.'
                        : 'The patient has left the session.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        },
        onError: (ErrorCodeType code, String message) {
          debugPrint('Agora Error [$code]: $message');
          if (code == ErrorCodeType.errJoinChannelRejected) {
            _showError('Failed to join channel (rejected). Please try again.');
          } else {
            _showError('Agora Error: $message');
          }
        },
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          debugPrint('Connection state changed: $state, reason: $reason');
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint('Token will expire soon');
          _renewToken();
        },
      ));

      // Join channel with retry logic
      await _joinChannelWithRetry();
    } catch (e) {
      debugPrint('Agora initialization error: $e');
      _showError('Failed to initialize video call: ${e.toString()}');
    }
  }

  void _startCallTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  // ... [Keep all your existing methods like _joinChannelWithRetry, _fetchToken, etc.] ...

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControlsVisibility,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background with blur effect
            _renderRemoteVideo(),

            // Local preview
            _renderLocalPreview(),

            // Gradient overlay for controls
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

            // Top bar with call info
            if (_showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        widget.userRole == 'doctor' ? 'Patient' : 'Doctor',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(_callDuration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Doctor-specific health records button
            if (widget.userRole == 'doctor' && _showControls)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 20,
                child: _buildIconButton(
                  icon: Icons.medical_services,
                  label: 'Records',
                  onPressed: _openHealthRecordDialog,
                  color: Colors.teal,
                ),
              ),

            // Loading indicator
            if (_isLoading) _renderLoading(),

            // Error message
            if (_errorMessage != null) _renderError(),

            // Bottom controls
            if (_showControls) _renderControls(),
          ],
        ),
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_errorMessage != null) {
      return Container(color: Colors.black);
    }

    if (_remoteUserVideo.isEmpty) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, size: 60, color: Colors.white54),
              const SizedBox(height: 20),
              Text(
                _isJoined ? 'Waiting for participant...' : 'Connecting...',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    final remoteUid = _remoteUserVideo.keys.first;
    final isMuted = _remoteUserVideo[remoteUid]!;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (!isMuted)
          AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine!,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: widget.channelName),
            ),
          )
        else
          Container(
            color: Colors.black,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, size: 80, color: Colors.white54),
                SizedBox(height: 20),
                Text(
                  'Camera is off',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _renderLocalPreview() {
    if (!_isJoined || _errorMessage != null) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!_isVideoDisabled)
                AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              else
                Container(
                  color: Colors.black,
                  child: const Icon(Icons.videocam_off,
                      size: 30, color: Colors.white),
                ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: _isVideoDisabled
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderControls() {
    if (_errorMessage != null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mic and camera status indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isMuted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic_off, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Muted',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    if (_isVideoDisabled)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_off,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Camera off',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Main control buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      onPressed: _toggleMute,
                      active: !_isMuted,
                    ),
                    _buildControlButton(
                      icon: Icons.cameraswitch,
                      label: 'Flip',
                      onPressed: _switchCamera,
                      active: true,
                    ),
                    _buildControlButton(
                      icon: _isVideoDisabled
                          ? Icons.videocam_off
                          : Icons.videocam,
                      label: _isVideoDisabled ? 'Camera on' : 'Camera off',
                      onPressed: _toggleVideo,
                      active: !_isVideoDisabled,
                    ),
                    const SizedBox(width: 20),
                    _buildEndCallButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool active,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, size: 24),
            color: active ? Colors.white : Colors.red[200],
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end, size: 24),
            color: Colors.white,
            onPressed: _endCall,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'End',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 24,
          child: IconButton(
            icon: Icon(icon, size: 20),
            color: Colors.white,
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _renderLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Connecting...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _renderError() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _retryInitialization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

//boommmmmmmmmmmmmmmmmmmm
  Future<void> _joinChannelWithRetry({int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await _engine!.joinChannel(
          token: token!,
          channelId: widget.channelName,
          uid: 0,
          options: const ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileCommunication,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
        return; // Success
      } catch (e) {
        attempts++;
        debugPrint('Join channel attempt $attempts failed: $e');
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<String?> _fetchToken(String channelName) async {
    try {
      final url = Uri.parse(
        'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=0&role=publisher',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          return data['token'] as String;
        }
      }
      debugPrint(
          'Token error: Status ${response.statusCode}, Body: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Token fetch failed: $e');
      return null;
    }
  }

  void _startTokenRenewal() {
    _tokenTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      await _renewToken();
    });
  }

  Future<void> _renewToken() async {
    try {
      final newToken = await _fetchToken(widget.channelName);
      if (newToken != null) {
        await _engine?.renewToken(newToken);
        token = newToken;
        debugPrint('Token renewed successfully');
      }
    } catch (e) {
      debugPrint('Token renewal failed: $e');
    }
  }

  Future<String?> _fetchPatientId() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('appointments')
          .doc(widget.appointmentId)
          .get();
      return doc['patientId'];
    } catch (e) {
      debugPrint('Error fetching patient ID: $e');
      return null;
    }
  }

  String _formatHealthField(dynamic field) {
    if (field == null) return "N/A";
    if (field is List) {
      if (field.isEmpty) return "None";
      if (field.first is Map && field.first.containsKey('label')) {
        return field.map((e) => e['label']).join(", ");
      }
      return field.join(", ");
    }
    if (field is String && field.isEmpty) return "N/A";
    return field.toString();
  }

  void _openHealthRecordDialog() async {
    try {
      final patientId = await _fetchPatientId();
      if (patientId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .collection('records')
          .doc('health')
          .get();

      if (!doc.exists || !mounted) return;

      final data = doc.data()!;
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("Patient's Health Record",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _recordTile("Blood Type", _formatHealthField(data['bloodType'])),
              _recordTile("Allergies", _formatHealthField(data['allergies'])),
              _recordTile("Chronic Conditions",
                  _formatHealthField(data['chronicDiseases'])),
              _recordTile(
                  "Medications", _formatHealthField(data['medications'])),
              _recordTile("Height (cm)", _formatHealthField(data['height'])),
              _recordTile("Weight (kg)", _formatHealthField(data['weight'])),
              if (updatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    "Last Updated: ${DateFormat('dd MMM yyyy').format(updatedAt)}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Error opening health record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load health records')),
        );
      }
    }
  }

  Widget _recordTile(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value?.isNotEmpty == true ? value! : "Not specified"),
    );
  }

  void _showError(String msg) {
    setState(() {
      _errorMessage = msg;
      _isLoading = false;
    });
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    await _initAgora();
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine?.muteLocalAudioStream(_isMuted);
  }

  void _toggleVideo() {
    setState(() => _isVideoDisabled = !_isVideoDisabled);
    _engine?.muteLocalVideoStream(_isVideoDisabled);
  }

  void _switchCamera() {
    _engine?.switchCamera().then((_) {
      setState(() => _isFrontCamera = !_isFrontCamera);
    });
  }

  Future<void> _endCall() async {
    final isDoctor = widget.userRole == 'doctor';

    if (isDoctor) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Appointment'),
          content: const Text('Are you sure you want to end this session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('End'),
            ),
          ],
        ),
      );

      // if (confirm == true) {
      //   try {
      //     await FirebaseFirestore.instance
      //         .collection('appointments')
      //         .doc(widget.appointmentId)
      //         .update({'status': 'completed'});
      //   } catch (e) {
      //     debugPrint('Error updating appointment status: $e');
      //   }
      // } else {
      //   return; // Doctor cancelled
      // }
    }

    await _engine?.leaveChannel();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isDoctor
              ? PrescriptionScreen(
                  appointmentId: widget.appointmentId,
                  callDuration: _callDuration,
                )
              : const AppointmentCompleteScreen(),
        ),
      );
    }
  }
}
