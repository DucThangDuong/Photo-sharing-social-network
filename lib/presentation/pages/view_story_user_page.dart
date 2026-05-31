import 'package:flutter/material.dart';
import '../../data/datasources/DTOs/StoryDTO.dart';
import '../../data/Helper.dart';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/CallAPIOfUser.dart';

class StoryViewPage extends StatefulWidget {
  final UserStoryDTO userStory;

  const StoryViewPage({super.key, required this.userStory});

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userStory.stories.isNotEmpty) {
        _markStoryAsViewed(widget.userStory.stories[0].id);
      }
    });
  }

  @override
  void dispose() {
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
    if (_currentIndex < widget.userStory.stories.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }
  // xem story trước đó của người dùng
  void _prevStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
                  _markStoryAsViewed(widget.userStory.stories[index].id);
                },
                itemBuilder: (context, index) {
                  final story = widget.userStory.stories[index];
                  String imageUrl = AppHelper.formatImageURL(story.mediaUrl);
                  return Image.network(imageUrl, fit: BoxFit.cover);
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
                      decoration: BoxDecoration(
                        color: index <= _currentIndex ? Colors.white : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
