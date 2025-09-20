// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class CartItem {
  final Product product;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = false,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems =
      []; // In real app, this would come from state management

  @override
  void initState() {
    super.initState();
    _loadSampleCartItems();
  }

  void _loadSampleCartItems() {
    // Add some sample items for demonstration
    cartItems = [
      CartItem(
        product: Product(
          id: "1",
          name: "Handmade Pottery Vase",
          description:
              "Beautiful ceramic vase with intricate traditional patterns.",
          imageUrl: "https://picsum.photos/400/400?pottery",
          imageUrls: const ["https://picsum.photos/400/400?pottery"],
          price: 650,
          sellerId: "seller1",
          sellerName: "Ramesh Kumar",
          category: ProductCategory.pottery,
          tags: const ["handmade", "pottery", "traditional", "ceramic"],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        quantity: 2,
      ),
      CartItem(
        product: Product(
          id: "2",
          name: "Embroidered Silk Dupatta",
          description:
              "Exquisite handwoven silk dupatta featuring traditional embroidery.",
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
        quantity: 1,
      ),
    ];
  }

  double get totalAmount {
    return cartItems.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem(index);
      return;
    }

    setState(() {
      cartItems[index].quantity = newQuantity;
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  void _proceedToCheckout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Text('Total amount: ₹${totalAmount.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Pay Now',
            onPressed: () {
              Navigator.pop(context);
              // Implement payment logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Payment integration coming soon!')),
              );
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start shopping to add items to your cart',
            style: AppStyles.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Browse Products',
            onPressed: () {
              // Navigate to home screen (index 0) instead of just popping
              Navigator.of(context).popUntil((route) => route.isFirst);
              // If we're in a nested navigation, go to home tab
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: Icons.shopping_bag,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return _buildCartItemCard(item, index);
      },
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacing12),
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
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spacing16),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              child: Container(
                width: 90,
                height: 90,
                color: AppColors.surfaceLight,
                child: item.product.imageUrls.isNotEmpty
                    ? Image.network(
                        item.product.imageUrls.first,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary),
                      )
                    : Icon(Icons.image_not_supported,
                        color: AppColors.textSecondary),
              ),
            ),

            const SizedBox(width: AppStyles.spacing16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${item.product.sellerName}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.product.formattedPrice,
                        style: AppStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: ₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _updateQuantity(index, item.quantity - 1),
                        icon: const Icon(Icons.remove),
                        color: AppColors.primary,
                        iconSize: 18,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Text(
                          item.quantity.toString(),
                          style: AppStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _updateQuantity(index, item.quantity + 1),
                        icon: const Icon(Icons.add),
                        color: AppColors.primary,
                        iconSize: 18,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _removeItem(index),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppStyles.radiusMedium),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cartItems.length} item${cartItems.length != 1 ? 's' : ''}',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Total Amount',
                    style: AppStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: AppStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacing20),

          // Checkout Button
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _proceedToCheckout,
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
                        Icons.payment,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: AppStyles.spacing8),
                      Text(
                        'Proceed to Checkout',
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
        ],
      ),
    );
  }
}
