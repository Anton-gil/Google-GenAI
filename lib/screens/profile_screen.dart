// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  
  bool _isEditing = false;
  bool _isLoading = false;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Mock user data - in real app, get from auth service
  late User currentUser;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  void _loadUserProfile() {
    // Mock user data - replace with actual user from auth service
    currentUser = User(
      id: 'user_123',
      name: 'Priya Sharma',
      email: 'priya.sharma@example.com',
      phone: '+91 9876543210',
      role: UserRole.both,
      verificationStatus: VerificationStatus.verified,
      address: 'MG Road, Bangalore, Karnataka 560001',
      bio: 'Passionate about supporting local artisans and traditional crafts. Love collecting handmade pottery and textiles.',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      isVerifiedArtisan: false,
    );
    
    _updateControllers();
  }
  
  void _updateControllers() {
    _nameController.text = currentUser.name;
    _phoneController.text = currentUser.phone;
    _addressController.text = currentUser.address ?? '';
    _bioController.text = currentUser.bio ?? '';
  }
  
  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Cancel editing, revert changes
        _updateControllers();
      }
      _isEditing = !_isEditing;
    });
  }
  
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update user data
      setState(() {
        currentUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          bio: _bioController.text.trim(),
        );
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _switchRole() {
    final newRole = currentUser.role == UserRole.seller 
        ? UserRole.buyer 
        : UserRole.seller;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Mode'),
        content: Text(
          'Switch to ${newRole.toString().split('.').last.toUpperCase()} mode?\n\n'
          'This will change your app experience to focus on '
          '${newRole == UserRole.seller ? 'selling products' : 'buying products'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          PrimaryButton(
            text: 'Switch',
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentUser = currentUser.copyWith(role: newRole);
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Switched to ${newRole.toString().split('.').last} mode!',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
  
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.textSecondary,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileContent(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.surface,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: currentUser.profileImageUrl != null
                      ? NetworkImage(currentUser.profileImageUrl!)
                      : null,
                  child: currentUser.profileImageUrl == null
                      ? Text(
                          currentUser.name.isNotEmpty 
                              ? currentUser.name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: AppStyles.headlineLarge.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : null,
                ),
              ),
              
              // Verification Badge
              if (currentUser.verificationStatus == VerificationStatus.verified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surface,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: AppColors.textOnPrimary,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // User Name
          Text(
            currentUser.name,
            style: AppStyles.headlineMedium.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // User Role and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusChip(
                currentUser.role.toString().split('.').last.toUpperCase(),
                AppColors.accent,
              ),
              const SizedBox(width: 12),
              _buildStatusChip(
                currentUser.verificationStatus.toString().split('.').last.toUpperCase(),
                currentUser.verificationStatus == VerificationStatus.verified
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Member Since
          Text(
            'Member since ${_formatDate(currentUser.createdAt)}',
            style: AppStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildProfileContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Information Section
          _buildSection(
            title: 'Personal Information',
            icon: Icons.person,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Full Name',
                enabled: _isEditing,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: TextEditingController(text: currentUser.email),
                labelText: 'Email Address',
                enabled: false,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                enabled: _isEditing,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _addressController,
                labelText: 'Address',
                enabled: _isEditing,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                hintText: 'Enter your address',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Bio Section
          _buildSection(
            title: 'About Me',
            icon: Icons.info_outline,
            children: [
              CustomTextField(
                controller: _bioController,
                labelText: 'Bio',
                enabled: _isEditing,
                maxLines: 4,
                hintText: currentUser.role == UserRole.seller
                    ? 'Tell customers about your craft and experience...'
                    : 'Share your interests and preferences...',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          if (_isEditing)
            _buildEditingActions()
          else
            _buildProfileActions(),
          
          const SizedBox(height: 24),
          
          // Settings Section
          if (!_isEditing) _buildSettingsSection(),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildEditingActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedCustomButton(
            text: 'Cancel',
            onPressed: _toggleEditMode,
            icon: Icons.close,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: 'Save Changes',
            onPressed: _isLoading ? null : _saveProfile,
            isLoading: _isLoading,
            icon: Icons.save,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProfileActions() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Edit Profile',
          onPressed: _toggleEditMode,
          icon: Icons.edit,
        ),
        
        const SizedBox(height: 12),
        
        if (currentUser.role == UserRole.both)
          OutlinedCustomButton(
            text: 'Switch to ${currentUser.role == UserRole.seller ? 'Buyer' : 'Seller'} Mode',
            onPressed: _switchRole,
            icon: Icons.swap_horiz,
          ),
      ],
    );
  }
  
  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            'Order History',
            Icons.history,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order history coming soon!')),
              );
            },
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          _buildSettingsItem(
            'Favorites',
            Icons.favorite_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites coming soon!')),
              );
            },
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          _buildSettingsItem(
            'Notifications',
            Icons.notifications_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          _buildSettingsItem(
            'Help & Support',
            Icons.help_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          _buildSettingsItem(
            'Privacy Policy',
            Icons.privacy_tip_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy coming soon!')),
              );
            },
          ),
          
          const Divider(height: 1, indent: 16, endIndent: 16),
          
          _buildSettingsItem(
            'Logout',
            Icons.logout,
            onTap: _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsItem(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppStyles.bodyLarge.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}