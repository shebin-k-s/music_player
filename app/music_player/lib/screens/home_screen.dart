import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicPlayer extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

  ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  ValueNotifier<bool> isLoading = ValueNotifier(false);

  String currentSong =
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  MusicPlayer({super.key});

  Future<void> _playPause() async {
    if (isPlayingNotifier.value) {
      isPlayingNotifier.value = false;
      isLoading.value = true;
      await _audioPlayer.pause();
      isLoading.value = false;
      print('success');
    } else {
      isPlayingNotifier.value = true;
      isLoading.value = true;
      await _audioPlayer.play(UrlSource(currentSong));
      isLoading.value = false;
    }
  }

  Future<void> _stop() async {
    isPlayingNotifier.value = false;
    isLoading.value = true;
    await _audioPlayer.stop();
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: isPlayingNotifier,
              builder: (context, isPlaying, child) {
                return Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 100,
                  color: Colors.blue,
                );
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: isLoading,
              builder: (context, loading, child) {
                if (loading) {
                  return const CircularProgressIndicator();
                } else if(isPlayingNotifier.value){
                  return const Text(
                    "Now Playing: Song 1",
                    style: TextStyle(fontSize: 24),
                  );
                } else {
                  return const Text(
                    "Play Song",
                    style: TextStyle(fontSize: 24),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _playPause,
              child: ValueListenableBuilder(
                  valueListenable: isPlayingNotifier,
                  builder: (context, isPlaying, child) {
                    return Text(
                      isPlaying ? "Pause" : "Play",
                    );
                  }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stop,
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
