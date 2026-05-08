import 'package:flutter/material.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../data/Helper.dart';

class SearchResultView extends StatelessWidget {
  final String selectedType;
  final String query;
  final List<SuggestedUserDTO> userResults;
  final List<PostSummaryDTO> postResults;
  final bool isLoading;
  final Function(String) onTypeChanged;

  const SearchResultView({
    super.key,
    required this.selectedType,
    required this.query,
    required this.userResults,
    required this.postResults,
    required this.isLoading,
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
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white54))
              : selectedType == 'Users'
                  ? _buildUserList()
                  : _buildPostGrid(),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    if (userResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: userResults.length,
      itemBuilder: (context, index) {
        final user = userResults[index];
        String avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? AppHelper.formatImageURL(user.avatarUrl!)
            : '';
        return ListTile(
          leading: avatarUrl.isNotEmpty
              ? CircleAvatar(backgroundImage: NetworkImage(avatarUrl))
              : const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          title: Text(user.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(user.fullName ?? '',
              style: const TextStyle(color: Colors.grey)),
        );
      },
    );
  }

  Widget _buildPostGrid() {
    if (postResults.isEmpty) {
      return const Center(child: Text('Không tìm thấy bài viết', style: TextStyle(color: Colors.grey)));
    }

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
        String imageUrl = post.postMedia.isNotEmpty
            ? AppHelper.formatImageURL(post.postMedia[0].mediaUrl)
            : '';
        return imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]))
            : Container(color: Colors.grey[900]);
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