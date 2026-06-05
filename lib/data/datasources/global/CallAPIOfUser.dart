import 'dart:io';
import 'package:dio/dio.dart';
import '../ApiServices.dart';
import '../DTOs/ChatDTO.dart';
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
  static Future<List<SuggestedUserDTO>> getFollowers(int userId) async {
    try {
      final response = await ApiService().get('/user/$userId/followers');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => SuggestedUserDTO.fromJson(json)).toList();
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

  // 26. Đăng xuất (POST /auth/logout)
  static Future<dynamic> logout(String? deviceToken) async {
    try {
      final response = await ApiService().post(
        '/auth/logout',
        data: deviceToken != null ? {'DeviceToken': deviceToken} : {},
      );
      return response;
    } catch (e) {
      return null;
    }
  }

  // Quên mật khẩu
  static Future<dynamic> forgotPassword(String email) async {
    return await ApiService().post(
      '/auth/forgot-password',
      data: {'Email': email},
    );
  }

  // Xác thực OTP
  static Future<dynamic> verifyOtp(String email, String otp) async {
    return await ApiService().post(
      '/auth/verify-otp',
      data: {'Email': email, 'Otp': otp},
    );
  }

  // Đặt lại mật khẩu mới
  static Future<dynamic> resetPassword(String email, String otp, String newPassword) async {
    return await ApiService().post(
      '/auth/reset-password',
      data: {'Email': email, 'Otp': otp, 'NewPassword': newPassword},
    );
  }

  // 27. Xóa story
  static Future<bool> deleteStory(int storyId) async {
    try {
      final response = await ApiService().delete('/story/$storyId');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Lấy hoặc tạo phòng chat
  static Future<int?> getOrCreateConversation(int otherUserId) async {
    try {
      final response = await ApiService().get('/chat/get-or-create/$otherUserId');
      if (response != null && response['data'] != null) {
        return response['data']['conversationId'];
      }
      return null;
    } catch (e) {
      print("Lỗi lấy phòng chat: $e");
      return null;
    }
  }

  // Lấy chi tiết phòng chat và tin nhắn
  static Future<ConversationDetailDTO?> getConversationMessages(int conversationId, {int page = 1, int limit = 20}) async {
    try {
      final response = await ApiService().get('/chat/$conversationId/messages', queryParameters: {'page': page, 'limit': limit});
      if (response != null && response['data'] != null) {
        return ConversationDetailDTO.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy tin nhắn: $e");
      return null;
    }
  }

  // Xóa tin nhắn
  static Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await ApiService().delete('/chat/messages/$messageId');
      return response != null && response['success'] == true;
    } catch (e) {
      print("Lỗi xóa tin nhắn: $e");
      return false;
    }
  }

  // Đánh dấu đã đọc tin nhắn
  static Future<bool> markConversationAsRead(int conversationId) async {
    try {
      final response = await ApiService().put('/chat/$conversationId/read');
      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      print("Lỗi đánh dấu đã đọc: $e");
      return false;
    }
  }

  // Gửi tin nhắn
  static Future<MessageDTO?> sendMessage(int conversationId, String? content, {dynamic mediaFile}) async {
    try {
      final FormData formData = FormData.fromMap({
        if (content != null && content.isNotEmpty) 'Content': content,
        if (mediaFile != null) 'MediaFile': await MultipartFile.fromFile(mediaFile.path, filename: mediaFile.path.split('/').last),
      });

      final response = await ApiService().post('/chat/$conversationId/messages', data: formData);
      if (response != null && response['data'] != null) {
        return MessageDTO.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      print("Lỗi gửi tin nhắn: $e");
      return null;
    }
  }

  // Lấy danh sách hộp thư thoại (chat/inbox)
  static Future<List<dynamic>> getInbox() async {
    try {
      final response = await ApiService().get('/chat/inbox');
      if (response != null && response['data'] != null) {
        return response['data'] as List;
      }
      return [];
    } catch (e) {
      print("Lỗi lấy danh sách inbox: $e");
      return [];
    }
  }

  // 28. Xem danh sách người đã xem story
  static Future<List<StoryViewerDTO>> getStoryViewers(int storyId) async {
    try {
      final response = await ApiService().get('/story/$storyId/viewers');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => StoryViewerDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 29. Thả tim/Bỏ thả tim story
  static Future<bool> toggleLikeStory(int storyId) async {
    try {
      final response = await ApiService().post('/story/$storyId/like');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 30. Lấy danh sách story đã lưu trữ (Archived)
  static Future<List<StoryDTO>> getArchivedStories() async {
    try {
      final response = await ApiService().get('/story/archived');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => StoryDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 31. Tạo Highlight mới với ảnh bìa
  static Future<bool> createHighlight(String title, List<int> storyIds, File coverImage) async {
    try {
      final formData = FormData.fromMap({
        'Title': title,
        'CoverImage': await MultipartFile.fromFile(coverImage.path),
      });
      for (var id in storyIds) {
        formData.fields.add(MapEntry('StoryIds', id.toString()));
      }

      final response = await ApiService().post(
        '/story/highlight',
        data: formData,
      );
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 32. Lấy danh sách highlight của người dùng
  static Future<List<HighlightDTO>> getMyHighlights() async {
    try {
      final response = await ApiService().get('/story/my-highlights');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => HighlightDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 33. Chi tiết một highlight
  static Future<HighlightDetailDTO?> getHighlightDetails(int highlightId) async {
    try {
      final response = await ApiService().get('/story/highlight/$highlightId');
      if (response != null && response['data'] != null) {
        return HighlightDetailDTO.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 34. Sửa highlight
  static Future<bool> updateHighlight(int highlightId, String title, List<int> storyIds, File? coverImage) async {
    try {
      var formDataMap = {
        'Title': title,
      };
      
      if (coverImage != null) {
        formDataMap['CoverImage'] = (await MultipartFile.fromFile(coverImage.path)) as String;
      }
      
      final formData = FormData.fromMap(formDataMap);
      for (var id in storyIds) {
        formData.fields.add(MapEntry('StoryIds', id.toString()));
      }

      final response = await ApiService().put(
        '/story/highlight/$highlightId',
        data: formData,
      );
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 35. Xóa highlight
  static Future<bool> deleteHighlight(int highlightId) async {
    try {
      final response = await ApiService().delete('/story/highlight/$highlightId');
      return response != null;
    } catch (e) {
      return false;
    }
  }

  // 36. Lấy danh sách highlight của người dùng khác
  static Future<List<HighlightDTO>> getUserHighlights(int userId) async {
    try {
      final response = await ApiService().get('/story/user/$userId/highlights');
      if (response != null && response['data'] != null) {
        var dataList = response['data'] as List;
        return dataList.map((json) => HighlightDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 37. Chi tiết một highlight với tư cách khách
  static Future<HighlightDetailDTO?> getGuestHighlightDetails(int highlightId) async {
    try {
      final response = await ApiService().get('/story/guest/highlight/$highlightId');
      if (response != null && response['data'] != null) {
        return HighlightDetailDTO.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}