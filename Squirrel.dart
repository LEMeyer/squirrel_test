import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const CameraPage(),
    );
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  late List<CameraDescription> _cameras;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    initCamera();
  }

Future<void> initCamera() async {
  try {
    _cameras = await availableCameras();
  } on Exception catch (e) {
    debugPrint('Error retrieving available cameras: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No cameras found')),
    );
    return;
  }

  if (_cameras.isEmpty) {
    debugPrint('No cameras found');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No cameras found')),
    );
    return;
  }

  _controller = CameraController(_cameras.first, ResolutionPreset.high, imageFormatGroup: ImageFormatGroup.jpeg);

  try {
    await _controller.initialize();
  } on Exception catch (e) {
    debugPrint('Error initializing camera: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error initializing camera: $e')),
    );
    return;
  }

  if (!mounted) {
    return;
  }

  setState(() {
    _isCameraInitialized = _controller.value.isInitialized;
  });

  onNewCameraSelected(_cameras.first);
}

  Future<void> onNewCameraSelected(CameraDescription description) async {
    final previousCameraController = _controller;

    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController.initialize();
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    await previousCameraController?.dispose();

    if (mounted) {
      setState(() {
        _controller = cameraController;
      });
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller.value.isInitialized;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCameraInitialized) {
      return SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(child: CameraPreview(_controller)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _onTakePhotoPressed,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(70, 70),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _onRecordVideoPressed,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(70, 70),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.videocam,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Future<XFile?> capturePhoto() async {
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      final file = await _controller.takePicture();
      return file;
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  void _onTakePhotoPressed() async {
    final xFile = await capturePhoto();
    if (xFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            imagePath: xFile.path,
          ),
        ),
      );
    }
  }

  Future<XFile?> captureVideo() async {
    if (_controller.value.isRecordingVideo) {
      return null;
    }
    try {
      setState(() {
        _isRecording = true;
      });
      await _controller.startVideoRecording();
      await Future.delayed(const Duration(seconds: 5));
      final video = await _controller.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      return video;
    } on CameraException catch (e) {
      debugPrint('Error occurred while capturing video: $e');
      return null;
    }
  }

  void _onRecordVideoPressed() async {
    final xFile = await captureVideo();
    if (xFile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreviewPage(
            videoPath: xFile.path,
          ),
        ),
      );
    }
  }
}

class PreviewPage extends StatefulWidget {
  final String? imagePath;
  final String? videoPath;

  const PreviewPage({Key? key, this.imagePath, this.videoPath}) : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _startVideoPlayer();
    }
  }

  Future<void> _startVideoPlayer() async {
    if (widget.videoPath != null) {
      controller = VideoPlayerController.file(File(widget.videoPath!));
      await controller!.initialize();
      await controller!.setLooping(true);
      await controller!.play();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.imagePath != null
            ? Image.file(
                File(widget.imagePath!),
                fit: BoxFit.cover,
              )
            : AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              ),
      ),
    );
  }
}


