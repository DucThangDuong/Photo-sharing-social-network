import 'package:flutter/material.dart';
import 'create_account_number.dart';

class RegisterEmailPage extends StatefulWidget {
  const RegisterEmailPage({super.key});

  @override
  State<RegisterEmailPage> createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends State<RegisterEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  // Hàm kiểm tra định dạng Email bằng Regular Expression (Regex)
  bool _isValidEmail(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // Hàm hiển thị thông báo lỗi nhanh
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // 1. Tiêu đề
                        const Text(
                          'Email của bạn là gì?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // 2. Mô tả
                        const Text(
                          'Nhập email có thể dùng để liên hệ với bạn. Sẽ không ai nhìn thấy thông tin này trên trang cá nhân của bạn.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 3. Ô nhập Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Color(0xFF333333)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                              const BorderSide(color: Colors.white54),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 4. Nút Tiếp (Có check định dạng)
                        _buildButton(
                          label: 'Tiếp',
                          color: const Color(0xFF0064E0),
                          onPressed: () {
                            String email = _emailController.text.trim();
                            if (email.isEmpty) {
                              _showError('Vui lòng nhập email');
                            } else if (!_isValidEmail(email)) {
                              _showError('Định dạng email không hợp lệ');
                            } else {
                              // Chuyển sang màn hình Mật khẩu
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    const CreatePasswordPage()),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        // 5. Nút Đăng ký bằng số di động
                        _buildButton(
                          label: 'Đăng ký bằng số di động',
                          color: const Color(0xFF262626),
                          onPressed: () => Navigator.pop(context),
                        ),

                        const Spacer(),

                        // 6. Chân trang
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                'Tôi có tài khoản rồi',
                                style: TextStyle(
                                    color: Color(0xFF0064E0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget dùng chung cho các nút bấm
  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}