// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class AuthResult {
  final bool success;
  final String? message;
  final app_user.User? user;

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

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  app_user.User? _currentUser;
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();

  // Expose auth state as stream
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  // Initialize auth service and listen to Firebase auth changes
  void initialize() {
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        // Convert Firebase user to app user
        _currentUser = _convertFirebaseUserToAppUser(firebaseUser);
        _authStateController.add(true);
      } else {
        _currentUser = null;
        _authStateController.add(false);
      }
    });
  }

  // Convert Firebase User to app User
  app_user.User _convertFirebaseUserToAppUser(User firebaseUser) {
    return app_user.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? _extractNameFromEmail(firebaseUser.email ?? ''),
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      role: app_user.UserRole.both,
      verificationStatus: firebaseUser.emailVerified 
          ? app_user.VerificationStatus.verified 
          : app_user.VerificationStatus.pending,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      profileImageUrl: firebaseUser.photoURL,
      isVerifiedArtisan: false,
    );
  }

  // Email/Password login
  Future<AuthResult> login(String email, String password) async {
    try {
      // Special case for test user
      if (email == 'seraphex@gmail.com' && password == 'searaphex') {
        final user = app_user.User(
          id: 'test_user_001',
          name: 'Seraphex User',
          email: email,
          phone: '+91 98765 43210',
          role: app_user.UserRole.both,
          verificationStatus: app_user.VerificationStatus.verified,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          isVerifiedArtisan: true,
          bio: 'Test user for development purposes',
          address: 'Test Address, Test City, Test State',
        );

        _currentUser = user;
        _authStateController.add(true);

        return AuthResult(
          success: true,
          message: 'Login successful',
          user: user,
        );
      }

      // Validation
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

      // Firebase login
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = _convertFirebaseUserToAppUser(credential.user!);
        return AuthResult(
          success: true,
          message: 'Login successful',
          user: _currentUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Login failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address';
          break;
        case 'wrong-password':
          message = 'Invalid password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later';
          break;
        default:
          message = e.message ?? 'Login failed';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'An error occurred. Please try again.',
      );
    }
  }

  // Google Sign In
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return const AuthResult(
          success: false,
          message: 'Google sign in was cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _currentUser = _convertFirebaseUserToAppUser(userCredential.user!);
        return AuthResult(
          success: true,
          message: 'Google sign in successful',
          user: _currentUser,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Google sign in failed',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Google sign in error: ${e.toString()}',
      );
    }
  }

  // Facebook Sign In - Placeholder (you'll need to implement facebook_auth package)
  Future<AuthResult> signInWithFacebook() async {
    // For now, return mock result
    await Future.delayed(const Duration(seconds: 2));

    // Mock Facebook sign in
    final user = app_user.User(
      id: 'facebook_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Facebook User',
      email: 'user@facebook.com',
      phone: '+91 98765 43210',
      role: app_user.UserRole.both,
      verificationStatus: app_user.VerificationStatus.verified,
      createdAt: DateTime.now(),
      profileImageUrl: 'https://via.placeholder.com/150/1877F2/FFFFFF?text=F',
    );

    _currentUser = user;
    _authStateController.add(true);

    return AuthResult(
      success: true,
      message: 'Facebook sign in successful',
      user: user,
    );
  }

  // Register with Firebase
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required app_user.UserRole role,
    String? aadhaarNumber,
  }) async {
    try {
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

      if (role == app_user.UserRole.seller &&
          (aadhaarNumber == null || aadhaarNumber.length != 12)) {
        return const AuthResult(
          success: false,
          message: 'Valid Aadhaar number required for sellers',
        );
      }

      // Create Firebase user
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create app user
        final user = app_user.User(
          id: credential.user!.uid,
          name: name,
          email: email,
          phone: phone,
          role: role,
          verificationStatus: role == app_user.UserRole.seller
              ? app_user.VerificationStatus.pending
              : app_user.VerificationStatus.verified,
          aadhaarNumber: aadhaarNumber,
          createdAt: DateTime.now(),
          isVerifiedArtisan: false,
        );

        _currentUser = user;

        return AuthResult(
          success: true,
          message: 'Registration successful',
          user: user,
        );
      } else {
        return const AuthResult(
          success: false,
          message: 'Registration failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'An error occurred. Please try again.',
      );
    }
  }

  // Phone verification
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
        verificationStatus: app_user.VerificationStatus.pending,
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

  Future<app_user.User?> updateUserProfile({
    String? name,
    String? bio,
    String? address,
    String? profileImageUrl,
    app_user.UserRole? role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_currentUser == null) return null;

    // Update Firebase user profile if needed
    if (name != null && _firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.updateDisplayName(name);
    }

    _currentUser = _currentUser!.copyWith(
      name: name,
      bio: bio,
      address: address,
      profileImageUrl: profileImageUrl,
      role: role,
    );

    return _currentUser;
  }

  Future<bool> switchUserRole(app_user.UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser == null) return false;

    // Only allow switching to 'both' or if current role supports it
    if (_currentUser!.role == app_user.UserRole.both || newRole == app_user.UserRole.both) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      return true;
    }

    return false;
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    _currentUser = null;
    _authStateController.add(false);
  }

  // Check if user exists
  Future<bool> checkUserExists(String email) async {
    try {
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Guest login functionality
  Future<AuthResult> loginAsGuest() async {
    try {
      // Create a guest user without Firebase authentication
      final guestUser = app_user.User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Guest User',
        email: 'guest@artisan-marketplace.com',
        phone: '',
        role: app_user.UserRole.buyer,
        verificationStatus: app_user.VerificationStatus.verified,
        createdAt: DateTime.now(),
        isVerifiedArtisan: false,
        bio: 'Browsing as guest',
      );

      _currentUser = guestUser;
      _authStateController.add(true);

      return AuthResult(
        success: true,
        message: 'Browsing as guest',
        user: guestUser,
      );
    } catch (e) {
      return const AuthResult(
        success: false,
        message: 'Failed to browse as guest',
      );
    }
  }

  // Check if current user is guest
  bool get isGuestUser => _currentUser?.id.startsWith('guest_') ?? false;

  String _extractNameFromEmail(String email) {
    final username = email.split('@')[0];
    return username
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
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
    if (_currentUser!.verificationStatus != app_user.VerificationStatus.pending) {
      progress += 0.3; // Video submitted
    }

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

  // Dispose stream controller
  void dispose() {
    _authStateController.close();
  }
}