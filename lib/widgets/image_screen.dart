import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  final String pageTitle;
  final List<dynamic> imageFiles; // List of image URLs or paths
  final int initialIndex; // The index of the currently selected image
  final String imageFile; // The image that was clicked
  final String ticketId; // The ticket ID

  const ImageScreen({
    Key? key,
    required this.pageTitle,
    required this.imageFiles,
    required this.initialIndex,
    required this.imageFile,
    required this.ticketId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 141, 36, 41),
        title: Text(pageTitle),
      ),
      body: Center(
        child: PageView.builder(
          itemCount: imageFiles.length,
          controller: PageController(initialPage: initialIndex),
          scrollDirection: Axis.horizontal, // Horizontal scrolling
          itemBuilder: (context, index) {
            return Center(
              child: Image.network(
                imageFiles[index], // Show image at the current index
                fit: BoxFit.contain, // Adjust image fit (optional)
                width: double.infinity,
                height: double.infinity,
              ),
            );
          },
        ),
      ),
    );
  }
}
