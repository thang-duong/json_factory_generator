// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:example/models/post.dart';
import 'package:example/models/product.dart';
import 'package:example/models/user.dart';

/// Auto-generated JsonFactory for type-safe JSON parsing in Flutter/Dart
///
/// A centralized factory for parsing JSON data into strongly-typed Dart objects.
/// Works with any model class annotated with @jsonModel and @JsonSerializable.
///
/// Features:
/// - Type-safe JSON parsing for models and lists of models
/// - Automatic null-safety handling
/// - Support for generic types and collections
/// - Built-in error handling with clear messages
///
/// Usage examples:
///   // Parse a single object
///   final user = JsonFactory.fromJson<User>(jsonMap);
///   
///   // Parse a list of objects
///   final users = JsonFactory.fromJson<List<User>>(jsonList);
///   
///   // Handle nullable types
///   final userOrNull = JsonFactory.fromJson<User?>(maybeNull);
///   final usersOrNull = JsonFactory.fromJson<List<User>?>(maybeNull);
class JsonFactory {
  /// Maps Dart Types to their corresponding JSON parsing functions.
  /// Key: The Dart Type (e.g., User, Post)
  /// Value: A function that converts JSON data to that Type
  static final Map<Type, FromJsonFunc> _factories = {
    Product: (json) => Product.fromJson(json as Map<String, dynamic>),
    Post: (json) => Post.fromJson(json as Map<String, dynamic>),
    User: (json) => User.fromJson(json as Map<String, dynamic>),
  };

  /// Internal map of string type names to actual Dart Types.
  /// Note: keys are non-nullable simple names (no '?', no generics)
  static final Map<String, Type> _typeMap = {
    'Product': Product,
    'Post': Post,
    'User': User,
  };

  /// Type-safe casting functions for converting lists of dynamic to strongly-typed lists.
  /// Key: The element Type (e.g., User for List<User>)
  /// Value: A function that safely casts a List<dynamic> to List<T>
  static final Map<Type, List<dynamic> Function(List<dynamic>)> _listCasters = {
    Product: (list) => list.cast<Product>().toList(),
    Post: (list) => list.cast<Post>().toList(),
    User: (list) => list.cast<User>().toList(),
  };
  /// Converts JSON data to the specified type T
  /// Supports both single objects and lists, with nullable T handling.
  static T fromJson<T>(dynamic json) {
    // If incoming JSON is null:
    // - If T is nullable (e.g. User?, List<User>?), return null as T
    // - Else, throw a clear error
    if (json == null) {
      if (_isNullableT<T>()) {
        return null as T; // safe because T is nullable
      }
      throw ArgumentError('JSON data is null for non-nullable type $T');
    }

    // If it's a list, handle as List<Inner>
    if (json is List) {
      return _handleListType<T>(json);
    }

    // Else expect a single object (Map)
    return _handleSingleType<T>(json);
  }

  /// Handles conversion of `List<Inner>` types.
  /// Example: when `T` is `List<Post>` or `List<Post>?`.
  static T _handleListType<T>(List json) {
    final typeStr = _typeNameOf<T>();
    final bareTypeStr = _stripNullability(typeStr); // e.g. "List<User>"

    // If T isn't List<...>, just return as-is (caller asked for raw list)
    if (!bareTypeStr.startsWith('List<') || !bareTypeStr.endsWith('>')) {
      return json as T;
    }

    // Extract inner type name: "User" from "List<User>"
    final innerTypeName = bareTypeStr.substring(5, bareTypeStr.length - 1);

    // Map to the Dart Type of inner model
    final innerDartType = _typeMap[innerTypeName];
    if (innerDartType == null) {
      throw ArgumentError('Unknown inner type $innerTypeName in $typeStr');
    }

    // 1) Parse each JSON item using the registered factory for Inner
    final factory = _factories[innerDartType];
    if (factory == null) {
      throw ArgumentError(
          'No factory registered for inner type $innerTypeName in $typeStr');
    }
    final rawList = json.map((e) => factory(e)).toList(); // List<dynamic>

    // 2) Cast to strongly-typed List<Inner> using a generated caster
    final caster = _listCasters[innerDartType];
    if (caster != null) {
      final typedList = caster(rawList); // List<Inner>
      // 3) Return as T (where T == List<Inner> or List<Inner>?)
      return typedList as T;
    }

    // Fallback: return dynamic list if no caster available
    return rawList as T;
  }

  /// Handles conversion of single object types (e.g., `User` or `User?`).
  static T _handleSingleType<T>(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw ArgumentError(
        'Expected JSON object (Map) for type $T, got ${json.runtimeType}',
      );
    }

    final typeStr = _stripNullability(_typeNameOf<T>()); // e.g. "User"
    final dartType = _typeMap[typeStr];
    if (dartType == null) {
      throw ArgumentError('Unknown or unregistered type $typeStr for $T');
    }

    final factory = _factories[dartType];
    if (factory == null) {
      throw ArgumentError('No factory registered for type $typeStr');
    }

    return factory(json) as T;
  }

  // -----------------------------
  // Helpers
  // -----------------------------

  /// Returns true if generic T is a nullable type (ends with '?').
  static bool _isNullableT<T>() {
    final s = _typeNameOf<T>();
    return s.endsWith('?');
  }

  /// Returns T's name as string (e.g., "User", "User?", "List<User>", "List<User>?")
  static String _typeNameOf<T>() => T.toString();

  /// Strips a single trailing '?' (nullability) from a type name string.
  static String _stripNullability(String typeName) =>
      typeName.endsWith('?') ? typeName.substring(0, typeName.length - 1) : typeName;
}

/// Type definition for JSON factory functions.
/// 
/// Each registered model type has a corresponding factory function
/// that takes dynamic JSON data and returns a parsed model instance.
typedef FromJsonFunc = dynamic Function(dynamic json);
