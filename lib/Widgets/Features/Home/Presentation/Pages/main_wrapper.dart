import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../data/datasources/global/User.dart';
import 'home_page.dart';

// Giả sử bạn đã tạo các file này
// import 'pages/search_page.dart';
// import 'pages/profile_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  bool _isFetchingUser = true;
  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Gọi hàm lấy dữ liệu ngay khi vừa nạp màn hình
  }

  Future<void> _fetchUserProfile() async {
    try {
      // 1. Gọi API lấy dữ liệu như bạn viết
      final userRes = await ApiService().get('/user/profile');

      // Kiểm tra an toàn trước khi map dữ liệu
      if (userRes != null && userRes['data'] != null) {
        UserModelDTO user = UserModelDTO.fromJson(userRes['data']);

        // 2. Nạp vào kho Provider
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
      }
    } catch (e) {
      print("Lỗi lấy thông tin người dùng: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingUser = false;
        });
      }
    }
  }
  int _selectedIndex = 0;

  // Danh sách các trang tương ứng với các nút ở thanh bên dưới
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Search Page', style: TextStyle(color: Colors.white))), // Placeholder
    const Center(child: Text('Reels Page', style: TextStyle(color: Colors.white))),  // Placeholder
    const Center(child: Text('Profile Page', style: TextStyle(color: Colors.white))), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    if (_isFetchingUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      // IndexedStack giúp giữ nguyên vị trí cuộn khi bạn chuyển tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF262626), width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: false, // Instagram không hiện chữ dưới icon
          showUnselectedLabels: false,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              activeIcon: Icon(Icons.video_library),
              label: 'Reels',
            ),
            BottomNavigationBarItem(
              icon: _buildProfileIcon(false),
              activeIcon: _buildProfileIcon(true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Widget riêng cho Icon Profile để có vòng tròn và chấm đỏ thông báo
  Widget _buildProfileIcon(bool isActive) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.transparent,
              width: 1,
            ),
          ),
          child: const CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=my_profile'),
          ),
        ),
        // Chấm đỏ thông báo (như ảnh bạn gửi)
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF121212), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}