import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/widgets/main_screen.dart';

class DetailsScreen extends StatelessWidget {
  final String trackTitle;
  final String trackUrl;
  final int duration;
  final VoidCallback onBack;

  DetailsScreen(
      {super.key,
      required this.trackTitle,
      required this.onBack,
      required this.trackUrl,
      required this.duration});

  ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);

  Duration totalDuration = const Duration(seconds: 0);

  Future<void> setupAudioPlayer() async {
    audioPlayer.setSourceUrl(trackUrl);
    totalDuration = Duration(seconds: duration);

    audioPlayer.onPositionChanged.listen((position) {
      currentPosition.value = position;
    });
  }

  Future<void> playPause() async {
    if (isPlayingNotifier.value) {
      isPlayingNotifier.value = false;
      isLoading.value = true;
      await audioPlayer.pause();
      isLoading.value = false;
    } else {
      isPlayingNotifier.value = true;
      isLoading.value = true;
      await audioPlayer.resume();
      isLoading.value = false;
    }
  }

  Future<void> stop() async {
    isPlayingNotifier.value = false;
    isLoading.value = true;
    await audioPlayer.stop();
    isLoading.value = false;
  }

  Future<void> seekTo(Duration duration) async {
    await audioPlayer.seek(duration);
  }

  @override
  Widget build(BuildContext context) {
    setupAudioPlayer();

    playPause();
    return WillPopScope(
      onWillPop: () async {
        onBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              onBack();
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                valueListenable: isPlayingNotifier,
                builder: (context, isPlaying, child) {
                  return Image.asset(
                    isPlaying
                        ? 'assets/images/rotating.gif'
                        : 'assets/images/static.png',
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                trackTitle,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<Duration>(
                    valueListenable: currentPosition,
                    builder: (context, position, child) {
                      return Text(
                        "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                      );
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder<Duration>(
                      valueListenable: currentPosition,
                      builder: (context, position, child) {
                        return Slider(
                          value: position.inSeconds.toDouble(),
                          min: 0,
                          max: totalDuration.inSeconds.toDouble(),
                          onChanged: (value) {
                            seekTo(Duration(seconds: value.toInt()));
                          },
                        );
                      },
                    ),
                  ),
                  Text(
                    "${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder(
                valueListenable: isPlayingNotifier,
                builder: (context, isPlaying, child) {
                  return IconButton(
                    iconSize: 64,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                    ),
                    onPressed: () => playPause(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
