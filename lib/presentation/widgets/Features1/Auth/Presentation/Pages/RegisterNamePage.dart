import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Widgets/Button/AuthButton.dart';
import '../Widgets/Header/NameHeader.dart';
import '../Widgets/InputField/NameAndUserNameInputField.dart';

class RegisterNamePage extends StatefulWidget {
  const RegisterNamePage({super.key});

  @override
  State<RegisterNamePage> createState() => _RegisterNamePageState();
}

class _RegisterNamePageState extends State<RegisterNamePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isUsernameValid = false;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi để validate realtime
    _usernameController.addListener(() {
      setState(() {
        _isUsernameValid = _usernameController.text.length > 6;
      });
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_fullNameController.text.isEmpty) {
      _showError('Vui lòng nhập tên đầy đủ');
    } else if (!_isUsernameValid) {
      _showError('Tên người dùng phải dài hơn 6 ký tự');
    } else {
      // Chuyển sang bước tiếp theo (ví dụ: Ngày sinh)
      print("Tiếp tục với: ${_usernameController.text}");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
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
              const NameHeader(),
              const SizedBox(height: 30),

              NameAndUserNameInputField(
                controller: _fullNameController,
                label: 'Tên đầy đủ',
                hint: 'Nhập tên đầy đủ của bạn',
              ),
              const SizedBox(height: 20),

              NameAndUserNameInputField(
                controller: _usernameController,
                label: 'Tên người dùng',
                hint: 'Nhập tên người dùng',
                isValid: _isUsernameValid, // Truyền trạng thái validate vào
              ),
              const SizedBox(height: 30),

              AuthButton(
                label: 'Đăng ký',
                color: const Color(0xFF0064E0),
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}