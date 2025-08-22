import 'package:example/models/base_response.dart';
import 'package:example/models/user.dart';
import 'package:example/models/post.dart';
import 'package:test/test.dart';

void main() {
  group('BaseResponse Tests', () {
    group('Constructor Tests', () {
      test('should create BaseResponse with required parameters', () {
        final response = BaseResponse<String>(
          success: true,
          message: 'Operation successful',
        );

        expect(response.success, equals(true));
        expect(response.message, equals('Operation successful'));
        expect(response.data, isNull);
        expect(response.code, isNull);
      });

      test('should create BaseResponse with all parameters', () {
        final response = BaseResponse<int>(
          success: false,
          message: 'Operation failed',
          data: 404,
          code: 400,
        );

        expect(response.success, equals(false));
        expect(response.message, equals('Operation failed'));
        expect(response.data, equals(404));
        expect(response.code, equals(400));
      });

      test('should create BaseResponse with User data', () {
        final user = User(id: 1, name: 'John Doe');
        final response = BaseResponse<User>(
          success: true,
          message: 'User retrieved successfully',
          data: user,
          code: 200,
        );

        expect(response.success, equals(true));
        expect(response.message, equals('User retrieved successfully'));
        expect(response.data, equals(user));
        expect(response.data?.id, equals(1));
        expect(response.data?.name, equals('John Doe'));
        expect(response.code, equals(200));
      });

      test('should create BaseResponse with List data', () {
        final posts = [
          Post(id: 1, title: 'First Post', content: 'Content 1'),
          Post(id: 2, title: 'Second Post', content: 'Content 2'),
        ];
        final response = BaseResponse<List<Post>>(
          success: true,
          message: 'Posts retrieved successfully',
          data: posts,
          code: 200,
        );

        expect(response.success, equals(true));
        expect(response.message, equals('Posts retrieved successfully'));
        expect(response.data?.length, equals(2));
        expect(response.data?[0].title, equals('First Post'));
        expect(response.data?[1].title, equals('Second Post'));
        expect(response.code, equals(200));
      });
    });

    group('toString Tests', () {
      test('should return correct string representation', () {
        final response = BaseResponse<String>(
          success: true,
          message: 'Test message',
          data: 'test data',
          code: 200,
        );

        final stringRepresentation = response.toString();
        expect(stringRepresentation, contains('success: true'));
        expect(stringRepresentation, contains('message: Test message'));
        expect(stringRepresentation, contains('data: test data'));
        expect(stringRepresentation, contains('code: 200'));
      });

      test('should handle null fields in toString', () {
        final response = BaseResponse<String>(
          success: false,
          message: 'Error message',
        );

        final stringRepresentation = response.toString();
        expect(stringRepresentation, contains('success: false'));
        expect(stringRepresentation, contains('message: Error message'));
        expect(stringRepresentation, contains('data: null'));
        expect(stringRepresentation, contains('code: null'));
      });
    });

    group('Generic Type Tests', () {
      test('should work with different primitive types', () {
        final intResponse = BaseResponse<int>(
          success: true,
          message: 'Integer data',
          data: 42,
        );
        expect(intResponse.data, isA<int>());
        expect(intResponse.data, equals(42));

        final doubleResponse = BaseResponse<double>(
          success: true,
          message: 'Double data',
          data: 3.14,
        );
        expect(doubleResponse.data, isA<double>());
        expect(doubleResponse.data, equals(3.14));

        final boolResponse = BaseResponse<bool>(
          success: true,
          message: 'Boolean data',
          data: true,
        );
        expect(boolResponse.data, isA<bool>());
        expect(boolResponse.data, equals(true));
      });

      test('should work with Map type', () {
        final mapData = {'key1': 'value1', 'key2': 'value2'};
        final response = BaseResponse<Map<String, String>>(
          success: true,
          message: 'Map data',
          data: mapData,
        );

        expect(response.data, isA<Map<String, String>>());
        expect(response.data?['key1'], equals('value1'));
        expect(response.data?['key2'], equals('value2'));
      });

      test('should work with nested BaseResponse', () {
        final innerResponse = BaseResponse<String>(
          success: true,
          message: 'Inner response',
          data: 'inner data',
        );

        final outerResponse = BaseResponse<BaseResponse<String>>(
          success: true,
          message: 'Outer response',
          data: innerResponse,
        );

        expect(outerResponse.data, isA<BaseResponse<String>>());
        expect(outerResponse.data?.success, equals(true));
        expect(outerResponse.data?.data, equals('inner data'));
      });
    });

    group('Real-world Usage Scenarios', () {
      test('should represent typical API success response', () {
        final user = User(id: 123, name: 'Alice Smith');
        final response = BaseResponse<User>(
          success: true,
          message: 'User fetched successfully',
          data: user,
          code: 200,
        );

        expect(response.success, equals(true));
        expect(response.message, isA<String>());
        expect(response.message, isNotEmpty);
        expect(response.data, isNotNull);
        expect(response.data, isA<User>());
        expect(response.code, equals(200));
        expect(response.data?.id, equals(123));
        expect(response.data?.name, equals('Alice Smith'));
      });

      test('should represent typical API error response', () {
        final response = BaseResponse<User?>(
          success: false,
          message: 'User not found',
          data: null,
          code: 404,
        );

        expect(response.success, equals(false));
        expect(response.message, isA<String>());
        expect(response.message, isNotEmpty);
        expect(response.data, isNull);
        expect(response.code, equals(404));
      });

      test('should handle list data response', () {
        final posts = List.generate(5, (index) => 
          Post(
            id: index + 1, 
            title: 'Post ${index + 1}', 
            content: 'Content ${index + 1}'
          )
        );

        final response = BaseResponse<List<Post>>(
          success: true,
          message: 'Posts retrieved successfully',
          data: posts,
          code: 200,
        );

        expect(response.success, equals(true));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<Post>>());
        expect(response.data?.length, equals(5));
        expect(response.code, equals(200));
        expect(response.data?.first.title, equals('Post 1'));
        expect(response.data?.last.title, equals('Post 5'));
      });

      test('should handle empty list response', () {
        final response = BaseResponse<List<Post>>(
          success: true,
          message: 'No posts found',
          data: [],
          code: 200,
        );

        expect(response.success, equals(true));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<Post>>());
        expect(response.data?.isEmpty, equals(true));
        expect(response.code, equals(200));
      });
    });

    group('Edge Cases', () {
      test('should handle different HTTP status codes', () {
        final testCases = [
          {'success': true, 'code': 200, 'message': 'OK'},
          {'success': true, 'code': 201, 'message': 'Created'},
          {'success': false, 'code': 400, 'message': 'Bad Request'},
          {'success': false, 'code': 401, 'message': 'Unauthorized'},
          {'success': false, 'code': 404, 'message': 'Not Found'},
          {'success': false, 'code': 500, 'message': 'Internal Server Error'},
        ];

        for (final testCase in testCases) {
          final response = BaseResponse<String?>(
            success: testCase['success'] as bool,
            message: testCase['message'] as String,
            data: null,
            code: testCase['code'] as int,
          );

          expect(response.success, equals(testCase['success']));
          expect(response.code, equals(testCase['code']));
          expect(response.message, equals(testCase['message']));
        }
      });

      test('should handle negative and zero codes', () {
        final negativeResponse = BaseResponse<String>(
          success: false,
          message: 'Negative code',
          code: -1,
        );

        final zeroResponse = BaseResponse<String>(
          success: true,
          message: 'Zero code',
          code: 0,
        );

        expect(negativeResponse.code, equals(-1));
        expect(zeroResponse.code, equals(0));
      });

      test('should handle special characters in message', () {
        final specialMessage = r'Special chars: !@#$%^&*()_+-=[]{}|;:,.<>?/~`';
        final response = BaseResponse<String>(
          success: true,
          message: specialMessage,
        );

        expect(response.message, equals(specialMessage));
      });

      test('should handle long message strings', () {
        final longMessage = 'Error: ' + 'x' * 100;
        final response = BaseResponse<String>(
          success: false,
          message: longMessage,
        );

        expect(response.message.length, equals(107)); // 'Error: ' + 100 x's
        expect(response.message.startsWith('Error: '), isTrue);
      });
    });

    group('Error Handling Tests', () {
      test('should handle invalid JSON structure', () {
        expect(
          () => BaseResponse<String>.fromJson(
            {'invalid': 'structure'},
            (json) => json as String,
          ),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle type conversion errors', () {
        final json = {
          'success': 'not_a_boolean',
          'message': 'Test message',
        };

        expect(
          () => BaseResponse<String>.fromJson(
            json,
            (json) => json as String,
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });
  });
}
