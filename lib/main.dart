import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mind Matchup',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Set the splash screen as the initial page
    );
  }
}
