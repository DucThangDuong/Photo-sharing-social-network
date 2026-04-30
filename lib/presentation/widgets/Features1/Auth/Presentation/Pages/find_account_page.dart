import 'package:flutter/material.dart';
import '../Widgets/Button/AuthButton.dart';
import '../Widgets/Header/FindAccountHeader.dart';
import '../Widgets/InputField/FindAccountInputField.dart';

class FindAccountPage extends StatefulWidget {
  const FindAccountPage({super.key});

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}
class _FindAccountPageState extends State<FindAccountPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isSearchingByPhone = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // Hàm xử lý đổi chế độ tìm kiếm
  void _toggleSearchMode() {
    setState(() {
      _isSearchingByPhone = !_isSearchingByPhone;
      _inputController.clear();
    });
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
              // 1. Header
              FindAccountHeader(isSearchingByPhone: _isSearchingByPhone),
              const SizedBox(height: 15),

              // 2. Input Field
              FindAccountInputField(
                controller: _inputController,
                isSearchingByPhone: _isSearchingByPhone,
              ),
              const SizedBox(height: 20),

              // 3. Nút Tiếp tục
              AuthButton(
                label: 'Tiếp tục',
                color: const Color(0xFF0064E0),
                onPressed: () => print("Đang tìm: ${_inputController.text}"),
              ),
              const SizedBox(height: 15),

              // 4. Nút chuyển đổi phương thức
              AuthButton(
                label: _isSearchingByPhone
                    ? 'Tìm bằng email hoặc tên người dùng'
                    : 'Tìm bằng số di động',
                color: const Color(0xFF262626),
                onPressed: _toggleSearchMode,
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}