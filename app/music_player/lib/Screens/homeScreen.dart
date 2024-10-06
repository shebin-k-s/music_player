import 'package:flutter/material.dart';
import 'package:music_player/api/api.dart';
import 'package:music_player/api/model.dart';
import 'package:music_player/widgets/main_screen.dart';
import 'mini_player.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  ValueNotifier<bool> isPlaying = ValueNotifier(false);

  ValueNotifier<int> currentTrackIndex = ValueNotifier(-1);

  List<Song> songs = [];

  TextEditingController searchController = TextEditingController();

  ValueNotifier<String> searchQuery = ValueNotifier('');

  HomeScreen({super.key});

  Future<List<Song>> getSongs() async {
    return ApiService().getSongData(
        searchQuery.value.isNotEmpty ? searchQuery.value : 'malayalam song');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade800, Colors.indigo.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search songs...',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) async{
                        searchQuery.value = value;
                        songs = await getSongs();
                        
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: searchQuery,
                  builder: (context, query, child) {
                    return FutureBuilder<List<Song>>(
                      future: getSongs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 60, color: Colors.red.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading data',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.red.shade300),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.music_off,
                                    size: 60, color: Colors.white70),
                                SizedBox(height: 16),
                                Text(
                                  'No songs found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        } else {
                          songs = snapshot.data!;
                          return ListView.builder(
                            itemCount: songs.length,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            songs[index].imageUrl,
                                            fit: BoxFit.cover,
                                            width: 70,
                                            height: 70,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                songs[index].name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Unknown Artist',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: currentTrackIndex,
                                          builder: (context, value, child) {
                                            return IconButton(
                                              icon: Icon(
                                                isPlaying.value &&
                                                        value == index
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                size: 40,
                                                color: Colors.indigo.shade400,
                                              ),
                                              onPressed: () async {
                                                audioPlayer.setSourceUrl(
                                                    songs[index].downloadUrl);
                                                int temp =
                                                    currentTrackIndex.value;
                                                currentTrackIndex.value = index;

                                                if (isPlaying.value &&
                                                    temp == index) {
                                                  isPlaying.value = false;
                                                  await audioPlayer.pause();
                                                } else {
                                                  isPlaying.value = true;
                                                  await audioPlayer.resume();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomSheet: ValueListenableBuilder(
      //   valueListenable: currentTrackIndex,
      //   builder: (context, index, child) {
      //     if (index >= 0) {
      //       return MiniPlayer(
      //         trackTitle: songs[index].name,
      //         duration: songs[index].duration,
      //         downloadUrl: songs[index].downloadUrl,
      //         onClose: () {
      //           isPlaying.value = false;
      //         },
      //       );
      //     } else {
      //       return const SizedBox.shrink();
      //     }
      //   },
      // ),
    );
  }
}
