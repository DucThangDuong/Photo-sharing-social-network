import '../ApiServices.dart';
import '../DTOs/PostDTO.dart';
import '../DTOs/StoryDTO.dart';

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
      final response = await ApiService().get('/user/postsSummary/${userId}');
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
}