import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:music_player/Screens/details_screen.dart';
import 'package:music_player/api/api.dart';
import 'package:music_player/api/label.dart';
import 'package:music_player/api/model.dart';
import 'package:music_player/widgets/main_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakePhotoAutomatically extends StatefulWidget {
  @override
  _TakePhotoAutomaticallyState createState() => _TakePhotoAutomaticallyState();
}

class _TakePhotoAutomaticallyState extends State<TakePhotoAutomatically> {
  List<CameraDescription> cameras = [];

  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  ValueNotifier<bool> isLoading = ValueNotifier(true);

  List<Song> songs = [];

  Future<List<Song>> getSongs(String query) async {
    if (songs.isEmpty) {
      int randomNumber = Random().nextInt(10) + 1;
      String res = "";
      if (query == 'sad') {
        res = neutral[randomNumber];
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
      }else if (query == "neutral") {
        res = melody[randomNumber];
      }else  {
        res = "malayalam song";
      }

      return ApiService().getSongData(res);
    } else {
      return songs;
    }
  }

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
        model: 'assets/facialmodel.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  @override
  void initState() {
    super.initState();
    audioPlayer.stop();

    _requestPermissions();
    _tfliteInit();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

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

        var recognitions = await Tflite.runModelOnImage(
            path: image.path, // required
            imageMean: 0.0, // defaults to 117.0
            imageStd: 255.0, // defaults to 1.0
            numResults: 2, // defaults to 5
            threshold: 0.2, // defaults to 0.1
            asynch: true // defaults to true
            );

        if (recognitions == null) {
          print("recognitions is null");
          return;
        }
        print(recognitions);
        songs = await getSongs(recognitions[0]['label']);

        if (recognitions.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          int count = prefs.getInt(recognitions[0]['label']) ?? 0;

          count++;
          await prefs.setInt(recognitions[0]['label'], count);

          print("Sad recognized, count updated: $count");
        }

        isLoading.value = false;

        // final directory =
        //     await getExternalStorageDirectory();
        // String newPath =
        //     '${directory?.path}/${DateTime.now().millisecondsSinceEpoch}.png'; // Generate a unique filename

        // await File(image.path).copy(newPath);

        // await GallerySaver.saveImage(newPath); j

        // log('Photo saved to: $newPath');
      } catch (e) {
        print('Error taking photo: $e');
      }
    }
  }

  void loadImages() {}

  @override
  void dispose() {
    super.dispose();
    _cameraController?.dispose();
    audioPlayer.stop();

    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        if (loading) {
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
        } else if (songs.isNotEmpty) {
          return DetailsScreen(
            songs: songs,
            selectedIndex: 0,
            onBack: () {},
          );
        } else {
          return const Center(
            child: Text(
              'No songs found.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          );
        }
      },
    );
  }
}
