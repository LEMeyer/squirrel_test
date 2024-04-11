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
              Expanded(child