import 'package:json_factory_annotation/json_factory_annotation.dart';
import 'package:test/test.dart';

void main() {
  group('JSON Factory Generator', () {
    test('should export jsonModel annotation', () {
      expect(jsonModel, isNotNull);
      expect(jsonModel, isA<JsonModel>());
    });

    test('JsonModel annotation should have correct properties', () {
      const annotation = JsonModel();
      expect(annotation, isA<JsonModel>());
    });

    test('annotation is const and comparable', () {
      const annotation1 = JsonModel();
      const annotation2 = JsonModel();
      expect(annotation1, equals(annotation2));
      expect(annotation1.hashCode, equals(annotation2.hashCode));
    });

    test('jsonModel constant should be equal to new JsonModel instance', () {
      const newInstance = JsonModel();
      expect(jsonModel, equals(newInstance));
    });
  });
}
