import 'package:example/generated/json_factory.dart';
import 'package:example/models/post.dart';
import 'package:example/models/user.dart';
import 'package:test/test.dart';

// Test class that is not registered with JsonFactory
class UnregisteredType {
  final String value;
  UnregisteredType(this.value);
}

void main() {

  group('JsonFactory Tests', () {
    test('should parse single object', () {
      final json = {'id': 1, 'name': 'Test User'};
      final user = JsonFactory.fromJson<User>(json);

      expect(user, isA<User>());
      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
    });

    test('should parse list of objects', () {
      final json = [
        {'id': 1, 'title': 'Post 1', 'content': 'Content 1'},
        {'id': 2, 'title': 'Post 2', 'content': 'Content 2'},
      ];

      final posts = JsonFactory.fromJson<List<Post>>(json);

      expect(posts, isA<List<Post>>());
      expect(posts.length, equals(2));
      expect(posts[0], isA<Post>());
      expect(posts[0].id, equals(1));
      expect(posts[0].title, equals('Post 1'));
      expect(posts[0].content, equals('Content 1'));
      expect(posts[1].id, equals(2));
      expect(posts[1].title, equals('Post 2'));
      expect(posts[1].content, equals('Content 2'));
    });

    test('should throw on unregistered type', () {
      final json = {'value': 'test'};
      expect(
        () => JsonFactory.fromJson<UnregisteredType>(json),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'No factory registered for type UnregisteredType',
        )),
      );
    });

    test('should throw on invalid json format', () {
      final invalidJson = 'not a json object';
      expect(
        () => JsonFactory.fromJson<User>(invalidJson),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          contains('Expected JSON object for type User'),
        )),
      );
    });
  });
}
