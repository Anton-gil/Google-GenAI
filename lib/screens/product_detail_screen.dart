// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../services/ai_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AIService _aiService = AIService();
  
  bool _isFavorited = false;
  bool _isInCart = false;
  int _quantity = 1;
  String? _chatResponse;
  bool _isChatLoading = false;
  final TextEditingController _chatController = TextEditingController();
  
  // Mock artisan data - in real app, fetch from backend
  late User artisan;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Mock artisan data
    artisan = User(
      id: widget.product.sellerId,
      name: widget.product.sellerName ?? 'Master Artisan',
      email: 'artisan@example.com',
      phone: '+91 9876543210',
      role: UserRole.seller,
      verificationStatus: VerificationStatus.verified,
      address: 'Traditional Craft Village, India',
      bio: 'Third generation craftsperson specializing in traditional handicrafts',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      isVerifiedArtisan: true,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _askAIQuestion(String question) async {
    if (question.trim().isEmpty) return;
    
    setState(() {
      _isChatLoading = true;
      _chatResponse = null;
    });
    
    try {
      final response = await _aiService.answerProductQuestion(
        widget.product,
        question,
      );
      
      setState(() {
        _chatResponse = response;
      });
    } catch (e) {
      setState(() {
        _chatResponse = 'Sorry, I couldn\'t answer that question right now. Please try again.';
      });
    } finally {
      setState(() {
        _isChatLoading = false;
      });
    }
  }

  void _addToCart() {
    setState(() {
      _isInCart = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.textOnPrimary,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited 
              ? '${widget.product.name} added to favorites!' 
              : '${widget.product.name} removed from favorites',
        ),
        backgroundColor: _isFavorited ? AppColors.success : AppColors.textSecondary,
      ),
    );
  }

  void _contactArtisan() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    artisan.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artisan.name,
                        style: AppStyles.titleLarge,
                      ),
                      if (artisan.isVerifiedArtisan)
                        Row(
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.artisanGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Artisan',
                              style: AppStyles.bodySmall.copyWith(
                                color: AppColors.artisanGold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedCustomButton(
                    text: 'Call',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling feature coming soon!')),
                      );
                    },
                    icon: Icons.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Message',
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Messaging feature coming soon!')),
                      );
                    },
                    icon: Icons.message,
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildProductInfo(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      actions: [
        IconButton(
          onPressed: _toggleFavorite,
          icon: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border,
            color: _isFavorited ? AppColors.error : AppColors.textOnPrimary,
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            );
          },
          icon: const Icon(Icons.share),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product Image
            widget.product.imageUrls.isNotEmpty
                ? PageView.builder(
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.product.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceLight,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      );
                    },
                  )
                : Container(
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.image,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                  ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            
            // Image indicators
            if (widget.product.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.imageUrls.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textOnPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: AppStyles.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.category.name.toUpperCase(),
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${widget.product.price.toStringAsFixed(0)}',
                    style: AppStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.product.suggestedPrice != null && 
                      widget.product.suggestedPrice! > widget.product.price)
                    Text(
                      '₹${widget.product.suggestedPrice!.toStringAsFixed(0)}',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tags
          if (widget.product.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.product.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Text(
                  tag,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              )).toList(),
            ),
          
          const SizedBox(height: 16),
          
          // Artisan Info
          _buildArtisanInfo(),
        ],
      ),
    );
  }

  Widget _buildArtisanInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              artisan.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      artisan.name,
                      style: AppStyles.titleMedium,
                    ),
                    if (artisan.isVerifiedArtisan) ..[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppColors.artisanGold,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  artisan.address ?? 'Local Artisan',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          OutlinedCustomButton(
            text: 'Contact',
            onPressed: _contactArtisan,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Story'),
              Tab(text: 'AI Chat'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(),
                _buildStoryTab(),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: AppStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.justify,
          ),
          
          if (widget.product.descriptionLocal.isNotEmpty) ..[
            const SizedBox(height: 20),
            Text(
              'Local Description',
              style: AppStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.product.descriptionLocal,
                style: AppStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          Text(
            'Product Details',
            style: AppStyles.titleMedium,
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow('Category', widget.product.category.name.toUpperCase()),
          _buildDetailRow('Created', _formatDate(widget.product.createdAt)),
          _buildDetailRow('Availability', widget.product.isAvailable ? 'In Stock' : 'Out of Stock'),
          if (widget.product.tags.isNotEmpty)
            _buildDetailRow('Tags', widget.product.tags.join(', ')),
        ],
      ),
    );
  }

  Widget _buildStoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: AppColors.artisanGold,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Artisan Story',
                style: AppStyles.titleLarge.copyWith(
                  color: AppColors.artisanGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (widget.product.culturalStory != null && widget.product.culturalStory!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.artisanGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.artisanGold.withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.product.culturalStory!,
                style: AppStyles.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The artisan hasn\'t shared a story for this product yet.',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Artisan Bio
          Text(
            'About the Artisan',
            style: AppStyles.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            artisan.bio ?? 'A skilled craftsperson dedicated to traditional techniques.',
            style: AppStyles.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Ask AI about this product',
                style: AppStyles.titleMedium.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get instant answers about the product, care instructions, or cultural significance',
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick Questions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickQuestion('How is this made?'),
              _buildQuickQuestion('Care instructions?'),
              _buildQuickQuestion('Cultural significance?'),
              _buildQuickQuestion('Similar products?'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chat Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask anything about this product...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _askAIQuestion(value);
                      _chatController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isChatLoading ? null : () {
                  if (_chatController.text.trim().isNotEmpty) {
                    _askAIQuestion(_chatController.text);
                    _chatController.clear();
                  }
                },
                icon: _isChatLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chat Response
          if (_chatResponse != null)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _chatResponse!,
                    style: AppStyles.bodyMedium,
                  ),
                ),
              ),
            )
          else if (_isChatLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'AI is thinking...',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ask me anything about this product!',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestion(String question) {
    return GestureDetector(
      onTap: () {
        _askAIQuestion(question);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Text(
          question,
          style: AppStyles.bodySmall.copyWith(
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () {
                      setState(() {
                        _quantity--;
                      });
                    } : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 18,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _quantity.toString(),
                      style: AppStyles.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 18,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Add to Cart Button
            Expanded(
              child: PrimaryButton(
                text: _isInCart ? 'Added to Cart' : 'Add to Cart',
                onPressed: _isInCart ? null : _addToCart,
                icon: _isInCart ? Icons.check : Icons.add_shopping_cart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}