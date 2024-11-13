import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PickImagePage extends StatefulWidget {
  final Function(List<File>) onImagesPicked;

  PickImagePage({required this.onImagesPicked});

  @override
  _PickImagePageState createState() => _PickImagePageState();
}

class _PickImagePageState extends State<PickImagePage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 12) {
      _showLimitWarning();
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _showLimitWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limit Reached"),
        content: Text("You can only select up to 12 images."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _confirmSelection() {
    if (_selectedImages.length < 4) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("More Images Needed"),
          content: Text("Please select at least 4 images."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    widget.onImagesPicked(_selectedImages);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Images"),
        backgroundColor: Color.fromARGB(255, 4, 193, 199),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Pick between 4 to 12 images for the game.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 4, 193, 199)),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 4, 193, 199).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color.fromARGB(255, 4, 193, 199), width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.add_a_photo, size: 36, color: Color.fromARGB(255, 4, 193, 199)),
                      ),
                    ),
                  );
                } else {
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color.fromARGB(255, 6, 255, 218), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImages[index], fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Icon(Icons.remove_circle, color: Colors.red, size: 24),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _confirmSelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 193, 199),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Confirm Selection", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
