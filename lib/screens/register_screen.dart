// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.buyer;
  bool _agreeToTerms = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        aadhaarNumber: _selectedRole == UserRole.seller ? _aadhaarController.text.trim() : null,
      );

      if (result.success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Registration successful!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate to verification or home
        Navigator.of(context).pushReplacementNamed('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')),
        );
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress Indicator
              Container(
                padding: const EdgeInsets.all(AppStyles.spacing16),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: AppColors.border.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              
              Expanded(
                child: PageView(
                  controller: PageController(initialPage: _currentStep),
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  children: [
                    _buildBasicInfoStep(),
                    _buildAccountStep(),
                    _buildVerificationStep(),
                  ],
                ),
              ),
              
              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(AppStyles.spacing16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedCustomButton(
                          text: 'Back',
                          onPressed: _previousStep,
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: _currentStep == 2
                          ? PrimaryButton(
                              text: 'Create Account',
                              onPressed: _register,
                              isLoading: _isLoading,
                            )
                          : PrimaryButton(
                              text: 'Next',
                              onPressed: _nextStep,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Basic Information',
            style: AppStyles.heading2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppStyles.spacing8),
          Text(
            'Let\'s start with your basic details',
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: AppStyles.spacing32),
          
          CustomTextField(
            label: 'Full Name',
            hintText: 'Enter your full name',
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppStyles.spacing16),
          
          EmailTextField(controller: _emailController),
          
          const SizedBox(height: AppStyles.spacing16),
          
          PhoneTextField(controller: _phoneController),
          
          const SizedBox(height: AppStyles.spacing24),
          
          Text(
            'I want to:',
            style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          
          const SizedBox(height: AppStyles.spacing12),
          
          ...UserRole.values.map((role) => RadioListTile<UserRole>(
            title: Text(_getRoleTitle(role)),
            subtitle: Text(_getRoleSubtitle(role)),
            value: role,
            groupValue: _selectedRole,
            onChanged: (UserRole? value) {
              setState(() => _selectedRole = value!);
            },
            activeColor: AppColors.primary,
          )),
        ],
      ),
    );
  }

  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account Security',
            style: AppStyles.heading2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppStyles.spacing8),
          Text(
            'Create a secure password for your account',
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: AppStyles.spacing32),
          
          PasswordTextField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppStyles.spacing16),
          
          PasswordTextField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          
          const SizedBox(height: AppStyles.spacing24),
          
          Container(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'Password Requirements',
                      style: AppStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• At least 6 characters long\n• Use a combination of letters and numbers\n• Avoid using personal information',
                  style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppStyles.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verification',
            style: AppStyles.heading2.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: AppStyles.spacing8),
          Text(
            _selectedRole == UserRole.seller 
                ? 'Additional verification required for sellers'
                : 'Almost done! Please review and confirm',
            style: AppStyles.bodyMedium,
          ),
          const SizedBox(height: AppStyles.spacing32),
          
          if (_selectedRole == UserRole.seller) ...[
            CustomTextField(
              label: 'Aadhaar Number',
              hintText: 'Enter 12-digit Aadhaar number',
              controller: _aadhaarController,
              prefixIcon: Icons.credit_card,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Aadhaar number is required for sellers';
                }
                if (value.length != 12) {
                  return 'Please enter a valid 12-digit Aadhaar number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppStyles.spacing24),
            
            Container(
              padding: const EdgeInsets.all(AppStyles.spacing16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        'Seller Verification Process',
                        style: AppStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Your account will be reviewed by our team\n• You may be contacted for additional verification\n• This process helps maintain quality and trust',
                    style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppStyles.spacing32),
          
          // Terms and Conditions
          CheckboxListTile(
            value: _agreeToTerms,
            onChanged: (bool? value) {
              setState(() => _agreeToTerms = value ?? false);
            },
            title: RichText(
              text: TextSpan(
                style: AppStyles.bodyMedium,
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          
          const SizedBox(height: AppStyles.spacing16),
          
          // Account Summary
          Container(
            padding: const EdgeInsets.all(AppStyles.spacing16),
            decoration: AppStyles.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Summary',
                  style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Name', _nameController.text),
                _buildSummaryRow('Email', _emailController.text),
                _buildSummaryRow('Phone', _phoneController.text),
                _buildSummaryRow('Role', _getRoleTitle(_selectedRole)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: AppStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return 'Buy handmade products';
      case UserRole.seller:
        return 'Sell my creations';
      case UserRole.both:
        return 'Buy and sell products';
    }
  }

  String _getRoleSubtitle(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return 'Discover and purchase unique artisan products';
      case UserRole.seller:
        return 'List and sell your handmade items';
      case UserRole.both:
        return 'Full marketplace access as buyer and seller';
    }
  }
}