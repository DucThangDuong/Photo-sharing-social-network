import 'package:flutter/material.dart';

import '../../../../../../data/Models/PostMedia.dart';


class PostMediaSlider extends StatefulWidget {
  final List<PostMedia> mediaList;
  const PostMediaSlider({super.key, required this.mediaList});

  @override
  State<PostMediaSlider> createState() => _PostMediaSliderState();
}

class _PostMediaSliderState extends State<PostMediaSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            itemCount: widget.mediaList.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (ctx, i) => Image.network(widget.mediaList[i].mediaUrl, fit: BoxFit.cover),
          ),
        ),
        if (widget.mediaList.length > 1)
          Positioned(
            bottom: 12,
            child: Row(
              children: List.generate(widget.mediaList.length, (i) => Container(
                width: 6, height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == i ? Colors.white : Colors.white38,
                ),
              )),
            ),
          )
      ],
    );
  }
}