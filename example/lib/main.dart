import 'package:example/generated/json_factory.dart';

import 'models/user.dart';
import 'models/post.dart';

void main() {
  // Example JSON data
  final userJson = {
    'id': 1,
    'name': 'John Doe',
  };

  final postJson = {
    'id': 1,
    'title': 'Hello World',
    'content': 'This is my first post'
  };

  final postsJson = [
    {'id': 1, 'title': 'Post 1', 'content': 'Content 1'},
    {'id': 2, 'title': 'Post 2', 'content': 'Content 2'},
  ];

  // Parse JSON data using auto-generated JsonFactory
  final user = JsonFactory.fromJson<User>(userJson);
  final post = JsonFactory.fromJson<Post>(postJson);
  final posts = JsonFactory.fromJson<List<Post>>(postsJson);

  // Print results
  print('User: ${user.name} (ID: ${user.id})');
  print('Post: ${post.title}');
  print('Post content: ${post.content}');
  print('Posts count: ${posts.length}');
  for (final p in posts) {
    print('- ${p.title}: ${p.content}');
  }
}
