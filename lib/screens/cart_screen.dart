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
    this.isSelected = true,
  });

  double get totalPrice => product.price * quantity;
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Mock cart items - in real app, this would come from state management
  List<CartItem> cartItems = [];
  bool _isSelectAll = true;

  @override
  void initState() {
    super.initState();
    _loadMockCartItems();
  }

  void _loadMockCartItems() {
    // Mock data for demonstration
    cartItems = [
      CartItem(
        product: Product(
          id: '1',
          name: 'Handwoven Silk Scarf',
          description: 'Beautiful handwoven silk scarf with traditional patterns',
          imageUrl: 'https://picsum.photos/200/200?random=1',
          imageUrls: ['https://picsum.photos/200/200?random=1'],
          price: 2500.0,
          sellerId: 'seller1',
          sellerName: 'Master Weaver',
          category: ProductCategory.textiles,
          tags: ['silk', 'handwoven', 'traditional'],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
        quantity: 2,
      ),
      CartItem(
        product: Product(
          id: '2',
          name: 'Clay Pottery Vase',
          description: 'Hand-thrown clay vase with natural glazing',
          imageUrl: 'https://picsum.photos/200/200?random=2',
          imageUrls: ['https://picsum.photos/200/200?random=2'],
          price: 1200.0,
          sellerId: 'seller2',
          sellerName: 'Pottery Artist',
          category: ProductCategory.pottery,
          tags: ['clay', 'handmade', 'eco-friendly'],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
      ),
    ];
    setState(() {});
  }

  double get selectedItemsTotal {
    return cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get selectedItemsCount {
    return cartItems
        .where((item) => item.isSelected)
        .fold(0, (sum, item) => sum + item.quantity);
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _toggleItemSelection(int index) {
    setState(() {
      cartItems[index].isSelected = !cartItems[index].isSelected;
      _updateSelectAllState();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _isSelectAll = !_isSelectAll;
      for (var item in cartItems) {
        item.isSelected = _isSelectAll;
      }
    });
  }

  void _updateSelectAllState() {
    _isSelectAll = cartItems.every((item) => item.isSelected);
  }

  void _proceedToCheckout() {
    if (selectedItemsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to checkout'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _showCheckoutDialog();
  }

  void _showCheckoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: $selectedItemsCount'),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${selectedItemsTotal.toStringAsFixed(2)}',
              style: AppStyles.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose payment method:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Pay Now',
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // Show loading and simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      
      // Remove selected items from cart
      setState(() {
        cartItems.removeWhere((item) => item.isSelected);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Cart (${cartItems.length})'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  cartItems.clear();
                });
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: AppColors.textOnPrimary),
              ),
            ),
        ],
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
            size: 120,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: AppStyles.headlineMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover amazing handcrafted products\nfrom local artisans',
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Start Shopping',
            onPressed: () => Navigator.pop(context),
            icon: Icons.shopping_bag_outlined,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        // Select All Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              Checkbox(
                value: _isSelectAll,
                onChanged: (_) => _toggleSelectAll(),
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select All (${cartItems.length})',
                style: AppStyles.titleMedium,
              ),
              const Spacer(),
              if (selectedItemsCount > 0)
                Text(
                  '$selectedItemsCount items selected',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
        
        const Divider(height: 1),
        
        // Cart Items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItemCard(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Selection Checkbox
            Checkbox(
              value: item.isSelected,
              onChanged: (_) => _toggleItemSelection(index),
              activeColor: AppColors.primary,
            ),
            
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.surfaceLight,
                child: Image.network(
                  item.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${item.product.sellerName}',
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${item.product.price.toStringAsFixed(0)}',
                        style: AppStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.product.category.name.toUpperCase(),
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _updateQuantity(index, item.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppColors.primary,
                      iconSize: 20,
                    ),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.quantity.toString(),
                        style: AppStyles.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _updateQuantity(index, item.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppColors.primary,
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${item.totalPrice.toStringAsFixed(0)}',
                  style: AppStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  iconSize: 20,
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
                      'Selected ($selectedItemsCount items)',
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${selectedItemsTotal.toStringAsFixed(2)}',
                      style: AppStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                PrimaryButton(
                  text: 'Checkout',
                  onPressed: _proceedToCheckout,
                  icon: Icons.payment,
                  isFullWidth: false,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Payment Options
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Secure payment • COD available',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}