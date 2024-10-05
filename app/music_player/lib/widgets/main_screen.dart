import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/Screens/homeScreen.dart';
import 'package:music_player/screens/camera.dart';

import '../Screens/ai_screen.dart';
  AudioPlayer audioPlayer = AudioPlayer();


class MainScreen extends StatelessWidget {
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  final _pages = [
    HomeScreen(),
    TakePhotoAutomatically(),
  ];

  MainScreen({super.key});

  void _onItemTapped(int index) {
    selectedIndexNotifier.value = index;
  }

 

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedIndexNotifier,
      builder: (context, index, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gecfy'),
          ),
          body: _pages[index],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.computer),
                label: 'AI',
              ),
            ],
            currentIndex: index,
            selectedItemColor: Colors.blue,
            onTap: (index) => _onItemTapped(index),
          ),
        );
      },
    );
  }
}
