import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasources/global/User.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/datasources/DTOs/StoryDTO.dart';
import '../../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../../data/Helper.dart';
import '../../../../../presentation/pages/new_post_page.dart';
import '../Widgets/profile_header.dart';
import '../Widgets/profile_info.dart';
import '../Widgets/profile_post_grid.dart';
import '../Widgets/profile_liked_post_grid.dart';
import '../Widgets/profile_archived_post_grid.dart';
import '../../../../../../presentation/pages/new_story_page.dart';
import '../../../../../../presentation/pages/view_story_user_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasStories = false;
  UserStoryDTO? _userStory;
  int _selectedTabIndex = 0;
  List<HighlightDTO> _highlights = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<UserProvider>().user;
      if (currentUser != null) {
        _fetchUserStories(currentUser.id);
      }
    });
  }
  //lấy danh sách story của người dùng từ api
  Future<void> _fetchUserStories(int userId) async {
    try {
      final activeStories = await CallMyAPI.getMyStoryActive();
      final myHighlights = await CallMyAPI.getMyHighlights();
      
      if (mounted) {
        UserStoryDTO? currentUserStory;
        for (var story in activeStories) {
          if (story.userId == userId) {
            currentUserStory = story;
            break;
          }
        }
        setState(() {
          if (currentUserStory != null) {
            _hasStories = currentUserStory.stories.isNotEmpty;
            _userStory = currentUserStory;
          }
          _highlights = myHighlights;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
    }
  }

  void _viewHighlight(HighlightDTO highlight) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    
    final highlightDetail = await CallMyAPI.getHighlightDetails(highlight.id);
    if (mounted) Navigator.pop(context);

    if (highlightDetail == null || highlightDetail.stories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải điểm nhấn hoặc điểm nhấn rỗng')));
      }
      return;
    }

    final user = context.read<UserProvider>().user;
    if (user == null) return;

    UserStoryDTO dummyUserStory = UserStoryDTO(
      userId: user.id,
      username: user.username,
      avatarUrl: user.avatarUrl,
      hasSeen: true,
      stories: highlightDetail.stories,
    );

    if (mounted) {
      final bool? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewPage(userStory: dummyUserStory),
        ),
      );
      if (result == true) {
        _fetchUserStories(user.id);
        setState(() {});
      }
    }
  }

  void _createHighlightDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    
    final archivedStories = await CallMyAPI.getArchivedStories();
    if (mounted) Navigator.pop(context); // pop loading

    if (archivedStories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có story nào để tạo Highlight')),
        );
      }
      return;
    }

    List<int> selectedStoryIds = [];
    TextEditingController titleController = TextEditingController();
    File? selectedCoverImage;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.only(
                top: 16, left: 16, right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tạo điểm nhấn mới', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Chọn ảnh bìa
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setStateSB(() {
                            selectedCoverImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[600]!, width: 1),
                          image: selectedCoverImage != null
                              ? DecorationImage(image: FileImage(selectedCoverImage!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: selectedCoverImage == null
                            ? const Icon(Icons.add_a_photo, color: Colors.white54, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text('Chọn ảnh bìa', style: TextStyle(color: Colors.white54, fontSize: 12))),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tên điểm nhấn',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn tin:', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: archivedStories.length,
                      itemBuilder: (context, index) {
                        final story = archivedStories[index];
                        final isSelected = selectedStoryIds.contains(story.id);
                        return GestureDetector(
                          onTap: () {
                            setStateSB(() {
                              if (isSelected) {
                                selectedStoryIds.remove(story.id);
                              } else {
                                selectedStoryIds.add(story.id);
                              }
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                AppHelper.formatImageURL(story.mediaUrl),
                                fit: BoxFit.cover,
                              ),
                              if (isSelected)
                                Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: Icon(Icons.check_circle, color: Colors.blue, size: 30),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (selectedStoryIds.isEmpty || selectedCoverImage == null) ? null : () async {
                        final title = titleController.text.trim().isEmpty ? 'Highlight' : titleController.text.trim();
                        final success = await CallMyAPI.createHighlight(title, selectedStoryIds, selectedCoverImage!);
                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tạo điểm nhấn thành công')));
                            Navigator.pop(context);
                            // Load lại thông tin cá nhân
                            final currentUser = context.read<UserProvider>().user;
                            if (currentUser != null) {
                              _fetchUserStories(currentUser.id);
                              // Force build lại để ProfileInfo (nếu có update highlight) tự gọi api lại
                              setState(() {}); 
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Tạo', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _editHighlightDialog(HighlightDTO highlight, HighlightDetailDTO detail) async {
    final archivedStories = await CallMyAPI.getArchivedStories();
    // Gộp archived stories và stories đang có trong highlight để có list tổng để chọn
    // Vì archivedStories API chỉ trả về story KHÔNG có trong highlight nào.
    // Nên phải map lại detail.stories sang StoryDTO và gộp vào.
    List<StoryDTO> availableStories = [...archivedStories];
    for (var s in detail.stories) {
      if (!availableStories.any((a) => a.id == s.id)) {
        availableStories.add(s);
      }
    }
    
    // Sort theo thời gian tạo giảm dần
    availableStories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    List<int> selectedStoryIds = detail.stories.map((s) => s.id).toList();
    TextEditingController titleController = TextEditingController(text: detail.title);
    File? selectedCoverImage;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.only(
                top: 16, left: 16, right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chỉnh sửa điểm nhấn', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Chọn ảnh bìa
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setStateSB(() {
                            selectedCoverImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[600]!, width: 1),
                          image: selectedCoverImage != null
                              ? DecorationImage(image: FileImage(selectedCoverImage!), fit: BoxFit.cover)
                              : (highlight.coverUrl != null && highlight.coverUrl!.isNotEmpty)
                                  ? DecorationImage(image: NetworkImage(AppHelper.formatImageURL(highlight.coverUrl!)), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (selectedCoverImage == null && (highlight.coverUrl == null || highlight.coverUrl!.isEmpty))
                            ? const Icon(Icons.add_a_photo, color: Colors.white54, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text('Đổi ảnh bìa', style: TextStyle(color: Colors.white54, fontSize: 12))),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tên điểm nhấn',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn tin:', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: availableStories.length,
                      itemBuilder: (context, index) {
                        final story = availableStories[index];
                        final isSelected = selectedStoryIds.contains(story.id);
                        return GestureDetector(
                          onTap: () {
                            setStateSB(() {
                              if (isSelected) {
                                selectedStoryIds.remove(story.id);
                              } else {
                                selectedStoryIds.add(story.id);
                              }
                            });
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                AppHelper.formatImageURL(story.mediaUrl),
                                fit: BoxFit.cover,
                              ),
                              if (isSelected)
                                Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Center(
                                    child: Icon(Icons.check_circle, color: Colors.blue, size: 30),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedStoryIds.isEmpty ? null : () async {
                        final title = titleController.text.trim().isEmpty ? 'Highlight' : titleController.text.trim();
                        final success = await CallMyAPI.updateHighlight(highlight.id, title, selectedStoryIds, selectedCoverImage);
                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật điểm nhấn thành công')));
                            Navigator.pop(context);
                            final currentUser = context.read<UserProvider>().user;
                            if (currentUser != null) {
                              _fetchUserStories(currentUser.id);
                              setState(() {}); 
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _showHighlightOptions(HighlightDTO highlight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text('Chỉnh sửa điểm nhấn', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    );
                    final detail = await CallMyAPI.getHighlightDetails(highlight.id);
                    if (mounted) Navigator.pop(context); // pop loading
                    
                    if (detail != null) {
                      _editHighlightDialog(highlight, detail);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Xóa điểm nhấn', style: TextStyle(color: Colors.red, fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Xóa điểm nhấn?', style: TextStyle(color: Colors.white)),
                        content: const Text('Bạn có chắc chắn muốn xóa điểm nhấn này không?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      final success = await CallMyAPI.deleteHighlight(highlight.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thành công')));
                        final currentUser = context.read<UserProvider>().user;
                        if (currentUser != null) {
                          _fetchUserStories(currentUser.id);
                          setState(() {}); 
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //các option để người dùng chọn xem có new story, xem story
  void _showAvatarOptions(BuildContext context) {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: Colors.white),
                  title: const Text('Thêm tin mới', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoryUploadPage()),
                    );
                    _fetchUserStories(currentUser.id);
                  },
                ),
                if (_hasStories && _userStory != null)
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: Colors.white),
                    title: const Text('Xem tin', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StoryViewPage(userStory: _userStory!)),
                      );
                      if (result == true) {
                        // Load lại thông tin cá nhân và story nếu người dùng vừa xóa tin
                        _fetchUserStories(currentUser.id);
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Expanded(
              child: Text(
                currentUser.fullName ?? currentUser.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewPostScreen()),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// lấy thông tin cơ bản
            ProfileHeader(
              user: currentUser,
              onAvatarTap: () => _showAvatarOptions(context),
              hasStories: _hasStories,
            ),
// các button chỉnh sửa, chia sẻ trang cá nhân, thêm bạn
            ProfileInfo(user: currentUser),
            
            // Nút tạo highlight
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _createHighlightDialog,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 30),
                          ),
                          const SizedBox(height: 5),
                          const Text('Mới', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    ..._highlights.map((highlight) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: GestureDetector(
                          onTap: () => _viewHighlight(highlight),
                          onLongPress: () => _showHighlightOptions(highlight),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 1),
                                  image: highlight.coverUrl != null && highlight.coverUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(AppHelper.formatImageURL(highlight.coverUrl!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: (highlight.coverUrl == null || highlight.coverUrl!.isEmpty)
                                    ? const Icon(Icons.star, color: Colors.white, size: 30)
                                    : null,
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  highlight.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

// tab bar hinh ảnh , like, lưu trữ
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.favorite_border)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
// nội dung các tab
                  if (_selectedTabIndex == 0)
                    ProfilePostGrid(
                      key: ValueKey(currentUser.postsNumber),
                      user: currentUser,
                    )
                  else if (_selectedTabIndex == 1)
                    ProfileLikedPostGrid(
                      user: currentUser,
                    )
                  else
                    ProfileArchivedPostGrid(
                      user: currentUser,
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