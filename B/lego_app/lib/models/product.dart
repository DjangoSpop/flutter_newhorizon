import 'package:uuid/uuid.dart';

class Product {
  String id;
  String name;
  String description;
  double price;
  double discountedPrice;
  String barcode;
  String category;
  String subcategory;
  List<String> sizes;
  List<String> colors;
  String brand;
  int quantity;
  bool inStock;
  List<String> imagePaths;
  double rating;
  int reviewCount;

  Product({
    String? id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.barcode,
    required this.category,
    required this.subcategory,
    required this.sizes,
    required this.colors,
    required this.brand,
    required this.quantity,
    required this.inStock,
    required this.imagePaths,
    this.rating = 0.0,
    this.reviewCount = 0,
  }) : this.id = id ?? Uuid().v4();

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountedPrice: json['discountedPrice'].toDouble(),
      barcode: json['barcode'],
      category: json['category'],
      subcategory: json['subcategory'],
      sizes: List<String>.from(json['sizes']),
      colors: List<String>.from(json['colors']),
      brand: json['brand'],
      quantity: json['quantity'],
      inStock: json['inStock'],
      imagePaths: List<String>.from(json['imagePaths']),
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'barcode': barcode,
      'category': category,
      'subcategory': subcategory,
      'sizes': sizes,
      'colors': colors,
      'brand': brand,
      'quantity': quantity,
      'inStock': inStock,
      'imagePaths': imagePaths,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
