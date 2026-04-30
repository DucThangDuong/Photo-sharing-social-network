import 'Post.dart';
import 'PostViewModel.dart';
import 'User.dart';
import 'PostMedia.dart';

class MockData {
  static List<PostViewModel> getPosts() {
    final userT1 = User(
      id: 101,
      username: 't1_fanpage',
      email: 't1@gmail.com',
      passwordHash: 'hashed_pw',
      fullName: 'T1 LoL Team',
      avatarUrl: 'https://i.pravatar.cc/150?u=t1',
      createdAt: DateTime.now(),
    );

    return [
      PostViewModel(
        post: Post(id: 1, userId: 101, caption: 'Vô địch CKTG 2023!', createdAt: DateTime.now()),
        user: userT1,
        mediaList: [
          PostMedia(id: 1, postId: 1, mediaUrl: 'https://picsum.photos/id/237/600/400', sortOrder: 1, createdAt: DateTime.now()),
          PostMedia(id: 2, postId: 1, mediaUrl: 'https://picsum.photos/id/238/600/400', sortOrder: 2, createdAt: DateTime.now()),
        ],
        likeCount: 15000,
        commentCount: 450,
      ),
    ];
  }
  static List<User> getSuggestedUsers() {
    return List.generate(5, (index) => User(
      id: 200 + index,
      username: 'user_suggest_$index',
      email: 'suggest@gmail.com',
      passwordHash: '',
      fullName: 'Người dùng gợi ý $index',
      avatarUrl: 'https://i.pravatar.cc/150?u=suggest_$index',
      createdAt: DateTime.now(),
    ));
  }
}