import 'package:flutter/material.dart';

class SearchResultView extends StatelessWidget {
  final String selectedType;
  final String query;
  final List<dynamic> userResults; // Thêm biến này
  final List<dynamic> postResults; // Thêm biến này
  final Function(String) onTypeChanged;

  const SearchResultView({
    super.key,
    required this.selectedType,
    required this.query,
    required this.userResults, // Yêu cầu truyền vào
    required this.postResults, // Yêu cầu truyền vào
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildTab('Người dùng', 'Users'),
            _buildTab('Bài viết', 'Posts'),
          ],
        ),
        // THAY THẾ PHẦN NÀY:
        Expanded(
          child: selectedType == 'Users'
              ? _buildUserList()
              : _buildPostGrid(),
        ),
      ],
    );
  }

  // Hàm vẽ danh sách người dùng
  Widget _buildUserList() {
    return ListView.builder(
      itemCount: userResults.length,
      itemBuilder: (context, index) {
        final user = userResults[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['avatar']),
          ),
          title: Text(user['username'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(user['name'],
              style: const TextStyle(color: Colors.grey)),
        );
      },
    );
  }

  // Hàm vẽ lưới bài viết
  Widget _buildPostGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.75,
      ),
      itemCount: postResults.length,
      itemBuilder: (context, index) {
        final post = postResults[index];
        return Image.network(post['imageUrl'], fit: BoxFit.cover);
      },
    );
  }

  Widget _buildTab(String label, String type) {
    bool isSelected = selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => onTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2)),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }
}