import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class NewPostPhotoGrid extends StatelessWidget {
  final List<AssetEntity> assets;
  final List<AssetEntity> selectedAssets;
  final bool isMultiSelectMode;
  final VoidCallback onCameraTap;
  final Function(AssetEntity, bool, int) onAssetTap;

  const NewPostPhotoGrid({
    super.key,
    required this.assets,
    required this.selectedAssets,
    required this.isMultiSelectMode,
    required this.onCameraTap,
    required this.onAssetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: assets.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              color: Colors.white12,
              child: TextButton(
                onPressed: onCameraTap,
                child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 30),
              ),
            );
          }

          final asset = assets[index - 1];
          int selectedIndex = selectedAssets.indexOf(asset);
          bool isSelected = selectedIndex != -1;

          return GestureDetector(
            onTap: () => onAssetTap(asset, isSelected, selectedIndex),
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
                if (isSelected) Container(color: Colors.white.withOpacity(0.3)),
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