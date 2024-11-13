import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'pick_image.dart';

class MemoryGame extends StatefulWidget {
  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  List<String> _defaultImages = [
    'assets/images/rao.jpg',
    'assets/images/abey.jpg',
    'assets/images/alfin.jpg',
    'assets/images/sanjo.jpg',
    'assets/images/edwin.jpg',
    'assets/images/gladson.jpg',
    'assets/images/hari.jpg',
    'assets/images/aromal.jpg',
  ];

  List<String>? _cards;
  List<bool>? _revealed;
  List<File> _userImages = [];
  int _selectedCardIndex = -1;
  int _score = 0;
  bool _isProcessing = false;
  bool _isGameStarted = false;
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
  }

  void _startNewGame({bool useDefaultImages = false}) {
    setState(() {
      _isGameStarted = false;
      _startTime = null;
      _elapsedTime = Duration.zero;
      if (useDefaultImages) {
        _userImages.clear(); // Clear user images to use default images
      }
      final imagesToUse = _userImages.isNotEmpty ? _userImages : _defaultImages;
      _cards = (imagesToUse + imagesToUse).map((image) => image is File ? image.path : image as String).toList();
      _cards!.shuffle(Random());
      _revealed = List.filled(_cards!.length, false);
      _score = 0;
      _selectedCardIndex = -1;
      _isProcessing = false;
    });
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kandu Pidiku"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _startNewGame(),
            tooltip: 'Reset Game',
          ),
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: () => _startNewGame(useDefaultImages: true),
            tooltip: 'Reset to Default Images',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $_score',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 4, 193, 199)),
            ),
          ),
          if (!_isGameStarted) 
            ElevatedButton(
              onPressed: _startGame,
              child: Text("Start Game"),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cards?.length ?? 0,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: _buildCard(index),
                  );
                },
              ),
            ),
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
                              _userImages = images;
                            });
                            _startNewGame();
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
                  style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 4, 193, 199), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: _revealed![index] ? Colors.white : const Color.fromARGB(255, 0, 217, 224),
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
                ? Image.asset(_cards![index], width: 100, height: 100, fit: BoxFit.cover)
                : Image.file(File(_cards![index]), width: 100, height: 100, fit: BoxFit.cover))
            : Icon(Icons.find_in_page_rounded, size: 40, color: Colors.white),
      ),
    );
  }

  void _onCardTap(int index) {
    if (!_isGameStarted || _revealed![index] || _isProcessing || _selectedCardIndex == index) return;

    setState(() {
      _revealed![index] = true;

      if (_selectedCardIndex == -1) {
        _selectedCardIndex = index;
      } else {
        if (_cards![_selectedCardIndex] == _cards![index]) {
          _score += 10;
          _checkGameOver();
          _selectedCardIndex = -1;
        } else {
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

  void _checkGameOver() {
    if (_revealed!.every((revealed) => revealed)) {
      _elapsedTime = DateTime.now().difference(_startTime!);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Congratulations!"),
          content: Text("You've matched all pairs!\nYour score is $_score.\nTime taken: ${_elapsedTime.inSeconds} seconds."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewGame();
              },
              child: Text("Play Again"),
            ),
          ],
        ),
      );
    }
  }
}
