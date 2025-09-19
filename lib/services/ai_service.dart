// lib/services/ai_service.dart
import 'dart:io';
import 'dart:math';
import '../models/product.dart';

class AIEnhancementResult {
  final String enhancedDescription;
  final String localDescription;
  final double suggestedPrice;
  final List<String> tags;
  final ProductCategory suggestedCategory;
  final Map<String, dynamic> analysisData;

  const AIEnhancementResult({
    required this.enhancedDescription,
    required this.localDescription,
    required this.suggestedPrice,
    required this.tags,
    required this.suggestedCategory,
    required this.analysisData,
  });
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Mock AI service for MVP - in real app, this would call actual AI APIs
  Future<AIEnhancementResult> analyzeProductImage(
    File imageFile,
    String? userDescription,
  ) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock AI analysis based on common artisan products
    final random = Random();
    final categories = ProductCategory.values;
    final category = categories[random.nextInt(categories.length)];

    final mockDescriptions = _getMockDescriptions(category);
    final mockLocalDescriptions = _getMockLocalDescriptions(category);
    
    final enhancedDescription = userDescription?.isNotEmpty == true
        ? _enhanceUserDescription(userDescription!, category)
        : mockDescriptions[random.nextInt(mockDescriptions.length)];

    final localDescription = mockLocalDescriptions[random.nextInt(mockLocalDescriptions.length)];

    final suggestedPrice = _calculateMockPrice(category);
    final tags = _generateTags(category);

