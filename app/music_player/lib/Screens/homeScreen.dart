import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/applications/music_player/music_player_bloc.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<MusicPlayerBloc>().add(FetchMusic(
        query: searchController.text.isNotEmpty
            ? searchController.text
            : "malayalam"));

    print('home revul');
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
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) async {
                        context
                            .read<MusicPlayerBloc>()
                            .add(FetchMusic(query: value));
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                  buildWhen: (previous, current) =>
                      current is MusicFetched || current is MusicFetching,
                  builder: (context, state) {
                    print(state);
                    if (state is MusicFetched) {
                      if (state.songs.isEmpty) {
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
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: state.songs.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  context
                                      .read<MusicPlayerBloc>()
                                      .add(PlayMusic(musicIndex: index));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailsScreen(
                                        song: state.songs[index],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          state.songs[index].imageUrl,
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
                                              state.songs[index].name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              state.songs[index].authorName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      BlocBuilder<MusicPlayerBloc,
                                          MusicPlayerState>(
                                        buildWhen: (previous, current) =>
                                            ((current is MusicPlaying &&
                                                    current.currentMusicIndex ==
                                                        index) ||
                                                (current is MusicPaused &&
                                                    current.currentMusicIndex ==
                                                        index) ||
                                                current is MusicPlaying &&
                                                    current.previousMusicIndex ==
                                                        index),
                                        builder: (context, state) {
                                          final isPlaying = state
                                                  is MusicPlaying &&
                                              state.currentMusicIndex == index;
                                          print(
                                              '$state index $index isplaying $isPlaying');
                                          return IconButton(
                                            icon: Icon(
                                              isPlaying
                                                  ? Icons.pause_circle_filled
                                                  : Icons.play_circle_filled,
                                              size: 40,
                                              color: Colors.indigo.shade400,
                                            ),
                                            onPressed: () async {
                                              if (isPlaying) {
                                                context
                                                    .read<MusicPlayerBloc>()
                                                    .add(PauseMusic());
                                              } else {
                                                context
                                                    .read<MusicPlayerBloc>()
                                                    .add(PlayMusic(
                                                      musicIndex: index,
                                                    ));
                                              }
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
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
   

/*
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
              */