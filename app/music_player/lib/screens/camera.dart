import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:music_player/Screens/details_screen.dart';
import 'package:music_player/api/api.dart';
import 'package:music_player/api/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
      return ApiService().getSongData('$query malayalam songs');
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
      log("Taking photo...");
      _takePhoto();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile image = await _cameraController!.takePicture();

        log("taked");

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
        log("hurry..............,,");
        print(recognitions);
        songs = await getSongs(recognitions[0]['label']);

        isLoading.value = false;

        // final directory =
        //     await getExternalStorageDirectory();
        // String newPath =
        //     '${directory?.path}/${DateTime.now().millisecondsSinceEpoch}.png'; // Generate a unique filename

        // await File(image.path).copy(newPath);

        // await GallerySaver.saveImage(newPath);

        // log('Photo saved to: $newPath');
      } catch (e) {
        print('Error taking photo: $e');
      }
    }
  }

  void loadImages() {}

  @override
  void dispose() {
    _cameraController?.dispose();

    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, loading, child) {
        if (loading) {
          return Center(
            child: Image.asset(
              'assets/images/loading.gif',
            ),
          );
        } else if (songs.isNotEmpty) {
          return DetailsScreen(
            songs:songs,
            selectedIndex: 0,
            onBack: () {},
          );
        } else {
          // Handle the case where there are no songs found
          return const Center(
            child: Text(
              'No songs found.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          );
        }
      },
    );
  }
}
