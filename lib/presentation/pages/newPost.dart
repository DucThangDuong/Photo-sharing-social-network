import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:untitled/data/Helper.dart';

import '../widgets/newPost/AppBar.dart';
import '../widgets/newPost/ImagePreview.dart';
import '../widgets/newPost/PermissionNotice.dart';
import '../widgets/newPost/PhotoGrid.dart';
import '../widgets/newPost/PostControlBar.dart';
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
      if (albums.isNotEmpty) {
        List<AssetEntity> recentAssets = await albums[0].getAssetListPaged(page: 0, size: 100);
        setState(() {
          _assets = recentAssets;
        });
      }
    } else {
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NewPostAppBar(
        isMultiSelectMode: isMultiSelectMode,
        selectedAssets: selectedAssets,
        imagePath: imagePath,
      ),
      body: Column(
        children: [
          NewPostImagePreview(imagePath: imagePath),
          NewPostControlBar(
            isMultiSelectMode: isMultiSelectMode,
            onToggleMultiSelectMode: () {
              setState(() {
                isMultiSelectMode = !isMultiSelectMode;
                if (!isMultiSelectMode) {
                  selectedAssets.clear();
                }
              });
            },
          ),
          NewPostPermissionNotice(onManagePermission: _fetchAssets),
          NewPostPhotoGrid(
            assets: _assets,
            selectedAssets: selectedAssets,
            isMultiSelectMode: isMultiSelectMode,
            onCameraTap: () async {
              final isAllow = await AppHelper.requestCameraPermission();
              if (!isAllow) return;
              final imagePicker = ImagePicker();
              final imageFile = await imagePicker.pickImage(source: ImageSource.camera);
              if (imageFile != null) {
                await Gal.putImage(imageFile.path);
                setState(() {
                  imagePath = imageFile.path;
                });
              }
            },
            onAssetTap: (asset, isSelected, selectedIndex) async {
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
                      if (file != null) {
                        setState(() {
                          imagePath = file.path;
                        });
                      }
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
          ),
        ],
      ),
    );
  }
}