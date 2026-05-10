import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/User.dart';
import 'package:provider/provider.dart';

class StoryUploadPage extends StatefulWidget {
  // Nhận file ảnh từ màn hình chọn ảnh (Gallery/Camera) truyền sang
  final File? imageFile;

  const StoryUploadPage({super.key, this.imageFile});

  @override
  State<StoryUploadPage> createState() => _StoryUploadPageState();
}

class _StoryUploadPageState extends State<StoryUploadPage> {
  bool _isUploading = false;
  File? _currentImageFile;

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _currentImageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadStory() async {
    if (_currentImageFile == null) return;
    
    setState(() => _isUploading = true);

    try {
      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(_currentImageFile!.path),
      });
      
      await ApiService().post('/story/add', data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào tin của bạn!')),
        );
        Navigator.pop(context); // Đăng xong thì đóng màn hình này lại
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lên: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen tuyền
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================================
            // LỚP DƯỚI CÙNG: ẢNH HIỂN THỊ TOÀN MÀN HÌNH HOẶC MÀN HÌNH ĐEN CHỌN ẢNH
            // ==========================================
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16), // Bo góc mượt mà kiểu iOS
                child: _currentImageFile != null
                    ? Image.file(_currentImageFile!, fit: BoxFit.cover)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image, size: 80, color: Colors.white54),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0095F6),
                              ),
                              child: const Text('Chọn ảnh từ thư viện', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Màn đen mờ khi đang upload
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            // ==========================================
            // LỚP TRÊN (TOP): CÁC NÚT CÔNG CỤ (Đóng, Thêm chữ, Sticker...)
            // ==========================================
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Hủy
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Các nút công cụ
                  if (_currentImageFile != null)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_fields, color: Colors.white, size: 28),
                          onPressed: () {}, 
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white, size: 28),
                          onPressed: () {}, 
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: Colors.white, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // ==========================================
            // LỚP DƯỚI (BOTTOM): CÁC NÚT ĐĂNG STORY (Chỉ hiện khi đã chọn ảnh)
            // ==========================================
            if (_currentImageFile != null)
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: Row(
                  children: [
                    // Nút "Tin của bạn"
                    Expanded(
                      child: GestureDetector(
                        onTap: _isUploading ? null : _uploadStory,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6), // Nền đen mờ
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final user = userProvider.user;
                              final avatarUrl = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                  ? 'http://10.0.2.2:5090${user.avatarUrl}'
                                  : 'https://i.pravatar.cc/150';
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(avatarUrl),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Tin của bạn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nút "Gửi đến" (Mũi tên trắng)
                    GestureDetector(
                      onTap: _isUploading ? null : _uploadStory,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}