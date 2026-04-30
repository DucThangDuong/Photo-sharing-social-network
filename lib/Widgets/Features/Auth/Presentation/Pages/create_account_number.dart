import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../presentation/widgets/Features1/Auth/Presentation/Pages/login_page.dart';
import '../Widgets/InputField/PasswordInputField.dart';
import '../Widgets/Header/PasswordHeader.dart';
import '../Widgets/Button/RememberMeOption.dart';

class CreatePasswordPage extends StatefulWidget {
  final String email;
  const CreatePasswordPage({super.key, required this.email});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberPassword = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  // Logic xử lý link
  Future<void> _handleUrl() async {
    final Uri url = Uri.parse('https://help.instagram.com/1020536697967549');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Lỗi mở link');
    }
  }
  Future<void> _handleRegister() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().post(
        '/auth/register',
        data: {
          'Email': widget.email,
          'Password': password,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo tài khoản thành công')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => InstagramLoginDark()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo tài khoản thất bại: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              // Sử dụng các Widget đã tách
              const PasswordHeader(),
              const SizedBox(height: 30),

              PasswordInputField(
                controller: _passwordController,
                isVisible: _isPasswordVisible,
                toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(height: 15),

              RememberMeOption(
                value: _rememberPassword,
                onChanged: (val) => setState(() => _rememberPassword = val ?? true),
                onLearnMore: _handleUrl,
              ),
              const SizedBox(height: 30),

              // Nút Tiếp tục
              _buildSubmitButton(),

              const Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Các hàm build phụ cho các nút đơn giản
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0064E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text('Tiếp', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: const Text(
          'Tôi có tài khoản rồi',
          style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}