import 'dart:io';

import 'package:flutter/cupertino.dart';

class NewCaptionImagePreview extends StatelessWidget {
  final bool isMultipleImages;
  final List<String> imagePaths;

  const NewCaptionImagePreview({
    super.key,
    required this.isMultipleImages,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: isMultipleImages
          ? GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(imagePaths[index]), fit: BoxFit.cover),
          );
        },
      )
          : Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(imagePaths[0]), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}