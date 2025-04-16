// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';

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
//       onUserOffline: (RtcConnection connection, int remoteUid,
//           UserOfflineReasonType reason) {
//         setState(() => _remoteUserVideo.remove(remoteUid));
//         if (_remoteUserVideo.isEmpty) _showCallEndedMessage();
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
//           _renderRemoteVideo(),
//           _renderLocalPreview(),
//           _renderControls(),
//           if (_isLoading) _renderLoading(),
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

import 'dart:convert';
import 'package:flutter/material.dart';
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

  bool _isLoading = true;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoDisabled = false;
  bool _isFrontCamera = true;

  RtcEngine? _engine;
  final Map<int, bool> _remoteUserVideo = {};

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
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
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
        setState(() => _remoteUserVideo[remoteUid] = false);
      },
      onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
        setState(() => _remoteUserVideo[remoteUid] = muted);
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        setState(() => _remoteUserVideo.remove(remoteUid));
        if (_remoteUserVideo.isEmpty) _showCallEndedMessage();
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

  Future<String?> _fetchPatientId() async {
    final doc = await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .get();
    return doc['patientId'];
  }

  void _openHealthRecordDialog() async {
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
            _recordTile("Blood Type", data['bloodType']),
            _recordTile("Allergies", data['allergies']),
            _recordTile("Cronic Conditions", data['chronic']),
            _recordTile("Medications", data['medications']),
            _recordTile("Height (cm)", data['height'].toString()),
            _recordTile("Weight (kg)", data['weight'].toString()),
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
  }

  Widget _recordTile(String label, String? value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(value?.isNotEmpty == true ? value! : "Not specified"),
    );
  }

  void _showCallEndedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ending Session...')),
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
          _renderLocalPreview(),
          _renderControls(),
          if (_isLoading) _renderLoading(),
          if (widget.userRole == 'doctor')
            Positioned(
              top: 40,
              right: 20,
              child: FloatingActionButton(
                heroTag: 'records',
                backgroundColor: Colors.teal,
                onPressed: _openHealthRecordDialog,
                child: const Icon(Icons.description),
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderRemoteVideo() {
    if (_remoteUserVideo.isEmpty) {
      return Center(
        child: Text(
          _isJoined ? 'Waiting for participant...' : 'Connecting...',
          style: const TextStyle(color: Colors.white),
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
          const Icon(Icons.videocam_off, size: 80, color: Colors.white),
      ],
    );
  }

  Widget _renderLocalPreview() {
    if (!_isJoined) return const SizedBox.shrink();

    return Positioned(
      top: 24,
      right: 16,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
                const Icon(Icons.videocam_off, size: 40, color: Colors.white),
            ],
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
