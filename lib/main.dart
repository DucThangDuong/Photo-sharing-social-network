import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const NewPostScreen(),
    );
  }
}

class NewPostScreen extends StatelessWidget {
  const NewPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildImagePreview(),
          _buildControlBar(),
          _buildPermissionNotice(),
          _buildPhotoGrid(),
        ],
      ),
    );
  }

  // 1. Thanh AppBar trên cùng
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: () {},
      ),
      title: const Text(
        'Bài viết mới',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Tiếp',
            style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // 2. Vùng xem trước ảnh lớn
  Widget _buildImagePreview() {
    return AspectRatio(
      aspectRatio: 1, // Tỷ lệ 1:1 cho khung ảnh vuông
      child: Container(
        color: const Color(0xFF121212), // Màu xám đen
        child: Stack(
          children: [
            Image.network('https://picsum.photos/id/237/600/600', fit: BoxFit.cover, width: double.infinity),
          ],
        ),
      ),
    );
  }

  // 3. Thanh công cụ "Gần đây" và "Chọn" nhiều ảnh
  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút chọn thư mục
          Row(
            children: const [
              Text(
                'Gần đây',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
            ],
          ),
          // Nút Chọn nhiều ảnh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.filter_none, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Chọn',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Thông báo quyền truy cập ảnh
  Widget _buildPermissionNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bạn đã cấp cho Instagram quyền truy cập vào một số ảnh và video.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Quản lý',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Lưới hiển thị các ảnh trong thư viện
  Widget _buildPhotoGrid() {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 4 cột
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 20, // Số lượng ảnh giả lập
        itemBuilder: (context, index) {
          if (index == 0) {
            // Nút Camera ở vị trí đầu tiên
            return Container(
              color: Colors.white12,
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30),
            );
          }
          // Các ô ảnh giả lập
          return Container(
            color: Colors.grey.withOpacity(0.3 + (index % 5) * 0.1),
            // Thay bằng Image.network hoặc Image.asset trong thực tế
          );
        },
      ),
    );
  }

}