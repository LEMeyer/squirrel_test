import 'dart:io';

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

    _controller = CameraController(
      description,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller.initialize();
    } on Exception catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    await previousCameraController?.dispose();

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
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_controller.description);
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
                      backgroundColor: Colors.purple,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color:  Colors.white,
                      size: 30,
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
}

class PreviewPage extends StatefulWidget {
  final String imagePath;

  const PreviewPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        leading: Container(), // Empty container to hide back button
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Retake Photo'),
                  onPressed: () {
                    // Pops the current preview page and then the camera page to retake photo
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.check_circle),
                  label: Text('Use Photo'),
                  onPressed: () {
                    // For now, do nothing or navigate to a new page where you use the photo
                    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => UsePhotoPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
