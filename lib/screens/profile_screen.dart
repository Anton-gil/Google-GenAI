// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
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
  late User currentUser;
  bool _isEditing = false;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    // Initialize with sample user data - replace with actual user data
    currentUser = User(
      id: '1',
      name: 'Artisan Name',
      email: 'artisan@email.com',
      phone: '+91 9876543210',
      role: UserRole.both,
      verificationStatus: VerificationStatus.verified,
      address: 'Local Address, City, State',
      bio: 'Traditional craftsperson specializing in handmade items',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isVerifiedArtisan: true,
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
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _updateControllers(); // Reset if cancelled
      }
    });
  }

  void _saveProfile() {
    setState(() {
      currentUser = currentUser.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        bio: _bioController.text,
      );
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _switchRole() {
    final newRole = currentUser.role == UserRole.seller ? UserRole.buyer : UserRole.seller;
    setState(() {
      currentUser = currentUser.copyWith(role: newRole);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to ${newRole.toString().split('.').last} mode')),
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
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileForm(),
            const SizedBox(height: 24),
            if (_isEditing) _buildEditActions(),
            if (!_isEditing) _buildProfileActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: currentUser.profileImageUrl != null
                  ? NetworkImage(currentUser.profileImageUrl!)
                  : null,
              child: currentUser.profileImageUrl == null
                  ? Text(
                      currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (currentUser.isVerifiedArtisan)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.artisanGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          currentUser.name,
          style: AppStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusChip(
              currentUser.role.toString().split('.').last.toUpperCase(),
              AppColors.primary,
            ),
            const SizedBox(width: 8),
            if (currentUser.isVerifiedArtisan)
              _buildStatusChip('VERIFIED ARTISAN', AppColors.artisanGold),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Member since ${_formatDate(currentUser.createdAt)}',
          style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
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

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          enabled: _isEditing,
          prefixIcon: Icons.person,
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: TextEditingController(text: currentUser.email),
          label: 'Email',
          enabled: false,
          prefixIcon: Icons.email,
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          enabled: _isEditing,
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        
        const SizedBox(height: 16),
        
        CustomTextField(
          controller: _addressController,
          label: 'Address',
          enabled: _isEditing,
          prefixIcon: Icons.location_on,
          maxLines: 2,
        ),
        
        const SizedBox(height: 24),
        
        _buildSectionTitle('About'),
        
        CustomTextField(
          controller: _bioController,
          label: 'Bio / Artisan Story',
          enabled: _isEditing,
          prefixIcon: Icons.info,
          maxLines: 4,
          hint: 'Tell buyers about your craft and story...',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppStyles.titleLarge.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEditActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedCustomButton(
            text: 'Cancel',
            onPressed: _toggleEditMode,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton(
            text: 'Save Changes',
            onPressed: _saveProfile,
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
        
        OutlinedCustomButton(
          text: 'Switch to ${currentUser.role == UserRole.seller ? 'Buyer' : 'Seller'} Mode',
          onPressed: _switchRole,
          icon: Icons.swap_horiz,
        ),
        
        const SizedBox(height: 24),
        
        _buildSettingsSection(),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsItem(
          'Order History',
          Icons.history,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order history coming soon!')),
          ),
        ),
        
        _buildSettingsItem(
          'Notifications',
          Icons.notifications_outlined,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification settings coming soon!')),
          ),
        ),
        
        _buildSettingsItem(
          'Settings',
          Icons.settings,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings coming soon!')),
          ),
        ),
        
        _buildSettingsItem(
          'Help & Support',
          Icons.help,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Help & Support coming soon!')),
          ),
        ),
        
        _buildSettingsItem(
          'Privacy Policy',
          Icons.privacy_tip,
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Privacy Policy coming soon!')),
          ),
        ),
        
        _buildSettingsItem(
          'Logout',
          Icons.logout,
          _logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: AppStyles.bodyLarge.copyWith(
            color: isDestructive ? AppColors.error : null,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
