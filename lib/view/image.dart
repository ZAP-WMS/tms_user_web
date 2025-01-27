import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImageScreen extends StatefulWidget {
  final List<dynamic> imageFiles;
  final int initialIndex;
  final String pageTitle;

  const ImageScreen({
    required this.imageFiles,
    required this.initialIndex,
    String? imageFile,
    required ticketId,
    required this.pageTitle,
  });

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Image'),
      ),
      body: Center(
        child: CarouselSlider.builder(
          itemCount: widget.imageFiles.length,
          options: CarouselOptions(
            initialPage: widget.initialIndex,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIdx) {
            return Container(
              child: widget.pageTitle == 'pendingPage'
                  ? PhotoView(
                      imageProvider: NetworkImage(widget.imageFiles[index]),
                      //imageProvider: FileImage(File(widget.imageFiles[index])),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.black),
                    )
                  : PhotoView(
                      imageProvider: FileImage(File(widget.imageFiles[index])),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.black),
                    ),
            );
          },
        ),
      ),
    );
  }
}
