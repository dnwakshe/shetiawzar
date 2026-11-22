import 'package:flutter/foundation.dart';

/// Represents a handcrafted agricultural tool product in the Wakshe Agrotech catalog,
/// aligned with the Wakshe Agrotech Store design specification.
@immutable
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String icon;
  final String tag;
  final String description;
  final String imageUrl;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.stock = 10,
    this.icon = '🌾',
    this.tag = 'Farm essential',
    required this.description,
    this.imageUrl = '',
    required this.updatedAt,
  });

  /// Standard tool categories as defined in the store design
  static const List<String> categories = [
    'All',
    'Cutting',
    'Digging',
    'Other',
  ];

  /// Checks if the product is in stock
  bool get isAvailable => stock > 0;

  /// Formatted price with the Indian Rupee symbol
  String get formattedPrice {
    final intPrice = price.round();
    // Simple Indian number formatting
    return '₹$intPrice';
  }

  /// Checks if [imageUrl] points to a remote web resource
  bool get isNetworkImage =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  /// Returns a copy of this product with the given fields replaced.
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? icon,
    String? tag,
    String? description,
    String? imageUrl,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      icon: icon ?? this.icon,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this [Product] into a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'icon': icon,
      'tag': tag,
      'description': description,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Constructs a [Product] from a map with safe fallbacks.
  factory Product.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Product(
      id: map['id']?.toString() ?? '',
      name: (map['name'] as String?)?.trim() ?? 'Handcrafted Tool',
      category: (map['category'] as String?)?.trim() ?? 'Other',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      icon: (map['icon'] as String?)?.trim() ?? '🌾',
      tag: (map['tag'] as String?)?.trim() ?? 'Farm essential',
      description: (map['description'] as String?)?.trim() ?? '',
      imageUrl: (map['imageUrl'] as String?)?.trim() ?? '',
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          price == other.price &&
          stock == other.stock &&
          icon == other.icon &&
          tag == other.tag &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        price,
        stock,
        icon,
        tag,
        description,
        imageUrl,
        updatedAt,
      );

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price, stock: $stock, icon: $icon)';
  }
}
