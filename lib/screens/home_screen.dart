// lib/screens/home_screen.dart (Enhanced Version)
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'seller_dashboard_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _aiService = AIService();
  final _searchController = TextEditingController();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  ProductCategory? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    
    // Mock product data - in real app, fetch from API
    _products = [
      Product(
        id: "1",
        name: "Handmade Pottery Vase",
        description: "Beautiful ceramic vase with intricate traditional patterns. Made using time-honored techniques passed down through generations.",
        descriptionLocal: "पारंपरिक भारतीय मिट्टी के बर्तनों की कलाकृति। हाथ से बनाया गया अनूठा फूलदान।",
        imageUrl: "https://picsum.photos/400/400?pottery",
        price: 650,
        suggestedPrice: 700,
        sellerId: "seller1",
        sellerName: "Ramesh Kumar",
        category: ProductCategory.pottery,
        tags: ["handmade", "pottery", "traditional", "ceramic"],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        viewCount: 234,
        rating: 4.7,
        reviewCount: 18,
        culturalStory: "This pottery style has been practiced in our village for over 300 years...",
      ),
      Product(
        id: "2",
        name: "Embroidered Silk Dupatta",
        description: "Exquisite handwoven silk dupatta featuring traditional embroidery and vibrant colors. Perfect for special occasions.",
        descriptionLocal: "सुंदर हाथ से बुना गया रेशमी दुपट्टा। पारंपरिक कढ़ाई के साथ।",
        imageUrl: "https://picsum.photos/400/400?silk",
        price: 1200,
        sellerId: "seller2",
        sellerName: "Meera Devi",
        category: ProductCategory.textiles,
        tags: ["silk", "embroidered", "dupatta", "traditional"],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        viewCount: 156,
        rating: 4.9,
        reviewCount: 24,
      ),
      Product(
        id: "3",
        name: "Brass Handicraft Bowl",
        description: "Elegant brass bowl with intricate engravings. Perfect for home decoration or religious ceremonies.",
        descriptionLocal: "पीतल का सुंदर कटोरा। धार्मिक अनुष्ठानों के लिए आदर्श।",
        imageUrl: "https://picsum.photos/400/400?brass",
        price: 450,
        suggestedPrice: 500,
        sellerId: "seller3",
        sellerName: "Vikash Singh",
        category: ProductCategory.metalwork,
        tags: ["brass", "handicraft", "bowl", "religious"],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        viewCount: 89,
        rating: 4.5,
        reviewCount: 12,
      ),
      Product(
        id: "4",
        name: "Wooden Elephant Sculpture",
        description: "Masterfully carved wooden elephant showcasing traditional Indian woodworking techniques.",
        descriptionLocal: "लकड़ी का हाथी की मूर्ति। पारंपरिक नक्काशी की कलाकृति।",
        imageUrl: "https://picsum.photos/400/400?wood",
        price: 800,
        sellerId: "seller4",
        sellerName: "Arjun Sharma",
        category: ProductCategory.woodwork,
        tags: ["wood", "elephant", "sculpture", "carved"],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        viewCount: 345,
        rating: 4.8,
        reviewCount: 31,
      ),
      Product(
        id: "5",
        name: "Silver Oxidized Necklace",
        description: "Beautiful handcrafted silver necklace with traditional oxidized finish and cultural motifs.",
        descriptionLocal: "चांदी का हस्तनिर्मित हार। पारंपरिक डिजाइन के साथ।",
        imageUrl: "https://picsum.photos/400/400?jewelry",
        price: 1500,
        sellerId: "seller5",
        sellerName: "Priya Jewels",
        category: ProductCategory.jewelry,
        tags: ["silver", "necklace", "oxidized", "traditional"],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        viewCount: 78,
        rating: 4.6,
        reviewCount: 9,
      ),
      Product(
        id: "6",
        name: "Madhubani Painting",
        description: "Authentic Madhubani painting on handmade paper, depicting traditional Bihar folk art.",
        descriptionLocal: "मधुबनी चित्रकला। बिहार की पारंपरिक लोक कला।",
        imageUrl: "https://picsum.photos/400/400?painting",
        price: 2000,
        suggestedPrice: 1800,
        sellerId: "seller6",
        sellerName: "Sunita Kumari",
        category: ProductCategory.painting,
        tags: ["madhubani", "painting", "folk art", "bihar"],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 267,
        rating: 4.9,
        reviewCount: 22,
      ),
    ];
    
    _filteredProducts = List.from(_products);
    setState(() => _isLoading = false);
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterProducts();
  }

  void _onCategorySelected(ProductCategory? category) {
    setState(() => _selectedCategory = category);
    _filterProducts();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.palette, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Artisan Marketplace',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isLoggedIn) ...[
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            if (user?.role == UserRole.seller || user?.role == UserRole.both)
              IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
                  );
                },
              ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Section
                _buildSearchAndFilter(),
                
                // Category Filter
                _buildCategoryFilter(),
                
                // Products Grid
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : _buildProductsGrid(),
                ),
              ],
            ),
      floatingActionButton: !isLoggedIn
          ? null
          : user?.role == UserRole.buyer
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.chat, color: AppColors.textOnPrimary),
                )
              : null,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SearchTextField(
              controller: _searchController,
              hintText: 'Search products, artisans...',
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                _showFilterDialog();
              },
              icon: const Icon(
                Icons.tune,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', null),
          ...ProductCategory.values.map((category) => 
            _buildCategoryChip(category.name.toUpperCase(), category)
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _onCategorySelected(selected ? category : null),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return EnhancedProductCard(
          product: _filteredProducts[index],
          onTap: () => _navigateToProductDetail(_filteredProducts[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No products found for "$_searchQuery"'
                : 'No products available',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try searching with different keywords'
                : 'Check back later for new arrivals',
            style: const TextStyle(color: AppColors.textHint),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Price Range Filter
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildPriceRangeChip('Under ₹500'),
                const SizedBox(width: 8),
                _buildPriceRangeChip('₹500 - ₹1000'),
                const SizedBox(width: 8),
                _buildPriceRangeChip('Above ₹1000'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Rating Filter
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildRatingChip('4+ Stars'),
                _buildRatingChip('3+ Stars'),
                _buildRatingChip('Any Rating'),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters here
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        // TODO: Implement price range filter
      },
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }

  Widget _buildRatingChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        // TODO: Implement rating filter
      },
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.border),
    );
  }

  void _navigateToProductDetail(Product product) {
    // TODO: Navigate to product detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${product.name}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Enhanced Product Card Widget
class EnhancedProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const EnhancedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with badges
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceLight,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.textHint,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // AI Enhancement Badge
                  if (product.suggestedPrice != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.textOnPrimary,
                              size: 10,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // View Count
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${product.viewCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Category Badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.categoryDisplayName,
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Seller Name
                    Text(
                      'by ${product.sellerName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Rating and Reviews
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.artisanGold,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          ' (${product.reviewCount})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (product.hasPriceDifference)
                              Text(
                                product.formattedSuggestedPrice,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 10,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}