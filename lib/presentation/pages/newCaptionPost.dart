import 'package:flutter/material.dart';
import '../widgets/newCaptionPost/CaptionAppBar.dart';
import '../widgets/newCaptionPost/CaptionBottomShare.dart';
import '../widgets/newCaptionPost/CaptionImagePreview.dart';
import '../widgets/newCaptionPost/CaptionInput.dart';

class FinalSharePostScreen extends StatefulWidget {
  const FinalSharePostScreen({super.key, required this.imagePaths});
  final List<String> imagePaths;
  @override
  State<FinalSharePostScreen> createState() => _FinalSharePostScreenState();
}

class _FinalSharePostScreenState extends State<FinalSharePostScreen> {
  late bool isMultipleImages;

  @override
  void initState() {
    super.initState();
    isMultipleImages = widget.imagePaths.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewCaptionAppBar(
        onToggleMultipleImages: () {
          setState(() {
            isMultipleImages = !isMultipleImages;
          });
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NewCaptionImagePreview(
                    isMultipleImages: isMultipleImages,
                    imagePaths: widget.imagePaths,
                  ),
                  const NewCaptionInput(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const NewCaptionBottomShare(),
        ],
      ),
    );
  }
}