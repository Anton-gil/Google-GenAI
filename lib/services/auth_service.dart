// lib/services/auth_service.dart
import '../models/user.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Mock login for MVP - in real app, integrate with Firebase/Supabase
  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Please enter both email and password',
      );
    }

    if (password.length < 6) {
      return const AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    // Mock user creation
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: _extractNameFromEmail(email),
      email: email,
      phone: '+91 98765 43210',
      role: UserRole.both,
      verificationStatus: VerificationStatus.pending,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    _isLoggedIn = true;

    return AuthResult(
      success: true,
      message: 'Login successful',
      user: user,
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? aadhaarNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Mock validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Please fill in all required fields',
      );
    }

    if (password.length < 6) {
      return const AuthResult(
        success: false,
        message: 'Password must be at least 6 characters',
      );
    }

    if (role == UserRole.seller && (aadhaarNumber == null || aadhaarNumber.length != 12)) {
      return const AuthResult(
        success: false,
        message: 'Valid Aadhaar number required for sellers',
      );
    }

    // Mock user creation
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: role,
      verificationStatus: role == UserRole.seller 
          ? VerificationStatus.pending 
          : VerificationStatus.verified,
      aadhaarNumber: aadhaarNumber,
      createdAt: DateTime.now(),
      isVerifiedArtisan: false,
    );

    _currentUser = user;
    _isLoggedIn = true;

    return AuthResult(
      success: true,
      message: 'Registration successful',
      user: user,
    );
  }

  Future<AuthResult> verifyPhone(String otp) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock OTP verification
    if (otp == '123456') {
      return const AuthResult(
        success: true,
        message: 'Phone verified successfully',
      );
    } else {
      return const AuthResult(
        success: false,
        message: 'Invalid OTP. Please try again.',
      );
    }
  }

  Future<bool> sendOTP(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock OTP sending - always returns true for MVP
    return true;
  }

  Future<AuthResult> submitVerificationVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 3));

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        verificationStatus: VerificationStatus.pending,
      );

      return const AuthResult(
        success: true,
        message: 'Verification video submitted. Review in progress.',
      );
    }

    return const AuthResult(
      success: false,
      message: 'No user logged in',
    );
  }

  Future<User?> updateUserProfile({
    String? name,
    String? bio,
    String? address,
    String? profileImageUrl,
    UserRole? role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) return null;

    _currentUser = _currentUser!.copyWith(
      name: name,
      bio: bio,
      address: address,
      profileImageUrl: profileImageUrl,
      role: role,
    );

    return _currentUser;
  }

  Future<bool> switchUserRole(UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser == null) return false;

    // Only allow switching to 'both' or if current role supports it
    if (_currentUser!.role == UserRole.both || newRole == UserRole.both) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      return true;
    }

    return false;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
  }

  // Mock method to simulate checking if user exists
  Future<bool> checkUserExists(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For MVP, always return false (new user)
    return false;
  }

  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username.replaceAll('.', ' ').replaceAll('_', ' ').split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Mock method for getting user's selling statistics
  Future<Map<String, int>> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return {
      'totalProducts': 12,
      'totalSales': 45,
      'totalViews': 1234,
      'totalRevenue': 23500,
    };
  }

  // Mock method for getting verification progress
  double getVerificationProgress() {
    if (_currentUser == null) return 0.0;
    
    double progress = 0.3; // Basic info
    
    if (_currentUser!.phone.isNotEmpty) progress += 0.2; // Phone verified
    if (_currentUser!.aadhaarNumber != null) progress += 0.2; // Aadhaar added
    if (_currentUser!.verificationStatus != VerificationStatus.pending) progress += 0.3; // Video submitted
    
    return progress;
  }

  List<String> getVerificationSteps() {
    return [
      'Complete basic profile information',
      'Verify phone number',
      'Add Aadhaar details',
      'Submit verification video',
      'Wait for manual verification (NGO visit)',
    ];
  }
}