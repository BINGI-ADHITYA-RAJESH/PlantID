import 'package:flutter/material.dart';
import 'package:test/ui.dart';


void main() {
  runApp(const MyApp());
  
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const CaptureScreen(),
        '/results': (context) =>const  ResultsScreen(),
      },
    );
  }
}

