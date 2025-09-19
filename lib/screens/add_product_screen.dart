// lib/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/ai_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  
  File? _selectedImage;
  bool _isProcessing = false;
  bool _isAIEnhanced = false;
  
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isAIEnhanced = false;
      });
      await _enhanceWithAI();
    }
  }

  Future<void> _enhanceWithAI() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // AI image enhancement and description generation
      final description = await _aiService.generateProductDescription(_selectedImage!);
      final suggestedPrice = await _aiService.suggestProductPrice(
        _categoryController.text.isEmpty ? 'Handicraft' : _categoryController.text
      );

      setState(() {
        _descriptionController.text = description;
        _priceController.text = suggestedPrice.toString();
        _isAIEnhanced = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI enhancement failed: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and add an image')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create product and save
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        category: ProductCategory.handicraft,
        imageUrls: [_selectedImage!.path],
        sellerId: 'current_user_id', // Replace with actual user ID
        isAvailable: true,
        createdAt: DateTime.now(),
        artisanStory: 'Crafted with traditional techniques',
      );

      Navigator.pop(context, product);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.surfaceLight,
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, 
                               size: 48, 
                               color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text('Tap to add product photo',
                               style: AppStyles.bodyText),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              
              OutlinedCustomButton(
                text: _selectedImage != null ? 'Change Photo' : 'Add Photo',
                onPressed: _pickImage,
                icon: Icons.photo_camera,
                isFullWidth: true,
              ),
              
              if (_isProcessing) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text('AI is enhancing your product...', 
                           style: AppStyles.bodyText),
                    ],
                  ),
                ),
              ],

              if (_isAIEnhanced) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.artisanGold),
                      const SizedBox(width: 8),
                      Text('AI enhanced your product details!',
                           style: AppStyles.bodyText.copyWith(
                             color: AppColors.success,
                           )),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Product Details Form
              CustomTextField(
                controller: _nameController,
                labelText: 'Product Name',
                hintText: 'Enter product name',
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _categoryController,
                labelText: 'Category',
                hintText: 'e.g., Handicraft, Textile, Jewelry',
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Describe your product...',
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _priceController,
                labelText: 'Price (₹)',
                hintText: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Price is required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Enter valid price';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              PrimaryButton(
                text: 'Save Product',
                onPressed: _isProcessing ? null : _saveProduct,
                isLoading: _isProcessing,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
