import '../ApiServices.dart';
import '../DTOs/PostDTO.dart';
import '../DTOs/StoryDTO.dart';
import '../DTOs/UserDTO.dart';
import '../DTOs/NotificationDTO.dart';

class CallMyAPI {
  static Future<List<HomePostDTO>> getFeedsOfMe() async {
    try {
      final response = await ApiService().get('/user/feed');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => HomePostDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<PostSummaryDTO>> getMyPostsSummary() async {
    try {
      final response = await ApiService().get('/user/postsSummary');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<PostSummaryDTO>> getPostsSummary(int userId) async {
    try {
      final response = await ApiService().get('/user/${userId}/postsSummary');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<UserStoryDTO>> getMyStoryActive() async {
    try {
      final response = await ApiService().get('/story/active');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => UserStoryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<UserStoryDTO>> getGuestStoryActive(int userId) async {
    try {
      final response = await ApiService().get('/story/guest/${userId}/active');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => UserStoryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<PostSummaryDTO>> getMyLikedPostsSummary() async {
    try {
      final response = await ApiService().get('/post/liked');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  static Future<List<PostSummaryDTO>> getMyArchivedPostsSummary() async {
    try {
      final response = await ApiService().get('/post/archived');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await ApiService().get('/notification');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final response = await ApiService().put('/notification/$notificationId/read');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 1. Lấy bài viết nổi bật cho trang khám phá từ api
  static Future<List<PostSummaryDTO>> getTrendingPosts() async {
    try {
      final response = await ApiService().get('/post/trending');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. Tìm kiếm người dùng
  static Future<List<SuggestedUserDTO>> searchUsers(String keyword) async {
    try {
      final response = await ApiService().get('/user/search/users', queryParameters: {'keyword': keyword});
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SuggestedUserDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 3. Tìm kiếm bài viết
  static Future<List<PostSummaryDTO>> searchPosts(String keyword) async {
    try {
      final response = await ApiService().get('/post/search', queryParameters: {'keyword': keyword});
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => PostSummaryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 4. Lấy chi tiết bài viết
  static Future<dynamic> getPostDetail(int postId) async {
    try {
      final response = await ApiService().get('/post/$postId/me');
      return response;
    } catch (e) {
      return null;
    }
  }

  // 5. Lấy danh sách comments
  static Future<List<CommentDTO>> getComments(int postId) async {
    try {
      final response = await ApiService().get('/post/$postId/comments');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => CommentDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 6. Like / Unlike bài viết
  static Future<bool> toggleLikePost(int postId) async {
    try {
      final response = await ApiService().post('/post/$postId/like', data: {});
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 6b. Danh sách lượt like bài viết
  static Future<List<SuggestedUserDTO>> getPostLikes(int postId) async {
    try {
      final response = await ApiService().get('/post/$postId/likers');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SuggestedUserDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 7. Gửi comment
  static Future<dynamic> sendComment(int postId, String content) async {
    try {
      final response = await ApiService().post(
        '/post/$postId/comment',
        data: {'Content': content},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // 8. Cập nhật bài viết (PUT)
  static Future<dynamic> updatePost(int postId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService().put(
        '/post/$postId',
        data: data,
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // 8b. Cập nhật caption bài viết (PUT)
  static Future<dynamic> updatePostCaption(int postId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService().put(
        '/post/update/$postId/caption',
        data: data,
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // 9. Xóa bài viết (DELETE)
  static Future<bool> deletePost(int postId) async {
    try {
      final response = await ApiService().delete('/post/$postId');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 10. Lấy thông tin cá nhân của người dùng hiện tại
  static Future<dynamic> getUserProfile() async {
    try {
      final response = await ApiService().get('/user/profile');
      return response;
    } catch (e) {
      return null;
    }
  }

  // 11. Lấy chi tiết bài viết (dùng cho user_post_detail_page)
  static Future<dynamic> getUserPostsDetail(String endpoint) async {
    try {
      final response = await ApiService().get(endpoint);
      return response;
    } catch (e) {
      return null;
    }
  }

  // 12. Cập nhật profile (PUT)
  static Future<dynamic> updateUserProfile(dynamic formData) async {
    try {
      final response = await ApiService().put('/user/profile', data: formData);
      return response;
    } catch (e) {
      return null;
    }
  }

  // 13. Follow / Unfollow người dùng
  static Future<dynamic> followUser(int userId) async {
    try {
      final response = await ApiService().post('/user/follow/$userId', data: {});
      return response;
    } catch (e) {
      return null;
    }
  }

  // 14. Lấy followers
  static Future<List<SummaryUserDTO>> getFollowers(int userId) async {
    try {
      final response = await ApiService().get('/user/$userId/followers');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SummaryUserDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 15. Lấy followings
  static Future<List<SuggestedUserDTO>> getFollowings(int userId) async {
    try {
      final response = await ApiService().get('/user/$userId/following');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SuggestedUserDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 16. Lấy suggestions
  static Future<List<SuggestedUserDTO>> getSuggestions() async {
    try {
      final response = await ApiService().get('/user/suggestions');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SuggestedUserDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 17. Đăng bài viết mới
  static Future<dynamic> newPost(dynamic formData) async {
    try {
      final response = await ApiService().post('/post/newPost', data: formData);
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> createNewPost(dynamic formData) => newPost(formData);

  // 18. Thêm story mới
  static Future<dynamic> newStory(dynamic formData) async {
    try {
      final response = await ApiService().post('/story/add', data: formData);
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> addNewStory(dynamic formData) => newStory(formData);

  // 19. Xem story
  static Future<bool> viewStory(int storyId) async {
    try {
      final response = await ApiService().post('/story/view/$storyId');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 20. Lấy thông tin user khác bằng ID
  static Future<dynamic> getUserProfileById(int userId) async {
    try {
      final response = await ApiService().get('/user/profile/$userId');
      return response;
    } catch (e) {
      return null;
    }
  }

  // 21. Kiểm tra follow user khác
  static Future<dynamic> isFollowUser(int userId) async {
    try {
      final response = await ApiService().get('/user/isFollow?followingId=$userId');
      return response;
    } catch (e) {
      return null;
    }
  }

  // 22. Lấy thông tin bài viết trong trạng thái lưu trữ
  static Future<dynamic> getPostDetailArchived(int postId) async {
    try {
      final response = await ApiService().get('/post/$postId/archived/me');
      return response;
    } catch (e) {
      return null;
    }
  }

  // 23. Đăng nhập (POST /auth/login)
  static Future<dynamic> login(String email, String password) async {
    final response = await ApiService().post(
      '/auth/login',
      data: {
        'Email': email,
        'Password': password,
      },
    );
    return response;
  }

  // 24. Kiểm tra Email (POST /auth/checkEmail)
  static Future<dynamic> checkEmail(String email) async {
    final response = await ApiService().post(
      '/auth/checkEmail',
      data: {'Email': email},
    );
    return response;
  }

  // 25. Đăng ký (POST /auth/register)
  static Future<dynamic> register(String email, String password, String username, String fullName) async {
    final response = await ApiService().post(
      '/auth/register',
      data: {
        'Email': email,
        'Password': password,
        'UserName': username,
        'FullName': fullName,
      },
    );
    return response;
  }
}