import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:laudentestthree/menu.dart';

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

void _back() {
    setState(() {
      runApp(Menu());
      // This will eventually go to Squirrel page
    });
  }

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
                  ElevatedButton(
                    onPressed: _back,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(70, 70),
                      shape: const CircleBorder(),
                      backgroundColor: Colors.purple,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color:  Colors.white,
                      size: 30,
                    ),
                  )
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

class CommentPage extends StatefulWidget {
  final String imagePath;

  const CommentPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  String? _selectedSquirrelTag;  // Variable to hold the selected dropdown value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(
              File(widget.imagePath),
              height: 200, // Smaller preview of the photo
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write a comment...',
              ),
              maxLines: null,
            ),
          ),
          DropdownButton<String>(
            value: _selectedSquirrelTag,
            hint: Text("Select Tag Status"),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSquirrelTag = newValue;
              });
            },
            items: <String>['Tagged Squirrel', 'Untagged Squirrel']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.upload),
              label: Text('Upload'),
              onPressed: _selectedSquirrelTag != null ? () {
                // Add upload functionality here
              } : null,  // Disable button when no dropdown item is selected
            ),
          ),
        ],
      ),
    );
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
                   Navigator.of(context).push(MaterialPageRoute(
                   builder: (context) => CommentPage(imagePath: widget.imagePath),
                   ));
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