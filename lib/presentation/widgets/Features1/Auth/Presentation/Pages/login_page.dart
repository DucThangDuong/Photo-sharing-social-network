import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/presentation/widgets/Features1/Auth/Presentation/Pages/register_page.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../Home/Presentation/Pages/main_wrapper.dart';
import '../Widgets/Button/AuthButton.dart';
import '../Widgets/InputField/AuthInputField.dart';
import '../Widgets/Logo/Login_Logo.dart';
import '../Widgets/Logo/MetaFooter.dart';
import 'find_account_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled/data/datasources/ApiServices.dart';

class InstagramLoginDark extends StatefulWidget {
  @override
  _InstagramLoginDarkState createState() => _InstagramLoginDarkState();
}
class _InstagramLoginDarkState extends State<InstagramLoginDark> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().post(
        '/auth/login',
        data: {
          'Email': email,
          'Password': password,
        },
      );

      if (response != null && response['data'] != null) {
        final String? token = response['data']['access_token'];
        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'access_token', value: token);
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
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
            children: [
              const Spacer(flex: 1),
              const LoginLogo(),
              const SizedBox(height: 50),

              // Ô nhập Email/User
              AuthInputField(
                controller: _emailController,
                hint: 'Tên người dùng, email/số di động',
              ),
              const SizedBox(height: 12),

              // Ô nhập Mật khẩu
              AuthInputField(
                controller: _passwordController,
                hint: 'Mật khẩu',
                isPassword: true,
                isVisible: _isPasswordVisible,
                toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),

              const SizedBox(height: 15),

              // Nút Đăng nhập
              AuthButton(
                label: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                color: const Color(0xFF0064E0),
                onPressed: _isLoading ? () {} : _handleLogin,
              ),

              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FindAccountPage())),
                child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.white)),
              ),

              const Spacer(flex: 2),

              // Nút Tạo tài khoản (Style Outlined)
              _buildCreateAccountButton(),
              const SizedBox(height: 15),

              const MetaFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget riêng cho nút tạo tài khoản vì nó có style Outlined khác biệt
  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0064E0), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhonePage())),
        child: const Text('Tạo tài khoản mới', style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)),
      ),
    );
  }
}