// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'cart_screen.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isAvailable;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isAvailable = true,
  });
}

class PaymentScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  final List<PaymentMethod> _paymentMethods = [
    const PaymentMethod(
      id: 'upi',
      name: 'UPI',
      description: 'Pay using UPI apps like PhonePe, Google Pay',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF6C5CE7),
    ),
    const PaymentMethod(
      id: 'card',
      name: 'Credit/Debit Card',
      description: 'Pay using your credit or debit card',
      icon: Icons.credit_card,
      color: Color(0xFF00B894),
    ),
    const PaymentMethod(
      id: 'netbanking',
      name: 'Net Banking',
      description: 'Pay using your bank account',
      icon: Icons.account_balance,
      color: Color(0xFF0984E3),
    ),
    const PaymentMethod(
      id: 'cod',
      name: 'Cash on Delivery',
      description: 'Pay when your order is delivered',
      icon: Icons.money,
      color: Color(0xFFE17055),
    ),
    const PaymentMethod(
      id: 'wallet',
      name: 'Digital Wallet',
      description: 'Pay using Paytm, Mobikwik, etc.',
      icon: Icons.wallet,
      color: Color(0xFF00CEC9),
    ),
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppStyles.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildDeliveryDetails(),
                  const SizedBox(height: AppStyles.spacing24),
                  _buildPaymentMethods(),
                  const SizedBox(height: AppStyles.spacing32),
                  _buildPayButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppStyles.spacing16),
          ...widget.cartItems.map((item) => _buildOrderItem(item)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${widget.totalAmount.toStringAsFixed(0)}',
                style: AppStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppStyles.spacing12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.surfaceLight,
              child: item.product.imageUrls.isNotEmpty
                  ? Image.network(
                      item.product.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary),
                    )
                  : const Icon(Icons.image_not_supported,
                      color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppStyles.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${(item.product.price * item.quantity).toStringAsFixed(0)}',
            style: AppStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spacing20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: AppStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppStyles.spacing16),

          // Address
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Delivery Address',
              hintText: 'Enter your complete address',
              prefixIcon: Icon(Icons.location_on),
            ),
            maxLines: 3,
          ),

          const SizedBox(height: AppStyles.spacing16),

          // Phone
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: AppStyles.spacing16),

          // Notes
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Delivery Instructions (Optional)',
              hintText: 'Any special instructions for delivery',
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: AppStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppStyles.spacing16),
        ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod?.id == method.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
        border: Border.all(
          color: isSelected ? method.color : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: method.isAvailable
              ? () {
                  setState(() => _selectedPaymentMethod = method);
                }
              : null,
          borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.spacing8),
                  decoration: BoxDecoration(
                    color: method.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                  ),
                  child: Icon(
                    method.icon,
                    color: method.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppStyles.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.name,
                        style: AppStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: method.isAvailable ? null : AppColors.textHint,
                        ),
                      ),
                      Text(
                        method.description,
                        style: AppStyles.bodySmall.copyWith(
                          color: method.isAvailable
                              ? AppColors.textSecondary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: method.color,
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.textHint,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      width: double.infinity,
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
          onTap: _processPayment,
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
                  size: 24,
                ),
                const SizedBox(width: AppStyles.spacing8),
                Text(
                  'Pay ₹${widget.totalAmount.toStringAsFixed(0)}',
                  style: AppStyles.titleLarge.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_addressController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in delivery details'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isProcessing = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Payment Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order has been placed successfully.'),
            const SizedBox(height: 8),
            Text('Payment Method: ${_selectedPaymentMethod!.name}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${widget.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            const Text('Order will be delivered within 3-5 business days.'),
          ],
        ),
        actions: [
          PrimaryButton(
            text: 'Continue Shopping',
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to cart
              Navigator.of(context).pop(); // Go back to home
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
