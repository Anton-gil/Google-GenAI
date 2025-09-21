// lib/screens/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';
import '../services/ai_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  bool _isAIGenerating = false;
  String? _aiGeneratedDescription;
  double? _aiSuggestedPrice;
  
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();

  final List<String> _categories = [
    'Handicrafts',
    'Jewelry',
    'Textiles',
    'Pottery',
    'Woodwork',
    'Metalwork',
    'Paintings',
    'Sculptures',
    'Home Decor',
    'Accessories',
    'Traditional Wear',
    'Art Supplies',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        // Auto-generate AI content after image selection
        await _generateAIContent();
      }
    } catch (e) {
      _showSnackBar('Failed to select image: $e');
    }
  }

  Future<void> _generateAIContent() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isAIGenerating = true;
    });
    
    try {
      // Generate AI description and price
      final description = await _aiService.generateProductDescription(
        imagePath: _selectedImage!.path,
        category: _categoryController.text.isNotEmpty 
            ? _categoryController.text 
            : 'Handicraft',
      );
      
      final price = await _aiService.suggestPrice(
        category: _categoryController.text.isNotEmpty 
            ? _categoryController.text 
            : 'Handicraft',
        description: description,
      );
      
      setState(() {
        _aiGeneratedDescription = description;
        _aiSuggestedPrice = price;
        
        // Auto-fill the description if empty
        if (_descriptionController.text.isEmpty && description.isNotEmpty) {
          _descriptionController.text = description;
        }
        
        // Auto-fill the price if empty
        if (_priceController.text.isEmpty && price > 0) {
          _priceController.text = price.toStringAsFixed(2);
        }
      });
    } catch (e) {
      _showSnackBar('Failed to generate AI content: $e');
    } finally {
      setState(() {
        _isAIGenerating = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    _categoryController.text = _categories[index];
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedImage == null) {
      _showSnackBar('Please select an image for your product');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // TODO: Implement product creation with backend service
      // For now, just show success message
      _showSnackBar('Product added successfully!');
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      _showSnackBar('Failed to add product: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Product'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          if (_isAIGenerating)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUploadSection(),
              const SizedBox(height: 24),
              
              // AI Enhancement Banner
              if (_isAIGenerating) _buildAILoadingBanner(),
              if (_aiGeneratedDescription != null && !_isAIGenerating) 
                _buildAIAssistantBanner(),
              
              const SizedBox(height: 16),
              
              // Product Title
              CustomTextField(
                controller: _titleController,
                label: 'Product Title',
                hint: 'Enter a catchy title for your product',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Category
              CustomTextField(
                controller: _categoryController,
                label: 'Category',
                hint: 'Select product category',
                readOnly: true,
                onTap: _showCategoryDialog,
                suffixIcon: Icons.arrow_drop_down,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: _aiGeneratedDescription?.isEmpty ?? true 
                    ? 'Describe your product or let AI generate it' 
                    : 'AI-generated description (you can edit)',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price (₹)',
                      hint: 'Enter price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (_aiSuggestedPrice != null)
                    Column(
                      children: [
                        const Text(
                          'AI Suggested',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹${_aiSuggestedPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Tags
              CustomTextField(
                controller: _tagsController,
                label: 'Tags (optional)',
                hint: 'Add tags separated by commas',
                helperText: 'e.g., handmade, traditional, eco-friendly',
              ),
              const SizedBox(height: 32),
              
              // Add Product Button
              PrimaryButton(
                text: 'Add Product',
                onPressed: _addProduct,
                isLoading: _isLoading,
                icon: Icons.add_shopping_cart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: _selectedImage == null
          ? InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tap to add product photo',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI will enhance and analyze your image',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _aiGeneratedDescription = null;
                          _aiSuggestedPrice = null;
                          _descriptionController.clear();
                          _priceController.clear();
                        });
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _showImageSourceDialog,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAILoadingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI is analyzing your image and generating content...',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _generateAIContent,
                child: const Text('Regenerate'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AI has generated content based on your image. You can edit the description and price as needed.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
