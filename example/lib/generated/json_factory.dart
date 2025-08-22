// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated on: 2025-08-22 11:30:19.108569

import 'package:example/models/post.dart';
import 'package:example/models/product.dart';
import 'package:example/models/user.dart';

/// Auto-generated JsonFactory for type-safe JSON parsing
/// Generated on: 2025-08-22 11:30:19.109570
/// 
/// This class provides centralized, type-safe JSON parsing for all
/// model classes annotated with @jsonModel and @JsonSerializable.
/// 
/// Usage:
///   final user = JsonFactory.fromJson<User>(jsonMap);
///   final users = JsonFactory.fromJson<List<User>>(jsonList);
class JsonFactory {
  /// Internal map of Type to JSON parsing functions.
  /// Each entry maps a model class Type to its fromJson factory method.
  static final Map<Type, FromJsonFunc> _factories = {
    Product: (json) => Product.fromJson(json as Map<String, dynamic>),
    Post: (json) => Post.fromJson(json as Map<String, dynamic>),
    User: (json) => User.fromJson(json as Map<String, dynamic>),
  };

  /// Internal map of string type names to actual Dart Types.
  /// Used for resolving generic types like List<User> at runtime.
  static final Map<String, Type> _typeMap = {
    'Product': Product,
    'Post': Post,
    'User': User,
  };

  /// Generated list casters for safe List<T> type conversion.
  /// 
  /// When parsing List<ModelType>, we first parse each JSON object into
  /// model instances (creating List<dynamic>), then use these casters
  /// to safely convert to List<ModelType> with proper generic typing.
  /// 
  /// This avoids runtime type errors and provides compile-time safety.
  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {
    Product: (list) => list.cast<Product>().toList(),
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

/// Type definition for JSON factory functions.
/// 
/// Each registered model type has a corresponding factory function
/// that takes dynamic JSON data and returns a parsed model instance.
typedef FromJsonFunc = dynamic Function(dynamic json);
