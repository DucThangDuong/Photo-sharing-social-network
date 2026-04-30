import 'package:flutter/material.dart';

import '../../../../../../data/Models/User.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';

class ProfileHeader extends StatelessWidget {
  final UserModelDTO user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), //tạo khoảng cách bên trái phải trên dưới
      child: Row(
        children: [
          // hiển thị ảnh dại diện và bóng ghi chú
          Stack(//cho phép các widget trong children có thể chồng lên nhau
            children: [
              //bo tròn avater cho giống với inta thôi (khi có dữ liệu api thì lấy url gán vào đây)
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[800],
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              ),
              // bong ghi chu
              Positioned( //cho phép di chuyển trai phải lên xuống (để di chuyển bong bong lên trên hình avatar)
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(  //viền khung lại và bo tròn goc đó ;;))
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(15), //tròn góc ne
                    border: Border.all(color: Colors.black, width: 1), //vien khung ne
                  ),
                  child: const Text(
                    'Đang mê mẩn...',   //thich thay nội dung bong bóng cảm xúc fnaof thì thay vào đây
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),

          // các thong tin như so bài viết, so ngươi follow, so ngươi dang theo dõi
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('0', 'bài viết'),  //khi nào kéo api thì thêm số bài viết có id user vào và đếm
                _buildStatItem('10tr', 'người theo dõi'), //người theo dõi thì cũng vậy (lấy bảng follow)
                _buildStatItem('2', 'đang theo dõi'), //như trên
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}