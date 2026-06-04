import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import 'package:untitled/data/datasources/global/SnackBarError.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 0; // 0: Nhập Email, 1: Nhập OTP, 2: Nhập Mật khẩu mới
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Bước 1: Gửi yêu cầu quên mật khẩu
  Future<void> _handleSendEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập email')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await CallMyAPI.forgotPassword(email);
      if (response != null && response['success'] == true) {
        setState(() {
          _currentStep = 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? 'Đã gửi mã OTP')));
      } else {
        SnackBarError.show(context, prefix: response?['message'] ?? 'Gửi OTP thất bại');
      }
    } catch (e) {
      SnackBarError.show(context, prefix: 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Bước 2: Xác thực OTP
  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập mã OTP')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await CallMyAPI.verifyOtp(email, otp);
      if (response != null && response['success'] == true) {
        setState(() {
          _currentStep = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP hợp lệ. Vui lòng nhập mật khẩu mới.')));
      } else {
        SnackBarError.show(context, prefix: response?['message'] ?? 'OTP không hợp lệ');
      }
    } catch (e) {
      SnackBarError.show(context, prefix: 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Bước 3: Đặt lại mật khẩu
  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải dài ít nhất 6 ký tự')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await CallMyAPI.resetPassword(email, otp, newPassword);
      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật mật khẩu thành công!')));
        Navigator.pop(context); // Quay về trang đăng nhập
      } else {
        SnackBarError.show(context, prefix: response?['message'] ?? 'Cập nhật mật khẩu thất bại');
      }
    } catch (e) {
      SnackBarError.show(context, prefix: 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildStep0() {
    return Column(
      children: [
        const Text(
          'Tìm tài khoản của bạn',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Nhập email của bạn để nhận mã xác nhận mật khẩu mới.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Email người dùng',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0064E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Gửi mã', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Text(
          'Nhập mã xác nhận',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Nhập mã gồm 6 chữ số vừa được gửi đến ${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _otpController,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Mã OTP',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0064E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Text(
          'Tạo mật khẩu mới',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Vui lòng tạo một mật khẩu mới có ít nhất 6 ký tự.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _newPasswordController,
          style: const TextStyle(color: Colors.white),
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Mật khẩu mới',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPasswordController,
          style: const TextStyle(color: Colors.white),
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Xác nhận mật khẩu mới',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0064E0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Cập nhật mật khẩu', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_reset, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              if (_currentStep == 0) _buildStep0(),
              if (_currentStep == 1) _buildStep1(),
              if (_currentStep == 2) _buildStep2(),
            ],
          ),
        ),
      ),
    );
  }
}
