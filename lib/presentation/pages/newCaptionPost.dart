import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
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
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isMultipleImages = widget.imagePaths.length > 1;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String caption = _captionController.text.trim();
      
      var formData = FormData.fromMap({
        'Caption': caption,
      });

      for (var path in widget.imagePaths) {
        formData.files.add(MapEntry(
          'Images',
          await MultipartFile.fromFile(path),
        ));
      }

      await ApiService().post('/user/newPost', data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công!')),
        );
        Navigator.pop(context); // Đóng màn hình đăng bài sau khi thành công
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng bài thất bại: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  NewCaptionInput(controller: _captionController),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          NewCaptionBottomShare(
            isLoading: _isLoading,
            onPressed: _handlePost,
          ),
        ],
      ),
    );
  }
}