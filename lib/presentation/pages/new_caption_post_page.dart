import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/global/User.dart';
import '../../data/datasources/DTOs/UserDTO.dart';
import '../widgets/new_caption_post/caption_AppBar.dart';
import '../widgets/new_caption_post/caption_btn_share.dart';
import '../widgets/new_caption_post/caption_image_preview.dart';
import '../widgets/new_caption_post/caption_input.dart';

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
  // post bài viết này lên api
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
      await ApiService().post('/post/newPost', data: formData);
      if (mounted) {
        try {
          final userRes = await ApiService().get('/user/profile');
          if (userRes != null && userRes['data'] != null) {
            UserModelDTO updatedUser = UserModelDTO.fromJson(userRes['data']);
            Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
          }
        } catch (e) {
          debugPrint("Lỗi tải lại thông tin người dùng: $e");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng bài thành công!')),
        );
        Navigator.pop(context, true);
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