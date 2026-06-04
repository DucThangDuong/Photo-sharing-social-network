import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import 'package:untitled/data/datasources/DTOs/ChatDTO.dart';
import 'package:untitled/data/Helper.dart';

class SharePostBottomSheet extends StatefulWidget {
  final int postId;

  const SharePostBottomSheet({Key? key, required this.postId}) : super(key: key);

  @override
  State<SharePostBottomSheet> createState() => _SharePostBottomSheetState();
}

class _SharePostBottomSheetState extends State<SharePostBottomSheet> {
  List<InboxItemDTO> _inboxUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Set of selected conversation IDs
  final Set<int> _selectedConversations = {};

  @override
  void initState() {
    super.initState();
    _fetchInbox();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInbox() async {
    try {
      final response = await CallMyAPI.getInbox();
      if (mounted) {
        setState(() {
          _inboxUsers = response.map((json) => InboxItemDTO.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPost() async {
    if (_selectedConversations.isEmpty) return;
    
    // Đường link bài viết dạng deep link
    final postLink = "app://post/${widget.postId}";
    
    // Gửi lần lượt đến các người dùng đã chọn
    bool allSuccess = true;
    for (int conversationId in _selectedConversations) {
      final result = await CallMyAPI.sendMessage(conversationId, postLink);
      if (result == null) {
        allSuccess = false;
      }
    }
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(allSuccess ? 'Đã gửi thành công' : 'Có lỗi khi gửi tới một số người')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<InboxItemDTO> displayUsers = [];
    if (_searchQuery.isNotEmpty) {
      displayUsers = _inboxUsers.where((c) => c.otherUserName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    } else {
      displayUsers = _inboxUsers;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Thanh nhỏ ở trên cùng
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          
          // Danh sách người dùng để chia sẻ (Grid)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white54))
                : displayUsers.isEmpty
                    ? const Center(child: Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: displayUsers.length,
                        itemBuilder: (context, index) {
                          final user = displayUsers[index];
                          final isSelected = _selectedConversations.contains(user.conversationId);
                          final avatarUrl = user.otherUserAvatar != null && user.otherUserAvatar!.isNotEmpty
                              ? AppHelper.formatImageURL(user.otherUserAvatar!)
                              : '';
                              
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedConversations.remove(user.conversationId);
                                } else {
                                  _selectedConversations.add(user.conversationId);
                                }
                              });
                            },
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey[800],
                                      backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                      child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                                    ),
                                    if (isSelected)
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.check_circle, color: Colors.blue, size: 30),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.otherUserName,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          
          // Nút gửi (hiện ra khi có người được chọn)
          if (_selectedConversations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _sendPost,
                  child: Text('Gửi (${_selectedConversations.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
