import 'dart:developer' as dev;
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:music_player/Screens/details_screen.dart';
import 'package:music_player/api/label.dart';
import 'package:music_player/applications/music_player/music_player_bloc.dart';
import 'package:music_player/domains/song_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakePhotoAutomatically extends StatefulWidget {
  const TakePhotoAutomatically({super.key});

  @override
  _TakePhotoAutomaticallyState createState() => _TakePhotoAutomaticallyState();
}

class _TakePhotoAutomaticallyState extends State<TakePhotoAutomatically> {
  List<CameraDescription> cameras = [];

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  List<Song> songs = [];

  void getSongs(String query) async {
    int randomNumber = Random().nextInt(10) + 1;
    print(query);
    String res = "";
    if (query == 'sad') {
      res = neutral.toString();
    } else if (query == "happy") {
      res = happy[randomNumber];
    } else if (query == "angry") {
      res = neutral[randomNumber];
    } else if (query == "disgusted") {
      res = inspiring[randomNumber];
    } else if (query == "surprised") {
      res = melody[randomNumber];
    } else if (query == "fearful") {
      res = motivating[randomNumber];
    } else if (query == "neutral") {
      res = melody[randomNumber];
    } else {
      res = "malayalam song";
    }

    context.read<MusicPlayerBloc>().add(FetchMusic(query: res));
  }

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
      model: 'assets/facialmodel.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    if (res == null) {
      print('Error loading model');
    }

    dev.log("tflite init");
  }

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    await _tfliteInit();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty || cameras.length <= 1) {
      dev.log('No front-facing camera found');
      return;
    }
    dev.log('Front-facing camera found');

    _cameraController = CameraController(
      cameras[1],
      ResolutionPreset.high,
    );

    try {
      await _cameraController?.initialize();
      setState(() {
        _isCameraInitialized = true;
      });

      // Automatically take a photo after the camera is initialized
      _takePhoto();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile image = await _cameraController!.takePicture();
        dev.log('Image taken');
        var recognitions;
        try {
          recognitions = await Tflite.runModelOnImage(
            path: image.path, // required
            imageMean: 117, // defaults to 117.0
            imageStd: 1, // defaults to 1.0
            numResults: 2, // defaults to 5
            threshold: 0.1, // defaults to 0.1
            asynch: true, // defaults to true
          );
        } catch (e) {
          print("Error running model: $e");
          return;
        }

        if (recognitions == null || recognitions.isEmpty) {
          print("No recognitions found");
          return;
        }

        print(recognitions);
        getSongs(recognitions[0]['label']);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        int count = prefs.getInt(recognitions[0]['label']) ?? 0;

        count++;
        await prefs.setInt(recognitions[0]['label'], count);
        Tflite.close();
      } catch (e) {
        print('Error taking photo: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    context.read<MusicPlayerBloc>().add(StopMusic());

    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      buildWhen: (previous, current) =>
          current is MusicFetched || previous is MusicLoading,
      builder: (context, state) {
        if (state is MusicFetched) {
          context.read<MusicPlayerBloc>().add(PlayMusic(musicIndex: 0));
          return DetailsScreen(
            song: state.songs.isNotEmpty
                ? state.songs[0]
                : Song(
                    authorName: 'authorName',
                    name: 'name',
                    imageUrl: 'imageUrl',
                    downloadUrl: 'downloadUrl',
                    duration: 120,
                  ),
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: LoadingIndicator(
                indicatorType: Indicator.lineScale,
                strokeWidth: 0.5,
                backgroundColor: Colors.transparent,
                colors: [Colors.black],
              ),
            ),
          );
        }
      },
    );
  }
}
