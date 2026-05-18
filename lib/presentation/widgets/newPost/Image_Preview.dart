import 'dart:io';

import 'package:flutter/material.dart';

class NewPostImagePreview extends StatelessWidget {
  final String imagePath;

  const NewPostImagePreview({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: const Color(0xFF121212),
        child: Stack(
          children: [
            if (imagePath.isEmpty)
              Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }
}