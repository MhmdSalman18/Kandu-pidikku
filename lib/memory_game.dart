import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'pick_image.dart'; // Custom page for picking images

class MemoryGame extends StatefulWidget {
  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  // Default card images stored in assets
  List<String> _defaultImages = [
    'assets/images/dark.jpeg',
    'assets/images/elec.jpeg',
    'assets/images/fire.jpeg',
    'assets/images/nature.jpeg',
    'assets/images/snow.jpeg',
    'assets/images/solar.jpeg',
    'assets/images/tech.jpeg',
    'assets/images/water.jpeg',
  ];

  List<String>? _cards; // List to store shuffled cards
  List<bool>? _revealed; // Tracks revealed state of each card
  List<File> _userImages = []; // Stores user-uploaded images
  int _selectedCardIndex = -1; // Index of currently selected card
  int _score = 0; // Player's score
  bool _isProcessing = false; // Prevents multiple taps during animation
  bool _isGameStarted = false; // Indicates whether the game has started
  DateTime? _startTime; // Tracks the start time of the game
  Duration _elapsedTime =
      Duration.zero; // Tracks time taken to complete the game

  @override
  void initState() {
    super.initState();
    _startNewGame(useDefaultImages: true); // Start with default images
  }

  // Starts a new game with shuffled cards
  void _startNewGame({bool useDefaultImages = false}) {
    setState(() {
      _isGameStarted = false;
      _startTime = null;
      _elapsedTime = Duration.zero;

      // Clear user images if using default images
      if (useDefaultImages) {
        _userImages.clear();
      }

      // Choose images to use: default or user-uploaded
      final imagesToUse = _userImages.isNotEmpty ? _userImages : _defaultImages;

      // Duplicate and shuffle cards
      _cards = (imagesToUse + imagesToUse)
          .map((image) => image is File ? image.path : image as String)
          .toList();
      _cards!.shuffle(Random());

      // Reset state variables
      _revealed = List.filled(_cards!.length, false);
      _score = 0;
      _selectedCardIndex = -1;
      _isProcessing = false;
    });
  }

  // Starts the game timer and allows interaction with the grid
  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        leading: Padding(
      padding: const EdgeInsets.all(8.0), // Optional padding for better alignment
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.jpeg', // Path to your image
          fit: BoxFit.cover, // Ensures the image scales properly
        ),
      ),
        ),
        title: Text(
      "Mind Matchup", // Title text remains
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
      // Reset the game, retaining current image set
      IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () => _startNewGame(),
        tooltip: 'Reset Game',
      ),
      // Reset the game with default images
      IconButton(
        icon: Icon(Icons.restart_alt),
        onPressed: () => _startNewGame(useDefaultImages: true),
        tooltip: 'Reset to Default Images',
      ),
        ],
      ),
      
      
        body: Column(
          children: [
            // Displays the player's current score
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 193, 199),
                ),
              ),
            ),
            // Button to start the game
            if (!_isGameStarted)
              ElevatedButton(
                onPressed: _startGame,
                child: Text("Start Game"),
              )
            else
              // Grid of cards displayed once the game starts
              Expanded(
                child: _cards == null || _cards!.isEmpty
                    ? Center(child: Text("No cards available!"))
                    : GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 cards per row
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _cards!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _onCardTap(index), // Handles card tap
                            child: _buildCard(index), // Builds the card widget
                          );
                        },
                      ),
              ),
            // Button to add custom images
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PickImagePage(
                            onImagesPicked: (images) {
                              setState(() {
                                _userImages = images; // Save uploaded images
                              });
                              _startNewGame(); // Start new game with uploaded images
                            },
                          ),
                        ),
                      );
                    },
                    child: Icon(Icons.add_photo_alternate, color: Colors.white),
                    backgroundColor: Color.fromARGB(255, 4, 193, 199),
                    tooltip: 'Pick Images',
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Add Custom Images",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 4, 193, 199),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds individual card widget
  Widget _buildCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color:
            _revealed![index] ? Colors.white : Color.fromARGB(255, 0, 217, 224),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(2, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: _revealed![index]
            ? (_cards![index].startsWith('assets/')
                ? Image.asset(_cards![index],
                    width: 100, height: 100, fit: BoxFit.cover)
                : Image.file(File(_cards![index]),
                    width: 100, height: 100, fit: BoxFit.cover))
            : Icon(Icons.find_in_page_rounded, size: 40, color: Colors.white),
      ),
    );
  }

  // Handles card tap logic
  void _onCardTap(int index) {
    if (!_isGameStarted ||
        _revealed![index] ||
        _isProcessing ||
        _selectedCardIndex == index) return;

    setState(() {
      _revealed![index] = true; // Reveal the card

      if (_selectedCardIndex == -1) {
        _selectedCardIndex = index; // Store the first selected card
      } else {
        // Check if two selected cards match
        if (_cards![_selectedCardIndex] == _cards![index]) {
          _score += 10; // Increment score for a match
          _checkGameOver(); // Check if all pairs are matched
          _selectedCardIndex = -1; // Reset selected index
        } else {
          // If cards don't match, flip them back after delay
          _isProcessing = true;
          int previousIndex = _selectedCardIndex;
          _selectedCardIndex = -1;
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              _revealed![previousIndex] = false;
              _revealed![index] = false;
              _isProcessing = false;
            });
          });
        }
      }
    });
  }

  // Checks if all cards are matched
  void _checkGameOver() {
    if (_revealed!.every((revealed) => revealed)) {
      _elapsedTime =
          DateTime.now().difference(_startTime!); // Calculate elapsed time
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Congratulations!"),
          content: Text(
              "You've matched all pairs!\nYour score is $_score.\nTime taken: ${_elapsedTime.inSeconds} seconds."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _startNewGame(); // Start a new game
              },
              child: Text("Play Again"),
            ),
          ],
        ),
      );
    }
  }
}
