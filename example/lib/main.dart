import 'package:example/generated/json_factory.dart';
import 'package:example/models/base_response.dart';
import 'models/user.dart';
import 'models/post.dart';

void main() {
  // Basic usage examples
  demonstrateBasicUsage();
  
  // API response handling examples  
  demonstrateApiResponseHandling();
}

void demonstrateBasicUsage() {
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

void demonstrateApiResponseHandling() {
  // Example API response
  final apiResponse = {
    'success': true,
    'message': 'Data retrieved successfully',
    'code': 200,
    'data': {
      'id': 1,
      'name': 'John Doe'
    }
  };

  // Parse API response with type safety
  final response = BaseResponse<User?>.fromJson(apiResponse, JsonFactory.fromJson);
  
  print('API Response:');
  print('Success: ${response.success}');
  print('Message: ${response.message}');
  print('User: ${response.data?.name}');

  // Example with list
  final apiListResponse = {
    'success': true,
    'message': 'Posts retrieved successfully',
    'code': 200,
    'data': [
      {'id': 1, 'title': 'Post 1', 'content': 'Content 1'},
      {'id': 2, 'title': 'Post 2', 'content': 'Content 2'},
    ]
  };

  // Parse API list response with type safety
  final listResponse = BaseResponse<List<Post>>.fromJson(apiListResponse, JsonFactory.fromJson);
  print('API List Response:');
  print('Success: ${listResponse.success}');
  print('Message: ${listResponse.message}');
  print('Posts:');
  listResponse.data?.forEach((post) {
    print('- ${post.title}: ${post.content}');
  });
}
