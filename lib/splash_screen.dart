import 'package:flutter/material.dart';
import 'dart:async';
import 'memory_game.dart'; // Import the home page file

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Automatically navigate to the home page after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MemoryGame()),
      );
    });

    return Scaffold(
      backgroundColor: Color(0xFF04213F), // Updated background color using #04213F
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your logo path
              width: 150,
            ),
            SizedBox(height: 20),
            Text(
              "Mind Matchup",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
