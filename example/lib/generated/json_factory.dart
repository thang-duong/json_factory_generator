// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated on: 2025-08-22 10:55:49.505616

import 'package:example/models/post.dart';
import 'package:example/models/user.dart';

/// Auto-generated JsonFactory configuration
/// Generated on: 2025-08-22 10:55:49.506487
class JsonFactory {
  static final Map<Type, FromJsonFunc> _factories = {
    Post: (json) => Post.fromJson(json as Map<String, dynamic>),
    User: (json) => User.fromJson(json as Map<String, dynamic>),
  };

  static final Map<String, Type> _typeMap = {
    'Post': Post,
    'User': User,
  };

  /// Generated list casters to convert `List<dynamic>` into `List<T>` safely
  /// without long `if/else` chains. Each entry corresponds to a model type
  /// registered in `_factories`. Keep this in sync with `_factories`.
  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {
    Post: (list) => list.cast<Post>().toList(),
    User: (list) => list.cast<User>().toList(),
  };
  /// Converts JSON data to the specified type T
  /// Supports both single objects and lists
  static T fromJson<T>(dynamic json) {
    if (json == null) {
      throw ArgumentError('JSON data is null for type $T');
    }

    // Handle List<T>
    if (json is List) {
      return _handleListType<T>(json);
    }

    // Handle single object
    return _handleSingleType<T>(json);
  }

  /// Handles conversion of `List<Inner>` types.
  /// Example: when `T` is `List<Post>`, this will:
  /// 1) parse each JSON item using the registered factory for `Post`,
  /// 2) cast the result to `List<Post>` via a generated caster,
  /// 3) return it as `T`.
  static T _handleListType<T>(List json) {
    final typeStr = T.toString();
    // If T isn't a List<...>, just return the original list as-is.
    if (!typeStr.startsWith('List<') || !typeStr.endsWith('>')) {
      return json as T;
    }

    // Extract inner type name, e.g. "Post" from "List<Post>".
    final innerTypeName = typeStr.substring(5, typeStr.length - 1);

    // Look up the actual Dart Type from the generated type map.
    final dartType = _typeMap[innerTypeName];
    if (dartType == null) {
      throw ArgumentError('Unknown type $innerTypeName in List<$innerTypeName>');
    }

    // Step 1: Map raw JSON to model instances using the correct factory.
    final factory = _factories[dartType]!;
    final rawList = json.map((e) => factory(e)).toList(); // List<dynamic>

    // Step 2: Cast to a strongly-typed List<Inner> using a generated caster.
    final caster = _listCasters[dartType];
    if (caster != null) {
      final typedList = caster(rawList); // List<Inner>
      // Step 3: Return as T (where T == List<Inner>).
      return typedList as T;
    }

    // Fallback: return the dynamic list if no caster is available.
    return rawList as T;
  }

  /// Handles conversion of single object types
  static T _handleSingleType<T>(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
          'Expected JSON object for type $T, got ${json.runtimeType}');
    }

    final factory = _factories[T];
    if (factory == null) {
      throw ArgumentError('No factory registered for type $T');
    }

    return factory(json) as T;
  }

}

/// Type definition for JSON factory functions
typedef FromJsonFunc = dynamic Function(dynamic json);
