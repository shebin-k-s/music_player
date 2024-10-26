// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:music_player/Screens/details_screen.dart';
// import 'package:music_player/domains/song_model.dart';
// import 'package:music_player/widgets/main_screen.dart';

// class MiniPlayer extends StatefulWidget {
//   final String trackTitle;
//   final String downloadUrl;
//   final VoidCallback onClose;
//   final int duration;

//   const MiniPlayer({
//     Key? key,
//     required this.trackTitle,
//     required this.onClose,
//     required this.downloadUrl,
//     required this.duration,
//   }) : super(key: key);

//   @override
//   _MiniPlayerState createState() => _MiniPlayerState();
// }

// class _MiniPlayerState extends State<MiniPlayer> {
//   ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
//   ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);
//   Duration totalDuration = Duration.zero;
//   double _sliderValue = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _setupAudioPlayer();
//   }

//   Future<void> _setupAudioPlayer() async {
//     await audioPlayer.setSourceUrl(widget.downloadUrl);

//     audioPlayer.onPositionChanged.listen((position) {
//       currentPosition.value = position;
//       if (mounted) {
//         setState(() {
//           _sliderValue =
//               (position.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
//         });
//       }
//     });

//     // Get and listen to duration changes
//     audioPlayer.onDurationChanged.listen((duration) {
//       setState(() {
//         totalDuration = duration;
//       });
//     });

//     // Handle audio completion
//     audioPlayer.onPlayerComplete.listen((event) {
//       isPlayingNotifier.value = false;
//     });
//   }

//   Future<void> _playPause() async {
//     if (isPlayingNotifier.value) {
//       isPlayingNotifier.value = false;
//       await audioPlayer.pause();
//     } else {
//       isPlayingNotifier.value = true;
//       await audioPlayer.resume();
//     }
//   }

//   Future<void> _seekTo(double value) async {
//     final position =
//         Duration(seconds: (totalDuration.inSeconds * value).toInt());
//     await audioPlayer.seek(position);
//   }

//   @override
//   void dispose() {
//     audioPlayer.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Navigate to the full details page when the mini-player is tapped
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailsScreen(
//               songs: [
//                 Song(
//                   name: widget.trackTitle,
//                   imageUrl: '',
//                   downloadUrl: widget.downloadUrl,
//                   duration: widget.duration,
//                 ),
//               ],
//               selectedIndex: 0,
//               onBack: () {
//                 if (isPlayingNotifier.value) {
//                   audioPlayer.resume();
//                 }
//               },
//             ),
//           ),
//         );
//       },
//       child: Container(
//         height: 90,
//         color: Colors.grey[850],
//         padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
//         child: Row(
//           children: [
//             // Track image or placeholder
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ClipOval(
//                 child: Image.asset(
//                   'assets/images/rotating.gif',
//                   width: 60,
//                   height: 60,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             // Track title and progress slider
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     widget.trackTitle,
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   ValueListenableBuilder<Duration>(
//                     valueListenable: currentPosition,
//                     builder: (context, position, child) {
//                       return SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
//                           trackHeight: 2.5,
//                           overlayShape: RoundSliderOverlayShape(overlayRadius: 10.0),
//                         ),
//                         child: Slider(
//                           value: _sliderValue,
//                           min: 0,
//                           max: 1,
//                           activeColor: Colors.blueAccent,
//                           inactiveColor: Colors.grey,
//                           onChanged: (value) {
//                             setState(() {
//                               _sliderValue = value;
//                             });
//                             _seekTo(value);
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             // Play/Pause button with animation
//             ValueListenableBuilder<bool>(
//               valueListenable: isPlayingNotifier,
//               builder: (context, isPlaying, child) {
//                 return IconButton(
//                   icon: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 300),
//                     transitionBuilder: (child, animation) {
//                       return ScaleTransition(scale: animation, child: child);
//                     },
//                     child: Icon(
//                       isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
//                       key: ValueKey<bool>(isPlaying),
//                       color: Colors.blueAccent,
//                       size: 36,
//                     ),
//                   ),
//                   onPressed: _playPause,
//                 );
//               },
//             ),
//             // Close button
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.white),
//               onPressed: widget.onClose,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
