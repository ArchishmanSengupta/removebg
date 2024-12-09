import 'package:flutter/material.dart';
import 'package:removebg/removebg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _removeBackground();
  }

  ImageProvider? _imageProvider = const AssetImage('assets/jobs.png');

  void _removeBackground() async {
    /// The line `final imageProvider = await Removebg.removebg(_imageProvider);` is calling a method named `removebg` from a class or library named `Removebg` and passing `_imageProvider` as an argument. The `await` keyword is used to wait for the asynchronous operation to complete before assigning the result to the `imageProvider` variable.
    if (_imageProvider == null) {
      return;
    }
    final imageProvider = await Removebg.removebg(_imageProvider!);
    setState(() {
      _imageProvider = imageProvider;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              const Text('Hello World'),
              if (_imageProvider != null)
                Image(
                  image: _imageProvider!,
                  height: 200,
                  width: 200,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
