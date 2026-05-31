import 'package:flutter/cupertino.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage('https://th.bing.com/th/id/R.f422436b61a413ab7808a9e95ad6197a?rik=NpXAxzdSeTPOdg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-LUFC1dRZ6hY%2fUP9GGT0aOqI%2fAAAAAAAACP0%2f3JSxwW1F_os%2fs1600%2fManchester%2bUnited%2bLogo%2bHD%2bWallpapers.jpg&ehk=JGa1VNf3VP7xwDQ1496IDfjTB8YuO7gmbloDtX8eie8%3d&risl=&pid=ImgRaw&r=0'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}