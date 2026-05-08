import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/Helper.dart';
import 'EditProfileField.dart';

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
                onPressed: isLoading ? null : onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0095F6),
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