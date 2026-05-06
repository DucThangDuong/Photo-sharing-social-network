import 'package:flutter/material.dart';

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
  String _selectedType = 'Posts';
  List<dynamic> _posts = [
    {'imageUrl': 'https://picsum.photos/500/800?random=1', 'views': '75,8K'},
    {'imageUrl': 'https://picsum.photos/500/800?random=2', 'views': '1,2 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=3', 'views': '2 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=4', 'views': '10,4 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=5', 'views': '482K'},
    {'imageUrl': 'https://picsum.photos/500/800?random=6', 'views': '1 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=7', 'views': '9,5 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=8', 'views': '118K'},
    {'imageUrl': 'https://picsum.photos/500/800?random=9', 'views': '878K'},
    {'imageUrl': 'https://picsum.photos/500/800?random=10', 'views': '4,8 triệu'},
    {'imageUrl': 'https://picsum.photos/500/800?random=11', 'views': '250K'},
    {'imageUrl': 'https://picsum.photos/500/800?random=12', 'views': '1,5 triệu'},
  ]; // kéo dữ liệu api vào đây
  List<dynamic> _userResults = [
  {'name': 'Đinh Tấn Thành', 'username': 'dinhtan6974', 'avatar': 'https://i.pravatar.cc/150?u=1'},
  {'name': 'Hân Phạm', 'username': 'hanpham_huit', 'avatar': 'https://i.pravatar.cc/150?u=2'},
  {'name': 'Nguyễn Văn A', 'username': 'anv_99', 'avatar': 'https://i.pravatar.cc/150?u=3'},
  ];
  List<dynamic> _postResults = [
  {'imageUrl': 'https://picsum.photos/500/800?random=20', 'views': '50K'},
  {'imageUrl': 'https://picsum.photos/500/800?random=21', 'views': '125K'},
  {'imageUrl': 'https://picsum.photos/500/800?random=22', 'views': '1,1 triệu'},
  {'imageUrl': 'https://picsum.photos/500/800?random=23', 'views': '900K'},
  ];
  // Logic gọi API để ở đây...

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
                setState(() => _isSearching = _isSubmitted = false);
              },
              onSubmitted: (val) => setState(() => _isSubmitted = true),
            ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isSubmitted) {
      return SearchResultView(
        selectedType: _selectedType,
        query: _searchController.text,
        userResults: _userResults, // Truyền list user[cite: 5]
        postResults: _postResults, // Truyền list post[cite: 5]
        onTypeChanged: (type) => setState(() => _selectedType = type),
      );
    }
    if (_isSearching) {
      return const RecentSearchList(); // lưu thông tin lịch sử tìm kiếm gần đây
    }
    return DiscoveryGrid(posts: _posts, isLoading: false);
  }
}