import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/global/CallAPIOfUser.dart';
import '../../data/datasources/DTOs/ChatDTO.dart';
import '../../data/datasources/DTOs/PostDTO.dart';
import '../../data/datasources/SignalR.dart';
import '../../data/datasources/global/User.dart';
import '../../data/Helper.dart';
import '../../Widgets/Features/Search/Presentation/Page/discover_post_detail_page.dart';

class ChatDetailPage extends StatefulWidget {
  final int conversationId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatDetailPage({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  ConversationDetailDTO? _conversation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _initSignalR();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreMessages();
    }
  }

  Future<void> _initSignalR() async {
    SignalRService().addMessageListener('chatDetail', (message) {
      if (!mounted) return;
      if (message.conversationId == widget.conversationId) {
        setState(() {
          if (_conversation == null) {
             _conversation = ConversationDetailDTO(
               otherUserId: 0,
               otherUserName: widget.otherUserName,
               otherUserAvatar: widget.otherUserAvatar,
               messages: [message],
             );
          } else {
            bool exists = _conversation!.messages.any((m) => m.id == message.id);
            if (!exists) {
              _conversation!.messages.insert(0, message);
            }
          }
        });
        CallMyAPI.markConversationAsRead(widget.conversationId);
      }
    });

    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token != null) {
      await SignalRService().connect(token);
    }
  }

  @override
  void dispose() {
    SignalRService().removeMessageListener('chatDetail');
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final detail = await CallMyAPI.getConversationMessages(widget.conversationId, page: 1);
      if (mounted) {
        setState(() {
          _conversation = detail;
          _isLoading = false;
          _currentPage = 1;
          _hasMore = (detail?.messages.length ?? 0) >= 20;
        });
      }

      await CallMyAPI.markConversationAsRead(widget.conversationId);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final detail = await CallMyAPI.getConversationMessages(widget.conversationId, page: nextPage);
      if (mounted && detail != null) {
        setState(() {
          if (detail.messages.isEmpty) {
            _hasMore = false;
          } else {
            _conversation?.messages.addAll(detail.messages);
            _currentPage = nextPage;
            _hasMore = detail.messages.length >= 20;
          }
          _isLoadingMore = false;
        });
      } else {
        if (mounted) setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      debugPrint('Error loading more messages: $e');
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      // Gửi qua HTTP POST
      final newMessage = await CallMyAPI.sendMessage(widget.conversationId, text);
      if (newMessage != null && mounted) {
        setState(() {
          if (_conversation == null) {
            _conversation = ConversationDetailDTO(
              otherUserId: 0,
              otherUserName: widget.otherUserName,
              otherUserAvatar: widget.otherUserAvatar,
              messages: [newMessage],
            );
          } else {
            bool exists = _conversation!.messages.any((m) => m.id == newMessage.id);
            if (!exists) {
              _conversation!.messages.insert(0, newMessage);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final File file = File(image.path);
        final newMessage = await CallMyAPI.sendMessage(widget.conversationId, null, mediaFile: file);
        if (newMessage != null && mounted) {
          setState(() {
            if (_conversation == null) {
              _conversation = ConversationDetailDTO(
                otherUserId: 0,
                otherUserName: widget.otherUserName,
                otherUserAvatar: widget.otherUserAvatar,
                messages: [newMessage],
              );
            } else {
              _conversation!.messages.insert(0, newMessage);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking and sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserProvider>().user;
    final int currentUserId = currentUser?.id ?? 0;

    String displayAvatar = _conversation?.otherUserAvatar ?? widget.otherUserAvatar ?? '';
    String displayName = _conversation?.otherUserName ?? widget.otherUserName;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[800],
              backgroundImage: displayAvatar.isNotEmpty ? NetworkImage(AppHelper.formatImageURL(displayAvatar)) : null,
              child: displayAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 20) : null,
            ),
            const SizedBox(width: 10),
            Text(
              displayName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white54))
          : Column(
              children: [
                Expanded(
                  child: _conversation == null || _conversation!.messages.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _conversation!.messages.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _conversation!.messages.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
                                  ),
                                ),
                              );
                            }

                            final msg = _conversation!.messages[index];
                            bool isMe = msg.senderId == currentUserId;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: GestureDetector(
                                onLongPress: () {
                                  if (isMe) {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: const Color(0xFF262626),
                                      builder: (context) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.delete, color: Colors.redAccent),
                                              title: const Text('Thu hồi tin nhắn', style: TextStyle(color: Colors.redAccent)),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                final success = await CallMyAPI.deleteMessage(msg.id);
                                                if (success && mounted) {
                                                  setState(() {
                                                    _conversation!.messages.removeWhere((m) => m.id == msg.id);
                                                  });
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Không thể thu hồi tin nhắn')),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: _isPostLink(msg.content)
                                    ? Container(
                                        margin: const EdgeInsets.only(bottom: 8, top: 4),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                                        ),
                                        child: PostLinkPreview(
                                          postId: _extractPostId(msg.content!)!,
                                        ),
                                      )
                                    : Container(
                                        margin: const EdgeInsets.only(bottom: 8, top: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isMe ? const Color(0xFF3797F0) : const Color(0xFF262626),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                                        ),
                                        child: msg.messageType == 2 && msg.mediaUrl != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(AppHelper.formatImageURL(msg.mediaUrl!)),
                                              )
                                            : Text(
                                                msg.content ?? '',
                                                style: const TextStyle(color: Colors.white, fontSize: 15),
                                              ),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
                // Ô nhập tin nhắn
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF121212),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF262626),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            onPressed: _pickAndSendImage,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Nhắn tin...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF3797F0)),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  bool _isPostLink(String? content) {
    if (content == null) return false;
    return content.startsWith('app://post/');
  }

  int? _extractPostId(String content) {
    final match = RegExp(r'app://post/(\d+)').firstMatch(content);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}

/// Widget hiển thị preview bài viết trong tin nhắn
class PostLinkPreview extends StatefulWidget {
  final int postId;

  const PostLinkPreview({super.key, required this.postId});

  @override
  State<PostLinkPreview> createState() => _PostLinkPreviewState();
}

class _PostLinkPreviewState extends State<PostLinkPreview> {
  HomePostDTO? _post;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    try {
      final response = await CallMyAPI.getPostDetail(widget.postId);
      if (mounted) {
        HomePostDTO? post;
        if (response != null) {
          dynamic postData;
          if (response is Map<String, dynamic> && response.containsKey('data')) {
            postData = response['data'];
          } else {
            postData = response;
          }
          if (postData != null && postData is Map<String, dynamic>) {
            post = HomePostDTO.fromJson(postData);
          }
        }
        setState(() {
          _post = post;
          _isLoading = false;
          _hasError = post == null;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: SizedBox(width: 20,
            height: 20,
            child: CircularProgressIndicator(
                color: Colors.white38, strokeWidth: 2))),
      );
    }

    if (_hasError || _post == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: const Text('Bài viết không khả dụng',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
      );
    }

    final imageUrl = _post!.postMedia.isNotEmpty
        ? AppHelper.formatImageURL(_post!.postMedia.first.mediaUrl)
        : '';
    final avatarUrl = _post!.avatarUrl != null && _post!.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(_post!.avatarUrl!)
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscoverPostDetailPage(
              postId: widget.postId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hình ảnh bài viết
            if (imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            // Thông tin bài viết
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(
                        avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(
                        Icons.person, color: Colors.white, size: 14) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _post!.username,
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        if (_post!.caption != null &&
                            _post!.caption!.isNotEmpty)
                          Text(
                            _post!.caption!,
                            style: const TextStyle(color: Colors.grey,
                                fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
              child: Text(
                'Nhấn để xem bài viết',
                style: TextStyle(color: Colors.blue[300], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}