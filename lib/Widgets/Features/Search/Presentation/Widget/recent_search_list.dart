import 'package:flutter/material.dart';

class RecentSearchList extends StatelessWidget {
  const RecentSearchList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập, sau này Thành có thể lấy từ Local Storage hoặc API
    final List<Map<String, String>> recentSearches = [
      {'name': 'Đinh Tấn Thành', 'subtitle': 'dinhtan6974', 'type': 'user'},
      {'name': 'HUIT News', 'subtitle': 'Trường Đại học Công Thương', 'type': 'user'},
      {'name': 'Flutter Vietnam', 'subtitle': 'Cộng đồng lập nghiệp', 'type': 'tag'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gần đây',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () => print("Xóa tất cả tìm kiếm"),
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFF0064E0),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final item = recentSearches[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF262626),
                  backgroundImage: item['type'] == 'user'
                      ? const NetworkImage('https://via.placeholder.com/150')
                      : null,
                  child: item['type'] == 'tag'
                      ? const Icon(Icons.tag, color: Colors.white)
                      : null,
                ),
                title: Text(
                  item['name']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  item['subtitle']!,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => print("Xóa mục này"),
                ),
                onTap: () => print("Chuyển đến trang của ${item['name']}"),
              );
            },
          ),
        ),
      ],
    );
  }
}