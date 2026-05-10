import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/datasources/ApiServices.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../data/Helper.dart';
import '../../../Profile/Presentation/Page/profile_page.dart';
import '../../../Search/Presentation/Page/search_page.dart';
import 'home_page.dart';


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
    _fetchUserProfile();
  }

  // lấy dữ liệu user được lưu trong cache
  Future<void> _fetchUserProfile() async {
    try {
      final userRes = await ApiService().get('/user/profile');
      if (userRes != null && userRes['data'] != null) {
        UserModelDTO user = UserModelDTO.fromJson(userRes['data']);
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

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const Center(
        child: Text('Reels Page', style: TextStyle(color: Colors.white))),
    // Placeholder
    const ProfilePage(),
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
          showSelectedLabels: false,
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

  Widget _buildProfileIcon(bool isActive) {
    final currentUser = context
        .read<UserProvider>()
        .user;
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
          child: CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
                AppHelper.formatImageURL(currentUser?.avatarUrl ?? "")),
          ),
        ),
      ],
    );
  }
}