import 'package:flutter/material.dart';
import 'package:flutter_application_2/Squirrel.dart';
import 'package:flutter_application_2/squirrelPage.dart';
import 'package:flutter_application_2/recentsPage.dart';
import 'package:flutter_application_2/settings.dart';

void main() {
  runApp(const Menu());
}

class Menu extends StatelessWidget {
  const Menu({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squirrel App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff880011)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _text = "";

  void _openCamera() {
    setState(() {
      runApp(MyApp());
      // This will eventually go to camera
    });
  }

  void _openSettings() {
    setState(() {
      runApp(Settings());
      // This will eventually go to settings
    });
  }

  void _openSquirrelSelect() {
    setState(() {
      runApp(SquirrelPage());
      // This will eventually go to Squirrel page
    });
  }

  void _openRecents() {
    setState(() {
      runApp(RecentsPage());
      // This will eventually go to recent squirrel uploads
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF880011),
        title: const Text("Untitled Squirrel App", style: TextStyle(
          color: Color.fromARGB(255, 208, 169, 105),
        ),
        ),
        centerTitle: true,
      
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Align(
            
            child: FloatingActionButton.extended(
              elevation: 1.0,
              onPressed: _openCamera,
              tooltip: 'Camera',
              label: Text('Camera'),
              icon: const Icon(Icons.add_a_photo_rounded)),
            ),const Text(
              '',
            ),
          Align(
            child: FloatingActionButton.extended(
              elevation: 1.0,
              onPressed: _openSettings,
              tooltip: 'Settings',
              label: Text('Settings'),
              icon: const Icon(Icons.settings)),
          ),const Text(
              '',
            ),
          Align(
            child: FloatingActionButton.extended(
              elevation: 1.0,
              onPressed: _openSquirrelSelect,
              tooltip: 'Squirrels',
              label: Text('Squirrels'),
              icon: const Icon(Icons.catching_pokemon)),
          ),const Text(
              '',
            ),
          Align(
            child: FloatingActionButton.extended(
              elevation: 1.0,
              onPressed: _openRecents,
              tooltip: 'Recents',
              label: Text('Recents'),
              icon: const Icon(Icons.backup_table_rounded)),
          ),const Text(
            '',
          ),
            
          Text(
            '$_text',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}