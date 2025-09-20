// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildSellerInfo(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildProductDescription(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildCulturalStory(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildTags(),
                  const SizedBox(height: AppStyles.spacing32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Product Image
            Image.network(
              widget.product.imageUrls.isNotEmpty
                  ? widget.product.imageUrls[_selectedImageIndex]
                  : widget.product.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.surfaceLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
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
                      size: 64,
                    ),
                  ),
                );
              },
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
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.imageUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedImageIndex == index
                            ? AppColors.textOnPrimary
                            : AppColors.textOnPrimary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isFavorite ? 'Added to favorites' : 'Removed from favorites',
                ),
              ),
            );
          },
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? AppColors.error : AppColors.textOnPrimary,
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
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppStyles.spacing12,
            vertical: AppStyles.spacing4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            widget.product.categoryDisplayName,
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: AppStyles.spacing12),

        // Product Name
        Text(
          widget.product.name,
          style: AppStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppStyles.spacing8),

        // Price Row
        Row(
          children: [
            Text(
              widget.product.formattedPrice,
              style: AppStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.product.hasPriceDifference) ...[
              const SizedBox(width: AppStyles.spacing12),
              Text(
                widget.product.formattedSuggestedPrice,
                style: AppStyles.titleLarge.copyWith(
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: AppStyles.spacing8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppStyles.spacing8,
                  vertical: AppStyles.spacing4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                ),
                child: Text(
                  'AI Suggested',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.accentDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: AppStyles.spacing16),

        // Rating and Reviews
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < widget.product.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.accent,
                  size: 16,
                );
              }),
            ),
            const SizedBox(width: AppStyles.spacing8),
            Text(
              '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              widget.product.sellerName.isNotEmpty
                  ? widget.product.sellerName[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppStyles.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.sellerName,
                  style: AppStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Verified Artisan',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.artisanGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat feature coming soon!')),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.spacing12),
        Text(
          widget.product.description,
          style: AppStyles.bodyLarge,
        ),
        if (widget.product.descriptionLocal.isNotEmpty) ...[
          const SizedBox(height: AppStyles.spacing12),
          Text(
            widget.product.descriptionLocal,
            style: AppStyles.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCulturalStory() {
    if (widget.product.culturalStory == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cultural Story',
          style: AppStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.spacing12),
        Container(
          padding: const EdgeInsets.all(AppStyles.spacing16),
          decoration: BoxDecoration(
            color: AppColors.artisanGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
            border: Border.all(color: AppColors.artisanGold.withOpacity(0.3)),
          ),
          child: Text(
            widget.product.culturalStory!,
            style: AppStyles.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    if (widget.product.tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.spacing12),
        Wrap(
          spacing: AppStyles.spacing8,
          runSpacing: AppStyles.spacing8,
          children: widget.product.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppStyles.spacing12,
                vertical: AppStyles.spacing4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                '#$tag',
                style: AppStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppStyles.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed:
                      _quantity > 1 ? () => setState(() => _quantity--) : null,
                  icon: const Icon(Icons.remove),
                  color: AppColors.primary,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.spacing16),
                  child: Text(
                    _quantity.toString(),
                    style: AppStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppStyles.spacing16),

          // Add to Cart Button
          Expanded(
            child: Container(
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Added ${_quantity} ${widget.product.name} to cart'),
                        action: SnackBarAction(
                          label: 'View Cart',
                          onPressed: () {
                            // Navigate to cart
                          },
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.spacing24,
                      vertical: AppStyles.spacing16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: AppColors.textOnPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: AppStyles.spacing8),
                        Text(
                          'Add to Cart',
                          style: AppStyles.titleMedium.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
