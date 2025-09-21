import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/product_card.dart';
import 'seller_dashboard_screen.dart';
import 'chat_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  ProductCategory? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';
  Set<String> _favoriteProductIds = {};

  List<Product> get _likedProducts =>
      _products.where((p) => _favoriteProductIds.contains(p.id)).toList();

  // Filter variables
  double _minPrice = 0;
  double _maxPrice = 10000;

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
        description:
            "Beautiful ceramic vase with intricate traditional patterns.",
        descriptionLocal: "पारंपरिक भारतीय मिट्टी के बर्तनों की कलाकृति।",
        imageUrl: "https://picsum.photos/400/400?pottery",
        imageUrls: const ["https://picsum.photos/400/400?pottery"],
        price: 650,
        suggestedPrice: 700,
        sellerId: "seller1",
        sellerName: "Ramesh Kumar",
        category: ProductCategory.pottery,
        tags: const ["handmade", "pottery", "traditional", "ceramic"],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        culturalStory:
            "This pottery style has been practiced in our village for over 300 years...",
      ),
      Product(
        id: "2",
        name: "Embroidered Silk Dupatta",
        description:
            "Exquisite handwoven silk dupatta featuring traditional embroidery.",
        descriptionLocal: "सुंदर हाथ से बुना गया रेशमी दुपट्टा।",
        imageUrl: "https://picsum.photos/400/400?silk",
        imageUrls: const ["https://picsum.photos/400/400?silk"],
        price: 1200,
        sellerId: "seller2",
        sellerName: "Meera Devi",
        category: ProductCategory.textiles,
        tags: const ["silk", "embroidered", "dupatta", "traditional"],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Product(
        id: "3",
        name: "Brass Handicraft Bowl",
        description: "Elegant brass bowl with intricate engravings.",
        descriptionLocal: "पीतल का सुंदर कटोरा।",
        imageUrl: "https://picsum.photos/400/400?brass",
        imageUrls: const ["https://picsum.photos/400/400?brass"],
        price: 450,
        suggestedPrice: 500,
        sellerId: "seller3",
        sellerName: "Vikash Singh",
        category: ProductCategory.metalwork,
        tags: const ["brass", "handicraft", "bowl", "religious"],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: "4",
        name: "Wooden Elephant Sculpture",
        description:
            "Masterfully carved wooden elephant showcasing traditional techniques.",
        descriptionLocal: "लकड़ी का हाथी की मूर्ति।",
        imageUrl: "https://picsum.photos/400/400?wood",
        imageUrls: const ["https://picsum.photos/400/400?wood"],
        price: 800,
        sellerId: "seller4",
        sellerName: "Arjun Sharma",
        category: ProductCategory.woodwork,
        tags: const ["wood", "elephant", "sculpture", "carved"],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: "5",
        name: "Silver Oxidized Necklace",
        description:
            "Beautiful handcrafted silver necklace with traditional finish.",
        descriptionLocal: "चांदी का हस्तनिर्मित हार।",
        imageUrl: "https://picsum.photos/400/400?jewelry",
        imageUrls: const ["https://picsum.photos/400/400?jewelry"],
        price: 1500,
        sellerId: "seller5",
        sellerName: "Priya Jewels",
        category: ProductCategory.jewelry,
        tags: const ["silver", "necklace", "oxidized", "traditional"],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
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
            product.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            product.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));

        final matchesCategory =
            _selectedCategory == null || product.category == _selectedCategory;

        final matchesPrice =
            product.price >= _minPrice && product.price <= _maxPrice;

        return matchesSearch && matchesCategory && matchesPrice;
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

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favoriteProductIds.contains(product.id)) {
        _favoriteProductIds.remove(product.id);
      } else {
        _favoriteProductIds.add(product.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteProductIds.contains(product.id)
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  bool _isProductFavorite(Product product) {
    return _favoriteProductIds.contains(product.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.palette, color: AppColors.textOnPrimary),
            SizedBox(width: 8),
            Text(
              'Artisan Marketplace',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline,
                color: AppColors.textOnPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
          if (user?.role == UserRole.seller || user?.role == UserRole.both)
            IconButton(
              icon: const Icon(Icons.dashboard, color: AppColors.textOnPrimary),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SellerDashboardScreen()),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: Column(
                children: [
                  _buildSearchAndFilter(),
                  _buildCategoryFilter(),
                  Expanded(
                    child: _filteredProducts.isEmpty
                        ? _buildEmptyState()
                        : _buildProductsGrid(),
                  ),
                  if (_likedProducts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Liked Products', style: AppStyles.titleLarge),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _likedProducts.length,
                        itemBuilder: (context, index) {
                          final product = _likedProducts[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.all(8),
                            child: ProductCard(
                              product: product,
                              onTap: () => _navigateToProductDetail(product),
                              onFavoriteToggle: () => _toggleFavorite(product),
                              isFavorite: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
      floatingActionButton: user?.role == UserRole.buyer
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
      padding: const EdgeInsets.all(AppStyles.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products, artisans...',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon:
                              Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spacing16,
                    vertical: AppStyles.spacing12,
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacing12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _showFilterDialog,
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
      height: 60,
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spacing16,
        vertical: AppStyles.spacing8,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCategoryChip('All', null, Icons.apps),
          for (ProductCategory category in ProductCategory.values)
            _buildCategoryChip(
              category.name.toUpperCase(),
              category,
              _getCategoryIcon(category),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.pottery:
        return Icons.local_drink;
      case ProductCategory.textiles:
        return Icons.checkroom;
      case ProductCategory.metalwork:
        return Icons.build;
      case ProductCategory.woodwork:
        return Icons.carpenter;
      case ProductCategory.jewelry:
        return Icons.diamond;
      case ProductCategory.painting:
        return Icons.palette;
      case ProductCategory.sculpture:
        return Icons.account_balance;
      case ProductCategory.handmade:
        return Icons.handyman;
      case ProductCategory.other:
        return Icons.category;
    }
  }

  Widget _buildCategoryChip(
      String label, ProductCategory? category, IconData icon) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(right: AppStyles.spacing8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) =>
            _onCategorySelected(selected ? category : null),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        ),
        elevation: isSelected ? 2 : 0,
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
        return ProductCard(
          product: _filteredProducts[index],
          onTap: () => _navigateToProductDetail(_filteredProducts[index]),
          onFavoriteToggle: () => _toggleFavorite(_filteredProducts[index]),
          isFavorite: _isProductFavorite(_filteredProducts[index]),
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
            _searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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

              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Price Range Slider
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 10000,
                divisions: 20,
                labels: RangeLabels(
                  '₹${_minPrice.toInt()}',
                  '₹${_maxPrice.toInt()}',
                ),
                onChanged: (RangeValues values) {
                  setModalState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),

              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildPriceRangeChip('Under ₹500', 0, 500),
                  _buildPriceRangeChip('₹500 - ₹1000', 500, 1000),
                  _buildPriceRangeChip('₹1000 - ₹2000', 1000, 2000),
                  _buildPriceRangeChip('Above ₹2000', 2000, 10000),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Quick Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickFilterChip('AI Enhanced', () {
                    setModalState(() {
                      _filteredProducts = _products
                          .where((product) => product.suggestedPrice != null)
                          .toList();
                    });
                  }),
                  _buildQuickFilterChip('Verified Artisans', () {
                    setModalState(() {
                      _filteredProducts = _products
                          .where((product) =>
                              product.sellerName.contains('Verified'))
                          .toList();
                    });
                  }),
                  _buildQuickFilterChip('New Arrivals', () {
                    setModalState(() {
                      _filteredProducts = _products
                          .where((product) => product.createdAt.isAfter(
                              DateTime.now().subtract(const Duration(days: 7))))
                          .toList();
                    });
                  }),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _minPrice = 0;
                          _maxPrice = 10000;
                          _selectedCategory = null;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        _filterProducts();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _filterProducts();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeChip(String label, double minPrice, double maxPrice) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _minPrice = minPrice;
          _maxPrice = maxPrice;
        });
        _filterProducts();
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.normal,
      ),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      onSelected: (selected) {
        onTap();
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.normal,
      ),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
