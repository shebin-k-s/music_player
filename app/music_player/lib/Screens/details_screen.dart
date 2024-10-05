import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/api/model.dart';
import 'package:music_player/widgets/main_screen.dart';

class DetailsScreen extends StatelessWidget {
  // final String trackTitle;
  // final String trackUrl;
  // final int duration;
  final int selectedIndex;
  final VoidCallback onBack;
  final List<Song> songs;

  DetailsScreen({
    super.key,
    required this.onBack,
    // required this.trackTitle,
    // required this.trackUrl,
    // required this.duration,
    required this.songs,
    required this.selectedIndex,
  });

  ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  ValueNotifier<Duration> currentPosition = ValueNotifier(Duration.zero);

  ValueNotifier<int> currentIndex = ValueNotifier(0);

  Duration totalDuration = const Duration(seconds: 0);

  Future<void> setupAudioPlayer() async {
    currentIndex.value = selectedIndex;

    audioPlayer.setSourceUrl(songs[currentIndex.value].downloadUrl);
    totalDuration = Duration(seconds: songs[currentIndex.value].duration);

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

  Future<void> changeTracker(int value) async {
    int num = (currentIndex.value + value) % songs.length;
    currentIndex.value = num;
    audioPlayer.setSourceUrl(songs[num].downloadUrl);
    totalDuration = Duration(seconds: songs[num].duration);

    playPause();
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
                songs[selectedIndex].name,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    iconSize: 64,
                    onPressed: () => changeTracker(-1),
                    icon: const Icon(Icons.skip_previous),
                  ),
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
                  IconButton(
                    iconSize: 64,
                    onPressed: () => changeTracker(1),
                    icon: const Icon(Icons.skip_next),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
