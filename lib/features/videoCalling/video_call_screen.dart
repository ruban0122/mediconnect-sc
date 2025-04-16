// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;

// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// // class VideoCallScreen extends StatefulWidget {
// //   final String channelName;
// //   final String userRole; // 'doctor' or 'patient'
// //   final String appointmentId;

// //   const VideoCallScreen({
// //     super.key,
// //     required this.channelName,
// //     required this.userRole,
// //     required this.appointmentId,
// //   });

// //   @override
// //   State<VideoCallScreen> createState() => _VideoCallScreenState();
// // }

// // class _VideoCallScreenState extends State<VideoCallScreen> {
// //   static const String appId = 'a49de82128904c6db10e48851bba1b55';
// //   String? token;
// //   int localUid = 0;

// //   RtcEngine? _engine;
// //   bool _isJoined = false;

// //   final List<int> _remoteUids = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     initVideoCall();
// //   }

// //   Future<void> initVideoCall() async {
// //     await [Permission.camera, Permission.microphone].request();

// //     token = await fetchToken(widget.channelName, localUid);

// //     if (token == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Failed to fetch token')),
// //       );
// //       Navigator.pop(context);
// //       return;
// //     }

// //     _engine = createAgoraRtcEngine();
// //     await _engine!.initialize(const RtcEngineContext(appId: appId));
// //     await _engine!.enableVideo();

// //     _engine!.registerEventHandler(
// //       RtcEngineEventHandler(
// //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// //           debugPrint('Local user ${connection.localUid} joined');
// //           setState(() => _isJoined = true);
// //         },
// //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// //           setState(() => _remoteUids.add(remoteUid));
// //         },
// //         onUserOffline: (RtcConnection connection, int remoteUid,
// //             UserOfflineReasonType reason) {
// //           setState(() => _remoteUids.remove(remoteUid));
// //         },
// //       ),
// //     );

// //     await _engine!.joinChannel(
// //       token: token!,
// //       channelId: widget.channelName,
// //       uid: localUid,
// //       options: const ChannelMediaOptions(),
// //     );
// //   }

// //   Future<String?> fetchToken(String channelName, int uid) async {
// //     final url = Uri.parse(
// //       'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=$uid&role=publisher',
// //     );

// //     try {
// //       final response = await http.get(url);
// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         return data['token'];
// //       } else {
// //         debugPrint('Failed to fetch token: ${response.body}');
// //         return null;
// //       }
// //     } catch (e) {
// //       debugPrint('Token fetch error: $e');
// //       return null;
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _engine?.leaveChannel();
// //     _engine?.release();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: Stack(
// //         children: [
// //           _remoteUids.isNotEmpty
// //               ? AgoraVideoView(
// //                   controller: VideoViewController.remote(
// //                     rtcEngine: _engine!,
// //                     canvas: VideoCanvas(uid: _remoteUids.first),
// //                     connection: RtcConnection(channelId: widget.channelName),
// //                   ),
// //                 )
// //               : const Center(
// //                   child: Text("Waiting for participant...",
// //                       style: TextStyle(color: Colors.white))),
// //           Align(
// //             alignment: Alignment.topLeft,
// //             child: SafeArea(
// //               child: Container(
// //                 width: 120,
// //                 height: 160,
// //                 margin: const EdgeInsets.all(10),
// //                 child: AgoraVideoView(
// //                   controller: VideoViewController(
// //                     rtcEngine: _engine!,
// //                     canvas: const VideoCanvas(uid: 0),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Align(
// //             alignment: Alignment.bottomCenter,
// //             child: Padding(
// //               padding: const EdgeInsets.only(bottom: 32),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   _controlButton(Icons.call_end, Colors.red, () {
// //                     Navigator.pop(context);
// //                   }),
// //                 ],
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _controlButton(IconData icon, Color color, VoidCallback onTap) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 20),
// //       child: CircleAvatar(
// //         radius: 28,
// //         backgroundColor: color,
// //         child: IconButton(
// //           icon: Icon(icon, color: Colors.white),
// //           onPressed: onTap,
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String userRole; // 'doctor' or 'patient'
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

//   RtcEngine? _engine;
//   final List<int> _remoteUids = [];

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     try {
//       // 1. Request permissions
//       await [Permission.camera, Permission.microphone].request();

//       // 2. Fetch token
//       token = await _fetchToken(widget.channelName);
//       if (token == null) throw Exception('Failed to get token');

//       // 3. Create and initialize engine
//       _engine = createAgoraRtcEngine();
//       await _engine!.initialize(RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ));

//       // 4. Set client role based on user type
//       await _engine!.setClientRole(
//         role: widget.userRole == 'doctor'
//             ? ClientRoleType.clientRoleBroadcaster
//             : ClientRoleType.clientRoleAudience,
//       );

//       // 5. Enable video
//       await _engine!.enableVideo();

//       // 6. Register event handlers
//       _engine!.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//             setState(() {
//               _isJoined = true;
//               _localUid = connection.localUid;
//               _isLoading = false;
//             });
//           },
//           onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//             setState(() => _remoteUids.add(remoteUid));
//           },
//           onUserOffline: (RtcConnection connection, int remoteUid,
//               UserOfflineReasonType reason) {
//             setState(() => _remoteUids.remove(remoteUid));
//             if (_remoteUids.isEmpty) {
//               _showCallEndedMessage();
//             }
//           },
//           onError: (ErrorCodeType err, String msg) {
//             _showError('Error: $err, $msg');
//           },
//         ),
//       );

//       // 7. Join channel
//       await _engine!.joinChannel(
//         token: token!,
//         channelId: widget.channelName,
//         uid: 0, // Let Agora assign UID
//         options: const ChannelMediaOptions(
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         ),
//       );
//     } catch (e) {
//       _showError('Failed to initialize video call: $e');
//       if (mounted) Navigator.pop(context);
//     }
//   }

