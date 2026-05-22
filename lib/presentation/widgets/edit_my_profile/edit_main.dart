import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/Helper.dart';
import 'edit_field.dart';

class EditMain extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final TextEditingController genderController;
  final bool isDirty;
  final bool isLoading;
  final File? newAvatar;
  final String? currentAvatarUrl;
  final VoidCallback onPickImage;
  final VoidCallback onShowGenderPicker;
  final VoidCallback onSave;

  const EditMain({
    super.key,
    required this.nameController,
    required this.usernameController,
    required this.bioController,
    required this.genderController,
    required this.isDirty,
    required this.isLoading,
    required this.newAvatar,
    required this.currentAvatarUrl,
    required this.onPickImage,
    required this.onShowGenderPicker,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
                image: newAvatar != null
                    ? DecorationImage(image: FileImage(newAvatar!), fit: BoxFit.cover)
                    : (currentAvatarUrl != null
                    ? DecorationImage(image: NetworkImage(AppHelper.formatImageURL(currentAvatarUrl!)), fit: BoxFit.cover)
                    : null),
              ),
              child: newAvatar == null && currentAvatarUrl == null
                  ? const Icon(Icons.person, color: Color(0xFF121212), size: 45)
                  : null,
            ),
          ],
        ),
        TextButton(
          onPressed: onPickImage,
          child: const Text(
            'Chỉnh sửa ảnh',
            style: TextStyle(color: Color(0xFF0095F6),
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFF262626)),
              bottom: BorderSide(color: Color(0xFF262626)),
            ),
          ),
          child: Column(
            children: [
              EditProfileField(label: 'Tên', controller: nameController),
              EditProfileField(label: 'Tên người dùng',
                  controller: usernameController),
              EditProfileField(
                  label: 'Tiểu sử', controller: bioController),
              EditProfileField(
                label: 'Giới tính',
                controller: genderController,
                readOnly: true,
                onTap: onShowGenderPicker,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (isDirty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        final username = usernameController.text.trim();

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tên không được để trống')),
                          );
                          return;
                        }

                        if (username.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tên người dùng không được để trống')),
                          );
                          return;
                        }

                        if (usernameController.text.contains(' ')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tên người dùng không được chứa khoảng trắng')),
                          );
                          return;
                        }
                        final vietnameseRegex = RegExp(
                            r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]');
                        if (vietnameseRegex.hasMatch(usernameController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tên người dùng không được chứa dấu tiếng Việt')),
                          );
                          return;
                        }
                        final specialCharRegex = RegExp(r'^[a-zA-Z0-9_.]+$');
                        if (!specialCharRegex.hasMatch(username)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tên người dùng chỉ được dùng chữ cái không dấu, số, dấu chấm (.) và gạch dưới (_)')),
                          );
                          return;
                        }

                        onSave();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white),
                  ),
                )
                    : const Text('Lưu thay đổi', style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
              ),
            ),
          ),

        const SizedBox(height: 30),
      ],
    );
  }
}