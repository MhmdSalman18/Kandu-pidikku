import 'package:flutter/material.dart'; // Import Flutter's material design library.
import 'package:image_picker/image_picker.dart'; // Import the image picker package for selecting images.
import 'dart:io'; // Import dart:io to handle file operations.

/// A StatefulWidget to allow users to pick images from the gallery.
class PickImagePage extends StatefulWidget {
  // A callback function to return the selected images.
  final Function(List<File>) onImagesPicked;

  // Constructor to initialize the callback function.
  PickImagePage({required this.onImagesPicked});

  @override
  _PickImagePageState createState() => _PickImagePageState();
}

/// The state class for [PickImagePage].
class _PickImagePageState extends State<PickImagePage> {
  final ImagePicker _picker = ImagePicker(); // Image picker instance to access the gallery.
  List<File> _selectedImages = []; // List to store the selected image files.

  /// Function to pick an image from the gallery.
  Future<void> _pickImage() async {
    // Check if the limit of 12 images is reached.
    if (_selectedImages.length >= 12) {
      _showLimitWarning(); // Show a warning if the limit is reached.
      return;
    }

    // Open the image picker to select an image.
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    // If an image is selected, add it to the list of selected images.
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path)); // Convert XFile to File and add it.
      });
    }
  }

  /// Function to show a warning dialog when the image limit is reached.
  void _showLimitWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limit Reached"),
        content: Text("You can only select up to 12 images."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog.
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Function to confirm the selection of images.
  void _confirmSelection() {
    // Check if the number of selected images is less than 4.
    if (_selectedImages.length < 4) {
      // Show a warning dialog if fewer than 4 images are selected.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("More Images Needed"),
          content: Text("Please select at least 4 images."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog.
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    // Call the callback function with the selected images.
    widget.onImagesPicked(_selectedImages);

    // Close the current screen.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Images"), // Title of the app bar.
        backgroundColor: Color.fromARGB(255, 4, 193, 199), // Custom color.
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding around the text.
            child: Text(
              "Pick between 4 to 12 images for the game.", // Instruction text.
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w500, 
                color: Color.fromARGB(255, 4, 193, 199),
              ),
              textAlign: TextAlign.center, // Center the text.
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10), // Add padding around the grid.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns in the grid.
                crossAxisSpacing: 8, // Spacing between columns.
                mainAxisSpacing: 8, // Spacing between rows.
              ),
              itemCount: _selectedImages.length + 1, // Include an extra item for the "add" button.
              itemBuilder: (context, index) {
                // If the current item is the last one, show the "add" button.
                if (index == _selectedImages.length) {
                  return GestureDetector(
                    onTap: _pickImage, // Trigger image picker on tap.
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 4, 193, 199).withOpacity(0.2), // Semi-transparent background.
                        borderRadius: BorderRadius.circular(12), // Rounded corners.
                        border: Border.all(
                          color: Color.fromARGB(255, 4, 193, 199), 
                          width: 2,
                        ), // Border styling.
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo, 
                          size: 36, 
                          color: Color.fromARGB(255, 4, 193, 199),
                        ), // Add photo icon.
                      ),
                    ),
                  );
                } else {
                  // Display selected images with a delete button.
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 6, 255, 218), 
                            width: 2,
                          ), // Border styling.
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12), // Rounded corners for the image.
                          child: Image.file(
                            _selectedImages[index], 
                            fit: BoxFit.cover, // Fit the image inside the container.
                          ),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index); // Remove the image on tap.
                            });
                          },
                          child: Icon(
                            Icons.remove_circle, 
                            color: Colors.red, 
                            size: 24, // Delete icon.
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0), // Add padding around the button.
            child: ElevatedButton(
              onPressed: _confirmSelection, // Confirm the selected images.
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 193, 199), // Button color.
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Padding inside the button.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded button corners.
                ),
              ),
              child: Text(
                "Confirm Selection", 
                style: TextStyle(fontSize: 18, color: Colors.white), // Button text style.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
