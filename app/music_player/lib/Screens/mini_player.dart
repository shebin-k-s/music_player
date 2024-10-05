import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_player/Screens/details_screen.dart';
import 'package:music_player/widgets/main_screen.dart';

class MiniPlayer extends StatefulWidget {
  final String trackTitle;
  final String downloadUrl;
  final VoidCallback onClose;
  final int duration;

  MiniPlayer({
    super.key,
    required this.trackTitle,
    required this.onClose,
    required this.downloadUrl,
    required this.duration,
  });

  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);
  Duration totalDuration = Duration.zero;
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    await audioPlayer.setSourceUrl(widget.downloadUrl);

    audioPlayer.onPositionChanged.listen((position) {
      currentPosition.value = position;
      setState(() {
        _sliderValue =
            (position.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
      });
    });

    // Get and listen to duration changes
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    // Handle audio completion
    audioPlayer.onPlayerComplete.listen((event) {
      isPlayingNotifier.value = false;
    });
  }

  Future<void> _playPause() async {
    if (isPlayingNotifier.value) {
      isPlayingNotifier.value = false;
      await audioPlayer.pause();
    } else {
      isPlayingNotifier.value = true;
      await audioPlayer.resume();
    }
  }

  Future<void> _seekTo(double value) async {
    final position =
        Duration(seconds: (totalDuration.inSeconds * value).toInt());
    await audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the full details page when the mini-player is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsScreen(
              trackUrl: widget.downloadUrl,
              trackTitle: widget.trackTitle,
              duration: totalDuration.inSeconds,
              onBack: () {
                if (isPlayingNotifier.value) {
                  audioPlayer.resume();
                }
              },
            ),
          ),
        );
      },
      child: Container(
        height: 80,
        color: Colors.grey[900],
        child: Row(
          children: [
            // Display circular track image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.asset('assets/images/rotating.gif'),
              ),
            ),
            // Track title and progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.trackTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  ValueListenableBuilder<Duration>(
                    valueListenable: currentPosition,
                    builder: (context, position, child) {
                      return Slider(
                        value: _sliderValue,
                        min: 0,
                        max: 1,
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = value;
                          });
                          _seekTo(value);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // Play/Pause button
            ValueListenableBuilder<bool>(
              valueListenable: isPlayingNotifier,
              builder: (context, isPlaying, child) {
                return IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: _playPause,
                );
              },
            ),
            // Close or collapse button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: widget.onClose,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // The global audio player should not be disposed here
    super.dispose();
  }
}