//   Future<String?> _fetchToken(String channelName) async {
//     final url = Uri.parse(
//       'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?'
//       'channelName=$channelName&uid=0&role=publisher',
//     );

//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body)['token'];
//       } else {
//         throw Exception('Failed with status ${response.statusCode}');
//       }
//     } catch (e) {
//       debugPrint('Token fetch error: $e');
//       return null;
//     }
//   }

//   void _showCallEndedMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Other participant has left the call')),
//     );
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) Navigator.pop(context);
//     });
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _toggleMute() {
//     setState(() => _isMuted = !_isMuted);
//     _engine!.muteLocalAudioStream(_isMuted);
//   }

//   void _toggleVideo() {
//     setState(() => _isVideoDisabled = !_isVideoDisabled);
//     _engine!.muteLocalVideoStream(_isVideoDisabled);
//   }

//   Future<void> _endCall() async {
//     await _engine?.leaveChannel();
//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _engine?.leaveChannel();
//     _engine?.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Remote video
//           _renderRemoteVideo(),

//           // Local preview
//           if (_isJoined) _renderLocalPreview(),

//           // Controls
//           _renderControls(),

//           // Loading overlay
//           if (_isLoading) _renderLoading(),
//         ],
//       ),
//     );
//   }

//   Widget _renderRemoteVideo() {
//     if (_remoteUids.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _isJoined ? 'Waiting for participant...' : 'Connecting...',
//               style: const TextStyle(color: Colors.white),
//             ),
//             if (_isLoading)
//               const Padding(
//                 padding: EdgeInsets.only(top: 20),
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//           ],
//         ),
//       );
//     }

//     return AgoraVideoView(
//       controller: VideoViewController.remote(
//         rtcEngine: _engine!,
//         canvas: VideoCanvas(uid: _remoteUids.first),
//         connection: RtcConnection(channelId: widget.channelName),
//       ),
//     );
//   }

//   Widget _renderLocalPreview() {
//     return Positioned(
//       top: 20,
//       right: 20,
//       child: SizedBox(
//         width: 120,
//         height: 160,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: AgoraVideoView(
//             controller: VideoViewController(
//               rtcEngine: _engine!,
//               canvas: const VideoCanvas(uid: 0),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _renderControls() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 32),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _controlButton(
//               icon: _isMuted ? Icons.mic_off : Icons.mic,
//               color: _isMuted ? Colors.grey : Colors.blue,
//               onPressed: _toggleMute,
//             ),
//             const SizedBox(width: 20),
//             _controlButton(
//               icon: Icons.call_end,
//               color: Colors.red,
//               onPressed: _endCall,
//             ),
//             const SizedBox(width: 20),
//             _controlButton(
//               icon: _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
//               color: _isVideoDisabled ? Colors.grey : Colors.blue,
//               onPressed: _toggleVideo,
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
//       radius: 28,
//       backgroundColor: color,
//       child: IconButton(
//         icon: Icon(icon, color: Colors.white),
//         onPressed: onPressed,
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String userRole; // 'doctor' or 'patient'
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

  bool _isLoading = true;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isFrontCamera = true;

  RtcEngine? _engine;
  final List<int> _remoteUids = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    token = await _fetchToken(widget.channelName);
    if (token == null) return _showError('Failed to get token');

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));

    await _engine!.setClientRole(
      role: widget.userRole == 'doctor'
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    await _engine!.enableVideo();

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          _isJoined = true;
          _localUid = connection.localUid;
          _isLoading = false;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() => _remoteUids.add(remoteUid));
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() => _remoteUids.remove(remoteUid));
        if (_remoteUids.isEmpty) _showCallEndedMessage();
      },
      onError: (ErrorCodeType code, String message) {
        _showError("Agora Error [$code]: $message");
      },
    ));

    await _engine!.joinChannel(
      token: token!,
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<String?> _fetchToken(String channelName) async {
    final url = Uri.parse(
      'https://generateagoratoken-6sxq7hgfpa-uc.a.run.app?channelName=$channelName&uid=0&role=publisher',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['token'];
      } else {
        debugPrint('Token error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Token fetch failed: $e');
      return null;
    }
  }

  void _showCallEndedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Other participant has left')),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
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
    await _engine?.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _renderRemoteVideo(),
          if (_isJoined && !_isVideoDisabled) _renderLocalPreview(),
          _renderControls(),
          if (_isLoading) _renderLoading(),
        ],
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUids.isEmpty) {
      return Center(
        child: Text(
          _isJoined ? 'Waiting for participant...' : 'Connecting...',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUids.first),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  Widget _renderLocalPreview() {
    return Positioned(
      top: 24,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine!,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderControls() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _controlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              color: _isMuted ? Colors.grey : Colors.blue,
              onPressed: _toggleMute,
            ),
            const SizedBox(width: 16),
            _controlButton(
              icon: Icons.call_end,
              color: Colors.red,
              onPressed: _endCall,
            ),
            const SizedBox(width: 16),
            _controlButton(
              icon: _isVideoDisabled ? Icons.videocam_off : Icons.videocam,
              color: _isVideoDisabled ? Colors.grey : Colors.blue,
              onPressed: _toggleVideo,
            ),
            const SizedBox(width: 16),
            _controlButton(
              icon: Icons.cameraswitch,
              color: Colors.orange,
              onPressed: _switchCamera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: color,
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

