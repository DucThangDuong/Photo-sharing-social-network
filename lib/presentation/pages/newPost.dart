import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:untitled/data/Helper.dart';

import 'newCaptionPost.dart';
class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});
  @override
  State<NewPostScreen> createState() => NewPostState();
}
class NewPostState extends State<NewPostScreen> {
  List<AssetEntity> _assets = [];
  String imagePath = "";
  bool isMultiSelectMode = false;
  List<AssetEntity> selectedAssets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAssets();
    });
  }

  Future<void> _fetchAssets() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);
        List<AssetEntity> recentAssets = await albums[0].getAssetListPaged(page: 0, size: 100);
        setState(() {
          _assets = recentAssets;
        });
    } else {
      PhotoManager.openSetting();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildImagePreview(),
          _buildControlBar(),
          _buildPermissionNotice(),
          _buildPhotoGrid(),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: () {},
      ),
      title: const Text(
        'Bài viết mới',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () async {
            List<String> pathsToShare = [];
            if (isMultiSelectMode && selectedAssets.isNotEmpty) {
              for (var asset in selectedAssets) {
                final file = await asset.file;
                if (file != null) pathsToShare.add(file.path);
              }
            } else if (imagePath.isNotEmpty) {
              pathsToShare.add(imagePath);
            }
            if (pathsToShare.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ảnh để tiếp tục.')),
              );
              return;
            }
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinalSharePostScreen(imagePaths: pathsToShare),
                ),
              );
            }
          },
          child: const Text(
            'Tiếp',
            style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: const Color(0xFF121212),
        child: Stack(
          children: [
            if (imagePath.isEmpty)
              Container(
                color: Colors.black,
                width: double.infinity,
                height: double.infinity,
              )
            else
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Text(
                'Gần đây',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
            ],
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                isMultiSelectMode = !isMultiSelectMode;

                if (!isMultiSelectMode) {
                  selectedAssets.clear();
                } else if (imagePath.isNotEmpty) {
            }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMultiSelectMode ? Colors.blueAccent : Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_none, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Chọn',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bạn đã cấp cho Instagram quyền truy cập vào một số ảnh và video.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () {
              _fetchAssets();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Quản lý',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _assets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
                color: Colors.white12,
                child: TextButton(
                  onPressed: () async {
                    final isAllow = await AppHelper.requestCameraPermission();
                    if (!isAllow) return;
                    final imagePicker = ImagePicker();
                    final imageFile = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (imageFile != null) {
                      await Gal.putImage(imageFile.path);
                      setState(() {
                        imagePath = imageFile.path;
                      });
                    }
                  },
                  child: const Icon(
                      Icons.camera_alt_outlined, color: Colors.white, size: 30),
                )
            );
          }
          final asset = _assets[index - 1];
          int selectedIndex = selectedAssets.indexOf(asset);
          bool isSelected = selectedIndex != -1;
          return GestureDetector(
            onTap: () async {
              if (isMultiSelectMode) {
                setState(() {
                  if (isSelected) {
                    selectedAssets.remove(asset);
                  } else {
                    if (selectedAssets.length < 10) {
                      selectedAssets.add(asset);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bạn chỉ được chọn tối đa 10 ảnh.')));
                    }
                  }
                  if (selectedAssets.isNotEmpty) {
                    selectedAssets.last.file.then((file) {
                      if (file != null) imagePath = file.path;
                    });
                  }
                });
              } else {
                final file = await asset.file;
                if (file != null) {
                  setState(() {
                    imagePath = file.path;
                  });
                }
              }
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(const ThumbnailSize.square(200)),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    }
                    return Container(color: Colors.white12);
                  },
                ),
                if (isSelected)
                  Container(color: Colors.white.withOpacity(0.3)),
                if (isMultiSelectMode)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blueAccent : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? Text(
                        '${selectedIndex + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}