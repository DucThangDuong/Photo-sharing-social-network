import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class FinalSharePostScreen extends StatefulWidget {
  const FinalSharePostScreen({super.key, required this.imagePaths});
  final List<String> imagePaths;
  @override
  State<FinalSharePostScreen> createState() => _FinalSharePostScreenState();
}

class _FinalSharePostScreenState extends State<FinalSharePostScreen> {
  late bool isMultipleImages;

  @override
  void initState() {
    super.initState();
    isMultipleImages = widget.imagePaths.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreviewArea(),
                  _buildCaptionInput(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildBottomShareButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: const Text(
        'Bài viết mới',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              isMultipleImages = !isMultipleImages;
            });
          },
          child: Text("Đăng tải",
            style: const TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewArea() {
    return Container(
      height: 320,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: isMultipleImages
          ? GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.cover
            ),
          );
        },
      )
          : Center(
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
                File(widget.imagePaths[0]),
                fit: BoxFit.cover
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptionInput() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Thêm chú thích...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
  Widget _buildBottomShareButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        width: double.infinity,
        color: Colors.black,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4C68FF),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Chia sẻ',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}