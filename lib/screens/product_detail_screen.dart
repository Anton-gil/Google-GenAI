// lib/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

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
  final _culturalStoryController = TextEditingController();
  final _aiService = AIService();
  final _authService = AuthService();
  
  File? _selectedImage;
  ProductCategory _selectedCategory = ProductCategory.handmade;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  AIEnhancementResult? _aiResult;
  List<String> _tags = [];
  bool _showAIEnhancements = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _culturalStoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Mock image picker - in real app use image_picker package
    setState(() {
      _selectedImage = File('mock_image_path'); // Mock file
    });
    
    if (_selectedImage != null) {
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    
    setState(() => _isAnalyzing = true);
    
    try {
      _aiResult = await _aiService.analyzeProductImage(
        _selectedImage!,
        _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      );
      
      setState(() {
        _showAIEnhancements = true;
        _selectedCategory = _aiResult!.suggestedCategory;
        _tags = _aiResult!.tags;
      });
      
      _showAIEnhancementDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to analyze image. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showAIEnhancementDialog() {
    if (_aiResult == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text('AI Enhancement Ready!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Analysis Results:',
                style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              
              _buildEnhancementItem(
                'Category',
                _aiResult!.suggestedCategory.name.toUpperCase(),
                Icons.category,
              ),
              
              _buildEnhancementItem(
                'Suggested Price',
                '₹${_aiResult!.suggestedPrice.toStringAsFixed(0)}',
                Icons.price_change,
              ),
              
              _buildEnhancementItem(
                'Enhanced Description',
                _aiResult!.enhancedDescription,
                Icons.description,
                isLong: true,
              ),
              
              _buildEnhancementItem(
                'Local Description',
                _aiResult!.localDescription,
                Icons.language,
                isLong: true,
              ),
              
              _buildEnhancementItem(
                'Tags',
                _aiResult!.tags.join(', '),
                Icons.tag,
                isLong: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Review Later'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyAIEnhancements();
              Navigator.pop(context);
            },
            child: const Text('Apply All'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancementItem(String title, String content, IconData icon, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: isLong ? null : 2,
                  overflow: isLong ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyAIEnhancements() {
    if (_aiResult == null) return;
    
    setState(() {
      _descriptionController.text = _aiResult!.enhancedDescription;
      _priceController.text = _aiResult!.suggestedPrice.toStringAsFixed(0);
      _selectedCategory = _aiResult!.suggestedCategory;
      _tags = _aiResult!.tags;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI enhancements applied successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create product object (in real app, save to database)
      final product = Product(
        id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        descriptionLocal: _aiResult?.localDescription ?? '',
        imageUrl: 'https://picsum.photos/400/400', // Mock URL
        imageUrls: ['https://picsum.photos/400/400'], // Mock URLs
        price: double.tryParse(_priceController.text) ?? 0.0,
        suggestedPrice: _aiResult?.suggestedPrice,
        sellerId: currentUser.id,
        sellerName: currentUser.name,
        category: _selectedCategory,
        tags: _tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        aiEnhancementData: _aiResult?.analysisData,
        culturalStory: _culturalStoryController.text.trim().isNotEmpty 
            ? _culturalStoryController.text.trim() 
            : null,
      );

      // Mock save operation
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Product'),
        actions: [
          if (_showAIEnhancements)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: _showAIEnhancementDialog,
              tooltip: 'View AI Suggestions',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker Section
              _buildImageSection(),
              
              const SizedBox(height: AppStyles.spacing24),
              
              // Basic Information
              _buildBasicInfoSection(),
              
              const SizedBox(height: AppStyles.spacing24),
              
              // AI Enhancement Section
              if (_showAIEnhancements) _buildAIEnhancementSection(),
              
              const SizedBox(height: AppStyles.spacing24),
              
              // Cultural Story Section
              _buildCulturalStorySection(),
              
              const SizedBox(height: AppStyles.spacing32),
              
              // Save Button
              PrimaryButton(
                text: 'Add Product',
                onPressed: _saveProduct,
                isLoading: _isSaving,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Image',
            style: AppStyles.heading3,
          ),
          const SizedBox(height: AppStyles.spacing12),
          
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                border: Border.all(
                  color: _selectedImage != null ? AppColors.primary : AppColors.border,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppStyles.radiusMedium - 2),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.image,
                              size: 80,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (_isAnalyzing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(AppStyles.radiusMedium - 2),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppColors.accent),
                                  SizedBox(height: 16),
                                  Text(
                                    'AI is analyzing your image...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add product image',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI will analyze and enhance automatically',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.primary,
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

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppStyles.heading3,
          ),
          const SizedBox(height: AppStyles.spacing16),
          
          CustomTextField(
            label: 'Product Name',
            hintText: 'Enter product name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppStyles.spacing16),
          
          CustomTextField(
            label: 'Description',
            hintText: 'Describe your product',
            controller: _descriptionController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product description';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppStyles.spacing16),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Price (₹)',
                  hintText: '0',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ProductCategory>(
                          value: _selectedCategory,
                          isExpanded: true,
                          items: ProductCategory.values.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category.name.toUpperCase(),
                                style: AppStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (ProductCategory? value) {
                            setState(() => _selectedCategory = value!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (_aiResult != null && _aiResult!.suggestedPrice > 0) ...[
            const SizedBox(height: AppStyles.spacing12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI suggests ₹${_aiResult!.suggestedPrice.toStringAsFixed(0)} based on similar products',
                      style: AppStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _priceController.text = _aiResult!.suggestedPrice.toStringAsFixed(0);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIEnhancementSection() {
    return Container(
      decoration: AppStyles.cardDecoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'AI Enhancements',
                style: AppStyles.heading3.copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacing12),
          
          if (_aiResult != null) ...[
            Text(
              'Enhanced Description (Local):',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _aiResult!.localDescription,
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: AppStyles.spacing12),
            
            Text(
              'Generated Tags:',
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  tag,
                  style: AppStyles.bodySmall.copyWith(color: AppColors.primary),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCulturalStorySection() {
    return Container(
      decoration: AppStyles.cardDecoration,
      padding: const EdgeInsets.all(AppStyles.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories, color: AppColors.artisanGold),
              const SizedBox(width: 8),
              Text(
                'Cultural Story (Optional)',
                style: AppStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: AppStyles.spacing8),
          Text(
            'Share the story behind your creation, cultural significance, or traditional techniques used',
            style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppStyles.spacing16),
          
          CustomTextField(
            hintText: 'Tell the story of your creation...',
            controller: _culturalStoryController,
            maxLines: 4,
            helperText: 'This helps buyers appreciate the cultural value of your work',
          ),
        ],
      ),
    );
  }