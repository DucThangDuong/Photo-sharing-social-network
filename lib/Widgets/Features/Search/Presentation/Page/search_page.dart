import 'package:flutter/material.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/local/SearchCacheService.dart';
import '../Widget/discovery_grid.dart';
import '../Widget/recent_search_list.dart';
import '../Widget/search_input_field.dart';
import '../Widget/search_result_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  bool _isSubmitted = false;
  bool _isLoadingDiscover = true;
  bool _isLoadingResults = false;
  String _selectedType = 'Posts';

  // Bài viết nổi bật (trang khám phá)
  List<PostSummaryDTO> _posts = [];

  // Kết quả tìm kiếm
  List<SuggestedUserDTO> _userResults = [];
  List<PostSummaryDTO> _postResults = [];

  @override
  void initState() {
    super.initState();
    _fetchDiscoverPosts();
  }

  // Lấy bài viết nổi bật cho trang khám phá từ api
  Future<void> _fetchDiscoverPosts() async {
    try {
      final response = await ApiService().get('/post/trending');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _posts = rawList.map((i) => PostSummaryDTO.fromJson(i)).toList();
          _isLoadingDiscover = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDiscover = false);
      }
    }
  }
  // gọi 2 api , 1 cái là lấy người dùng, 1 cái lấy các bài post trùng tên
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isLoadingResults = true);
    try {
      final resultsUser = await ApiService().get('/user/search/users', queryParameters: {'keyword': query.trim()});
      if (mounted) {
        setState(() {
          var userList = resultsUser['data'] as List? ?? [];
          _userResults = userList.map((i) => SuggestedUserDTO.fromJson(i)).toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi tìm kiếm người dùng: $e');
    }

    try {
      final resultsPost = await ApiService().get('/post/search/posts', queryParameters: {'keyword': query.trim()});
      if (mounted) {
        setState(() {
          var postList = resultsPost['data'] as List? ?? [];
          _postResults = postList.map((i) => PostSummaryDTO.fromJson(i)).toList();
        });
      }
    } catch (e) {
      debugPrint('Lỗi tìm kiếm bài viết: $e');
    }

    if (mounted) {
      setState(() => _isLoadingResults = false);
    }
  }
  // gửi yêu cầu tìm kiếm từ khóa lên api
  Future<void> _handleSubmit(String val) async {
    if (val.trim().isNotEmpty) {
      SearchCacheService.addSearch(val.trim());
      setState(() => _isSubmitted = true);
      await _performSearch(val.trim());
    } else {
      setState(() => _isSubmitted = true);
    }
  }
  // các tabbar tìm kiếm, chuyển giữa người dùng và bài viết
  Widget _buildContent() {
    if (_isSubmitted) {
      return SearchResultView(
        selectedType: _selectedType,
        query: _searchController.text,
        userResults: _userResults,
        postResults: _postResults,
        isLoading: _isLoadingResults,
        onTypeChanged: (type) => setState(() => _selectedType = type),
      );
    }
    if (_isSearching) {
      return RecentSearchList(
        onSelectRecentSearch: (query) {
          _searchController.text = query;
          SearchCacheService.addSearch(query);
          setState(() => _isSubmitted = true);
          _performSearch(query);
        },
      );
    }
    return DiscoveryGrid(posts: _posts, isLoading: _isLoadingDiscover);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            SearchInputField(
              controller: _searchController,
              focusNode: _focusNode,
              isSearching: _isSearching,
              onTap: () => setState(() => _isSearching = true),
              onCancel: () {
                _focusNode.unfocus();
                setState(() {
                  _isSearching = false;
                  _isSubmitted = false;
                  _userResults = [];
                  _postResults = [];
                });
              },
              onSubmitted: _handleSubmit,
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

}