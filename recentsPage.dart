import 'package:flutter/material.dart';
import 'package:flutter_application_2/menu.dart';

void main() {
  runApp(const RecentsPage());
}

class RecentsPage extends StatelessWidget {
  const RecentsPage({super.key});
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

  void _back() {
    setState(() {
      runApp(Menu());
      // This will eventually go to Squirrel page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF880011),
        title: const Text("Recents", style: TextStyle(
          color: Color.fromARGB(255, 208, 169, 105),
        ),
        ),
        centerTitle: true,
        leading: BackButton(
          onPressed: _back,
            color: Colors.white
        ),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
          Container(
            height: 700,
            child: Column(
                        children: [ Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:50, color: Colors.grey[200],
                          child: const Align(alignment: Alignment.centerLeft, child: Text('username')))),
                          Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:500, color: Colors.amber[100],
                          child: const Center(child: Text('Image 1'))))
            ],
          )),
          Container(
            height: 700,
            child: Column(
                        children: [ Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:50, color: Colors.grey[200],
                          child: const Align(alignment: Alignment.centerLeft, child: Text('username')))),
                          Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:500, color: Colors.amber[100],
                          child: const Center(child: Text('Image 2'))))
            ],
          )),
          Container(
            height: 700,
            child: Column(
                        children: [ Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:50, color: Colors.grey[200],
                          child: const Align(alignment: Alignment.centerLeft, child: Text('username')))),
                          Align(
                          alignment: Alignment.topCenter, 
                          child: Container(height:500, color: Colors.amber[100],
                          child: const Center(child: Text('Image 3'))))
            ],
          )),
        ],
      )),
    );
  }
}