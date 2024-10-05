import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/camera.dart';
import 'package:music_player/widgets/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: MainScreen(),
    );
  }
}
