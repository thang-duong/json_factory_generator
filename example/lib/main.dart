import 'models/user.dart';
import 'models/post.dart';
import 'json_factory_config.dart';

void main() {
  // Initialize JSON factory configurations
  initializeJsonFactory();

  // Example JSON data
  final userJson = {
    'id': 1,
    'name': 'John Doe',
    'email': 'john@example.com'
  };

  final postJson = {
    'id': 1,
    'title': 'Hello World',
    'content': 'This is my first post'
  };

  // Parse JSON data
  final user = JsonFactory.fromJson<User>(userJson);
  final post = JsonFactory.fromJson<Post>(postJson);

  // Print results
  print('User: ${user.name}');
  print('Post: ${post.title}');
  print('Post content: ${post.content}');
}
