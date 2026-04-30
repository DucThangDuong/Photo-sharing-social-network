import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import '../Widgets/InputField/EmailInputField.dart';
import '../Widgets/Header/EmailHeader.dart';
import '../Widgets/Button/AuthButton.dart';
import 'create_account_number.dart';

class RegisterEmailPage extends StatefulWidget {
  const RegisterEmailPage({super.key});

  @override
  State<RegisterEmailPage> createState() => _RegisterEmailPageState();
}

class _RegisterEmailPageState extends State<RegisterEmailPage> {
  final TextEditingController _emailController = TextEditingController();

  // Logic kiểm tra Email
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmailHeader(), // 1. Tiêu đề
              const SizedBox(height: 30),

              EmailInputField(controller: _emailController), // 2. Ô nhập liệu
              const SizedBox(height: 20),

              AuthButton( // 3. Nút Tiếp tục
                label: 'Tiếp',
                color: const Color(0xFF0064E0),
                onPressed: _handleContinue,
              ),
              const SizedBox(height: 15),

              AuthButton( // 4. Nút Chuyển sang số điện thoại
                label: 'Đăng ký bằng số di động',
                color: const Color(0xFF262626),
                onPressed: () => Navigator.pop(context),
              ),

              const Spacer(),
              _buildFooter(), // 5. Chân trang
            ],
          ),
        ),
      ),
    );
  }

  // Tách logic xử lý nhấn nút để hàm build không bị dài
  Future<void> _handleContinue() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Vui lòng nhập email');
    } else if (!_isValidEmail(email)) {
      _showError('Định dạng email không hợp lệ');
    } else {
      var response = await ApiService().post(
          '/auth/checkEmail', data: {'Email': email});
      if (response != null && response['data'] != null) {
        final bool isEmailExist = response['data']['exists'];
        if (isEmailExist == true) {
          _showError('Email đã tồn tại');
        }
        else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePasswordPage(email: email)),
          );
        }
      }
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text(
            'Tôi có tài khoản rồi',
            style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}