import 'package:flutter/material.dart';

import '../../../../../../data/Models/User.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../presentation/pages/EditProfile.dart';

class ProfileInfo extends StatelessWidget {
  final UserModelDTO user;

  const ProfileInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      //tạo khoảng cách trai phải
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // hien thi link bio
          const SizedBox(height: 5),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [ //khi keo api thi thay vào link bio vao
                    const Icon(
                        Icons.alternate_email, color: Colors.white, size: 12),
                    Text(user.username, style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),

          // các nut bấm
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildActionButton('Chỉnh sửa', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const EditProfilePage())
                );
              })),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildActionButton('Chia sẻ trang cá nhân', () {})),
              const SizedBox(width: 8),
              // gợi ý kết ban
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed, // Gán logic khi nhấn vào đây
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14
          ),
        ),
      ),
    );
  }
}