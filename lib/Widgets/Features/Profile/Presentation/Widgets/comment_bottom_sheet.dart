import 'package:flutter/material.dart';

class CommentBottomSheet extends StatelessWidget {
  final dynamic post;
  const CommentBottomSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Bình luận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Sau này thay bằng post['comments'].length
              itemBuilder: (context, index) => ListTile(
                leading: const CircleAvatar(radius: 16, backgroundColor: Colors.blue),
                title: const Text('user_name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: const Text('Bình luận mẫu ở đây nè...', style: TextStyle(color: Colors.white, fontSize: 13)),
                trailing: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
              ),
            ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 15, right: 15, top: 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Thêm bình luận...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Đăng', style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }
}