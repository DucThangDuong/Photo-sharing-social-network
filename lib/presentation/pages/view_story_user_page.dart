import 'package:flutter/material.dart';
import '../../data/datasources/DTOs/StoryDTO.dart';
import '../../data/Helper.dart';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/CallAPIOfUser.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/global/User.dart';

class StoryViewPage extends StatefulWidget {
  final UserStoryDTO userStory;
  final bool isGuestHighlight;

  const StoryViewPage({super.key, required this.userStory, this.isGuestHighlight = false});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 30));

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userStory.stories.isNotEmpty) {
        _markStoryAsViewed(widget.userStory.stories[0].id);
        _animController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _markStoryAsViewed(int storyId) async {
    try {
      await CallMyAPI.viewStory(storyId);
    } catch (e) {
      debugPrint("Error marking story as viewed: $e");
    }
  }
  // xem story sau đó của người dùng
  void _nextStory() {
    _animController.stop();
    _animController.reset();
    if (_currentIndex < widget.userStory.stories.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }
  // xem story trước đó của người dùng
  void _prevStory() {
    _animController.stop();
    _animController.reset();
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _animController.forward();
    }
  }

  void _showDeleteDialog(int storyId) {
    _animController.stop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa tin', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context); // Đóng bottom sheet
                  final success = await CallMyAPI.deleteStory(storyId);
                  if (success) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa tin')));
                      Navigator.pop(context, true); // Đóng view story và trả về true để reload
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thất bại')));
                      _animController.forward(); // Tiếp tục chạy nếu thất bại
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      _animController.forward(); // Tiếp tục chạy khi đóng bottom sheet
    });
  }

  void _showViewersDialog(int storyId) {
    _animController.stop();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('Người xem', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: CallMyAPI.getStoryViewers(storyId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Chưa có người xem', style: TextStyle(color: Colors.white54)));
                      }
                      final viewers = snapshot.data!;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: viewers.length,
                        itemBuilder: (context, index) {
                          final viewer = viewers[index];
                          final avatar = viewer.avatarUrl != null ? AppHelper.formatImageURL(viewer.avatarUrl!) : '';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                            ),
                            title: Text(viewer.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(viewer.fullName ?? '', style: const TextStyle(color: Colors.white54)),
                            trailing: viewer.isLiked ? const Icon(Icons.favorite, color: Colors.red) : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _animController.forward();
    });
  }

  void _toggleLikeCurrentStory() async {
    final story = widget.userStory.stories[_currentIndex];
    setState(() {
      story.isLiked = !story.isLiked;
    });
    
    final success = await CallMyAPI.toggleLikeStory(story.id);
    if (!success) {
      if (mounted) {
        setState(() {
          story.isLiked = !story.isLiked; // revert nếu lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userStory.stories.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("Không có tin", style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTapUp: (details) {
                final width = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < width / 3) {
                  _prevStory();
                } else {
                  _nextStory();
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.userStory.stories.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  _animController.stop();
                  _animController.reset();
                  _animController.forward();
                  _markStoryAsViewed(widget.userStory.stories[index].id);
                },
                itemBuilder: (context, index) {
                  final story = widget.userStory.stories[index];
                  String imageUrl = AppHelper.formatImageURL(story.mediaUrl);
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), // Làm tối ảnh 30% để dễ đọc chữ
                      BlendMode.darken,
                    ),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  );
                },
              ),
            ),
            
            // Progress bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(widget.userStory.stories.length, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: index == _currentIndex 
                                  ? _animController.value 
                                  : (index < _currentIndex ? 1.0 : 0.0),
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          }
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Header info
            Positioned(
              top: 25,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.userStory.avatarUrl != null 
                        ? NetworkImage(AppHelper.formatImageURL(widget.userStory.avatarUrl!)) 
                        : null,
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.userStory.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppHelper.formatTimeAgo(widget.userStory.stories[_currentIndex].createdAt),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const Spacer(),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (userProvider.user?.id == widget.userStory.userId) {
                        return IconButton(
                          icon: const Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () => _showDeleteDialog(widget.userStory.stories[_currentIndex].id),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Các nút thao tác ở dưới cùng
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final isOwner = userProvider.user?.id == widget.userStory.userId;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Nút xem người xem (Bên trái, cho chủ sở hữu)
                      if (isOwner)
                        GestureDetector(
                          onTap: () => _showViewersDialog(widget.userStory.stories[_currentIndex].id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text('Người xem', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(), // Chỗ trống bên trái nếu không phải chủ

                      // Nút thả tim (Bên phải, cho người xem)
                      if (!isOwner && !widget.isGuestHighlight)
                        IconButton(
                          icon: Icon(
                            widget.userStory.stories[_currentIndex].isLiked 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            color: widget.userStory.stories[_currentIndex].isLiked 
                                ? Colors.red 
                                : Colors.white,
                            size: 32,
                          ),
                          onPressed: _toggleLikeCurrentStory,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
