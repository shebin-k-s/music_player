import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/Screens/homeScreen.dart';
import 'package:music_player/screens/analytics.dart';
import 'package:music_player/screens/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

AudioPlayer audioPlayer = AudioPlayer();

class MainScreen extends StatelessWidget {
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  final _pages = [
    HomeScreen(),
    TakePhotoAutomatically(),
    EmotionAnalyticsScreen(),
  ];

  MainScreen({super.key});

  void _onItemTapped(int index) async {
    selectedIndexNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedIndexNotifier,
      builder: (context, index, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Musify',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.indigo.shade800,
            elevation: 0,
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
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                label: 'Analytics',
              ),
            ],
            currentIndex: index,
            selectedItemColor: Colors.indigo.shade800,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 8,
            onTap: (index) => _onItemTapped(index),
          ),
        );
      },
    );
  }
}
