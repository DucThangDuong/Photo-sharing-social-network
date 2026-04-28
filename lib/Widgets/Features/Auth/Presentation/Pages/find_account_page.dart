import 'package:flutter/material.dart';

class FindAccountPage extends StatefulWidget {
  const FindAccountPage({super.key});

  @override
  State<FindAccountPage> createState() => _FindAccountPageState();
}

class _FindAccountPageState extends State<FindAccountPage> {
  final TextEditingController _inputController = TextEditingController();
  bool _isSearchingByPhone = false; // Biến để đổi giữa Email/Username và Phone

  @override
  void dispose() {
    _inputController.dispose();
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
                          'Tìm tài khoản',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 2. Mô tả (Đổi nội dung tùy theo phương thức tìm kiếm)
                        Text(
                          _isSearchingByPhone
                              ? 'Nhập số di động của bạn.'
                              : 'Nhập email hoặc tên người dùng của bạn.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),


                        const SizedBox(height: 15),

                        // 4. Ô nhập liệu
                        TextField(
                          controller: _inputController,
                          keyboardType: _isSearchingByPhone
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _isSearchingByPhone
                                ? 'Số di động'
                                : 'Email hoặc tên người dùng',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white54),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 5. Nút Tiếp tục
                        _buildButton(
                          label: 'Tiếp tục',
                          color: const Color(0xFF0064E0),
                          onPressed: () {
                            // Xử lý tìm kiếm tài khoản ở đây
                            print("Đang tìm: ${_inputController.text}");
                          },
                        ),
                        const SizedBox(height: 15),

                        // 6. Nút chuyển đổi phương thức tìm kiếm
                        _buildButton(
                          label: _isSearchingByPhone
                              ? 'Tìm bằng email hoặc tên người dùng'
                              : 'Tìm bằng số di động',
                          color: const Color(0xFF262626),
                          onPressed: () {
                            setState(() {
                              _isSearchingByPhone = !_isSearchingByPhone;
                              _inputController.clear(); // Xóa trắng ô nhập khi đổi mode
                            });
                          },
                        ),

                        const Spacer(),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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