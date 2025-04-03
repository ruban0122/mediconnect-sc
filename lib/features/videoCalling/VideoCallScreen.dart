// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final String token;

//   const VideoCallScreen({
//     super.key,
//     required this.channelName,
//     required this.token,
//   });

//   @override
//   State<VideoCallScreen> createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   late RtcEngine _engine;
//   int? _remoteUid;
//   bool _localUserJoined = false;

//   @override
//   void initState() {
//     super.initState();
//     _initAgora();
//   }

//   Future<void> _initAgora() async {
//     await [Permission.camera, Permission.microphone].request();

//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: "a49de82128904c6db10e48851bba1b55", // 🔴 Replace with actual App ID
//     ));

//     await _engine.enableVideo();

//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );

//     await _engine.joinChannel(
//       token: widget.token,
//       channelId: widget.channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel();
//     _engine.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Video Call")),
//       body: Stack(
//         children: [
//           // Remote User Video
//           Center(
//             child: _remoteUid != null
//                 ? AgoraVideoView(
//                     controller: VideoViewController.remote(
//                       rtcEngine: _engine,
//                       canvas: VideoCanvas(uid: _remoteUid!),
//                       connection: RtcConnection(channelId: widget.channelName),
//                     ),
//                   )
//                 : const Text("Waiting for the other user..."),
//           ),

//           // Local User Video (small overlay)
//           Positioned(
//             bottom: 20,
//             right: 20,
//             width: 100,
//             height: 150,
//             child: _localUserJoined
//                 ? AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           ),

//           // End Call Button
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: FloatingActionButton(
//               backgroundColor: Colors.red,
//               onPressed: () {
//                 _engine.leaveChannel();
//                 Navigator.pop(context);
//               },
//               child: const Icon(Icons.call_end),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }