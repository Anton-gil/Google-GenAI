// lib/models/product.dart
enum ProductCategory {
  pottery,
  textiles,
  jewelry,
  woodwork,
  metalwork,
  painting,
  sculpture,
  handmade,
  other
}

class Product {
  final String id;
  final String name;
  final String description;
  final String descriptionLocal; // Local language description
  final String imageUrl;
  final List<String> imageUrls; // Multiple images
  final double price;
  final double? suggestedPrice; // AI suggested price
  final String sellerId;
  final String sellerName;
  final ProductCategory category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int viewCount;
  final double rating;
  final int reviewCount;
  final Map<String, dynamic>? aiEnhancementData; // Store AI analysis data
  final String? culturalStory; // Artisan's story about the product

  const Product({
    required this.id,
    required this.name,
    required this.description,
    this.descriptionLocal = '',
    required this.imageUrl,
    this.imageUrls = const [],
    required this.price,
    this.suggestedPrice,
    required this.sellerId,
    required this.sellerName,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.viewCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.aiEnhancementData,
    this.culturalStory,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? descriptionLocal,
    String? imageUrl,
    List<String>? imageUrls,
    double? price,
    double? suggestedPrice,
    String? sellerId,
    String? sellerName,
    ProductCategory? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? viewCount,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? aiEnhancementData,
    String? culturalStory,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      descriptionLocal: descriptionLocal ?? this.descriptionLocal,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      aiEnhancementData: aiEnhancementData ?? this.aiEnhancementData,
      culturalStory: culturalStory ?? this.culturalStory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'descriptionLocal': descriptionLocal,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'price': price,
      'suggestedPrice': suggestedPrice,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'category': category.toString(),
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'viewCount': viewCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'aiEnhancementData': aiEnhancementData,
      'culturalStory': culturalStory,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      descriptionLocal: json['descriptionLocal'] ?? '',
      imageUrl: json['imageUrl'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      price: json['price']?.toDouble() ?? 0.0,
      suggestedPrice: json['suggestedPrice']?.toDouble(),
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ProductCategory.other,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      viewCount: json['viewCount'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      aiEnhancementData: json['aiEnhancementData'],
      culturalStory: json['culturalStory'],
    );
  }

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get formattedSuggestedPrice => suggestedPrice != null ? '₹${suggestedPrice!.toStringAsFixed(0)}' : '';
  
  bool get hasPriceDifference => suggestedPrice != null && (price - suggestedPrice!).abs() > 10;
  
  String get categoryDisplayName {
    switch (category) {
      case ProductCategory.pottery:
        return 'Pottery';
      case ProductCategory.textiles:
        return 'Textiles';
      case ProductCategory.jewelry:
        return 'Jewelry';
      case ProductCategory.woodwork:
        return 'Woodwork';
      case ProductCategory.metalwork:
        return 'Metalwork';
      case ProductCategory.painting:
        return 'Painting';
      case ProductCategory.sculpture:
        return 'Sculpture';
      case ProductCategory.handmade:
        return 'Handmade';
      case ProductCategory.other:
        return 'Other';
    }
  }
}