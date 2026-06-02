import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/CallAPIOfUser.dart';
import '../../data/datasources/global/User.dart';
import 'package:provider/provider.dart';

enum OverlayType { text, emoji }

class OverlayItem {
  final OverlayType type;
  final String content;
  Offset offset;
  final TextStyle? textStyle;

  OverlayItem({
    required this.type,
    required this.content,
    this.offset = const Offset(100, 100),
    this.textStyle,
  });
}

class StoryUploadPage extends StatefulWidget {
  final File? imageFile;

  const StoryUploadPage({super.key, this.imageFile});

  @override
  State<StoryUploadPage> createState() => _StoryUploadPageState();
}

class _StoryUploadPageState extends State<StoryUploadPage> {
  bool _isUploading = false;
  File? _currentImageFile;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  
  List<OverlayItem> _overlays = [];

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
  }

  // hình ảnh người dùng đã chọn để up lên story
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _currentImageFile = File(image.path);
        _overlays.clear(); // Reset overlays when picking a new image
      });
    }
  }

  // Chụp ảnh lại màn hình kèm text/emoji
  Future<File?> _captureImage() async {
    if (_overlays.isEmpty) return _currentImageFile;

    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final imagePath = File('${directory.path}/story_${DateTime.now().millisecondsSinceEpoch}.png');
        await imagePath.writeAsBytes(pngBytes);
        return imagePath;
      }
    } catch (e) {
      print("Lỗi chụp ảnh: $e");
    }
    return _currentImageFile;
  }

  // up hình ảnh lên api
  Future<void> _uploadStory() async {
    if (_currentImageFile == null) return;
    
    setState(() => _isUploading = true);

    try {
      File? finalImageToUpload = await _captureImage();
      if (finalImageToUpload == null) {
        throw Exception("Không thể xử lý hình ảnh.");
      }

      var formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(finalImageToUpload.path),
      });

      await CallMyAPI.addNewStory(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào tin của bạn!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lên: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _addTextOverlay() {
    TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Thêm chữ', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white, fontSize: 24),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  setState(() {
                    _overlays.add(OverlayItem(
                      type: OverlayType.text,
                      content: textController.text,
                      textStyle: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      offset: const Offset(100, 200),
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Xong', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _addEmojiOverlay() {
    // A simple mock list of emojis for user to select
    final List<String> emojis = ['😂', '😍', '🔥', '❤️', '👍', '🙏', '🎉', '😢', '😎', '✨'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            itemCount: emojis.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _overlays.add(OverlayItem(
                      type: OverlayType.emoji,
                      content: emojis[index],
                      offset: const Offset(150, 200),
                    ));
                  });
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(emojis[index], style: const TextStyle(fontSize: 40)),
                ),
              );
            },
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen tuyền
      body: SafeArea(
        child: Stack(
          children: [
            // RepaintBoundary bọc lấy hình ảnh và các overlay (để chụp ảnh)
            Positioned.fill(
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _currentImageFile != null
                          ? Image.file(_currentImageFile!, fit: BoxFit.cover)
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image, size: 80, color: Colors.white54),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0095F6),
                                    ),
                                    child: const Text('Chọn ảnh từ thư viện', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                      
                      // Hiển thị các text và emoji mà người dùng thêm vào
                      for (int i = 0; i < _overlays.length; i++)
                        Positioned(
                          left: _overlays[i].offset.dx,
                          top: _overlays[i].offset.dy,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _overlays[i].offset = Offset(
                                  _overlays[i].offset.dx + details.delta.dx,
                                  _overlays[i].offset.dy + details.delta.dy,
                                );
                              });
                            },
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                _overlays[i].content,
                                style: _overlays[i].type == OverlayType.text 
                                    ? _overlays[i].textStyle 
                                    : const TextStyle(fontSize: 60),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),

            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Hủy
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Các nút công cụ
                  if (_currentImageFile != null)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_fields, color: Colors.white, size: 28),
                          onPressed: _addTextOverlay, 
                        ),
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white, size: 28),
                          onPressed: _addEmojiOverlay, 
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.white, size: 28),
                          onPressed: () {
                            if (_overlays.isNotEmpty) {
                              setState(() {
                                _overlays.removeLast();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),

            if (_currentImageFile != null)
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: Row(
                  children: [
                    // Nút "Tin của bạn"
                    Expanded(
                      child: GestureDetector(
                        onTap: _isUploading ? null : _uploadStory,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6), // Nền đen mờ
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final user = userProvider.user;
                              final avatarUrl = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                  ? 'http://10.0.2.2:5090${user.avatarUrl}'
                                  : 'https://i.pravatar.cc/150';
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage: NetworkImage(avatarUrl),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Tin của bạn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    GestureDetector(
                      onTap: _isUploading ? null : _uploadStory,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}