import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import 'package:untitled/data/datasources/DTOs/ChatDTO.dart';
import 'package:untitled/data/datasources/SignalR.dart';
import 'package:untitled/data/Helper.dart';
import 'package:untitled/presentation/pages/chat_detail_page.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage({super.key});

  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  List<InboxItemDTO> _chats = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInbox();
    _initSignalR();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    SignalRService().removeMessageListener('inbox');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSignalR() async {
    // Đăng ký listener với key 'inbox' để không bị ghi đè bởi ChatDetailPage
    SignalRService().addMessageListener('inbox', (message) {
      if (!mounted) return;
      setState(() {
        final index = _chats.indexWhere((c) => c.conversationId == message.conversationId);
        if (index != -1) {
          _chats[index] = InboxItemDTO(
            conversationId: _chats[index].conversationId,
            otherUserName: _chats[index].otherUserName,
            otherUserAvatar: _chats[index].otherUserAvatar,
            lastMessage: message.messageType == 2 ? '[Hình ảnh]' : (message.content ?? ''),
            lastMessageAt: message.createdAt,
            hasUnread: true,
          );
          final item = _chats.removeAt(index);
          _chats.insert(0, item);
        } else {
          _fetchInbox();
        }
      });
    });

    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token != null) {
      await SignalRService().connect(token);
    }
  }

  Future<void> _fetchInbox() async {
    try {
      final response = await CallMyAPI.getInbox();
      if (mounted) {
        setState(() {
          _chats = response.map((json) => InboxItemDTO.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<InboxItemDTO> displayChats = [];
    bool noMatch = false;

    if (_searchQuery.isNotEmpty) {
      displayChats = _chats.where((c) => c.otherUserName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      if (displayChats.isEmpty) {
        noMatch = true;
        displayChats = _chats; // Nếu không có, hiển thị lại danh sách gốc ở dưới theo ý người dùng
      }
    } else {
      displayChats = _chats;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Tin nhắn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              // TODO: Tạo tin nhắn mới
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 16),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: _searchQuery.isNotEmpty ? 12 : 9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Báo không tìm thấy nếu noMatch = true
          if (noMatch)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
              child: Text('Không có người dùng này', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
            ),
          // Danh sách tin nhắn
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Tin nhắn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.white54))
                : displayChats.isEmpty
                    ? const Center(child: Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _fetchInbox,
                        child: ListView.builder(
                          itemCount: displayChats.length,
                          itemBuilder: (context, index) {
                            final chat = displayChats[index];
                            final String avatarUrl = chat.otherUserAvatar != null && chat.otherUserAvatar!.isNotEmpty
                                ? AppHelper.formatImageURL(chat.otherUserAvatar!)
                                : '';
                            
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                              ),
                              title: Text(
                                chat.otherUserName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: chat.hasUnread ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${chat.lastMessage ?? ''} ${chat.lastMessageAt != null ? '· ${_formatTime(chat.lastMessageAt)}' : ''}',
                                style: TextStyle(
                                  color: chat.hasUnread ? Colors.white : Colors.grey,
                                  fontWeight: chat.hasUnread ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: chat.hasUnread
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : const SizedBox(width: 1),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(
                                      conversationId: chat.conversationId,
                                      otherUserName: chat.otherUserName,
                                      otherUserAvatar: chat.otherUserAvatar,
                                    ),
                                  ),
                                ).then((_) => _fetchInbox());
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
