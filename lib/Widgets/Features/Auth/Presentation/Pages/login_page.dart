import 'package:flutter/material.dart';
import 'package:untitled/Widgets/Features/Auth/Presentation/Pages/register_page.dart';

import 'find_account_page.dart';

class InstagramLoginDark extends StatefulWidget {
  @override
  _InstagramLoginDarkState createState() => _InstagramLoginDarkState();
}

class _InstagramLoginDarkState extends State<InstagramLoginDark> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Đổi nền sang màu đen sâu
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 2. Logo Instagram Gradient (Dùng ảnh từ mạng hoặc asset của bạn)
              Center(
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Sử dụng link từ một nguồn CDN khác
                    image: const DecorationImage(
                      image: NetworkImage('https://cdn-icons-png.flaticon.com/512/174/174855.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 3. Ô nhập liệu (Đã được bo tròn và đổi màu tối)
              _buildTextField(_emailController, 'Tên người dùng, email/số di động', false),
              const SizedBox(height: 12),
              _buildTextField(_passwordController, 'Mật khẩu', true),

              const SizedBox(height: 15),

              // 4. Nút Đăng nhập xanh Meta
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0064E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Bo tròn dạng viên thuốc
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // 5. Quên mật khẩu
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindAccountPage()),
                  );
                },
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),

              const Spacer(flex: 2),

              // 6. Nút Tạo tài khoản mới (Viền xanh)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0064E0), width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhonePage()));
                  },
                  child: const Text(
                    'Tạo tài khoản mới',
                    style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 7. Branding Meta dưới cùng
              Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.all_inclusive, color: Colors.grey, size: 18),
                    const SizedBox(width: 5),
                    Text(
                      'Meta',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung đã được tinh chỉnh theo Dark Mode
  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(color: Colors.white), // Chữ nhập vào màu trắng
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFF1E1E1E), // Nền ô nhập xám đậm
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        // Bo tròn góc mạnh hơn (15) theo hình mẫu
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        )
            : null,
      ),
    );
  }
}