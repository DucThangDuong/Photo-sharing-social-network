import 'post_model.dart';

class MockData {
  static List<PostModel> getPosts() {
    return [
      PostModel(
        id: 1,
        user: UserModel(
            id: 101,
            username: 't1_fanpage',
            avatarUrl: 'https://i.pravatar.cc/150?u=t1' // Link avatar ngẫu nhiên
        ),
        mediaList: [
          PostMedia(mediaUrl: 'https://picsum.photos/id/237/600/400'), // Ảnh chó con
          PostMedia(mediaUrl: 'https://picsum.photos/id/238/600/400'), // Ảnh thành phố
        ],
        caption: 'Test thử tính năng cuộn ngang và Like!',
        likeCount: 15200,
        commentCount: 88,
        createdAt: DateTime.now(),
      ),
      PostModel(
        id: 2,
        user: UserModel(
            id: 102,
            username: 'flutter_dev',
            avatarUrl: 'https://i.pravatar.cc/150?u=dev'
        ),
        mediaList: [
          PostMedia(mediaUrl: 'https://picsum.photos/id/1/600/400'), // Ảnh laptop
        ],
        caption: 'Đang fix lỗi NetworkImage trong Flutter...',
        likeCount: 99,
        commentCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}