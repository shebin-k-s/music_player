import 'package:flutter/material.dart';
import 'package:music_player/api/api.dart';
import 'package:music_player/api/model.dart';
import 'package:music_player/widgets/main_screen.dart';
import 'mini_player.dart';
import 'details_screen.dart'; // Import the new details screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<bool> isPlaying =
      ValueNotifier(false); // Flag to show/hide mini-player
  ValueNotifier<int> currentTrackIndex = ValueNotifier(-1);
  List<Song> songs = [];

  Future<List<Song>> getSongs() async {
    if (songs.isEmpty) {
      return ApiService().getSongData('malayalam song');
    } else {
      return songs;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: getSongs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No songs found'));
        } else {
          songs = snapshot.data!;

          return Stack(
            children: [
              ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(songs[index].name),
                    trailing: IconButton(
                        icon: ValueListenableBuilder(
                            valueListenable: currentTrackIndex,
                            builder: (context, value, child) {
                              return Icon(
                                value == index ? Icons.pause : Icons.play_arrow,
                              );
                            }),
                        onPressed: () async {
                          audioPlayer.setSourceUrl(songs[index].downloadUrl);
                          currentTrackIndex.value = index;
                          if (isPlaying.value) {
                            isPlaying.value = false;
                            await audioPlayer.pause();
                          } else {
                            isPlaying.value = true;
                            await audioPlayer.resume();
                          }
                          print('Play ${songs[index].name}');
                        }),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            songs: songs,
                            selectedIndex: index,
                            onBack: () {
                              isPlaying.value = true;
                              currentTrackIndex.value = index;
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: currentTrackIndex,
                builder: (context, index, child) {
                  if (index >= 0) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: MiniPlayer(
                        trackTitle: songs[index].name,
                        duration: songs[index].duration,
                        downloadUrl: songs[index].downloadUrl,
                        onClose: () {
                          isPlaying.value = false;
                        },
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        }
      },
    );
  }
}