    return AIEnhancementResult(
      enhancedDescription: enhancedDescription,
      localDescription: localDescription,
      suggestedPrice: suggestedPrice,
      tags: tags,
      suggestedCategory: category,
      analysisData: {
        'confidence': 0.85 + random.nextDouble() * 0.15,
        'detectedObjects': _getDetectedObjects(category),
        'colorPalette': _getColorPalette(),
        'qualityScore': 0.7 + random.nextDouble() * 0.3,
        'marketComparison': {
          'averagePrice': suggestedPrice * (0.8 + random.nextDouble() * 0.4),
          'priceRange': '${(suggestedPrice * 0.7).toInt()} - ${(suggestedPrice * 1.3).toInt()}',
        }
      },
    );
  }

  Future<String> generateProductDescription(String productName, ProductCategory category) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final descriptions = _getMockDescriptions(category);
    final random = Random();
    return descriptions[random.nextInt(descriptions.length)];
  }

  Future<double> suggestPrice(ProductCategory category, String description) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _calculateMockPrice(category);
  }

  Future<List<String>> generateTags(String description, ProductCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _generateTags(category);
  }

  Future<String> translateToLocalLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock translations (in real app, use Google Translate API)
    final translations = {
      'Beautiful handmade': 'सुंदर हस्तनिर्मित',
      'Unique design': 'अनोखा डिज़ाइन',
      'Traditional craftsmanship': 'पारंपरिक शिल्पकारी',
      'High quality': 'उच्च गुणवत्ता',
      'Eco-friendly': 'पर्यावरण के अनुकूल',
    };

    String translated = text;
    translations.forEach((key, value) {
      translated = translated.replaceAll(key, value);
    });

    return translated;
  }

  // Helper methods for mock data generation
  List<String> _getMockDescriptions(ProductCategory category) {
    switch (category) {
      case ProductCategory.pottery:
        return [
          'Beautiful handcrafted ceramic piece with intricate traditional patterns. Made using time-honored techniques passed down through generations.',
          'Stunning earthenware pottery featuring unique glazing and artistic designs. Perfect for home decoration or functional use.',
          'Elegant ceramic creation showcasing the finest Indian pottery traditions with modern aesthetic appeal.',
        ];
      case ProductCategory.textiles:
        return [
          'Exquisite handwoven textile featuring traditional patterns and vibrant colors. Made using authentic Indian weaving techniques.',
          'Beautiful fabric creation showcasing intricate embroidery and cultural motifs. Perfect for clothing or home décor.',
          'Premium quality handloom textile with unique design elements and superior craftsmanship.',
        ];
      case ProductCategory.jewelry:
        return [
          'Stunning handcrafted jewelry piece featuring traditional Indian designs with modern elegance.',
          'Beautiful artisan jewelry showcasing intricate metalwork and cultural heritage in every detail.',
          'Elegant handmade jewelry combining traditional craftsmanship with contemporary style.',
        ];
      case ProductCategory.woodwork:
        return [
          'Masterfully carved wooden creation showcasing traditional Indian woodworking techniques and artistic excellence.',
          'Beautiful handcrafted wood piece featuring intricate carvings and smooth finish. Made from sustainable materials.',
          'Elegant wooden artwork combining functionality with aesthetic beauty, perfect for home decoration.',
        ];
      default:
        return [
          'Beautiful handcrafted item showcasing traditional Indian artisanship and unique cultural heritage.',
          'Stunning handmade creation featuring authentic techniques and superior quality materials.',
          'Elegant artisan piece combining traditional craftsmanship with modern appeal.',
        ];
    }
  }

  List<String> _getMockLocalDescriptions(ProductCategory category) {
    return [
      'पारंपरिक भारतीय शिल्पकारी का बेहतरीन नमूना। हाथ से बनाया गया यह अनूठा उत्पाद।',
      'कुशल कारीगरों द्वारा निर्मित यह सुंदर रचना। गुणवत्ता और कलात्मकता का संगम।',
      'प्राचीन तकनीकों से बना यह अद्भुत हस्तशिल्प। संस्कृति और कला का प्रतीक।',
    ];
  }

  String _enhanceUserDescription(String userDescription, ProductCategory category) {
    final enhancements = [
      'Beautiful $userDescription with traditional craftsmanship and unique artistic details.',
      'Stunning handmade $userDescription featuring authentic techniques and superior quality.',
      'Exquisite $userDescription showcasing cultural heritage and modern aesthetic appeal.',
    ];
    
    return enhancements[Random().nextInt(enhancements.length)];
  }

  double _calculateMockPrice(ProductCategory category) {
    final basePrice = switch (category) {
      ProductCategory.pottery => 500.0,
      ProductCategory.textiles => 800.0,
      ProductCategory.jewelry => 1200.0,
      ProductCategory.woodwork => 600.0,
      ProductCategory.metalwork => 900.0,
      ProductCategory.painting => 1500.0,
      ProductCategory.sculpture => 2000.0,
      _ => 400.0,
    };

    final random = Random();
    return basePrice + (random.nextDouble() * 500) - 250; // ±250 variation
  }

  List<String> _generateTags(ProductCategory category) {
    final baseTags = ['handmade', 'artisan', 'traditional', 'indian'];
    
    final categoryTags = switch (category) {
      ProductCategory.pottery => ['ceramic', 'clay', 'pottery', 'vase'],
      ProductCategory.textiles => ['fabric', 'weaving', 'embroidery', 'textile'],
      ProductCategory.jewelry => ['ornament', 'accessory', 'ethnic', 'jewelry'],
      ProductCategory.woodwork => ['wood', 'carved', 'furniture', 'décor'],
      ProductCategory.metalwork => ['metal', 'brass', 'bronze', 'crafted'],
      ProductCategory.painting => ['art', 'canvas', 'painted', 'artwork'],
      ProductCategory.sculpture => ['statue', 'carved', 'sculpture', 'art'],
      _ => ['unique', 'handcrafted', 'authentic', 'cultural'],
    };

    return [...baseTags, ...categoryTags.take(3)];
  }

  List<String> _getDetectedObjects(ProductCategory category) {
    switch (category) {
      case ProductCategory.pottery:
        return ['ceramic', 'clay', 'vessel', 'pottery'];
      case ProductCategory.textiles:
        return ['fabric', 'thread', 'pattern', 'textile'];
      case ProductCategory.jewelry:
        return ['metal', 'ornament', 'decoration', 'accessory'];
      default:
        return ['handmade', 'craft', 'art', 'traditional'];
    }
  }

  List<String> _getColorPalette() {
    final colors = ['#8B4513', '#DAA520', '#CD853F', '#D2691E', '#F4A460', '#DEB887'];
    return colors.take(3).toList();
  }

  // Chat/Search functionality
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock search results - in real app, this would query your database
    return [
      Product(
        id: 'search1',
        name: 'Handmade Pottery Vase',
        description: 'Beautiful ceramic vase matching your search',
        imageUrl: 'https://picsum.photos/200/300?search1',
        price: 650,
        sellerId: 'seller1',
        sellerName: 'Ram Kumar',
        category: ProductCategory.pottery,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<String> getChatbotResponse(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final responses = [
      'I found some beautiful handmade items that might interest you!',
      'Let me help you find the perfect artisan product.',
      'I can show you products from verified local artisans.',
      'Would you like to see items in a specific category?',
    ];
    
    return responses[Random().nextInt(responses.length)];
  }
}