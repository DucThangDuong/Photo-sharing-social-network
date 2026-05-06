import 'package:flutter/material.dart';

import '../../../../../data/datasources/ApiServices.dart';

class EditPostPage extends StatefulWidget {
  final dynamic post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _captionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Gán caption hiện tại vào ô nhập liệu
    _captionController = TextEditingController(text: widget.post['caption']);
  }

  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      // Giả sử Thành tạo thêm API PUT /user/posts/update/{id} ở Backend
      //tự thêm api của m vô nha
      final response = await ApiService().put(
        '/user/posts/update/${widget.post['id']}',
        data: {'Caption': _captionController.text.trim()},
      );

      if (mounted && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
        Navigator.pop(context, true); // Trở về và báo hiệu đã cập nhật
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // lib/presentation/profile/pages/edit_post_page.dart

  @override
  Widget build(BuildContext context) {
    // Đảm bảo cộng đúng chuỗi localhost/10.0.2.2 cho máy ảo
    String imageUrl = 'http://10.0.2.2:5090' + widget.post['postMedia'][0]['mediaUrl'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // ... (giữ nguyên phần AppBar cũ) ...
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header người dùng
            ListTile(
              leading: const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
              title: const Text('amisunami2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),

            // 2. PHẦN SỬA LỖI: Hiển thị hình ảnh theo tỷ lệ
            AspectRatio(
              aspectRatio: 1, // Tỷ lệ 1:1 (ảnh vuông) - bạn có thể chỉnh thành 4/5 nếu muốn ảnh dọc
              child: Container(
                width: double.infinity,
                color: Colors.grey[900], // Màu nền khi ảnh chưa tải xong
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy khung hình mà không để lại khoảng trắng
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
            ),

            // 3. Ô nhập chú thích
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Viết chú thích...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}