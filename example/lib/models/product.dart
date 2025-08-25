import 'package:json_factory_annotation/json_factory_annotation.dart';
import 'package:json_factory_generator/json_factory_generator.dart';

@jsonModel
class Product {
  final int id;
  final String name;
  final double price;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        inStock: json['inStock'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'inStock': inStock,
      };

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: \$$price, inStock: $inStock)';
}
