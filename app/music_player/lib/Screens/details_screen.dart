import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/api/model.dart';
import 'package:music_player/widgets/main_screen.dart';

class DetailsScreen extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onBack;
  final List<Song> songs;

  DetailsScreen({
    super.key,
    required this.onBack,
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
    await audioPlayer.stop();

    audioPlayer.setSourceUrl(songs[num].downloadUrl);
    totalDuration = Duration(seconds: songs[num].duration);

    currentIndex.value = num;
    isPlayingNotifier.value = false;

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
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ValueListenableBuilder(
                    valueListenable: isPlayingNotifier,
                    builder: (context, isPlaying, child) {
                      return Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            isPlaying
                                ? 'assets/images/rotating.gif'
                                : 'assets/images/static.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  ValueListenableBuilder(
                    valueListenable: currentIndex,
                    builder: (context, index, child) {
                      return Column(
                        children: [
                          Text(
                            songs[index].name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Unknown Artist',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  ValueListenableBuilder<Duration>(
                    valueListenable: currentPosition,
                    builder: (context, position, child) {
                      return Column(
                        children: [
                          Slider(
                            value: position.inSeconds.toDouble(),
                            min: 0,
                            max: totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              seekTo(Duration(seconds: value.toInt()));
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: currentIndex,
                                  builder: (context, value, child) {
                                    return Text(
                                      "${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 48,
                        onPressed: () => changeTracker(-1),
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white),
                      ),
                      ValueListenableBuilder(
                        valueListenable: isPlayingNotifier,
                        builder: (context, isPlaying, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 64,
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.deepPurple.shade800,
                              ),
                              onPressed: () => playPause(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        iconSize: 48,
                        onPressed: () => changeTracker(1),
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
