import 'package:flutter/material.dart';

import '../../../../../../data/Models/User.dart';

class DiscoverPeople extends StatelessWidget {
  final List<User> suggestedUsers; //danh sach ban be goi y
  const DiscoverPeople({super.key, required this.suggestedUsers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),//tạo khoang cach trai phai tren duoi
          child: Text('Khám phá mọi người', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(  //danh sách bạn be goi y
            scrollDirection: Axis.horizontal,  //cuon theo chieu ngang
            padding: const EdgeInsets.only(left: 15), //tạo khoang cach trai
            itemCount: suggestedUsers.length,
            itemBuilder: (context, index) { //lay tung user trong danh sach và hiển thị gợi ý
              final user = suggestedUsers[index];
              return _buildSuggestCard(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestCard(User user) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10), //tạo khoang cach phai
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10), //bo tròn khung gọi ý
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(user.avatarUrl ?? '')), //bo tron avatar
          const SizedBox(height: 10),
          Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0064E0), minimumSize: const Size(double.infinity, 30)),
            onPressed: () {
              print("theo doi ne");
            }, //sau khi kéo api thì xử lý logic ở đâu để thêm bạn bè
            child: const Text('Theo dõi', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}