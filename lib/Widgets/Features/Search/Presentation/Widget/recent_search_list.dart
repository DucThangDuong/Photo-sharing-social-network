import 'package:flutter/material.dart';
import '../../../../../data/datasources/local/SearchCacheService.dart';

class RecentSearchList extends StatefulWidget {
  const RecentSearchList({super.key});

  @override
  State<RecentSearchList> createState() => _RecentSearchListState();
}

class _RecentSearchListState extends State<RecentSearchList> {
  List<Map<String, String>> _recentSearches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearches();
  }

  Future<void> _loadSearches() async {
    final searches = await SearchCacheService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeSearch(String query) async {
    await SearchCacheService.removeSearch(query);
    setState(() {
      _recentSearches.removeWhere((item) => item['query'] == query);
    });
  }

  Future<void> _clearAll() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc muốn xóa tất cả lịch sử tìm kiếm?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa tất cả', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SearchCacheService.clearAll();
      setState(() => _recentSearches.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text('Không có tìm kiếm gần đây', style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gần đây',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: _clearAll,
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(
                    color: Color(0xFF0064E0),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final item = _recentSearches[index];
              final query = item['query'] ?? '';
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF262626),
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: Text(
                  query,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: () => _removeSearch(query),
                ),
                onTap: () {
                  // Có thể trigger tìm kiếm lại với query này
                },
              );
            },
          ),
        ),
      ],
    );
  }
}